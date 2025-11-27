import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import mysqlhelper 1.0
import generator 1.0
import Common 1.0
import "../components"

Item {
    id: root
    anchors.fill: parent

    property string tableName: ""
    property var columnModel: []
    property var displayTypes: []
    property var queryTypes: ["=", "!=", ">", ">=", "<", "<=", "LIKE", "BETWEEN", "IS NULL", "IS NOT NULL", "IN"]
    property var cppTypes: ["String", "Integer", "Long", "Double", "Boolean", "DateTime"]

    signal back

    Component.onCompleted: {
        loadDisplayTypes();
        if (tableName) {
            loadColumns();
        }
    }

    onTableNameChanged: {
        if (tableName) {
            loadColumns();
        }
    }

    function loadDisplayTypes() {
        try {
            var groups = JSON.parse(componentJson);
            var types = [];
            for (var i = 0; i < groups.length; i++) {
                var items = groups[i].items;
                for (var j = 0; j < items.length; j++) {
                    if (items[j].supportFormConfig) {
                        types.push({
                            "label": items[j].label,
                            "type": items[j].type
                        });
                    }
                }
            }
            displayTypes = types;
        } catch (e) {
            console.error("Error parsing componentJson:", e);
        }
    }

    function loadColumns() {
        console.log("Loading columns for table:", tableName);
        try {
            if (typeof MySqlHelper !== "undefined") {
                var cols = MySqlHelper.getDbTableColumns(tableName);
                // Add default values for UI flags if missing
                for (var i = 0; i < cols.length; i++) {
                    cols[i].isInsert = true;
                    cols[i].isEdit = true;
                    cols[i].isList = true;
                    cols[i].isQuery = false;
                    cols[i].queryType = "=";
                    cols[i].isRequired = (cols[i].isNullable === "NO");
                    cols[i].displayType = "StyledTextField";

                    // Smart default for display type
                    if (cols[i].cppType === "Integer" || cols[i].cppType === "Long" || cols[i].cppType === "Double") {
                        cols[i].displayType = "StyledSpinBox";
                    } else if (cols[i].cppType === "DateTime") {
                        // Maybe date picker later, default text for now
                    }
                }
                columnModel = cols;
            }
        } catch (e) {
            console.error("Error loading columns:", e);
        }
    }

    property string authorName: "Admin"
    property string packageName: "com.example"
    property string moduleName: "system"
    property string version: "1.0.0"

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 10

        // Top Bar
        RowLayout {
            Layout.fillWidth: true
            Button {
                text: "返回"
                onClicked: root.back()
            }
            Text {
                text: "生成配置 - " + tableName
                font.pixelSize: 18
                font.bold: true
            }
            Item {
                Layout.fillWidth: true
            }
            Button {
                text: "提交生成"
                highlighted: true
                onClicked: {
                    var config = {
                        "tableName": tableName,
                        "author": authorName,
                        "packageName": packageName,
                        "moduleName": moduleName,
                        "version": version,
                        "columns": columnModel
                    };
                    console.log("Generating code with config:", JSON.stringify(config));
                    var success = CodeGenerator.generate(config);
                    if (success) {
                        console.log("Code generated successfully!");
                        MessageManager.showToast("代码生成成功！", "success");
                    } else {
                        console.error("Code generation failed!");
                        MessageManager.showToast("代码生成失败，请检查日志", "error");
                    }
                    root.back();
                }
            }
        }

        TabBar {
            id: bar
            width: parent.width
            TabButton {
                text: "字段配置"
            }
            TabButton {
                text: "生成信息"
            }
        }

        StackLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: bar.currentIndex

            // Tab 1: Column Config
            ColumnLayout {
                // Table Header
                Rectangle {
                    Layout.fillWidth: true
                    height: 40
                    color: "#f8f8f9"

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        spacing: 5

                        Text {
                            Layout.preferredWidth: 40
                            text: "序号"
                            font.bold: true
                        }
                        Text {
                            Layout.preferredWidth: 100
                            text: "字段列名"
                            font.bold: true
                        }
                        Text {
                            Layout.preferredWidth: 100
                            text: "字段描述"
                            font.bold: true
                        }
                        Text {
                            Layout.preferredWidth: 80
                            text: "物理类型"
                            font.bold: true
                        }
                        Text {
                            Layout.preferredWidth: 80
                            text: "C++类型"
                            font.bold: true
                        }
                        Text {
                            Layout.preferredWidth: 100
                            text: "C++属性"
                            font.bold: true
                        }
                        Text {
                            Layout.preferredWidth: 40
                            text: "插入"
                            font.bold: true
                        }
                        Text {
                            Layout.preferredWidth: 40
                            text: "编辑"
                            font.bold: true
                        }
                        Text {
                            Layout.preferredWidth: 40
                            text: "列表"
                            font.bold: true
                        }
                        Text {
                            Layout.preferredWidth: 40
                            text: "查询"
                            font.bold: true
                        }
                        Text {
                            Layout.preferredWidth: 80
                            text: "查询方式"
                            font.bold: true
                        }
                        Text {
                            Layout.preferredWidth: 40
                            text: "必填"
                            font.bold: true
                        }
                        Text {
                            Layout.preferredWidth: 100
                            text: "显示类型"
                            font.bold: true
                        }
                        Text {
                            Layout.preferredWidth: 100
                            text: "字典类型"
                            font.bold: true
                        }
                    }
                }

                // Column List
                ListView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    model: root.columnModel
                    delegate: Rectangle {
                        width: ListView.view.width
                        height: 50
                        color: index % 2 === 0 ? "white" : "#f9f9f9"

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            spacing: 5

                            Text {
                                Layout.preferredWidth: 40
                                text: index + 1
                            }
                            Text {
                                Layout.preferredWidth: 100
                                text: modelData.columnName
                                elide: Text.ElideRight
                            }

                            // [修复] 字段描述编辑
                            TextField {
                                Layout.preferredWidth: 100
                                text: modelData.columnComment
                                onEditingFinished: {
                                    modelData.columnComment = text;
                                    root.columnModel[index].columnComment = text; // 显式同步
                                }
                            }

                            Text {
                                Layout.preferredWidth: 80
                                text: modelData.dataType
                                elide: Text.ElideRight
                            }

                            ComboBox {
                                Layout.preferredWidth: 80
                                model: root.cppTypes
                                currentIndex: root.cppTypes.indexOf(modelData.cppType)
                                onActivated: {
                                    modelData.cppType = currentText;
                                    root.columnModel[index].cppType = currentText;
                                }
                            }

                            // [修复] C++属性名编辑
                            TextField {
                                Layout.preferredWidth: 100
                                text: modelData.cppField
                                onEditingFinished: {
                                    modelData.cppField = text;
                                    root.columnModel[index].cppField = text;
                                }
                            }

                            CheckBox {
                                Layout.preferredWidth: 40
                                checked: modelData.isInsert
                                onToggled: {
                                    modelData.isInsert = checked;
                                    root.columnModel[index].isInsert = checked;
                                }
                            }
                            CheckBox {
                                Layout.preferredWidth: 40
                                checked: modelData.isEdit
                                onToggled: {
                                    modelData.isEdit = checked;
                                    root.columnModel[index].isEdit = checked;
                                }
                            }
                            CheckBox {
                                Layout.preferredWidth: 40
                                checked: modelData.isList
                                onToggled: {
                                    modelData.isList = checked;
                                    root.columnModel[index].isList = checked;
                                }
                            }
                            CheckBox {
                                id: queryCheckBox
                                Layout.preferredWidth: 40
                                checked: modelData.isQuery
                                onToggled: {
                                    modelData.isQuery = checked;
                                    root.columnModel[index].isQuery = checked;
                                }
                            }

                            ComboBox {
                                Layout.preferredWidth: 80
                                model: root.queryTypes
                                currentIndex: root.queryTypes.indexOf(modelData.queryType)
                                enabled: queryCheckBox.checked
                                onActivated: {
                                    modelData.queryType = currentText;
                                    root.columnModel[index].queryType = currentText;
                                }
                            }

                            CheckBox {
                                Layout.preferredWidth: 40
                                checked: modelData.isRequired
                                onToggled: {
                                    modelData.isRequired = checked;
                                    root.columnModel[index].isRequired = checked;
                                }
                            }

                            ComboBox {
                                Layout.preferredWidth: 100
                                textRole: "label"
                                valueRole: "type"
                                model: root.displayTypes
                                Component.onCompleted: {
                                    for (var i = 0; i < model.length; i++) {
                                        if (model[i].type === modelData.displayType) {
                                            currentIndex = i;
                                            break;
                                        }
                                    }
                                }
                                onActivated: {
                                    modelData.displayType = currentValue;
                                    root.columnModel[index].displayType = currentValue;
                                }
                            }

                            ComboBox {
                                Layout.preferredWidth: 100
                                model: ["请选择"]
                            }
                        }
                        Rectangle {
                            width: parent.width
                            height: 1
                            color: "#e8e8e8"
                            anchors.bottom: parent.bottom
                        }
                    }
                }
            }

            // Tab 2: Gen Info
            ColumnLayout {
                spacing: 20
                anchors.margins: 20

                RowLayout {
                    Text {
                        text: "作者姓名:"
                        font.bold: true
                        Layout.preferredWidth: 100
                    }
                    StyledTextField {
                        Layout.preferredWidth: 300
                        text: root.authorName
                        showLabel: false
                        onEditingFinished: root.authorName = text
                    }
                }

                RowLayout {
                    Text {
                        text: "模块名称:"
                        font.bold: true
                        Layout.preferredWidth: 100
                    }
                    StyledTextField {
                        Layout.preferredWidth: 300
                        text: root.moduleName
                        showLabel: false
                        onEditingFinished: root.moduleName = text
                    }
                }
                RowLayout {
                    Text {
                        text: "版本号:"
                        font.bold: true
                        Layout.preferredWidth: 100
                    }
                    StyledTextField {
                        Layout.preferredWidth: 300
                        text: root.version
                        showLabel: false
                        onEditingFinished: root.version = text
                    }
                }

                Item {
                    Layout.fillHeight: true
                }
            }
        }
    }
}
