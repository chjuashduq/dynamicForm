#include "CodeGenerator.h"
#include <QStandardPaths>
#include <QJsonDocument>
#include <QRegularExpression>
#include <QDebug>

CodeGenerator::CodeGenerator(QObject *parent) : QObject(parent)
{

}

// [新增] 代码清洗函数：去除多余空行，保持代码整洁
// 将连续的3个及以上换行（包含中间的空白字符）替换为2个换行
QString cleanUpCode(const QString &code) {
    QString result = code;
    static QRegularExpression regex("(\\n\\s*){3,}");
    result.replace(regex, "\n\n");
    return result;
}

// [新增] 自动包裹可视化生成的代码片段，解决 Syntax Error
// 为可视化编辑器生成的子控件代码添加 import 和根 Item
QString wrapVisualCode(const QString &componentCode) {
    QString header = 
        "import QtQuick\n"
        "import QtQuick.Controls\n"
        "import QtQuick.Layouts\n"
        "import \"../components\"\n"
        "import \"../mysqlhelper\"\n\n"
        "Item {\n"
        "    id: root\n"
        "    width: parent ? parent.width : 800\n"
        "    height: parent ? parent.height : 600\n\n"
        "    // 背景遮罩\n"
        "    Rectangle {\n"
        "        anchors.fill: parent\n"
        "        color: \"#f5f7fa\"\n"
        "    }\n\n"
        "    // 居中卡片容器\n"
        "    Rectangle {\n"
        "        id: formCard\n"
        "        width: Math.min(parent.width - 40, 900)\n"
        "        height: Math.min(parent.height - 40, contentScroll.contentHeight + 60)\n"
        "        anchors.centerIn: parent\n"
        "        color: \"white\"\n"
        "        radius: 8\n"
        "        border.color: \"#e0e0e0\"\n"
        "        border.width: 1\n\n"
        "        ScrollView {\n"
        "            id: contentScroll\n"
        "            anchors.fill: parent\n"
        "            anchors.margins: 20\n"
        "            clip: true\n\n"
        "            ColumnLayout {\n"
        "                width: parent.width\n"
        "                anchors.horizontalCenter: parent.horizontalCenter\n"
        "                spacing: 20\n\n";

    QString footer = 
        "\n            }\n"
        "        }\n"
        "    }\n"
        "}\n";

    return header + componentCode + footer;
}

bool CodeGenerator::generate(const QJsonObject &config)
{
    QVariantMap data = prepareData(config);
    
    // 模板文件映射
    QMap<QString, QString> templates;
    QString className = data["className"].toString();
    QString customEditQml = config["customEditQml"].toString();
    bool injectFunctions = config["injectFunctions"].toBool();
    
    templates["Entity.h.tpl"] = className + ".h";
    templates["Entity.cpp.tpl"] = className + ".cpp"; 
    templates["Controller.h.tpl"] = className + "Controller.h";
    templates["Controller.cpp.tpl"] = className + "Controller.cpp";
    templates["List.qml.tpl"] = className + "List.qml";
    templates["Edit.qml.tpl"] = className + "Edit.qml";

    bool success = true;
    
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
        
        // 特殊处理 Edit.qml (如果是自定义的可视化代码)
        if (tplName == "Edit.qml.tpl" && !customEditQml.isEmpty()) {
            // [关键修复] 包裹代码，解决 Syntax error
            rendered = wrapVisualCode(customEditQml);
            
            if (injectFunctions) {
                // 注入属性和生命周期
                QString props = QString(
                    "    property var controller: null\n"
                    "    property bool isAdd: true\n"
                    "    property var formData: ({})\n\n"
                    "    Component.onCompleted: {\n"
                    "        if (!isAdd && formData) {\n"
                    "            initFormData(formData);\n"
                    "        }\n"
                    "    }\n"
                    "    // [新增] 动态加载字典数据函数\n"
                    "    function loadDictData(dictType) {\n"
                    "        var items = [];\n"
                    "        try {\n"
                    "            if (typeof MySqlHelper !== \"undefined\") {\n"
                    "                var result = MySqlHelper.select(\"sys_dict_data\", [\"dict_label\", \"dict_value\"], \"dict_type='\" + dictType + \"' AND status='0' ORDER BY dict_sort\");\n"
                    "                for (var i = 0; i < result.length; i++) {\n"
                    "                    items.push({ \"label\": result[i].dict_label, \"value\": result[i].dict_value });\n"
                    "                }\n"
                    "            }\n"
                    "        } catch (e) {\n"
                    "            console.error(\"Error loading dict:\", dictType, e);\n"
                    "        }\n"
                    "        return items;\n"
                    "    }\n"
                );
                
                // 插入到 Item { 之后 (这里找的是 wrapVisualCode 生成的 Item {)
                int firstBrace = rendered.indexOf("{");
                if (firstBrace != -1) {
                    rendered.insert(firstBrace + 1, "\n" + props);
                }
                
                // 注入通用函数
                QString funcs = QString(
                    "\n    function saveData() {\n"
                    "        var data = {};\n"
                    "        collectData(root, data);\n"
                    "        if (!isAdd) {\n"
                    "             data[\"%1\"] = formData[\"%1\"];\n"
                    "        }\n"
                    "        var success = false;\n"
                    "        if (isAdd) success = controller.add(data);\n"
                    "        else success = controller.update(data);\n"
                    "        if (success) closeForm();\n"
                    "    }\n\n"
                    "    function closeForm() {\n"
                    "        if (root.StackView.view) root.StackView.view.pop();\n"
                    "        else root.visible = false;\n"
                    "    }\n\n"
                    "    function collectData(item, data) {\n"
                    "        for (var i = 0; i < item.children.length; i++) {\n"
                    "            var child = item.children[i];\n"
                    "            if (child.key && child.key !== \"\") {\n"
                    "                if (child.hasOwnProperty(\"text\")) data[child.key] = child.text;\n"
                    "                else if (child.hasOwnProperty(\"value\")) data[child.key] = child.value;\n"
                    "                else if (child.hasOwnProperty(\"currentText\")) data[child.key] = child.currentText;\n"
                    "                else if (child.hasOwnProperty(\"checked\")) data[child.key] = child.checked;\n"
                    "            }\n"
                    "            collectData(child, data);\n"
                    "        }\n"
                    "    }\n\n"
                    "    function initFormData(data) {\n"
                    "        fillData(root, data);\n"
                    "    }\n\n"
                    "    function fillData(item, data) {\n"
                    "        for (var i = 0; i < item.children.length; i++) {\n"
                    "            var child = item.children[i];\n"
                    "            if (child.key && child.key !== \"\" && data[child.key] !== undefined) {\n"
                    "                if (child.hasOwnProperty(\"text\")) child.text = data[child.key];\n"
                    "                else if (child.hasOwnProperty(\"value\")) child.value = data[child.key];\n"
                    "                else if (child.hasOwnProperty(\"currentText\")) child.currentIndex = child.find(data[child.key]);\n"
                    "                else if (child.hasOwnProperty(\"checked\")) child.checked = data[child.key];\n"
                    "            }\n"
                    "            fillData(child, data);\n"
                    "        }\n"
                    "    }\n"
                ).arg(data["pkCppField"].toString());
                
                int lastBrace = rendered.lastIndexOf("}");
                if (lastBrace != -1) {
                    rendered.insert(lastBrace, funcs);
                }
            }
            
        } else {
            // 使用内置模板
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
        
        // [关键修改] 最终代码清洗，去除多余空行
        rendered = cleanUpCode(rendered);

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
    
    data["createDate"] = QDateTime::currentDateTime().toString("yyyy-MM-dd HH:mm:ss");
    
    QVariantList colsList;
    QJsonArray columns = config["columns"].toArray();
    
    QString pkCppField = "id";

    for (const QJsonValue &val : columns) {
        QJsonObject obj = val.toObject();
        QVariantMap colMap = obj.toVariantMap();
        
        QString comment = colMap["columnComment"].toString();
        if (comment.trimmed().isEmpty()) {
            QString friendlyName = colMap["cppField"].toString();
            if (friendlyName.isEmpty()) friendlyName = colMap["columnName"].toString();
            colMap["columnComment"] = friendlyName;
        }

        colMap["isString"] = (colMap["cppType"].toString() == "String");
        colMap["isInteger"] = (colMap["cppType"].toString() == "Integer");
        colMap["isLong"] = (colMap["cppType"].toString() == "Long");
        colMap["isDouble"] = (colMap["cppType"].toString() == "Double");
        colMap["isBoolean"] = (colMap["cppType"].toString() == "Boolean");
        colMap["isDateTime"] = (colMap["cppType"].toString() == "DateTime");
        
        QString field = colMap["cppField"].toString();
        if (!field.isEmpty()) {
            colMap["cppFieldCap"] = field.at(0).toUpper() + field.mid(1);
        }
        
        if (colMap["isPk"].toBool()) {
            pkCppField = field;
        }

        QString cppType = colMap["cppType"].toString();
        if (cppType == "String") colMap["cppType"] = "QString";
        else if (cppType == "Integer") colMap["cppType"] = "int";
        else if (cppType == "Long") colMap["cppType"] = "qint64";
        else if (cppType == "Double") colMap["cppType"] = "double";
        else if (cppType == "Boolean") colMap["cppType"] = "bool";
        else if (cppType == "DateTime") colMap["cppType"] = "QDateTime";
        
        QString displayType = colMap["displayType"].toString();
        if (displayType == "StyledSpinBox") {
            colMap["valueProperty"] = "value";
        } else if (displayType == "StyledComboBox") {
            colMap["valueProperty"] = "currentValue";
        } else {
            colMap["valueProperty"] = "text";
        }

        // [新增] 检测是否包含 dictType
        if (colMap.contains("dictType") && !colMap["dictType"].toString().isEmpty()) {
            colMap["hasDictType"] = true;
            colMap["dictType"] = colMap["dictType"].toString();
        } else {
            colMap["hasDictType"] = false;
        }

        // 处理 options (作为后备)
        if (colMap.contains("options")) {
            QJsonArray opts = obj["options"].toArray();
            if (!opts.isEmpty()) {
                QJsonDocument doc(opts);
                QString jsonStr = doc.toJson(QJsonDocument::Compact);
                colMap["hasOptions"] = true;
                colMap["optionsStr"] = jsonStr;
            } else {
                colMap["hasOptions"] = false;
            }
        } else {
            colMap["hasOptions"] = false;
        }
        
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
        
        colMap["isQuery"] = colMap["isQuery"].toBool();
        colMap["isList"] = colMap["isList"].toBool();
        colMap["isEdit"] = colMap["isEdit"].toBool();
        colMap["isInsert"] = colMap["isInsert"].toBool();
        colMap["isRequired"] = colMap["isRequired"].toBool();
        
        colsList.append(colMap);
    }
    data["columns"] = colsList;
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