/*
 * File: {{ className }}Edit.qml
 * Description: Edit form for {{ tableName }}
 */
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"
import "../mysqlhelper"
import {{ moduleName }} 1.0

Item {
    id: root
    // [修复] 不使用 fill: parent，由 StackView 管理
    width: parent ? parent.width : 800
    height: parent ? parent.height : 600
    
    property var controller: null
    property bool isAdd: true
    property var formData: ({})
    
    Rectangle {
        anchors.fill: parent
        color: "#f5f7fa"
    }
    
    function loadDictData(dictType) {
        var items = [];
        try {
            if (typeof MySqlHelper !== "undefined") {
                var result = MySqlHelper.select("sys_dict_data", ["dict_label", "dict_value"], "dict_type='" + dictType + "' AND status='0' ORDER BY dict_sort");
                for (var i = 0; i < result.length; i++) {
                    items.push({ "label": result[i].dict_label, "value": result[i].dict_value });
                }
            }
        } catch (e) { console.error("Error loading dict:", dictType, e); }
        return items;
    }

    Component.onCompleted: {
        if (!isAdd && formData) {
            {{# columns }}
            {{# isEdit }}
            if(formData["{{ cppField }}"] !== undefined) {
                field_{{ cppField }}.{{ valueProperty }} = formData["{{ cppField }}"];
            }
            {{/ isEdit }}
            {{/ columns }}
        }
    }
    
    // 居中表单卡片
    Rectangle {
        id: formCard
        width: Math.min(parent.width - 40, 900)
        height: Math.min(parent.height - 40, contentLayout.implicitHeight + 80)
        anchors.centerIn: parent
        color: "white"
        radius: 8
        border.color: "#e0e0e0"
        border.width: 1
        
        ScrollView {
            anchors.fill: parent
            anchors.margins: 20
            clip: true
            contentWidth: width

            ColumnLayout {
                id: contentLayout
                width: parent.width
                spacing: 20
                
                Text {
                    text: (isAdd ? "新增" : "修改") + " {{ tableName }}"
                    font.pixelSize: 22
                    font.bold: true
                    color: "#303133"
                    Layout.alignment: Qt.AlignHCenter
                }
                
                GridLayout {
                    id: formGrid
                    Layout.fillWidth: true
                    columns: formCard.width > 600 ? 2 : 1
                    columnSpacing: 30
                    rowSpacing: 20
                    
                    {{# columns }}
                    {{# isEdit }}
                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.columnSpan: 1 
                        spacing: 5
                        
                        // [修复] 移除 anchors，使用 Layout 属性
                        Text { 
                            text: "{{ columnComment }}" 
                            font.pixelSize: 14
                            color: "#606266"
                            Layout.fillWidth: true
                            
                            // 必填星号
                            {{# isRequired }}
                            Text { 
                                text: "*"
                                color: "red"
                                font.pixelSize: 14
                                anchors.left: parent.right
                                anchors.leftMargin: 4
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            {{/ isRequired }}
                        }
                        
                        {{ displayType }} {
                            id: field_{{ cppField }}
                            Layout.fillWidth: true
                            showLabel: false 
                            enabled: true 
                            {{# isString }}placeholderText: "请输入{{ columnComment }}"{{/ isString }}
                            
                            {{# hasDictType }}
                            model: loadDictData("{{ dictType }}")
                            {{/ hasDictType }}
                            {{^ hasDictType }}
                            {{# hasOptions }}model: {{ optionsStr }}{{/ hasOptions }}
                            {{/ hasDictType }}
                            
                            {{# isDateTime }}
                            displayFormat: "yyyy-MM-dd HH:mm:ss"
                            outputFormat: "yyyyMMddHHmmsszzz"
                            {{/ isDateTime }}
                        }
                    }
                    {{/ isEdit }}
                    {{/ columns }}
                }

                Item { Layout.preferredHeight: 20 }
                
                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 20
                    StyledButton {
                        text: "取消"
                        buttonType: "secondary"
                        width: 100
                        enabled: true
                        onClicked: closeForm()
                    }
                    StyledButton {
                        text: "保存"
                        buttonType: "primary"
                        width: 100
                        enabled: true
                        onClicked: saveData()
                    }
                }
            }
        }
    }
    
    function saveData() {
        var data = {};
        {{# columns }}
        {{# isEdit }}
        data["{{ cppField }}"] = field_{{ cppField }}.{{ valueProperty }};
        {{# isRequired }}
        if(data["{{ cppField }}"] === undefined || data["{{ cppField }}"] === "") {
            console.warn("{{ columnComment }} 不能为空");
            return;
        }
        {{/ isRequired }}
        {{/ isEdit }}
        {{/ columns }}
        
        if (!isAdd) {
            data["{{ pkCppField }}"] = formData["{{ pkCppField }}"];
        }
        
        var success = false;
        if (isAdd) success = controller.add(data);
        else success = controller.update(data);
        
        if (success) closeForm();
        else console.error("Save failed");
    }
    
    function closeForm() {
        if (root.StackView.view) root.StackView.view.pop();
        else root.visible = false;
    }
}