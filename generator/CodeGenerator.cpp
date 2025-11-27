#include "CodeGenerator.h"
#include <QStandardPaths>

CodeGenerator::CodeGenerator(QObject *parent) : QObject(parent)
{

}

bool CodeGenerator::generate(const QJsonObject &config)
{
    QVariantMap data = prepareData(config);
    
    // List of templates to process
    // Format: templateName -> outputFileName
    QMap<QString, QString> templates;
    QString className = data["className"].toString();
    QString customEditQml = config["customEditQml"].toString();
    bool injectFunctions = config["injectFunctions"].toBool();
    
    templates["Entity.h.tpl"] = className + ".h";
    templates["Entity.cpp.tpl"] = className + ".cpp"; 
    templates["Controller.h.tpl"] = className + "Controller.h";
    templates["Controller.cpp.tpl"] = className + "Controller.cpp";
    templates["List.qml.tpl"] = className + "List.qml";
    
    // 如果有自定义 QML，我们仍然生成文件，但内容不同
    templates["Edit.qml.tpl"] = className + "Edit.qml";

    bool success = true;
    
    // Ensure output directory exists
    QString desktopPath = QStandardPaths::writableLocation(QStandardPaths::DesktopLocation);
    QString outputDir = desktopPath + "/GeneratedCode/" + className;
    QDir dir(outputDir);
    if (!dir.exists()) {
        dir.mkpath(".");
    }

    for (auto it = templates.begin(); it != templates.end(); ++it) {
        QString tplName = it.key();
        QString outName = it.value();
        
        QString rendered;
        
        // 特殊处理 Edit.qml
        if (tplName == "Edit.qml.tpl" && !customEditQml.isEmpty()) {
            rendered = customEditQml;
            
            // 注入功能函数 (saveData, closeForm, onCompleted)
            if (injectFunctions) {
                // 1. 添加必要的属性定义 (如果 FormGenerator 生成的代码没有包含)
                // FormGeneratorLogic 通常生成一个纯 Item，我们需要把它包装成 Edit 页面的上下文
                
                QString props = QString(
                    "    property var controller: null\n"
                    "    property bool isAdd: true\n"
                    "    property var formData: ({})\n\n"
                    "    Component.onCompleted: {\n"
                    "        if (!isAdd && formData) {\n"
                    "            // Auto-fill logic would go here, but visual binding handles keys\n"
                    "            // We need to iterate over controls and set values\n"
                    "            // Since we use 'key' property in Styled components, we can potentially find children\n"
                    "            initFormData(formData);\n"
                    "        }\n"
                    "    }\n\n"
                );
                
                // 插入属性到 Item { 之后
                int firstBrace = rendered.indexOf("{");
                if (firstBrace != -1) {
                    rendered.insert(firstBrace + 1, "\n" + props);
                }
                
                // 2. 添加 saveData 和 closeForm 函数
                QString funcs = QString(
                    "\n    function saveData() {\n"
                    "        var data = {};\n"
                    "        // Collect data from children (Recursive or Flattened)\n"
                    "        // Simpler approach: Rely on 'key' property\n"
                    "        collectData(root, data);\n"
                    "        \n"
                    "        if (!isAdd) {\n"
                    "             data[\"%1\"] = formData[\"%1\"];\n" // pkField
                    "        }\n"
                    "        \n"
                    "        var success = false;\n"
                    "        if (isAdd) success = controller.add(data);\n"
                    "        else success = controller.update(data);\n"
                    "        \n"
                    "        if (success) closeForm();\n"
                    "    }\n\n"
                    "    function closeForm() {\n"
                    "        if (root.StackView.view) root.StackView.view.pop();\n"
                    "        else root.visible = false;\n"
                    "    }\n\n"
                    "    // Helper to collect data from Styled controls recursively\n"
                    "    function collectData(item, data) {\n"
                    "        for (var i = 0; i < item.children.length; i++) {\n"
                    "            var child = item.children[i];\n"
                    "            if (child.key && child.key !== \"\") {\n"
                    "                // Check for value property\n"
                    "                if (child.hasOwnProperty(\"text\")) data[child.key] = child.text;\n"
                    "                else if (child.hasOwnProperty(\"value\")) data[child.key] = child.value;\n"
                    "                else if (child.hasOwnProperty(\"currentText\")) data[child.key] = child.currentText;\n"
                    "                else if (child.hasOwnProperty(\"checked\")) data[child.key] = child.checked;\n"
                    "            }\n"
                    "            collectData(child, data);\n"
                    "        }\n"
                    "    }\n\n"
                    "    // Helper to init data\n"
                    "    function initFormData(data) {\n"
                    "        fillData(root, data);\n"
                    "    }\n\n"
                    "    function fillData(item, data) {\n"
                    "        for (var i = 0; i < item.children.length; i++) {\n"
                    "            var child = item.children[i];\n"
                    "            if (child.key && child.key !== \"\" && data[child.key] !== undefined) {\n"
                    "                if (child.hasOwnProperty(\"text\")) child.text = data[child.key];\n"
                    "                else if (child.hasOwnProperty(\"value\")) child.value = data[child.key];\n"
                    "                else if (child.hasOwnProperty(\"currentText\")) child.currentIndex = child.find(data[child.key]);\n" // Simple combo handling
                    "                else if (child.hasOwnProperty(\"checked\")) child.checked = data[child.key];\n"
                    "            }\n"
                    "            fillData(child, data);\n"
                    "        }\n"
                    "    }\n"
                ).arg(data["pkCppField"].toString());
                
                // Append functions before last brace
                int lastBrace = rendered.lastIndexOf("}");
                if (lastBrace != -1) {
                    rendered.insert(lastBrace, funcs);
                }
            }
            
        } else {
            // 标准模板生成
            QFile tplFile(":/templates/" + tplName);
            if (!tplFile.open(QIODevice::ReadOnly | QIODevice::Text)) {
                qCritical() << "Failed to open template:" << tplName;
                success = false;
                continue;
            }
            
            QString tplContent = tplFile.readAll();
            tplFile.close();
            
            rendered = render(tplContent, data);
        }
        
        if (!writeToFile(outputDir + "/" + outName, rendered)) {
            success = false;
        }
    }
    
    return success;
}

QString CodeGenerator::render(const QString &templateContent, const QVariantMap &data)
{
    QString result = templateContent;
    
    // 1. Handle Loops {{# list }} ... {{/ list }}
    QRegularExpression loopRegex("\\{\\{#\\s*(\\w+)\\s*\\}\\}(.*?)\\{\\{/\\s*\\1\\s*\\}\\}", QRegularExpression::DotMatchesEverythingOption);
    
    while (true) {
        QRegularExpressionMatch match = loopRegex.match(result);
        if (!match.hasMatch()) break;
        
        QString key = match.captured(1);
        QString innerContent = match.captured(2);
        QString replacement;
        
        if (data.contains(key)) {
            QVariant val = data[key];
            if (val.typeId() == QMetaType::QVariantList) {
                QVariantList list = val.toList();
                for (const QVariant &item : list) {
                    if (item.typeId() == QMetaType::QVariantMap) {
                        QVariantMap itemData = item.toMap();
                        QVariantMap mergedData = data;
                        for(auto it = itemData.begin(); it != itemData.end(); ++it) {
                            mergedData.insert(it.key(), it.value());
                        }
                        replacement += render(innerContent, mergedData);
                    }
                }
            } else if (val.typeId() == QMetaType::Bool) {
                if (val.toBool()) {
                    replacement = render(innerContent, data);
                }
            }
        }
        
        result.replace(match.capturedStart(), match.capturedLength(), replacement);
    }
    
    // 2. Handle Inverse Loops/Conditions {{^ var }} ... {{/ var }}
    QRegularExpression invLoopRegex("\\{\\{\\^\\s*(\\w+)\\s*\\}\\}(.*?)\\{\\{/\\s*\\1\\s*\\}\\}", QRegularExpression::DotMatchesEverythingOption);
    while (true) {
        QRegularExpressionMatch match = invLoopRegex.match(result);
        if (!match.hasMatch()) break;
        
        QString key = match.captured(1);
        QString innerContent = match.captured(2);
        QString replacement;
        
        bool condition = false;
        if (data.contains(key)) {
            condition = data[key].toBool();
        }
        
        if (!condition) {
            replacement = render(innerContent, data);
        }
        
        result.replace(match.capturedStart(), match.capturedLength(), replacement);
    }
    
    // 3. Handle Variables {{ var }}
    QRegularExpression varRegex("\\{\\{\\s*(\\w+)\\s*\\}\\}");
    while (true) {
        QRegularExpressionMatch match = varRegex.match(result);
        if (!match.hasMatch()) break;
        
        QString key = match.captured(1);
        if (data.contains(key)) {
            result.replace(match.capturedStart(), match.capturedLength(), data[key].toString());
        } else {
            result.replace(match.capturedStart(), match.capturedLength(), "");
        }
    }
    
    return result;
}

QString CodeGenerator::camelCase(const QString &str, bool upperFirst)
{
    QString result;
    bool nextUpper = upperFirst;
    bool first = true;
    
    for (const QChar &c : str) {
        if (c == '_' || c == '-') {
            nextUpper = true;
        } else {
            if (first) {
                result += upperFirst ? c.toUpper() : c.toLower();
                first = false;
                nextUpper = false;
            } else {
                if (nextUpper) {
                    result += c.toUpper();
                    nextUpper = false;
                } else {
                    result += c;
                }
            }
        }
    }
    return result;
}

QVariantMap CodeGenerator::prepareData(const QJsonObject &config)
{
    QVariantMap data = config.toVariantMap();
    
    QString tableName = data["tableName"].toString();
    QString className = camelCase(tableName, true);
    QString instanceName = camelCase(tableName, false);
    
    data["className"] = className;
    data["instanceName"] = instanceName;
    
    // Add current date
    data["createDate"] = QDateTime::currentDateTime().toString("yyyy-MM-dd HH:mm:ss");
    
    QVariantList colsList;
    QJsonArray columns = config["columns"].toArray();
    
    // 预定义主键字段名，默认为 id
    QString pkCppField = "id";

    for (const QJsonValue &val : columns) {
        QJsonObject obj = val.toObject();
        QVariantMap colMap = obj.toVariantMap();
        
        // [修复] 如果没有注释，使用更友好的驼峰属性名或列名
        QString comment = colMap["columnComment"].toString();
        if (comment.trimmed().isEmpty()) {
            QString friendlyName = colMap["cppField"].toString();
            if (friendlyName.isEmpty()) friendlyName = colMap["columnName"].toString();
            colMap["columnComment"] = friendlyName;
        }

        // Add helper booleans/strings
        colMap["isString"] = (colMap["cppType"].toString() == "String");
        colMap["isInteger"] = (colMap["cppType"].toString() == "Integer");
        colMap["isLong"] = (colMap["cppType"].toString() == "Long");
        colMap["isDouble"] = (colMap["cppType"].toString() == "Double");
        colMap["isBoolean"] = (colMap["cppType"].toString() == "Boolean");
        colMap["isDateTime"] = (colMap["cppType"].toString() == "DateTime");
        
        // Capitalized field name for getters/setters
        QString field = colMap["cppField"].toString();
        if (!field.isEmpty()) {
            colMap["cppFieldCap"] = field.at(0).toUpper() + field.mid(1);
        }
        
        // [新增] 识别主键并保存到根数据中
        if (colMap["isPk"].toBool()) {
            pkCppField = field;
        }

        // Map to actual C++ types
        QString cppType = colMap["cppType"].toString();
        if (cppType == "String") colMap["cppType"] = "QString";
        else if (cppType == "Integer") colMap["cppType"] = "int";
        else if (cppType == "Long") colMap["cppType"] = "qint64";
        else if (cppType == "Double") colMap["cppType"] = "double";
        else if (cppType == "Boolean") colMap["cppType"] = "bool";
        else if (cppType == "DateTime") colMap["cppType"] = "QDateTime";
        
        // Determine value property for QML
        QString displayType = colMap["displayType"].toString();
        if (displayType == "StyledSpinBox") {
            colMap["valueProperty"] = "value";
        } else if (displayType == "StyledComboBox") {
            colMap["valueProperty"] = "currentValue";
        } else {
            colMap["valueProperty"] = "text";
        }
        
        // Query Type Booleans
        QString queryType = colMap["queryType"].toString();
        colMap["isQueryLike"] = (queryType == "LIKE");
        colMap["isQueryEqual"] = (queryType == "=");
        colMap["isQueryNE"] = (queryType == "!=");
        colMap["isQueryGT"] = (queryType == ">");
        colMap["isQueryGE"] = (queryType == ">=");
        colMap["isQueryLT"] = (queryType == "<");
        colMap["isQueryLE"] = (queryType == "<=");
        colMap["isQueryBetween"] = (queryType == "BETWEEN");
        colMap["isQueryIsNull"] = (queryType == "IS NULL");
        colMap["isQueryIsNotNull"] = (queryType == "IS NOT NULL");
        colMap["isQueryIn"] = (queryType == "IN");
        
        // Ensure booleans are set correctly
        colMap["isQuery"] = colMap["isQuery"].toBool();
        colMap["isList"] = colMap["isList"].toBool();
        colMap["isEdit"] = colMap["isEdit"].toBool();
        colMap["isInsert"] = colMap["isInsert"].toBool();
        colMap["isRequired"] = colMap["isRequired"].toBool();
        
        colsList.append(colMap);
    }
    data["columns"] = colsList;
    
    // [新增] 将找到的主键字段名注入到模板数据中
    data["pkCppField"] = pkCppField;
    
    return data;
}

bool CodeGenerator::writeToFile(const QString &fileName, const QString &content)
{
    QFile file(fileName);
    if (file.open(QIODevice::WriteOnly | QIODevice::Text)) {
        QTextStream out(&file);
        out.setEncoding(QStringConverter::Utf8);
        out << content;
        file.close();
        qDebug() << "Generated:" << fileName;
        return true;
    }
    qCritical() << "Failed to write file:" << fileName;
    return false;
}