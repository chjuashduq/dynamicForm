/*
 * File: {{ className }}List.qml
 * Author: {{ author }}
 * Date: {{ createDate }}
 * Description: List view for {{ tableName }}
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
    
    // Controller Instance
    {{ className }}Controller {
        id: controller
        onOperationSuccess: function(message) {
            console.log(message);
            loadData();
        }
        onOperationFailed: function(message) {
            console.error(message);
        }
    }
    
    Component.onCompleted: loadData()
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 10
        
        // Search Area
        Flow {
            Layout.fillWidth: true
            spacing: 10
            
            {{# columns }}
            {{# isQuery }}
            RowLayout {
                Text { 
                    text: "{{ columnComment }}: " 
                    visible: true 
                }
                StyledTextField {
                    id: search_{{ cppField }}
                    showLabel: false 
                    placeholderText: {{# isQueryBetween }}"范围: 开始,结束"{{/ isQueryBetween }}{{^ isQueryBetween }}"请输入"{{/ isQueryBetween }}
                    implicitWidth: 200
                }
            }
            {{/ isQuery }}
            {{/ columns }}
            
            RowLayout {
                StyledButton {
                    text: "搜索"
                    onClicked: {
                        pageNum = 1;
                        loadData();
                    }
                }
                StyledButton {
                    text: "重置"
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
        
        // Toolbar
        RowLayout {
            Layout.fillWidth: true
            StyledButton { 
                text: "新增"
                onClicked: {
                    var comp = Qt.createComponent("{{ className }}Edit.qml");
                    if (comp.status === Component.Ready) {
                        var obj = comp.createObject(root.parent, {controller: controller});
                        if (root.StackView.view) {
                            root.StackView.view.push(obj);
                        } else {
                            obj.parent = root.parent;
                        }
                    } else {
                        console.error("Error loading {{ className }}Edit.qml:", comp.errorString());
                    }
                }
            }
        }
        
        // Header
        Rectangle {
            Layout.fillWidth: true
            height: 40
            color: "#eee"
            RowLayout {
                anchors.fill: parent
                spacing: 10
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                
                {{# columns }}
                {{# isList }}
                Text { Layout.preferredWidth: 100; text: "{{ columnComment }}"; font.bold: true }
                {{/ isList }}
                {{/ columns }}
                Text { Layout.preferredWidth: 150; text: "操作"; font.bold: true }
            }
        }
        
        // List
        ListView {
            id: listView
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            model: root.tableModel
            
            delegate: Rectangle {
                width: ListView.view.width
                height: 50
                color: index % 2 === 0 ? "#fff" : "#f9f9f9"
                
                RowLayout {
                    anchors.fill: parent
                    spacing: 10
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    
                    {{# columns }}
                    {{# isList }}
                    Text {
                        Layout.preferredWidth: 100
                        text: modelData["{{ cppField }}"]
                        elide: Text.ElideRight
                    }
                    {{/ isList }}
                    {{/ columns }}
                    
                    RowLayout {
                        Layout.preferredWidth: 150
                        spacing: 5
                        StyledButton {
                            text: "编辑"
                            onClicked: {
                                var comp = Qt.createComponent("{{ className }}Edit.qml");
                                if (comp.status === Component.Ready) {
                                    var obj = comp.createObject(root.parent, {
                                        controller: controller,
                                        isAdd: false,
                                        formData: modelData
                                    });
                                    if (root.StackView.view) {
                                        root.StackView.view.push(obj);
                                    }
                                }
                            }
                        }
                        StyledButton {
                            text: "删除"
                            onClicked: {
                                var pk = 0;
                                {{# columns }}{{# isPk }}pk = modelData["{{ cppField }}"];{{/ isPk }}{{/ columns }}
                                controller.remove(pk);
                            }
                        }
                    }
                }
            }
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