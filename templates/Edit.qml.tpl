/*
 * File: {{ className }}Edit.qml
 * Author: {{ author }}
 * Date: {{ createDate }}
 * Description: Edit form for {{ tableName }}
 */
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"

Item {
    id: root
    width: parent ? parent.width : 800
    height: parent ? parent.height : 600
    
    property var controller: null
    property bool isAdd: true
    property var formData: ({})
    
    // 背景遮罩
    Rectangle {
        anchors.fill: parent
        color: "#f5f7fa"
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
    
    ScrollView {
        anchors.fill: parent
        anchors.margins: 20
        clip: true

        ColumnLayout {
            width: Math.min(parent.width, 900)
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 20
            
            Text {
                text: (isAdd ? "新增" : "修改") + " {{ tableName }}"
                font.pixelSize: 22
                font.bold: true
                color: "#303133"
                Layout.alignment: Qt.AlignHCenter
                Layout.bottomMargin: 10
            }
            
            // ================= 响应式表单内容区域 =================
            GridLayout {
                id: formGrid
                Layout.fillWidth: true
                // 响应式列数：宽屏显示3列，中屏2列，窄屏1列
                columns: root.width > 1200 ? 3 : (root.width > 800 ? 2 : 1)
                columnSpacing: 30
                rowSpacing: 20
                
                {{# columns }}
                {{# isEdit }}
                // 字段: {{ columnComment }}
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.columnSpan: 1 
                    spacing: 8
                    
                    Text { 
                        text: "{{ columnComment }}" 
                        font.pixelSize: 14
                        color: "#606266"
                        {{# isRequired }}
                        Text { text: "*"; color: "red"; anchors.left: parent.right; anchors.leftMargin: 2 }
                        {{/ isRequired }}
                    }
                    
                    {{ displayType }} {
                        id: field_{{ cppField }}
                        Layout.fillWidth: true
                        showLabel: false 
                        {{# isString }}placeholderText: "请输入{{ columnComment }}"{{/ isString }}
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
                    onClicked: closeForm()
                }
                StyledButton {
                    text: "保存"
                    buttonType: "primary"
                    width: 100
                    onClicked: saveData()
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
            // 使用生成器预处理的主键字段名
            data["{{ pkCppField }}"] = formData["{{ pkCppField }}"];
        }
        
        var success = false;
        if (isAdd) {
            success = controller.add(data);
        } else {
            success = controller.update(data);
        }
        
        if (success) {
            closeForm();
        } else {
            console.error("Save failed");
        }
    }
    
    function closeForm() {
        if (root.StackView.view) {
            root.StackView.view.pop();
        } else {
            root.visible = false;
        }
    }
}