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

    // 字典类型列表模型
    property var dictTypeModel: []

    // 保存可视化编辑器修改后的模型
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
            // [修复] 切换表时彻底清空缓存和预览状态
            savedVisualModel = null;
            bar.currentIndex = 0; // 重置到第一个Tab
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
                var defaultJson = '[{"group":"布局组件","items":[{"type":"StyledRow","label":"横向布局","icon":"▤"}]},{"group":"基础组件","items":[{"type":"StyledTextField","label":"文本输入","icon":"✎","supportFormConfig":true},{"type":"StyledSpinBox","label":"数字输入","icon":"123","supportFormConfig":true},{"type":"StyledComboBox","label":"下拉选择","icon":"▼","supportFormConfig":true},{"type":"StyledButton","label":"按钮","icon":"ok"},{"type":"StyledLabel","label":"文本标签","icon":"T"}]}]';
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
                    }

                    var colName = cols[i].columnName;

                    // [修改] 增加 flag 结尾判断
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

    // [新增] 递归遍历可视化模型，寻找并更新 Item
    function updateVisualModelRecursively(model, columnMap, unvisitedKeys) {
        var newModel = [];
        for (var i = 0; i < model.length; i++) {
            var item = model[i];
            var newItem = JSON.parse(JSON.stringify(item)); // 深拷贝
            var keepItem = true;

            // 检查是否是数据字段 (拥有 key 且不是布局容器或按钮)
            // 简单判断：如果 key 在 columnMap 中，说明是字段
            if (newItem.props && newItem.props.key && columnMap[newItem.props.key]) {
                var colData = columnMap[newItem.props.key];

                // 1. 同步属性 (Tab 1 -> Tab 3)
                newItem.props.label = colData.columnComment || colData.columnName;
                newItem.props.required = colData.isRequired;

                // 如果类型变了，更新类型 (例如手动改了 displayType)
                if (colData.displayType && newItem.type !== colData.displayType) {
                    newItem.type = colData.displayType;
                }

                // 如果是下拉框，同步选项
                if (newItem.type === "StyledComboBox" && colData.options) {
                    newItem.props.model = colData.options;
                }

                // 标记已访问
                var keyIndex = unvisitedKeys.indexOf(newItem.props.key);
                if (keyIndex > -1) {
                    unvisitedKeys.splice(keyIndex, 1);
                }

                // 如果 Tab 1 中取消了“编辑”，则在可视化中移除
                if (!colData.isEdit) {
                    keepItem = false;
                }
            } else
            // 此外：如果是一个看起来像字段的组件，但在 columnMap 中找不到 key，说明 Tab 1 删除了该列或改了名
            // 我们选择移除它，除非它是纯 UI 组件（如 Row/Label/Button）
            if (isDataComponent(newItem.type) && newItem.props && newItem.props.key) {
                // 这是一个数据组件，但其 key 不在当前的 columnModel 中 -> 移除
                keepItem = false;
            }

            // 递归处理子元素
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
        return ["StyledTextField", "StyledSpinBox", "StyledComboBox"].indexOf(type) !== -1;
    }

    // [修改] 双向同步：将字段配置同步到可视化编辑器 (合并模式)
    function syncToVisual() {
        if (!generatorLoader.item)
            return;

        // 1. 准备数据映射
        var columnMap = {};
        var unvisitedKeys = []; // 记录所有需要显示的字段 Key
        for (var i = 0; i < columnModel.length; i++) {
            var col = columnModel[i];
            columnMap[col.cppField] = col;
            if (col.isEdit) {
                unvisitedKeys.push(col.cppField);
            }
        }

        // 2. 如果已有可视化模型，进行合并更新
        if (savedVisualModel && savedVisualModel.length > 0) {
            // 递归更新现有模型（更新属性，移除被禁用的字段）
            var updatedModel = updateVisualModelRecursively(savedVisualModel, columnMap, unvisitedKeys);

            // 3. 处理剩余未访问的 Key（新增的字段）
            // 将它们添加到末尾
            if (unvisitedKeys.length > 0) {
                var newItems = createVisualItemsFromKeys(unvisitedKeys, columnMap);
                // 尝试添加到最后一个 Row 中，如果没有 Row 则新建
                if (updatedModel.length > 0 && updatedModel[updatedModel.length - 1].type === "StyledRow") {
                    var lastRow = updatedModel[updatedModel.length - 1];
                    lastRow.children = lastRow.children.concat(newItems);
                } else {
                    // 创建新行
                    updatedModel.push(createRow(updatedModel.length + 1, newItems));
                }
            }

            generatorLoader.item.formModel = updatedModel;
            console.log("Synced column changes to existing visual layout");
        } else {
            // 4. 没有历史模型，完全重新生成
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
                "required": col.isRequired
            };
            if (col.displayType === "StyledComboBox" && col.options) {
                props.model = col.options;
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

        // 底部按钮
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

    // [新增] 递归遍历可视化模型，同步回 Tab 1
    function syncFromVisualRecursively(model, columnMap) {
        for (var i = 0; i < model.length; i++) {
            var item = model[i];
            if (item.props && item.props.key && columnMap[item.props.key]) {
                var col = columnMap[item.props.key];
                // 标记为正在编辑（因为存在于可视化布局中）
                col.isEdit = true;
                // 同步属性回 Tab 1
                col.columnComment = item.props.label || col.columnComment;
                col.isRequired = (item.props.required === true);
                // 同步显示类型
                if (item.type && item.type.startsWith("Styled")) {
                    col.displayType = item.type;
                }
            }
            if (item.children && item.children.length > 0) {
                syncFromVisualRecursively(item.children, columnMap);
            }
        }
    }

    // [修改] 双向同步：从可视化编辑器同步回 Tab 1
    function syncFromVisual() {
        if (!generatorLoader.item)
            return;

        // 1. 保存当前视觉状态
        savedVisualModel = generatorLoader.item.formModel;

        // 2. 准备 columnMap
        var columnMap = {};
        for (var i = 0; i < columnModel.length; i++) {
            // 先默认设为 false，如果在 visual 中找到则设为 true
            columnModel[i].isEdit = false;
            columnMap[columnModel[i].cppField] = columnModel[i];
        }

        // 3. 递归更新
        if (savedVisualModel) {
            syncFromVisualRecursively(savedVisualModel, columnMap);
        }

        // 4. 强制刷新 ListView (Model 重置)
        var temp = columnModel;
        columnModel = [];
        columnModel = temp;

        console.log("Synced visual changes back to column config");
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
                                onActivated: {
                                    modelData.displayType = currentValue;
                                    root.columnModel[index].displayType = currentValue;
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

                                onActivated: {
                                    var selectedType = currentValue;
                                    modelData.dictType = selectedType;
                                    root.columnModel[index].dictType = selectedType;
                                    var opts = fetchDictOptions(selectedType);
                                    modelData.options = opts;
                                    root.columnModel[index].options = opts;
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
