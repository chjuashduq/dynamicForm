/*
 * File: {{ className }}List.qml
 * Author: {{ author }}
 * Date: {{ createDate }}
 * Description: {{ tableName }} 列表管理页面
 */
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"
import "../mysqlhelper"
import {{ moduleName }} 1.0

Item {
    id: root
    // [修复] 移除 anchors.fill: parent，避免 StackView 冲突
    width: parent ? parent.width : 0
    height: parent ? parent.height : 0
    
    property var tableModel: []
    property int pageNum: 1
    property int pageSize: 10
    
    // 字典选项数据
    {{# columns }}
    {{# hasDictType }}
    property var options_{{ cppField }}: []
    {{/ hasDictType }}
    {{/ columns }}

    function loadDictData(dictType) {
        var items = [];
        try {
            if (typeof MySqlHelper !== "undefined") {
                var result = MySqlHelper.select("sys_dict_data", ["dict_label", "dict_value"], "dict_type='" + dictType + "' AND status='0' ORDER BY dict_sort");
                for (var i = 0; i < result.length; i++) {
                    items.push({ "label": result[i].dict_label, "value": result[i].dict_value });
                }
            }
        } catch (e) {
            console.error("Error loading dict:", dictType, e);
        }
        return items;
    }

    function getOptionLabel(options, value) {
        if (!options || !Array.isArray(options)) return value;
        for (var i = 0; i < options.length; i++) {
            if (options[i].value == value) return options[i].label;
        }
        return value;
    }

    {{ className }}Controller {
        id: controller
        onOperationSuccess: function(message) {
            loadData();
        }
        onOperationFailed: function(message) {
            console.error("Failed:", message);
        }
    }
    
    Component.onCompleted: {
        {{# columns }}
        {{# hasDictType }}
        options_{{ cppField }} = loadDictData("{{ dictType }}");
        {{/ hasDictType }}
        {{/ columns }}
        loadData();
    }
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 15
        spacing: 10
        
        // --- 搜索区域 ---
        Rectangle {
            Layout.fillWidth: true
            height: searchLayout.implicitHeight + 20
            color: "white"
            radius: 4
            border.color: "#d1d5db" // [修改] 加深边框
            border.width: 1
            
            ColumnLayout {
                id: searchLayout
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10
                
                Text {
                    text: "查询条件"
                    font.bold: true
                    font.pixelSize: 14
                    color: "#333"
                }

                GridLayout {
                    Layout.fillWidth: true
                    columns: root.width < 800 ? 2 : 4
                    columnSpacing: 15
                    rowSpacing: 10
                    
                    {{# columns }}
                    {{# isQuery }}
                    RowLayout {
                        Layout.fillWidth: true
                        Text { 
                            text: "{{ columnComment }}:" 
                            font.pixelSize: 13
                            color: "#666"
                        }
                        {{# hasDictType }}
                        StyledComboBox {
                            id: search_{{ cppField }}
                            showLabel: false
                            Layout.fillWidth: true
                            enabled: true // [修复] 确保启用
                            textRole: "label"
                            valueRole: "value"
                            Component.onCompleted: {
                                var opts = loadDictData("{{ dictType }}");
                                opts.unshift({ "label": "全部", "value": "" });
                                model = opts;
                                currentIndex = 0;
                            }
                        }
                        {{/ hasDictType }}
                        {{^ hasDictType }}
                        StyledTextField {
                            id: search_{{ cppField }}
                            showLabel: false 
                            Layout.fillWidth: true
                            enabled: true // [修复] 确保启用
                            placeholderText: {{# isQueryBetween }}"范围: 开始,结束"{{/ isQueryBetween }}{{^ isQueryBetween }}"请输入"{{/ isQueryBetween }}
                        }
                        {{/ hasDictType }}
                    }
                    {{/ isQuery }}
                    {{/ columns }}
                    
                    // 按钮组
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.columnSpan: 1
                        Layout.alignment: Qt.AlignRight
                        spacing: 10
                        
                        StyledButton {
                            text: "搜索"
                            buttonType: "primary"
                            width: 60
                            enabled: true
                            onClicked: { pageNum = 1; loadData(); }
                        }
                        StyledButton {
                            text: "重置"
                            buttonType: "secondary"
                            width: 60
                            enabled: true
                            onClicked: {
                                {{# columns }}
                                {{# isQuery }}
                                {{# hasDictType }}
                                search_{{ cppField }}.currentIndex = 0;
                                {{/ hasDictType }}
                                {{^ hasDictType }}
                                search_{{ cppField }}.text = "";
                                {{/ hasDictType }}
                                {{/ isQuery }}
                                {{/ columns }}
                                pageNum = 1;
                                loadData()
                            }
                        }
                    }
                }
            }
        }
        
        // --- 工具栏 ---
        RowLayout {
            Layout.fillWidth: true
            spacing: 10
            
            StyledButton { 
                text: "新增"
                buttonType: "success"
                enabled: true // [修复] 显式启用
                onClicked: openEditDialog(true, {})
            }
            Item { Layout.fillWidth: true }
        }
        
        // --- 列表头 ---
        Rectangle {
            Layout.fillWidth: true
            height: 40
            color: "#f8f9fa"
            border.color: "#e5e7eb"
            border.width: 1

            RowLayout {
                anchors.fill: parent
                spacing: 10
                anchors.leftMargin: 15
                anchors.rightMargin: 15
                
                {{# columns }}
                {{# isList }}
                Text { 
                    Layout.preferredWidth: 120
                    Layout.fillWidth: true
                    text: "{{ columnComment }}"
                    font.bold: true 
                    color: "#4b5563"
                }
                {{/ isList }}
                {{/ columns }}
                Text { 
                    Layout.preferredWidth: 150
                    text: "操作" 
                    font.bold: true 
                    horizontalAlignment: Text.AlignHCenter
                    color: "#4b5563"
                }
            }
        }
        
        // --- 数据列表 ---
        ListView {
            id: listView
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            model: root.tableModel
            spacing: 0
            
            delegate: Rectangle {
                width: ListView.view.width
                height: 50
                color: index % 2 === 0 ? "#ffffff" : "#f9fafb"
                
                RowLayout {
                    anchors.fill: parent
                    spacing: 10
                    anchors.leftMargin: 15
                    anchors.rightMargin: 15
                    
                    {{# columns }}
                    {{# isList }}
                    Text {
                        Layout.preferredWidth: 120
                        Layout.fillWidth: true
                        {{# hasDictType }}
                        text: getOptionLabel(root.options_{{ cppField }}, modelData["{{ cppField }}"])
                        {{/ hasDictType }}
                        {{^ hasDictType }}
                        text: modelData["{{ cppField }}"]
                        {{/ hasDictType }}
                        elide: Text.ElideRight
                        color: "#374151"
                    }
                    {{/ isList }}
                    {{/ columns }}
                    
                    RowLayout {
                        Layout.preferredWidth: 150
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 8
                        
                        StyledButton {
                            text: "编辑"
                            width: 60
                            height: 30
                            enabled: true
                            onClicked: openEditDialog(false, modelData)
                        }
                        StyledButton {
                            text: "删除"
                            buttonType: "danger"
                            width: 60
                            height: 30
                            enabled: true
                            onClicked: controller.remove(modelData["{{ pkCppField }}"])
                        }
                    }
                }
            }
        }
    }
    
    function openEditDialog(isAdd, data) {
        // [修复] 使用相对路径引用，确保能找到生成的 Edit.qml
        var comp = Qt.createComponent("{{ className }}Edit.qml");
        
        if (comp.status === Component.Ready) {
            var props = { controller: controller, isAdd: isAdd, formData: data };
            var obj = comp.createObject(root.parent, props);
            
            if (root.StackView.view) root.StackView.view.push(obj);
            else { obj.parent = root.parent; obj.visible = true; }
        } else {
            console.error("Error loading Edit.qml:", comp.errorString());
        }
    }
    
    function loadData() {
        var query = {};
        {{# columns }}
        {{# isQuery }}
        {{# hasDictType }}
        query["{{ cppField }}"] = search_{{ cppField }}.currentValue;
        {{/ hasDictType }}
        {{^ hasDictType }}
        query["{{ cppField }}"] = search_{{ cppField }}.text;
        {{/ hasDictType }}
        {{/ isQuery }}
        {{/ columns }}
        
        var result = controller.list(pageNum, pageSize, query);
        tableModel = result;
    }
}