import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../mysqlhelper"
import "../generator"
import "../Common"
import "../components"

Item {
    id: root
    anchors.fill: parent

    property string tableName: ""
    property var columnModel: []
    property var displayTypes: []
    property var queryTypes: ["=", "!=", ">", ">=", "<", "<=", "LIKE", "BETWEEN", "IS NULL", "IS NOT NULL", "IN"]
    property var cppTypes: ["String", "Integer", "Long", "Double", "Boolean", "DateTime"]

    property var dictTypeModel: []
    property var savedVisualModel: null

    signal back

    Component.onCompleted: {
        loadDisplayTypes();
        loadDictTypes();
        if (tableName) {
            loadColumns();
        }
    }

    onTableNameChanged: {
        if (tableName) {
            loadColumns();
            savedVisualModel = null;
            if (bar)
                bar.currentIndex = 0;
            if (generatorLoader.item) {
                generatorLoader.item.formModel = [];
                generatorLoader.item.selectedItem = null;
            }
        }
    }

    function loadDisplayTypes() {
        try {
            if (typeof componentJson !== "undefined") {
                var groups = JSON.parse(componentJson);
            } else {
                console.warn("componentJson is undefined, using default list");
                var defaultJson = '[{"group":"布局组件","items":[{"type":"StyledRow","label":"横向布局","icon":"▤"}]},{"group":"基础组件","items":[{"type":"StyledTextField","label":"文本输入","icon":"✎","supportFormConfig":true},{"type":"StyledSpinBox","label":"数字输入","icon":"123","supportFormConfig":true},{"type":"StyledDateTime","label":"日期时间","icon":"🕒","supportFormConfig":true},{"type":"StyledComboBox","label":"下拉选择","icon":"▼","supportFormConfig":true},{"type":"StyledButton","label":"按钮","icon":"ok"},{"type":"StyledLabel","label":"文本标签","icon":"T"}]}]';
                var groups = JSON.parse(defaultJson);
            }
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

    function loadDictTypes() {
        try {
            if (typeof MySqlHelper !== "undefined") {
                var dicts = MySqlHelper.select("sys_dict_type", ["dict_name", "dict_type"], "status='0'");
                var list = [];
                list.push({
                    text: "无",
                    value: ""
                });
                for (var i = 0; i < dicts.length; i++) {
                    list.push({
                        text: dicts[i].dict_name + " (" + dicts[i].dict_type + ")",
                        value: dicts[i].dict_type
                    });
                }
                dictTypeModel = list;
            }
        } catch (e) {
            console.error("Error loading dict types:", e);
        }
    }

    function fetchDictOptions(dictType) {
        if (!dictType || dictType === "")
            return [];
        try {
            if (typeof MySqlHelper !== "undefined") {
                var where = "dict_type='" + dictType + "' AND status='0' ORDER BY dict_sort";
                var data = MySqlHelper.select("sys_dict_data", ["dict_label", "dict_value"], where);
                var options = [];
                for (var i = 0; i < data.length; i++) {
                    options.push({
                        label: data[i].dict_label,
                        value: data[i].dict_value
                    });
                }
                return options;
            }
        } catch (e) {
            console.error("Error fetching options for " + dictType + ":", e);
        }
        return [];
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
                    cols[i].dictType = "";
                    cols[i].options = [];

                    if (cols[i].cppType === "Integer" || cols[i].cppType === "Long" || cols[i].cppType === "Double") {
                        cols[i].displayType = "StyledSpinBox";
                    } else if (cols[i].cppType === "DateTime") {
                        cols[i].displayType = "StyledDateTime";
                    }

                    var colName = cols[i].columnName;

                    if (colName.endsWith("code") || colName.endsWith("flag")) {
                        cols[i].displayType = "StyledComboBox";
                        var foundDict = false;
                        for (var d = 0; d < dictTypeModel.length; d++) {
                            if (dictTypeModel[d].value === colName) {
                                foundDict = true;
                                break;
                            }
                        }
                        if (foundDict) {
                            cols[i].dictType = colName;
                            cols[i].options = fetchDictOptions(colName);
                            console.log("Auto-matched dictionary for " + colName);
                        }
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

    function findColumnByBindName(columnMap, bindName) {
        for (var key in columnMap) {
            if (columnMap[key].columnName === bindName) {
                return columnMap[key];
            }
        }
        return null;
    }

    function updateVisualModelRecursively(model, columnMap, unvisitedKeys) {
        var newModel = [];
        for (var i = 0; i < model.length; i++) {
            var item = model[i];
            var newItem = JSON.parse(JSON.stringify(item));
            var keepItem = true;
            var colData = null;

            if (newItem.props && newItem.props.bindColumn) {
                colData = findColumnByBindName(columnMap, newItem.props.bindColumn);
            } else if (newItem.props && newItem.props.key) {
                colData = columnMap[newItem.props.key];
            }

            if (colData) {
                newItem.props.label = colData.columnComment || colData.columnName;
                newItem.props.required = colData.isRequired;
                newItem.props.key = colData.cppField;

                // 同步 dictType
                newItem.props.dictType = colData.dictType;

                if (colData.displayType && newItem.type !== colData.displayType) {
                    newItem.type = colData.displayType;
                    if (newItem.type === "StyledDateTime") {
                        newItem.props.displayFormat = "yyyy-MM-dd HH:mm:ss";
                        newItem.props.outputFormat = "yyyyMMddHHmmsszzz";
                    }
                }

                if (newItem.type === "StyledComboBox" && colData.options) {
                    newItem.props.model = colData.options;
                }

                var keyIndex = unvisitedKeys.indexOf(colData.cppField);
                if (keyIndex > -1) {
                    unvisitedKeys.splice(keyIndex, 1);
                }

                if (!colData.isEdit) {
                    keepItem = false;
                }
            } else if (isDataComponent(newItem.type) && newItem.props && newItem.props.key) {
                keepItem = false;
            }

            if (keepItem && newItem.children && newItem.children.length > 0) {
                newItem.children = updateVisualModelRecursively(newItem.children, columnMap, unvisitedKeys);
            }

            if (keepItem) {
                newModel.push(newItem);
            }
        }
        return newModel;
    }

    function isDataComponent(type) {
        return ["StyledTextField", "StyledSpinBox", "StyledComboBox", "StyledDateTime"].indexOf(type) !== -1;
    }

    function syncToVisual() {
        if (!generatorLoader.item)
            return;

        var columnMap = {};
        var unvisitedKeys = [];
        for (var i = 0; i < columnModel.length; i++) {
            var col = columnModel[i];
            columnMap[col.cppField] = col;
            if (col.isEdit) {
                unvisitedKeys.push(col.cppField);
            }
        }

        if (savedVisualModel && savedVisualModel.length > 0) {
            var updatedModel = updateVisualModelRecursively(savedVisualModel, columnMap, unvisitedKeys);

            if (unvisitedKeys.length > 0) {
                var newItems = createVisualItemsFromKeys(unvisitedKeys, columnMap);
                if (updatedModel.length > 0 && updatedModel[updatedModel.length - 1].type === "StyledRow") {
                    var lastRow = updatedModel[updatedModel.length - 1];
                    if (lastRow.props && lastRow.props.key === "row_actions") {
                        updatedModel.splice(updatedModel.length - 1, 0, createRow(updatedModel.length, newItems));
                    } else {
                        lastRow.children = lastRow.children.concat(newItems);
                    }
                } else {
                    updatedModel.push(createRow(updatedModel.length + 1, newItems));
                }
            }

            generatorLoader.item.formModel = updatedModel;
            console.log("Synced column changes to existing visual layout");
        } else {
            generateDefaultLayout();
        }
    }

    function createVisualItemsFromKeys(keys, columnMap) {
        var items = [];
        for (var i = 0; i < keys.length; i++) {
            var key = keys[i];
            var col = columnMap[key];
            if (!col)
                continue;

            var props = {
                "key": col.cppField,
                "label": col.columnComment || col.columnName,
                "layoutType": "percent",
                "widthPercent": 30,
                "visible": true,
                "enabled": true,
                "labelRatio": 0.2,
                "required": col.isRequired,
                "bindColumn": col.columnName,
                "dictType": col.dictType
            };

            if (col.displayType === "StyledComboBox") {
                if (col.options)
                    props.model = col.options;
            }
            if (col.displayType === "StyledDateTime") {
                props.displayFormat = "yyyy-MM-dd HH:mm:ss";
                props.outputFormat = "yyyyMMddHHmmsszzz";
                props.placeholder = "请选择时间";
            }

            items.push({
                "type": col.displayType || "StyledTextField",
                "id": "field_" + col.cppField,
                "props": props
            });
        }
        return items;
    }

    function createRow(index, children) {
        return {
            "type": "StyledRow",
            "id": "row_" + index,
            "props": {
                "key": "row_" + index,
                "layoutType": "fill",
                "spacing": 30,
                "paddingTop": 0,
                "paddingBottom": 10,
                "paddingLeft": 0,
                "paddingRight": 0,
                "wrap": true
            },
            "children": children || []
        };
    }

    function generateDefaultLayout() {
        var visualItems = [];
        var currentRowChildren = [];
        var rowIndex = 1;

        function pushRow() {
            if (currentRowChildren.length > 0) {
                visualItems.push(createRow(rowIndex, currentRowChildren));
                currentRowChildren = [];
                rowIndex++;
            }
        }

        for (var i = 0; i < columnModel.length; i++) {
            var col = columnModel[i];
            if (!col.isEdit)
                continue;

            var items = createVisualItemsFromKeys([col.cppField], (_ => {
                    var m = {};
                    m[col.cppField] = col;
                    return m;
                })());
            currentRowChildren.push(items[0]);

            if (currentRowChildren.length >= 3) {
                pushRow();
            }
        }
        pushRow();

        addBottomButtons(visualItems);
        generatorLoader.item.formModel = visualItems;
        console.log("Generated default layout");
    }

    function addBottomButtons(visualItems) {
        var submitLogic = "// 1. 验证所有字段\nvar validation = validateAll();\nif (!validation.valid) return;\n\n// 2. 收集数据\nvar data = getAllValues();\n\n// 3. 环境检查\nif (typeof controller === 'undefined') {\n    console.log('Preview Submit:', JSON.stringify(data));\n    showMessage('验证通过！(预览模式)', 'success');\n    return;\n}\n\n// 4. 处理主键\nif (isEditMode && formData && formData.id) {\n    data['id'] = formData.id;\n}\n\n// 5. 调用Controller\nvar success = isEditMode ? controller.update(data) : controller.add(data);\n\n// 6. 关闭\nif (success) {\n    if (typeof closeForm === 'function') closeForm();\n    else showMessage('保存成功', 'success');\n}";
        var cancelLogic = "if (typeof closeForm === 'function') closeForm();\nelse if (typeof root !== 'undefined' && root.StackView && root.StackView.view) root.StackView.view.pop();\nelse showMessage('取消操作', 'info');";
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
                "alignment": 4,
                "spacing": 20,
                "paddingTop": 20,
                "paddingBottom": 20,
                "wrap": false
            },
            "children": [btnCancel, btnSave]
        });
    }

    function syncFromVisualRecursively(model, columnMap) {
        for (var i = 0; i < model.length; i++) {
            var item = model[i];

            var col = null;
            if (item.props && item.props.bindColumn) {
                col = findColumnByBindName(columnMap, item.props.bindColumn);
            } else if (item.props && item.props.key) {
                col = columnMap[item.props.key];
            }

            if (col) {
                col.isEdit = true;
                col.columnComment = item.props.label || col.columnComment;
                col.isRequired = (item.props.required === true);

                if (item.props.key && item.props.key !== col.cppField) {
                    col.cppField = item.props.key;
                }

                // 同步 dictType
                if (item.props.dictType)
                    col.dictType = item.props.dictType;

                if (item.type && item.type.startsWith("Styled")) {
                    col.displayType = item.type;
                }
            }
            if (item.children && item.children.length > 0) {
                syncFromVisualRecursively(item.children, columnMap);
            }
        }
    }

    function syncFromVisual() {
        if (!generatorLoader.item)
            return;

        savedVisualModel = generatorLoader.item.formModel;

        var columnMap = {};
        for (var i = 0; i < columnModel.length; i++) {
            columnModel[i].isEdit = false;
            columnMap[columnModel[i].cppField] = columnModel[i];
        }

        if (savedVisualModel) {
            syncFromVisualRecursively(savedVisualModel, columnMap);
        }

        var temp = columnModel;
        columnModel = [];
        columnModel = temp;

        console.log("Synced visual changes back to column config");
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 10

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
                    if (generatorLoader.item)
                        syncFromVisual();

                    var config = {
                        "tableName": tableName,
                        "author": authorName,
                        "packageName": packageName,
                        "moduleName": moduleName,
                        "version": version,
                        "columns": columnModel
                    };
                    if (generatorLoader.item) {
                        // 调用新增的公开函数
                        var qmlBody = generatorLoader.item.getGeneratedCode();
                        config.customEditQml = qmlBody;
                        config.injectFunctions = true;
                    }

                    console.log("Generating code...");
                    var success = CodeGenerator.generate(config);

                    if (success) {
                        MessageManager.showToast("代码生成成功！", "success");
                    } else {
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
                            Layout.preferredWidth: 150
                            text: "字典数据"
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
                        property int rowIndex: index
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
                                text: rowIndex + 1
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
                                    root.columnModel[rowIndex].columnComment = text;
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
                                onActivated: function (idx) {
                                    modelData.cppType = currentText;
                                    root.columnModel[rowIndex].cppType = currentText;
                                }
                            }
                            TextField {
                                Layout.preferredWidth: 100
                                text: modelData.cppField
                                onEditingFinished: {
                                    modelData.cppField = text;
                                    root.columnModel[rowIndex].cppField = text;
                                }
                            }
                            CheckBox {
                                Layout.preferredWidth: 40
                                checked: modelData.isInsert
                                onToggled: {
                                    modelData.isInsert = checked;
                                    root.columnModel[rowIndex].isInsert = checked;
                                }
                            }
                            CheckBox {
                                Layout.preferredWidth: 40
                                checked: modelData.isEdit
                                onToggled: {
                                    modelData.isEdit = checked;
                                    root.columnModel[rowIndex].isEdit = checked;
                                }
                            }
                            CheckBox {
                                Layout.preferredWidth: 40
                                checked: modelData.isList
                                onToggled: {
                                    modelData.isList = checked;
                                    root.columnModel[rowIndex].isList = checked;
                                }
                            }
                            CheckBox {
                                id: queryCheckBox
                                Layout.preferredWidth: 40
                                checked: modelData.isQuery
                                onToggled: {
                                    modelData.isQuery = checked;
                                    root.columnModel[rowIndex].isQuery = checked;
                                }
                            }
                            ComboBox {
                                Layout.preferredWidth: 80
                                model: root.queryTypes
                                currentIndex: root.queryTypes.indexOf(modelData.queryType)
                                enabled: queryCheckBox.checked
                                onActivated: function (idx) {
                                    modelData.queryType = currentText;
                                    root.columnModel[rowIndex].queryType = currentText;
                                }
                            }
                            CheckBox {
                                Layout.preferredWidth: 40
                                checked: modelData.isRequired
                                onToggled: {
                                    modelData.isRequired = checked;
                                    root.columnModel[rowIndex].isRequired = checked;
                                }
                            }
                            ComboBox {
                                id: displayTypeCombo
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
                                onActivated: function (idx) {
                                    modelData.displayType = currentValue;
                                    root.columnModel[rowIndex].displayType = currentValue;
                                }
                            }

                            // 字典选择下拉框
                            ComboBox {
                                Layout.preferredWidth: 150
                                model: root.dictTypeModel
                                textRole: "text"
                                valueRole: "value"
                                enabled: displayTypeCombo.currentValue === "StyledComboBox"

                                Component.onCompleted: {
                                    var currentDict = modelData.dictType || "";
                                    var foundIndex = -1;
                                    for (var i = 0; i < root.dictTypeModel.length; i++) {
                                        if (root.dictTypeModel[i].value === currentDict) {
                                            foundIndex = i;
                                            break;
                                        }
                                    }
                                    if (foundIndex >= 0)
                                        currentIndex = foundIndex;
                                    else
                                        currentIndex = 0;
                                }

                                onActivated: function (comboIndex) {
                                    var selectedType = currentValue;
                                    modelData.dictType = selectedType;
                                    root.columnModel[rowIndex].dictType = selectedType;

                                    var opts = fetchDictOptions(selectedType);
                                    modelData.options = opts;
                                    root.columnModel[rowIndex].options = opts;

                                    console.log("Row " + rowIndex + " dict updated to: " + selectedType);
                                }
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
