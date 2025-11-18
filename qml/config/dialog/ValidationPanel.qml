import QtQuick 6.5
import QtQuick.Controls 6.5
import QtQuick.Layouts 1.4

/**
 * 校验配置面板
 * 简化版：只有自定义验证函数
 */
GroupBox {
    id: validationPanel
    title: "验证函数"
    
    property var editConfig: ({})
    signal configChanged()
    
    Column {
        anchors.fill: parent
        spacing: 15
        
        // 自定义验证函数
        GroupBox {
            title: "编写验证函数"
            width: parent.width
            
            Column {
                width: parent.width
                spacing: 10
                
                Label {
                    text: "编写JavaScript验证代码，返回true表示通过，false表示失败\n• 失去焦点时自动验证\n• 验证失败时标签标红并显示提示信息"
                    wrapMode: Text.WordWrap
                    width: parent.width
                    font.pixelSize: 11
                    color: "#666"
                }
                
                Label {
                    text: "可用变量：value（当前值）、formAPI（表单API）"
                    wrapMode: Text.WordWrap
                    width: parent.width
                    font.pixelSize: 11
                    color: "#666"
                }
                
                ScrollView {
                    width: parent.width
                    height: 200
                    
                    TextArea {
                        id: validationFunctionField
                        text: editConfig.validationFunction || ""
                        placeholderText: "// 年龄验证示例：\nif (!value || value < 18 || value > 100) {\n    showMessage('年龄必须在18-100之间', 'error');\n    return false;\n}\nreturn true;\n\n// 必填验证示例：\nif (!value || value.trim() === '') {\n    showMessage('此字段不能为空', 'error');\n    return false;\n}\nreturn true;\n\n// 长度验证示例：\nif (value.length < 6) {\n    showMessage('密码长度不能少于6位', 'error');\n    return false;\n}\nreturn true;"
                        font.family: "Consolas"
                        font.pixelSize: 12
                        wrapMode: TextArea.Wrap
                        onTextChanged: configChanged()
                    }
                }
                
                Label {
                    text: "⚠️ 重要：验证失败时必须调用 showMessage('错误消息', 'error') 并返回 false"
                    wrapMode: Text.WordWrap
                    width: parent.width
                    font.pixelSize: 11
                    color: "#ff6b6b"
                    font.bold: true
                }
            }
        }
    }
    
    function refreshFields() {
        if (!editConfig) return
        
        validationFunctionField.text = editConfig.validationFunction || ""
    }
    
    function getConfig() {
        return {
            validationFunction: validationFunctionField.text
        }
    }
    
    onEditConfigChanged: {
        refreshFields()
    }
}
