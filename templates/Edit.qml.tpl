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
    width: parent ? parent.width : 0
    height: parent ? parent.height : 0
    
    property var controller: null
    property bool isAdd: true
    property var formData: ({})
    
    Component.onCompleted: {
        if (!isAdd && formData) {
            {{# columns }}
            {{# isEdit }}
            // [恢复] 使用 cppField (驼峰名) 回填数据
            field_{{ cppField }}.{{ valueProperty }} = formData["{{ cppField }}"] || "";
            {{/ isEdit }}
            {{/ columns }}
        }
    }
    
    ColumnLayout {
        anchors.centerIn: parent
        width: 400
        spacing: 15
        
        Text {
            text: (isAdd ? "新增" : "修改") + " {{ tableName }}"
            font.pixelSize: 20
            font.bold: true
            Layout.alignment: Qt.AlignHCenter
        }
        
        {{# columns }}
        {{# isEdit }}
        RowLayout {
            Layout.fillWidth: true
            Text { 
                text: "{{ columnComment }}:" 
                Layout.preferredWidth: 80
                Layout.alignment: Qt.AlignVCenter
            }
            
            {{ displayType }} {
                id: field_{{ cppField }}
                Layout.fillWidth: true
                showLabel: false 
            }
        }
        {{/ isEdit }}
        {{/ columns }}
        
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 20
            StyledButton {
                text: "保存"
                onClicked: saveData()
            }
            StyledButton {
                text: "取消"
                onClicked: {
                    if (root.StackView.view) {
                        root.StackView.view.pop();
                    } else {
                        root.visible = false;
                    }
                }
            }
        }
    }
    
    function saveData() {
        var data = {};
        {{# columns }}
        {{# isEdit }}
        // 收集数据使用驼峰 Key
        data["{{ cppField }}"] = field_{{ cppField }}.{{ valueProperty }};
        {{/ isEdit }}
        {{/ columns }}
        
        if (!isAdd) {
            var pkField = "id";
            {{# columns }}{{# isPk }}pkField = "{{ cppField }}";{{/ isPk }}{{/ columns }}
            // formData 也是驼峰格式
            data[pkField] = formData[pkField];
        }
        
        var success = false;
        if (isAdd) {
            // 传递驼峰数据给 Controller，由 Controller 转换为下划线
            success = controller.add(data);
        } else {
            success = controller.update(data);
        }
        
        if (success) {
            if (root.StackView.view) {
                root.StackView.view.pop();
            }
        } else {
            console.error("Save failed");
        }
    }
}