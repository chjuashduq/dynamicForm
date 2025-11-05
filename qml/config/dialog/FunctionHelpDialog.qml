import QtQuick 6.5
import QtQuick.Controls 6.5
import QtQuick.Layouts 1.4

/**
 * 函数编写对话框
 * 提供函数提示和代码编辑功能
 */
Dialog {
    id: functionHelpDialog
    title: "函数编写"
    width: 900
    height: 700
    anchors.centerIn: parent
    modal: true

    property string currentEventType: ""
    property string currentEventCode: ""
    
    signal functionSaved(string eventType, string code)

    RowLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 10

        // 左侧：函数列表
        GroupBox {
            title: "可用函数"
            Layout.preferredWidth: 350
            Layout.fillHeight: true

            ScrollView {
                anchors.fill: parent
                anchors.margins: 5
                clip: true
                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                Column {
                    width: parent.width
                    spacing: 5

                    // 基础变量
                    Rectangle {
                        width: parent.width
                        height: 30
                        color: "#e3f2fd"
                        radius: 4
                        
                        Text {
                            anchors.centerIn: parent
                            text: "基础变量"
                            font.bold: true
                            color: "#1976d2"
                        }
                    }

                    Repeater {
                        model: [
                            {name: "self", desc: "当前控件对象", code: "self.value"},
                            {name: "controlsMap", desc: "所有控件映射表", code: "controlsMap['控件key']"},
                            {name: "value", desc: "当前控件的值", code: "value"},
                            {name: "key", desc: "控件的标识", code: "key"},
                            {name: "label", desc: "控件的标签", code: "label"}
                        ]
                        
                        Button {
                            width: parent.width - 10
                            height: 35
                            text: modelData.name + " - " + modelData.desc
                            font.pixelSize: 11
                            
                            onClicked: {
                                insertFunction(modelData.code);
                            }
                        }
                    }

                    // 表单API函数
                    Rectangle {
                        width: parent.width
                        height: 30
                        color: "#fff3cd"
                        radius: 4
                        
                        Text {
                            anchors.centerIn: parent
                            text: "表单API函数"
                            font.bold: true
                            color: "#856404"
                        }
                    }

                    Repeater {
                        model: [
                            {name: "showMessage", desc: "显示消息提示", code: "showMessage('提示信息', 'info'); // 类型: info, error, warning, success"},
                            {name: "validateForm", desc: "验证整个表单", code: "if (validateForm()) {\n    showMessage('表单验证通过', 'success');\n}"},
                            {name: "getControlValue", desc: "获取控件值", code: "var otherValue = getControlValue('控件key');\nconsole.log('获取到的值:', otherValue);"}
                        ]
                        
                        Button {
                            width: parent.width
                            height: 40
                            text: modelData.name + " - " + modelData.desc
                            
                            onClicked: {
                                insertFunction(modelData.code);
                            }
                        }
                    }

                    // 验证函数
                    Rectangle {
                        width: parent.width
                        height: 30
                        color: "#d4edda"
                        radius: 4
                        
                        Text {
                            anchors.centerIn: parent
                            text: "验证函数"
                            font.bold: true
                            color: "#155724"
                        }
                    }

                    Repeater {
                        model: [
                            {name: "validateEmail", desc: "验证邮箱格式", code: "if (!validateEmail(value)) {\n    return false; // 自动显示错误消息\n}"},
                            {name: "validatePhone", desc: "验证手机号", code: "if (!validatePhone(value)) {\n    return false; // 自动显示错误消息\n}"},
                            {name: "validateNumber", desc: "验证数字范围", code: "if (!validateNumber(value, 0, 100)) {\n    return false; // 验证0-100范围\n}"},
                            {name: "validateRegex", desc: "正则验证", code: "if (!validateRegex(value, '^\\\\d{6}$', '请输入6位数字')) {\n    return false;\n}"}
                        ]
                        
                        Button {
                            width: parent.width
                            height: 40
                            text: modelData.name + " - " + modelData.desc
                            
                            onClicked: {
                                insertFunction(modelData.code);
                            }
                        }
                    }

                    // 控件操作函数
                    Rectangle {
                        width: parent.width
                        height: 30
                        color: "#e2e3e5"
                        radius: 4
                        
                        Text {
                            anchors.centerIn: parent
                            text: "控件操作函数"
                            font.bold: true
                            color: "#383d41"
                        }
                    }

                    Repeater {
                        model: [
                            {name: "setControlValue", desc: "设置控件值", code: "setControlValue('控件key', '新值');"},
                            {name: "setControlText", desc: "设置控件文本", code: "setControlText('控件key', '新文本');"},
                            {name: "enableControl", desc: "启用控件", code: "enableControl('控件key');"},
                            {name: "disableControl", desc: "禁用控件", code: "disableControl('控件key');"},
                            {name: "focusControl", desc: "聚焦控件", code: "focusControl('控件key');"}
                        ]
                        
                        Button {
                            width: parent.width
                            height: 40
                            text: modelData.name + " - " + modelData.desc
                            
                            onClicked: {
                                insertFunction(modelData.code);
                            }
                        }
                    }

                    // 控件样式函数
                    Rectangle {
                        width: parent.width
                        height: 30
                        color: "#d1ecf1"
                        radius: 4
                        
                        Text {
                            anchors.centerIn: parent
                            text: "控件样式函数"
                            font.bold: true
                            color: "#0c5460"
                        }
                    }

                    Repeater {
                        model: [
                            {name: "setControlBackground", desc: "设置背景色", code: "setControlBackground('控件key', '#ff0000');"},
                            {name: "setControlColor", desc: "设置文字颜色", code: "setControlColor('控件key', '#ffffff');"},
                            {name: "hideControl", desc: "隐藏控件", code: "hideControl('控件key');"},
                            {name: "showControl", desc: "显示控件", code: "showControl('控件key');"},
                            {name: "resetControl", desc: "重置控件", code: "resetControl('控件key');"}
                        ]
                        
                        Button {
                            width: parent.width
                            height: 40
                            text: modelData.name + " - " + modelData.desc
                            
                            onClicked: {
                                insertFunction(modelData.code);
                            }
                        }
                    }

                    // 高级验证函数
                    Rectangle {
                        width: parent.width
                        height: 30
                        color: "#ffeaa7"
                        radius: 4
                        
                        Text {
                            anchors.centerIn: parent
                            text: "高级验证函数"
                            font.bold: true
                            color: "#6c5ce7"
                        }
                    }

                    Repeater {
                        model: [
                            {name: "validateIdCard", desc: "验证身份证", code: "if (!validateIdCard(value)) {\n    return false; // 自动显示错误消息\n}"},
                            {name: "validateChinese", desc: "验证中文", code: "if (!validateChinese(value)) {\n    return false; // 自动显示错误消息\n}"}
                        ]
                        
                        Button {
                            width: parent.width
                            height: 40
                            text: modelData.name + " - " + modelData.desc
                            
                            onClicked: {
                                insertFunction(modelData.code);
                            }
                        }
                    }
                }
            }
        }

        // 右侧：代码编辑区域
        GroupBox {
            title: "代码编辑区域"
            Layout.fillWidth: true
            Layout.fillHeight: true

            Column {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 15

                Text {
                    width: parent.width
                    text: getEventDescription()
                    wrapMode: Text.WordWrap
                    font.pixelSize: 14
                }

                Rectangle {
                    width: parent.width
                    height: 350
                    color: "#f8f9fa"
                    border.color: "#dee2e6"
                    border.width: 1
                    radius: 4

                    ScrollView {
                        anchors.fill: parent
                        anchors.margins: 10
                        clip: true

                        TextArea {
                            id: codeEditArea
                            text: currentEventCode
                            wrapMode: TextArea.Wrap
                            font.family: "Consolas, Monaco, monospace"
                            font.pixelSize: 12
                            selectByMouse: true
                            placeholderText: "在此编写JavaScript代码，点击左侧函数按钮可在光标处插入函数..."
                            
                            onTextChanged: {
                                currentEventCode = text;
                            }
                        }
                    }
                }

                RowLayout {
                    width: parent.width
                    spacing: 10
                    
                    Button {
                        text: "保存并关闭"
                        onClicked: {
                            functionSaved(currentEventType, currentEventCode);
                            functionHelpDialog.close();
                        }
                    }
                    
                    Button {
                        text: "清空代码"
                        onClicked: {
                            codeEditArea.text = "";
                        }
                    }
                    
                    Item {
                        Layout.fillWidth: true
                    }
                    
                    Button {
                        text: "取消"
                        onClicked: {
                            functionHelpDialog.close();
                        }
                    }
                }
            }
        }
    }

    standardButtons: Dialog.Close

    function insertFunction(code) {
        var cursorPosition = codeEditArea.cursorPosition;
        var currentText = codeEditArea.text;
        var beforeCursor = currentText.substring(0, cursorPosition);
        var afterCursor = currentText.substring(cursorPosition);
        
        // 在光标处插入代码
        var newText = beforeCursor + code + afterCursor;
        codeEditArea.text = newText;
        
        // 将光标移动到插入代码的末尾
        codeEditArea.cursorPosition = cursorPosition + code.length;
        codeEditArea.focus = true;
    }

    function getEventDescription() {
        switch (currentEventType) {
        case "focusLost":
            return "焦点丢失事件在控件失去焦点时触发。常用于验证输入内容、保存数据等操作。";
        case "textChanged":
            return "文本变化事件在文本输入控件的内容发生变化时触发。可用于实时验证、格式化等。";
        case "valueChanged":
            return "数值变化事件在数字或选择控件的值发生变化时触发。";
        case "clicked":
            return "按钮点击事件在按钮被点击时触发。用于执行特定的操作或功能。";
        default:
            return "选择左侧的函数来查看详细说明和示例代码。";
        }
    }

    function showFocusLostHelp(eventCode) {
        title = "编写焦点丢失事件函数";
        currentEventType = "focusLost";
        currentEventCode = eventCode || "";
        open();
    }

    function showChangeEventHelp(controlType, eventCode) {
        title = "编写变化事件函数";
        
        switch (controlType) {
        case "text":
        case "password":
            currentEventType = "textChanged";
            break;
        case "number":
        case "dropdown":
            currentEventType = "valueChanged";
            break;
        case "button":
            currentEventType = "clicked";
            break;
        default:
            currentEventType = "valueChanged";
        }
        
        currentEventCode = eventCode || "";
        open();
    }
}