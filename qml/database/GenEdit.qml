import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import mysqlhelper 1.0
import generator 1.0
import Common 1.0
import "../components"
import "../generator"

Item {
    id: root
    anchors.fill: parent

    property string tableName: ""
    property var columnModel: []
    property var displayTypes: []
    property var queryTypes: ["=", "!=", ">", ">=", "<", "<=", "LIKE", "BETWEEN", "IS NULL", "IS NOT NULL", "IN"]
    property var cppTypes: ["String", "Integer", "Long", "Double", "Boolean", "DateTime"]

    // 保存可视化编辑器修改后的模型，防止切换Tab丢失
    property var savedVisualModel: null

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
            // 切换表时清空缓存
            savedVisualModel = null;
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
                for (var i = 0; i < cols.length; i++) {
                    cols[i].isInsert = true;
                    cols[i].isEdit = true;
                    cols[i].isList = true;
                    cols[i].isQuery = false;
                    cols[i].queryType = "=";
                    cols[i].isRequired = (cols[i].isNullable === "NO");
                    cols[i].displayType = "StyledTextField";
                    if (cols[i].cppType === "Integer" || cols[i].cppType === "Long" || cols[i].cppType === "Double") {
                        cols[i].displayType = "StyledSpinBox";
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

    // ========== 新增：同步逻辑 ==========

    // 将当前字段配置同步到可视化编辑器
    function syncToVisual() {
        if (!generatorLoader.item)
            return;
        // 1. 如果已有保存的修改，直接加载
        if (savedVisualModel) {
            generatorLoader.item.formModel = savedVisualModel;
            console.log("已加载保存的可视化布局");
            return;
        }

        // 2. 否则，根据字段列表生成默认布局 (每行3列 + 底部按钮)
        var visualItems = [];
        var currentRowChildren = [];
        var rowIndex = 1;

        // 辅助函数：将当前行推入主列表
        function pushRow() {
            if (currentRowChildren.length > 0) {
                visualItems.push({
                    "type": "StyledRow",
                    "id": "row_" + rowIndex,
                    "props": {
                        "key": "row_" + rowIndex,
                        "layoutType": "fill",
                        "spacing": 30,
                        "paddingTop": 0,
                        "paddingBottom": 10,
                        "paddingLeft": 0,
                        "paddingRight": 0
                    },
                    "children": currentRowChildren
                });
                currentRowChildren = [];
                rowIndex++;
            }
        }

        // 遍历字段列表
        for (var i = 0; i < columnModel.length; i++) {
            var col = columnModel[i];
            // 只处理勾选了"编辑"的字段
            if (!col.isEdit)
                continue;
            var item = {
                "type": col.displayType || "StyledTextField",
                "id": "field_" + col.cppField,
                "props": {
                    "key": col.cppField,
                    "label": col.columnComment || col.columnName,
                    "layoutType": "percent" // 使用百分比布局
                    ,
                    "widthPercent": 30      // 30% 宽度，一行3个
                    ,
                    "visible": true,
                    "enabled": true,
                    // [修改] 默认标签占比设为 0.2 (20%)
                    "labelRatio": 0.2
                }
            };
            currentRowChildren.push(item);

            // 每3个控件换一行
            if (currentRowChildren.length >= 3) {
                pushRow();
            }
        }
        // 处理剩余控件
        pushRow();

        // 3. 添加底部操作按钮行 (修改了事件逻辑)

        // [修复] Submit 逻辑：先执行所有验证和数据收集，只在最后一步判断是 Controller 提交还是预览提示
        var submitLogic = "// 1. 验证所有字段 (预览模式下依然会执行，触发红框报错)\n" + "var validation = validateAll();\n" + "if (!validation.valid) return;\n\n" + "// 2. 收集数据\n" + "var data = getAllValues();\n\n" + "// 3. 处理主键 (如果是编辑模式)\n" + "if (isEditMode && formData && formData.id) {\n" + "    data['id'] = formData.id;\n" + "}\n\n" + "// 4. 提交数据\n" + "if (typeof controller !== 'undefined') {\n" + "    // 正式环境：调用 Controller\n" + "    var success = false;\n" + "    if (!isEditMode) {\n" + "        success = controller.add(data);\n" + "    } else {\n" + "        success = controller.update(data);\n" + "    }\n" + "    if (success) {\n" + "        if (typeof closeForm === 'function') closeForm();\n" + "        else showMessage('保存成功', 'success');\n" + "    }\n" + "} else {\n" + "    // 预览环境：模拟提交\n" + "    console.log('预览提交数据:', JSON.stringify(data));\n" + "    showMessage('验证通过！(预览模式不写入数据库)', 'success');\n" + "}";

        // [修复] Cancel 逻辑
        var cancelLogic = "if (typeof closeForm === 'function') {\n" + "    closeForm();\n" + "} else if (typeof root !== 'undefined' && root.StackView && root.StackView.view) {\n" + "    root.StackView.view.pop();\n" + "} else {\n" + "    showMessage('取消操作 (预览模式)', 'info');\n" + "}";

        var btnSave = {
            "type": "StyledButton",
            "id": "btn_submit",
            "props": {
                "key": "submit",
                "text": "保存",
                "buttonType": "primary",
                "width": 100,
                "layoutType": "fixed"
            },
            "events": {
                "onClicked": submitLogic
            }
        };
        var btnCancel = {
            "type": "StyledButton",
            "id": "btn_cancel",
            "props": {
                "key": "cancel",
                "text": "取消",
                "buttonType": "secondary",
                "width": 100,
                "layoutType": "fixed"
            },
            "events": {
                "onClicked": cancelLogic
            }
        };
        visualItems.push({
            "type": "StyledRow",
            "id": "row_actions",
            "props": {
                "key": "row_actions",
                "layoutType": "fill",
                "alignment": 4 // Center (Qt.AlignHCenter)
                ,
                "spacing": 20,
                "paddingTop": 20,
                "paddingBottom": 20,
                "paddingLeft": 0,
                "paddingRight": 0
            },
            "children": [btnCancel, btnSave]
        });

        // 赋值给可视化编辑器
        generatorLoader.item.formModel = visualItems;
        console.log("已生成默认布局，包含 " + visualItems.length + " 行");
    }

    // 从可视化编辑器同步回状态
    function syncFromVisual() {
        if (!generatorLoader.item)
            return;
        // 保存当前模型状态，以便下次进入时恢复
        savedVisualModel = generatorLoader.item.formModel;
        console.log("已保存可视化布局修改");
    }

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
                    // 1. 同步最新状态
                    if (generatorLoader.item) {
                        syncFromVisual();
                    }

                    // 2. 准备生成配置
                    var config = {
                        "tableName": tableName,
                        "author": authorName,
                        "packageName": packageName,
                        "moduleName": moduleName,
                        "version": version,
                        "columns": columnModel
                    };
                    // 3. 获取可视化生成的 QML 代码
                    if (generatorLoader.item) {
                        var qmlBody = generatorLoader.item.getGeneratedCode();
                        config.customEditQml = qmlBody;
                        config.injectFunctions = true; // 标记需要注入 helper 函数
                    }

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
            TabButton {
                text: "可视化布局调整"
            }

            onCurrentIndexChanged: {
                if (currentIndex === 2) {
                    syncToVisual();
                } else {
                    // 离开可视化 Tab 时自动保存
                    if (generatorLoader.item) {
                        syncFromVisual();
                    }
                }
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
                            TextField {
                                Layout.preferredWidth: 100
                                text: modelData.columnComment
                                onEditingFinished: {
                                    modelData.columnComment = text;
                                    root.columnModel[index].columnComment = text;
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

            // Tab 3: Visual Layout
            Item {
                Loader {
                    id: generatorLoader
                    source: "../generator/FormGenerator.qml"
                    anchors.fill: parent

                    onLoaded: {
                        if (item) {
                            item.previewMode = false;
                        }
                    }
                }
            }
        }
    }
}
