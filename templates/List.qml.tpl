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

Item {
    id: root
    width: parent ? parent.width : 0
    height: parent ? parent.height : 0
    
    property var tableModel: []
    property int pageNum: 1
    property int pageSize: 10
    
    // [新增] 字典选项数据，用于列表转义显示
    {{# columns }}
    {{# hasOptions }}
    property var options_{{ cppField }}: {{ optionsStr }}
    {{/ hasOptions }}
    {{/ columns }}

    // [新增] 字典值翻译函数
    function getOptionLabel(options, value) {
        if (!options || !Array.isArray(options)) return value;
        for (var i = 0; i < options.length; i++) {
            // 使用宽松相等 (==) 以匹配字符串 "1" 和数字 1
            if (options[i].value == value) return options[i].label;
        }
        return value;
    }

    // Controller Instance
    {{ className }}Controller {
        id: controller
        onOperationSuccess: function(message) {
            console.log("Success:", message);
            loadData();
        }
        onOperationFailed: function(message) {
            console.error("Failed:", message);
        }
    }
    
    Component.onCompleted: loadData()
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 15
        spacing: 10
        
        // Search Area
        GroupBox {
            title: "查询条件"
            Layout.fillWidth: true
            
            GridLayout {
                anchors.fill: parent
                // 响应式布局：根据宽度自动调整列数
                columns: root.width < 800 ? 2 : 4
                columnSpacing: 15
                rowSpacing: 10
                
                {{# columns }}
                {{# isQuery }}
                RowLayout {
                    Layout.fillWidth: true
                    Layout.columnSpan: 1
                    
                    Text { 
                        text: "{{ columnComment }}: " 
                        font.pixelSize: 13
                        Layout.alignment: Qt.AlignVCenter
                    }
                    StyledTextField {
                        id: search_{{ cppField }}
                        showLabel: false 
                        Layout.fillWidth: true
                        placeholderText: {{# isQueryBetween }}"范围: 开始,结束"{{/ isQueryBetween }}{{^ isQueryBetween }}"请输入"{{/ isQueryBetween }}
                    }
                }
                {{/ isQuery }}
                {{/ columns }}
                
                // 查询操作按钮
                RowLayout {
                    Layout.fillWidth: true
                    Layout.columnSpan: 1
                    Layout.alignment: Qt.AlignRight
                    spacing: 10
                    
                    StyledButton {
                        text: "搜索"
                        buttonType: "primary"
                        onClicked: {
                            pageNum = 1;
                            loadData();
                        }
                    }
                    StyledButton {
                        text: "重置"
                        buttonType: "secondary"
                        onClicked: {
                            {{# columns }}
                            {{# isQuery }}
                            search_{{ cppField }}.text = ""
                            {{/ isQuery }}
                            {{/ columns }}
                            pageNum = 1;
                            loadData()
                        }
                    }
                }
            }
        }
        
        // Toolbar
        RowLayout {
            Layout.fillWidth: true
            spacing: 10
            
            StyledButton { 
                text: "新增"
                buttonType: "success"
                onClicked: openEditDialog(true, {})
            }
            
            Item { Layout.fillWidth: true }
        }
        
        // List Header
        Rectangle {
            Layout.fillWidth: true
            height: 45
            color: "#f5f7fa"
            border.color: "#e4e7ed"
            border.width: 1
            radius: 4

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
                    color: "#606266"
                }
                {{/ isList }}
                {{/ columns }}
                Text { 
                    Layout.preferredWidth: 150
                    text: "操作" 
                    font.bold: true 
                    horizontalAlignment: Text.AlignHCenter
                    color: "#606266"
                }
            }
        }
        
        // List Content
        ListView {
            id: listView
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            model: root.tableModel
            spacing: 5
            
            delegate: Rectangle {
                width: ListView.view.width
                height: 50
                color: index % 2 === 0 ? "#ffffff" : "#fafafa"
                border.width: 0
                
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    propagateComposedEvents: true
                    onEntered: parent.color = "#f0f9eb"
                    onExited: parent.color = index % 2 === 0 ? "#ffffff" : "#fafafa"
                }
                
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
                        
                        // [新增] 如果有字典选项，显示翻译后的标签，否则显示原值
                        {{# hasOptions }}
                        text: getOptionLabel(root.options_{{ cppField }}, modelData["{{ cppField }}"])
                        {{/ hasOptions }}
                        {{^ hasOptions }}
                        text: modelData["{{ cppField }}"]
                        {{/ hasOptions }}
                        
                        elide: Text.ElideRight
                        color: "#333333"
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
                            onClicked: openEditDialog(false, modelData)
                        }
                        
                        StyledButton {
                            text: "删除"
                            buttonType: "danger"
                            width: 60
                            height: 30
                            onClicked: {
                                var pk = modelData["{{ pkCppField }}"];
                                controller.remove(pk);
                            }
                        }
                    }
                }
            }
        }
    }
    
    function openEditDialog(isAdd, data) {
        var comp = Qt.createComponent("{{ className }}Edit.qml");
        if (comp.status === Component.Ready) {
            var props = {
                controller: controller,
                isAdd: isAdd,
                formData: data
            };
            var obj = comp.createObject(root.parent, props);
            if (root.StackView.view) {
                root.StackView.view.push(obj);
            } else {
                obj.parent = root.parent;
            }
        } else {
            console.error("Error loading {{ className }}Edit.qml:", comp.errorString());
        }
    }
    
    function loadData() {
        var query = {};
        {{# columns }}
        {{# isQuery }}
        query["{{ cppField }}"] = search_{{ cppField }}.text;
        {{/ isQuery }}
        {{/ columns }}
        
        console.log("Querying with:", JSON.stringify(query));
        var result = controller.list(pageNum, pageSize, query);
        tableModel = result;
    }
}