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
                            {name: "formAPI", desc: "表单API对象", code: "formAPI.getAllValues()"},
                            {name: "formId", desc: "表单ID", code: "formId"},
                            {name: "formData", desc: "表单数据(JSON)", code: "formData"},
                            {name: "value", desc: "当前控件的值", code: "value"},
                            {name: "controlsMap", desc: "所有控件映射表", code: "controlsMap['控件key']"}
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
                            {name: "validateAll", desc: "验证所有控件", code: "var result = validateAll();\nif (result.valid) {\n    showMessage('验证通过', 'success');\n}"},
                            {name: "getAllValues", desc: "获取所有控件值", code: "var allData = getAllValues();\nconsole.log('表单数据:', JSON.stringify(allData));"},
                            {name: "getControlValue", desc: "获取控件值", code: "var otherValue = getControlValue('控件key');\nconsole.log('获取到的值:', otherValue);"},
                            {name: "isControlValid", desc: "检查单个控件是否验证通过", code: "if (formAPI.isControlValid('name')) {\n    console.log('姓名验证通过');\n}"},
                            {name: "areControlsValid", desc: "检查多个控件是否都验证通过", code: "// 检查姓名、年龄、邮箱是否都验证通过\nif (formAPI.areControlsValid(['name', 'age', 'email'])) {\n    // 所有字段都验证通过，可以执行数据库查询\n    var result = MySqlHelper.select('users', ['*'], 'name=\"' + getControlValue('name') + '\"');\n    console.log('查询结果:', JSON.stringify(result));\n} else {\n    showMessage('请先完成所有必填项', 'warning');\n}"},
                            {name: "resetForm", desc: "重置整个表单", code: "resetForm();\nshowMessage('表单已重置', 'info');"}
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

                    // 验证函数（仅在验证函数编辑时显示）
                    Rectangle {
                        width: parent.width
                        height: 30
                        color: "#d4edda"
                        radius: 4
                        visible: false  // 默认不显示，只在验证函数编辑时显示
                        
                        Text {
                            anchors.centerIn: parent
                            text: "验证函数（用于自定义验证）"
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
                            visible: false  // 默认不显示，只在验证函数编辑时显示
                            
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



                    // 数据库操作
                    Rectangle {
                        width: parent.width
                        height: 30
                        color: "#f8d7da"
                        radius: 4
                        
                        Text {
                            anchors.centerIn: parent
                            text: "数据库操作"
                            font.bold: true
                            color: "#721c24"
                        }
                    }

                    Repeater {
                        model: [
                            {name: "提交到数据库", desc: "保存表单数据", code: "// 提交表单数据\nvar submitData = {\n    dynamicId: formId,\n    data: JSON.stringify(formData)\n};\ntry {\n    MySqlHelper.insert('dynamicData', submitData);\n    showMessage('提交成功！', 'success');\n    resetForm();\n} catch(e) {\n    showMessage('提交失败: ' + e, 'error');\n    console.error('Insert error:', e);\n}"},
                            {name: "提交到指定表", desc: "保存到自定义表", code: "// 提交到指定数据库表\nvar data = {\n    username: getControlValue('username'),\n    email: getControlValue('email'),\n    dynamicId: formId\n};\ntry {\n    MySqlHelper.insert('users', data);\n    showMessage('保存成功！', 'success');\n    resetForm();\n} catch(e) {\n    showMessage('保存失败: ' + e, 'error');\n    console.error('Insert error:', e);\n}"},
                            {name: "查询数据", desc: "从数据库查询", code: "// 查询数据\nvar result = MySqlHelper.select('tableName', ['column1', 'column2'], 'id=1');\nconsole.log('查询结果:', JSON.stringify(result));"}
                        ]
                        
                        Button {
                            width: parent.width
                            height: 50
                            text: modelData.name + " - " + modelData.desc
                            
                            onClicked: {
                                insertFunction(modelData.code);
                            }
                        }
                    }

                    // 完整示例
                    Rectangle {
                        width: parent.width
                        height: 30
                        color: "#d1ecf1"
                        radius: 4
                        
                        Text {
                            anchors.centerIn: parent
                            text: "完整示例"
                            font.bold: true
                            color: "#0c5460"
                        }
                    }

                    Repeater {
                        model: [
                            {name: "提交按钮完整示例", desc: "验证+提交", code: "// 提交按钮完整示例\n// 1. 验证所有字段\nvar validation = validateAll();\nif (!validation.valid) {\n    return; // 验证失败，已自动提示\n}\n\n// 2. 准备提交数据（保存到dynamicData表）\nvar submitData = {\n    dynamicId: formId,\n    data: JSON.stringify(formData)\n};\n\n// 3. 提交到数据库\ntry {\n    MySqlHelper.insert('dynamicData', submitData);\n    showMessage('提交成功！', 'success');\n    resetForm(); // 重置表单\n} catch(e) {\n    showMessage('提交失败: ' + e, 'error');\n    console.error('Insert error:', e);\n}"}
                        ]
                        
                        Button {
                            width: parent.width
                            height: 60
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
            return "按钮点击事件在按钮被点击时触发。\n\n如果按钮设置为【提交】类型，点击时会自动执行所有验证，验证通过后才执行此函数。\n如果按钮设置为【重置】类型，点击时会自动清空所有表单控件的值。\n\n可用变量：formId（表单ID）、formData（表单数据JSON）、getAllValues()（获取所有值）";
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

    function showClickedEventHelp(eventCode) {
        title = "编写按钮点击事件函数";
        currentEventType = "clicked";
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
        default:
            currentEventType = "valueChanged";
        }
        
        currentEventCode = eventCode || "";
        open();
    }
}