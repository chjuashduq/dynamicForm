import QtQuick 6.5
import QtQuick.Controls 6.5
import QtQuick.Layouts 1.4

/**
 * 函数编写对话框（重构版）
 * 提供函数提示和代码编辑功能
 * API 函数已重新分类和去重
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

                    // ========== 1. 基础变量 ==========
                    Rectangle {
                        width: parent.width
                        height: 30
                        color: "#e3f2fd"
                        radius: 4
                        
                        Text {
                            anchors.centerIn: parent
                            text: "1. 基础变量"
                            font.bold: true
                            color: "#1976d2"
                        }
                    }


                    Repeater {
                        model: [
                            {name: "self", desc: "当前控件对象", code: "self.value"},
                            {name: "value", desc: "当前控件的值", code: "value"},
                            {name: "formId", desc: "表单ID", code: "formId"},
                            {name: "formData", desc: "表单数据(JSON)", code: "formData"},
                            {name: "isEditMode", desc: "是否为编辑模式", code: "if (isEditMode) { /* 编辑 */ } else { /* 新增 */ }"},
                            {name: "dataRecordId", desc: "数据记录ID(编辑)", code: "dataRecordId"}
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

                    // ========== 2. 获取控件值 ==========
                    Rectangle {
                        width: parent.width
                        height: 30
                        color: "#fff3cd"
                        radius: 4
                        
                        Text {
                            anchors.centerIn: parent
                            text: "2. 获取控件值"
                            font.bold: true
                            color: "#856404"
                        }
                    }

                    Repeater {
                        model: [
                            {name: "getAllValues", desc: "获取所有控件值", code: "var allData = getAllValues();\nconsole.log('表单数据:', JSON.stringify(allData));"},
                            {name: "getControlValue", desc: "获取指定控件值", code: "var username = getControlValue('username');\nconsole.log('用户名:', username);"}
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

                    // ========== 3. 设置控件值 ==========
                    Rectangle {
                        width: parent.width
                        height: 30
                        color: "#d4edda"
                        radius: 4
                        
                        Text {
                            anchors.centerIn: parent
                            text: "3. 设置控件值"
                            font.bold: true
                            color: "#155724"
                        }
                    }

                    Repeater {
                        model: [
                            {name: "setControlValue", desc: "设置控件值", code: "setControlValue('age', 25);"},
                            {name: "resetControl", desc: "重置单个控件", code: "resetControl('username');"},
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

                    // ========== 4. 控件状态控制 ==========
                    Rectangle {
                        width: parent.width
                        height: 30
                        color: "#e2e3e5"
                        radius: 4
                        
                        Text {
                            anchors.centerIn: parent
                            text: "4. 控件状态控制"
                            font.bold: true
                            color: "#383d41"
                        }
                    }

                    Repeater {
                        model: [
                            {name: "enableControl", desc: "启用控件", code: "enableControl('submit_btn');"},
                            {name: "disableControl", desc: "禁用控件", code: "disableControl('submit_btn');"},
                            {name: "showControl", desc: "显示控件", code: "showControl('email');"},
                            {name: "hideControl", desc: "隐藏控件", code: "hideControl('email');"},
                            {name: "focusControl", desc: "聚焦控件", code: "focusControl('username');"}
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


                    // ========== 5. 验证函数 ==========
                    Rectangle {
                        width: parent.width
                        height: 30
                        color: "#d1ecf1"
                        radius: 4
                        
                        Text {
                            anchors.centerIn: parent
                            text: "5. 验证函数"
                            font.bold: true
                            color: "#0c5460"
                        }
                    }

                    Repeater {
                        model: [
                            {name: "validateAll", desc: "验证所有控件", code: "var result = validateAll();\nif (result.valid) {\n    showMessage('验证通过', 'success');\n}"},
                            {name: "isControlValid", desc: "检查单个控件验证状态", code: "if (formAPI.isControlValid('email')) {\n    console.log('邮箱验证通过');\n}"},
                            {name: "areControlsValid", desc: "检查多个控件验证状态", code: "if (formAPI.areControlsValid(['name', 'age', 'email'])) {\n    showMessage('所有必填项验证通过', 'success');\n} else {\n    showMessage('请先完成所有必填项', 'warning');\n}"},
                            {name: "validateEmail", desc: "验证邮箱格式", code: "if (!validateEmail(value)) {\n    return false;\n}"},
                            {name: "validatePhone", desc: "验证手机号", code: "if (!validatePhone(value)) {\n    return false;\n}"},
                            {name: "validateIdCard", desc: "验证身份证号", code: "if (!validateIdCard(value)) {\n    return false;\n}"},
                            {name: "validateNumber", desc: "验证数字范围", code: "if (!validateNumber(value, 0, 100)) {\n    return false;\n}"},
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

                    // ========== 6. 消息提示 ==========
                    Rectangle {
                        width: parent.width
                        height: 30
                        color: "#f8d7da"
                        radius: 4
                        
                        Text {
                            anchors.centerIn: parent
                            text: "6. 消息提示"
                            font.bold: true
                            color: "#721c24"
                        }
                    }

                    Repeater {
                        model: [
                            {name: "showMessage", desc: "显示消息", code: "showMessage('操作成功', 'success');\n// 类型: info, success, warning, error"}
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

                    // ========== 7. 临时存储 ==========
                    Rectangle {
                        width: parent.width
                        height: 30
                        color: "#d1ecf1"
                        radius: 4
                        
                        Text {
                            anchors.centerIn: parent
                            text: "7. 临时存储"
                            font.bold: true
                            color: "#0c5460"
                        }
                    }

                    Repeater {
                        model: [
                            {name: "setTempValue", desc: "设置临时存储值", code: "// 在一个事件中存储数据\nsetTempValue('selectedCountry', getControlValue('country'));\nsetTempValue('userChoice', 'option1');"},
                            {name: "getTempValue", desc: "获取临时存储值", code: "// 在另一个事件中获取之前存储的数据\nvar country = getTempValue('selectedCountry');\nif (country === '00') {\n    showMessage('您选择了中国', 'info');\n}"},
                            {name: "clearTempStorage", desc: "清除临时存储", code: "// 清除单个键\nclearTempStorage('selectedCountry');\n\n// 清除所有临时存储\nclearTempStorage();"}
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

                    // ========== 8. 工具函数 ==========
                    Rectangle {
                        width: parent.width
                        height: 30
                        color: "#cfe2ff"
                        radius: 4
                        
                        Text {
                            anchors.centerIn: parent
                            text: "8. 工具函数"
                            font.bold: true
                            color: "#084298"
                        }
                    }

                    Repeater {
                        model: [
                            {name: "formatDateTime", desc: "格式化日期时间", code: "var now = formatDateTime();\n// 结果: '2025-11-18 13:31:33'\nvar customDate = formatDateTime(new Date('2025-01-01'));\n// 结果: '2025-01-01 00:00:00'"}
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


                    // ========== 9. 数据库操作 ==========
                    Rectangle {
                        width: parent.width
                        height: 30
                        color: "#fff3cd"
                        radius: 4
                        
                        Text {
                            anchors.centerIn: parent
                            text: "9. 数据库操作"
                            font.bold: true
                            color: "#856404"
                        }
                    }

                    Repeater {
                        model: [
                            {name: "INSERT - 插入数据", desc: "新增记录", code: "var data = {\n    username: getControlValue('username'),\n    email: getControlValue('email'),\n    createTime: formatDateTime()\n};\ntry {\n    var result = MySqlHelper.insert('users', data);\n    if (result) {\n        showMessage('提交成功！', 'success');\n        resetForm();\n    } else {\n        showMessage('提交失败', 'error');\n    }\n} catch(e) {\n    showMessage('提交失败: ' + e, 'error');\n}"},
                            {name: "SELECT - 查询数据", desc: "查询记录", code: "try {\n    var result = MySqlHelper.select('users', ['*'], 'username=\"张三\"');\n    console.log('查询结果:', JSON.stringify(result));\n    if (result.length > 0) {\n        showMessage('找到 ' + result.length + ' 条记录', 'success');\n    }\n} catch(e) {\n    showMessage('查询失败: ' + e, 'error');\n}"},
                            {name: "UPDATE - 更新数据", desc: "修改记录", code: "var data = {\n    email: getControlValue('email'),\n    age: getControlValue('age')\n};\nvar where = 'id=' + dataRecordId;\ntry {\n    MySqlHelper.update('users', data, where);\n    showMessage('更新成功！', 'success');\n} catch(e) {\n    showMessage('更新失败: ' + e, 'error');\n}"},
                            {name: "DELETE - 删除数据", desc: "删除记录", code: "var userId = getControlValue('user_id');\nvar where = 'id=' + userId;\ntry {\n    MySqlHelper.remove('users', where);\n    showMessage('删除成功！', 'success');\n} catch(e) {\n    showMessage('删除失败: ' + e, 'error');\n}"}
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

                    // ========== 10. 完整示例 ==========
                    Rectangle {
                        width: parent.width
                        height: 30
                        color: "#d1ecf1"
                        radius: 4
                        
                        Text {
                            anchors.centerIn: parent
                            text: "10. 完整示例"
                            font.bold: true
                            color: "#0c5460"
                        }
                    }

                    Repeater {
                        model: [
                            {name: "提交按钮完整示例", desc: "验证+提交", code: "// 1. 验证所有字段\nvar validation = validateAll();\nif (!validation.valid) {\n    return;\n}\n\n// 2. 准备提交数据\nvar submitData = {\n    dynamicId: formId,\n    data: JSON.stringify(formData),\n    createTime: formatDateTime()\n};\n\n// 3. 提交到数据库\ntry {\n    if (isEditMode) {\n        // 编辑模式：UPDATE\n        var where = 'id=' + dataRecordId;\n        var result = MySqlHelper.update('dynamicData', submitData, where);\n        if (result) {\n            showMessage('更新成功！', 'success');\n        }\n    } else {\n        // 新增模式：INSERT\n        var result = MySqlHelper.insert('dynamicData', submitData);\n        if (result) {\n            showMessage('提交成功！', 'success');\n            resetForm();\n        }\n    }\n} catch(e) {\n    showMessage('操作失败: ' + e, 'error');\n}"},
                            {name: "查询并填充表单", desc: "查询+自动填充", code: "// 根据用户名查询并填充表单\nvar username = getControlValue('search_username');\n\nif (!username) {\n    showMessage('请输入用户名', 'warning');\n    return;\n}\n\ntry {\n    var result = MySqlHelper.select('users', ['*'], 'username=\"' + username + '\"');\n    \n    if (result.length > 0) {\n        var user = result[0];\n        \n        // 自动填充表单\n        setControlValue('email', user.email);\n        setControlValue('age', user.age);\n        setControlValue('gender', user.gender);\n        \n        showMessage('查询成功', 'success');\n    } else {\n        showMessage('未找到该用户', 'warning');\n    }\n} catch(e) {\n    showMessage('查询失败: ' + e, 'error');\n}"}
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

            ScrollView {
                anchors.fill: parent
                anchors.margins: 10
                clip: true

                Column {
                    width: parent.width
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
