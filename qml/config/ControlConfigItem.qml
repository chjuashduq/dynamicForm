import QtQuick 6.5
import QtQuick.Controls 6.5
import QtQuick.Layouts 1.4

/**
 * 单个控件配置项
 * 支持label/value格式的options配置
 */
Rectangle {
    id: configItem
    
    property var controlConfig: ({})
    property int controlIndex: 0
    
    signal configChanged(var newConfig)
    signal removeRequested()
    
    height: contentLayout.height + 20
    color: "#ffffff"
    border.color: "#dee2e6"
    border.width: 1
    radius: 8
    
    ColumnLayout {
        id: contentLayout
        anchors.fill: parent
        anchors.margins: 15
        spacing: 15
        
        // 标题栏
        RowLayout {
            Layout.fillWidth: true
            
            Text {
                text: getControlTitle()
                font.pixelSize: 16
                font.bold: true
                color: "#495057"
                Layout.fillWidth: true
            }
            
            Button {
                text: "🗑️ 删除"
                onClicked: removeRequested()
                background: Rectangle {
                    color: parent.pressed ? "#721c24" : (parent.hovered ? "#bd2130" : "#dc3545")
                    radius: 4
                }
            }
        }
        
        // 基本属性配置
        Rectangle {
            Layout.fillWidth: true
            height: basicPropsLayout.height + 20
            color: "#f8f9fa"
            border.color: "#e9ecef"
            border.width: 1
            radius: 4
            
            GridLayout {
                id: basicPropsLayout
                anchors.fill: parent
                anchors.margins: 10
                columns: 4
                columnSpacing: 10
                rowSpacing: 8
                
                Text { text: "标识:" }
                TextField {
                    id: keyField
                    text: controlConfig.key || ""
                    onTextChanged: updateConfig()
                    Layout.fillWidth: true
                }
                
                Text { text: "标签:" }
                TextField {
                    id: labelField
                    text: controlConfig.label || ""
                    onTextChanged: updateConfig()
                    Layout.fillWidth: true
                }
                
                Text { text: "行:" }
                SpinBox {
                    id: rowSpinBox
                    from: 0
                    to: 20
                    value: controlConfig.row || 0
                    onValueChanged: updateConfig()
                }
                
                Text { text: "列:" }
                SpinBox {
                    id: columnSpinBox
                    from: 0
                    to: 10
                    value: controlConfig.column || 0
                    onValueChanged: updateConfig()
                }
                
                Text { text: "行跨度:" }
                SpinBox {
                    id: rowSpanSpinBox
                    from: 1
                    to: 10
                    value: controlConfig.rowSpan || 1
                    onValueChanged: updateConfig()
                }
                
                Text { text: "列跨度:" }
                SpinBox {
                    id: colSpanSpinBox
                    from: 1
                    to: 10
                    value: controlConfig.colSpan || 1
                    onValueChanged: updateConfig()
                }
                
                Text { text: "标签比例:" }
                RowLayout {
                    SpinBox {
                        id: labelRatioSpinBox
                        from: 0
                        to: 100
                        value: (controlConfig.labelRatio || 0.3) * 100
                        onValueChanged: updateConfig()
                    }
                    Text { text: "%" }
                }
            }
        }
        
        // 类型特定属性
        Rectangle {
            Layout.fillWidth: true
            height: typeSpecificLayout.height + 20
            color: "#f8f9fa"
            border.color: "#e9ecef"
            border.width: 1
            radius: 4
            visible: hasTypeSpecificProps()
            
            ColumnLayout {
                id: typeSpecificLayout
                anchors.fill: parent
                anchors.margins: 10
                spacing: 8
                
                Text {
                    text: "类型特定属性"
                    font.bold: true
                    color: "#495057"
                }
                
                // 文本框属性
                ColumnLayout {
                    Layout.fillWidth: true
                    visible: controlConfig.type === "text"
                    spacing: 5
                    
                    Text { text: "占位符文本:" }
                    TextField {
                        id: placeholderField
                        text: controlConfig.placeholder || ""
                        onTextChanged: updateConfig()
                        Layout.fillWidth: true
                    }
                    
                    Text { text: "默认值:" }
                    TextField {
                        id: textValueField
                        text: controlConfig.value || ""
                        onTextChanged: updateConfig()
                        Layout.fillWidth: true
                    }
                }
                
                // 数字框属性
                ColumnLayout {
                    Layout.fillWidth: true
                    visible: controlConfig.type === "number"
                    spacing: 5
                    
                    Text { text: "默认数值:" }
                    SpinBox {
                        id: numberValueSpinBox
                        from: -999999
                        to: 999999
                        value: controlConfig.value || 0
                        onValueChanged: updateConfig()
                    }
                }
                
                // 下拉框属性
                ColumnLayout {
                    Layout.fillWidth: true
                    visible: controlConfig.type === "dropdown"
                    spacing: 5
                    
                    Text { text: "选项列表 (格式: 显示文本|值，每行一个):" }
                    ScrollView {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 80
                        
                        TextArea {
                            id: optionsArea
                            text: controlConfig.options ? formatOptionsForEdit(controlConfig.options) : ""
                            onTextChanged: updateConfig()
                            wrapMode: TextArea.Wrap
                            placeholderText: "例如:\\n选项1|option1\\n选项2|option2"
                        }
                    }
                }
                
                // 复选框属性
                ColumnLayout {
                    Layout.fillWidth: true
                    visible: controlConfig.type === "checkbox"
                    spacing: 5
                    
                    Text { text: "选项列表 (格式: 显示文本|值，每行一个):" }
                    ScrollView {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 80
                        
                        TextArea {
                            id: checkboxOptionsArea
                            text: controlConfig.options ? formatOptionsForEdit(controlConfig.options) : ""
                            onTextChanged: updateConfig()
                            wrapMode: TextArea.Wrap
                            placeholderText: "例如:\\n选项1|option1\\n选项2|option2"
                        }
                    }
                    
                    Row {
                        spacing: 10
                        Text { text: "排列方向:" }
                        ComboBox {
                            id: directionCombo
                            model: ["horizontal", "vertical"]
                            currentIndex: (controlConfig.direction === "vertical") ? 1 : 0
                            onCurrentTextChanged: updateConfig()
                        }
                    }
                }
                
                // 单选框属性
                ColumnLayout {
                    Layout.fillWidth: true
                    visible: controlConfig.type === "radio"
                    spacing: 5
                    
                    Text { text: "选项列表 (格式: 显示文本|值，每行一个):" }
                    ScrollView {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 80
                        
                        TextArea {
                            id: radioOptionsArea
                            text: controlConfig.options ? formatOptionsForEdit(controlConfig.options) : ""
                            onTextChanged: updateConfig()
                            wrapMode: TextArea.Wrap
                            placeholderText: "例如:\\n选项1|option1\\n选项2|option2"
                        }
                    }
                }
                
                // 按钮属性
                ColumnLayout {
                    Layout.fillWidth: true
                    visible: controlConfig.type === "button"
                    spacing: 5
                    
                    Text { text: "按钮文本:" }
                    TextField {
                        id: buttonTextField
                        text: controlConfig.text || ""
                        onTextChanged: updateConfig()
                        Layout.fillWidth: true
                    }
                }
            }
        }
        
        // 事件配置
        Rectangle {
            Layout.fillWidth: true
            height: eventsLayout.height + 20
            color: "#fff3cd"
            border.color: "#ffeaa7"
            border.width: 1
            radius: 4
            
            ColumnLayout {
                id: eventsLayout
                anchors.fill: parent
                anchors.margins: 10
                spacing: 8
                
                Text {
                    text: "⚡ 事件配置"
                    font.bold: true
                    color: "#856404"
                }
                
                // 焦点丢失事件
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 5
                    
                    RowLayout {
                        Layout.fillWidth: true
                        Text { 
                            text: "焦点丢失事件:"
                            color: "#856404"
                        }
                        Button {
                            text: "💡 函数提示"
                            onClicked: focusLostHelpDialog.open()
                        }
                    }
                    
                    ScrollView {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 60
                        
                        TextArea {
                            id: focusLostArea
                            text: (controlConfig.events && controlConfig.events.onFocusLost) || ""
                            onTextChanged: updateConfig()
                            wrapMode: TextArea.Wrap
                            placeholderText: "输入JavaScript代码..."
                        }
                    }
                }
                
                // 变化事件
                ColumnLayout {
                    Layout.fillWidth: true
                    visible: controlConfig.type === "text" || controlConfig.type === "number"
                    spacing: 5
                    
                    RowLayout {
                        Layout.fillWidth: true
                        Text { 
                            text: controlConfig.type === "text" ? "文本变化事件:" : "数值变化事件:"
                            color: "#856404"
                        }
                        Button {
                            text: "💡 函数提示"
                            onClicked: changeEventHelpDialog.open()
                        }
                    }
                    
                    ScrollView {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 60
                        
                        TextArea {
                            id: changeArea
                            text: {
                                if (!controlConfig.events) return ""
                                return controlConfig.events.onTextChanged || controlConfig.events.onValueChanged || ""
                            }
                            onTextChanged: updateConfig()
                            wrapMode: TextArea.Wrap
                            placeholderText: "输入JavaScript代码..."
                        }
                    }
                }
                
                // 点击事件
                ColumnLayout {
                    Layout.fillWidth: true
                    visible: controlConfig.type === "button"
                    spacing: 5
                    
                    RowLayout {
                        Layout.fillWidth: true
                        Text { 
                            text: "点击事件:"
                            color: "#856404"
                        }
                        Button {
                            text: "💡 函数提示"
                            onClicked: clickEventHelpDialog.open()
                        }
                    }
                    
                    ScrollView {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 60
                        
                        TextArea {
                            id: clickArea
                            text: (controlConfig.events && controlConfig.events.onClicked) || ""
                            onTextChanged: updateConfig()
                            wrapMode: TextArea.Wrap
                            placeholderText: "输入JavaScript代码..."
                        }
                    }
                }
            }
        }
    }
    
    // 获取控件标题
    function getControlTitle() {
        var typeIcon = ""
        switch(controlConfig.type) {
            case "text": typeIcon = "📝"; break
            case "number": typeIcon = "🔢"; break
            case "dropdown": typeIcon = "📋"; break
            case "checkbox": typeIcon = "☑️"; break
            case "radio": typeIcon = "🔘"; break
            case "button": typeIcon = "🎯"; break
            default: typeIcon = "❓"
        }
        
        var label = controlConfig.label || controlConfig.key || "未命名控件"
        return typeIcon + " " + label + " (" + (controlConfig.type || "unknown") + ")"
    }
    
    // 检查是否有类型特定属性
    function hasTypeSpecificProps() {
        return controlConfig.type === "text" || 
               controlConfig.type === "number" || 
               controlConfig.type === "dropdown" || 
               controlConfig.type === "checkbox" ||
               controlConfig.type === "radio" ||
               controlConfig.type === "button"
    }
    
    // 格式化options用于编辑
    function formatOptionsForEdit(options) {
        if (!options || !Array.isArray(options)) return ""
        
        return options.map(function(option) {
            if (typeof option === "string") {
                return option + "|" + option
            } else if (option && option.label && option.value) {
                return option.label + "|" + option.value
            }
            return ""
        }).join("\\n")
    }
    
    // 解析编辑后的options
    function parseOptionsFromEdit(text) {
        if (!text || text.trim() === "") return []
        
        var lines = text.split("\\n").filter(function(line) {
            return line.trim() !== ""
        })
        
        return lines.map(function(line) {
            var parts = line.split("|")
            if (parts.length >= 2) {
                return {
                    "label": parts[0].trim(),
                    "value": parts[1].trim()
                }
            } else {
                // 如果没有|分隔符，label和value相同
                var trimmed = parts[0].trim()
                return {
                    "label": trimmed,
                    "value": trimmed
                }
            }
        })
    }
    
    // 更新配置
    function updateConfig() {
        var newConfig = {
            "type": controlConfig.type,
            "key": keyField.text,
            "label": labelField.text,
            "row": rowSpinBox.value,
            "column": columnSpinBox.value,
            "rowSpan": rowSpanSpinBox.value,
            "colSpan": colSpanSpinBox.value,
            "labelRatio": labelRatioSpinBox.value / 100.0
        }
        
        // 添加类型特定属性
        switch(controlConfig.type) {
            case "text":
                newConfig.placeholder = placeholderField.text
                newConfig.value = textValueField.text
                break
            case "number":
                newConfig.value = numberValueSpinBox.value
                break
            case "dropdown":
                var options = parseOptionsFromEdit(optionsArea.text)
                newConfig.options = options
                newConfig.value = options.length > 0 ? options[0].value : ""
                break
            case "checkbox":
                var checkboxOptions = parseOptionsFromEdit(checkboxOptionsArea.text)
                newConfig.options = checkboxOptions
                newConfig.value = checkboxOptions.length > 0 ? [checkboxOptions[0].value] : []
                newConfig.direction = directionCombo.currentText
                break
            case "radio":
                var radioOptions = parseOptionsFromEdit(radioOptionsArea.text)
                newConfig.options = radioOptions
                newConfig.value = radioOptions.length > 0 ? radioOptions[0].value : ""
                break
            case "button":
                newConfig.text = buttonTextField.text
                break
        }
        
        // 添加事件配置
        var events = {}
        if (focusLostArea.text.trim() !== "") {
            events.onFocusLost = focusLostArea.text
        }
        
        if (controlConfig.type === "text" && changeArea.text.trim() !== "") {
            events.onTextChanged = changeArea.text
        } else if (controlConfig.type === "number" && changeArea.text.trim() !== "") {
            events.onValueChanged = changeArea.text
        }
        
        if (controlConfig.type === "button" && clickArea.text.trim() !== "") {
            events.onClicked = clickArea.text
        }
        
        if (Object.keys(events).length > 0) {
            newConfig.events = events
        }
        
        configChanged(newConfig)
    }
    
    // 焦点丢失事件帮助对话框
    Dialog {
        id: focusLostHelpDialog
        title: "焦点丢失事件 - 可用函数"
        width: 600
        height: 500
        anchors.centerIn: parent
        modal: true
        
        ScrollView {
            anchors.fill: parent
            
            Column {
                width: parent.width
                spacing: 15
                
                Text {
                    text: "📋 可用的API函数："
                    font.bold: true
                    font.pixelSize: 16
                    color: "#2c3e50"
                }
                
                Rectangle {
                    width: parent.width
                    height: apiText.height + 20
                    color: "#f8f9fa"
                    border.color: "#dee2e6"
                    border.width: 1
                    radius: 4
                    
                    Text {
                        id: apiText
                        anchors.fill: parent
                        anchors.margins: 10
                        text: `🔧 控件操作函数：
• getControlValue('controlKey') - 获取控件值
• setControlValue('controlKey', value) - 设置控件值
• enableControl('controlKey') - 启用控件
• disableControl('controlKey') - 禁用控件
• showControl('controlKey') - 显示控件
• hideControl('controlKey') - 隐藏控件

🎨 样式函数：
• setControlBackground('controlKey', '#ff0000') - 设置背景色
• setControlColor('controlKey', 'blue') - 设置文字颜色

💬 消息函数：
• showMessage('消息内容', 'info') - 显示信息消息
• showMessage('错误信息', 'error') - 显示错误消息
• showMessage('警告信息', 'warning') - 显示警告消息

✅ 验证函数：
• validateEmail(email) - 验证邮箱格式
• validatePhone(phone) - 验证手机号格式
• validateChinese(text) - 验证中文字符
• validateNumber(text, min, max) - 验证数字范围
• validateRegex(value, pattern, errorMsg) - 自定义正则验证

🎯 特殊变量：
• self - 当前触发事件的控件对象
• self.text - 控件的文本值（文本框）
• self.value - 控件的数值（数字框）`
                        wrapMode: Text.WordWrap
                        font.family: "Consolas, Monaco, monospace"
                        font.pixelSize: 12
                    }
                }
                
                Text {
                    text: "💡 示例代码："
                    font.bold: true
                    font.pixelSize: 16
                    color: "#2c3e50"
                }
                
                Rectangle {
                    width: parent.width
                    height: exampleText.height + 20
                    color: "#fff3cd"
                    border.color: "#ffeaa7"
                    border.width: 1
                    radius: 4
                    
                    Text {
                        id: exampleText
                        anchors.fill: parent
                        anchors.margins: 10
                        text: `// 验证输入不为空
if(self.text === '') {
    showMessage('请输入内容', 'error');
    setControlBackground('controlKey', '#ffe6e6');
} else {
    setControlBackground('controlKey', '#e6ffe6');
}

// 验证邮箱格式
if(!validateEmail(self.text)) {
    setControlBackground('email', '#ffe6e6');
} else {
    showMessage('邮箱格式正确', 'info');
}

// 根据输入值控制其他控件
if(self.text.length > 5) {
    enableControl('submitBtn');
    setControlValue('status', '已启用');
} else {
    disableControl('submitBtn');
}`
                        wrapMode: Text.WordWrap
                        font.family: "Consolas, Monaco, monospace"
                        font.pixelSize: 11
                        color: "#856404"
                    }
                }
            }
        }
        
        standardButtons: Dialog.Ok
    }
    
    // 变化事件帮助对话框
    Dialog {
        id: changeEventHelpDialog
        title: "变化事件 - 可用函数"
        width: 600
        height: 400
        anchors.centerIn: parent
        modal: true
        
        ScrollView {
            anchors.fill: parent
            
            Column {
                width: parent.width
                spacing: 15
                
                Text {
                    text: "📋 变化事件特点："
                    font.bold: true
                    font.pixelSize: 16
                    color: "#2c3e50"
                }
                
                Rectangle {
                    width: parent.width
                    height: changeInfoText.height + 20
                    color: "#e3f2fd"
                    border.color: "#bbdefb"
                    border.width: 1
                    radius: 4
                    
                    Text {
                        id: changeInfoText
                        anchors.fill: parent
                        anchors.margins: 10
                        text: `🔄 变化事件在用户输入时实时触发
📝 文本框：每次字符输入都会触发
🔢 数字框：数值改变时触发
📋 下拉框：选择改变时触发

⚠️ 注意：变化事件触发频繁，避免在此执行耗时操作`
                        wrapMode: Text.WordWrap
                        font.pixelSize: 12
                        color: "#1565c0"
                    }
                }
                
                Text {
                    text: "💡 常用示例："
                    font.bold: true
                    font.pixelSize: 16
                    color: "#2c3e50"
                }
                
                Rectangle {
                    width: parent.width
                    height: changeExampleText.height + 20
                    color: "#fff3cd"
                    border.color: "#ffeaa7"
                    border.width: 1
                    radius: 4
                    
                    Text {
                        id: changeExampleText
                        anchors.fill: parent
                        anchors.margins: 10
                        text: `// 实时长度检查
if(self.text.length > 10) {
    setControlColor('controlKey', 'red');
    showMessage('输入过长', 'warning');
} else {
    setControlColor('controlKey', 'black');
}

// 数值范围检查
if(self.value > 100) {
    setControlBackground('controlKey', '#ffe6e6');
} else if(self.value > 50) {
    setControlBackground('controlKey', '#fff3e0');
} else {
    setControlBackground('controlKey', '#e6ffe6');
}

// 联动其他控件
if(self.text.includes('@')) {
    setControlValue('type', 'email');
    enableControl('sendBtn');
}`
                        wrapMode: Text.WordWrap
                        font.family: "Consolas, Monaco, monospace"
                        font.pixelSize: 11
                        color: "#856404"
                    }
                }
            }
        }
        
        standardButtons: Dialog.Ok
    }
    
    // 点击事件帮助对话框
    Dialog {
        id: clickEventHelpDialog
        title: "点击事件 - 可用函数"
        width: 600
        height: 400
        anchors.centerIn: parent
        modal: true
        
        ScrollView {
            anchors.fill: parent
            
            Column {
                width: parent.width
                spacing: 15
                
                Text {
                    text: "🎯 点击事件用途："
                    font.bold: true
                    font.pixelSize: 16
                    color: "#2c3e50"
                }
                
                Rectangle {
                    width: parent.width
                    height: clickInfoText.height + 20
                    color: "#f3e5f5"
                    border.color: "#ce93d8"
                    border.width: 1
                    radius: 4
                    
                    Text {
                        id: clickInfoText
                        anchors.fill: parent
                        anchors.margins: 10
                        text: `🔘 按钮点击时触发
📋 常用于表单提交、数据处理、状态切换
✅ 可以进行复杂的业务逻辑处理
🔄 可以调用所有API函数`
                        wrapMode: Text.WordWrap
                        font.pixelSize: 12
                        color: "#7b1fa2"
                    }
                }
                
                Text {
                    text: "💡 典型示例："
                    font.bold: true
                    font.pixelSize: 16
                    color: "#2c3e50"
                }
                
                Rectangle {
                    width: parent.width
                    height: clickExampleText.height + 20
                    color: "#fff3cd"
                    border.color: "#ffeaa7"
                    border.width: 1
                    radius: 4
                    
                    Text {
                        id: clickExampleText
                        anchors.fill: parent
                        anchors.margins: 10
                        text: `// 表单提交验证
var name = getControlValue('name');
var email = getControlValue('email');
var isValid = true;

if(!name || name.trim() === '') {
    showMessage('请输入姓名', 'error');
    setControlBackground('name', '#ffe6e6');
    isValid = false;
}

if(!validateEmail(email)) {
    showMessage('邮箱格式错误', 'error');
    isValid = false;
}

if(isValid) {
    showMessage('提交成功！', 'info');
    // 清空表单
    setControlValue('name', '');
    setControlValue('email', '');
} else {
    showMessage('请检查输入内容', 'error');
}

// 切换状态
var currentStatus = getControlValue('status');
if(currentStatus === '启用') {
    setControlValue('status', '禁用');
    setControlBackground('statusBtn', '#ffe6e6');
} else {
    setControlValue('status', '启用');
    setControlBackground('statusBtn', '#e6ffe6');
}`
                        wrapMode: Text.WordWrap
                        font.family: "Consolas, Monaco, monospace"
                        font.pixelSize: 11
                        color: "#856404"
                    }
                }
            }
        }
        
        standardButtons: Dialog.Ok
    }
}