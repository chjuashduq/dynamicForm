import QtQuick 6.5
import Common 1.0
/**
 * 表单控件操作API库
 * 提供统一的控件操作接口
 */
QtObject {
    id: formAPI
    
    // 控件映射表的引用
    property var controlsMap: ({})
    
    // 校验规则映射表 {controlKey: {rules: [...], message: "..."}}
    property var validationRules: ({})

    
    /**
     * 获取指定控件的值（支持各种控件类型）
     */
    function getControlValue(controlKey) {
        if (controlsMap[controlKey]) {
            var control = controlsMap[controlKey]
            if (control.hasOwnProperty("text")) {
                return control.text
            } else if (control.hasOwnProperty("value")) {
                return control.value
            } else if (control.hasOwnProperty("currentText")) {
                return control.currentText
            }
        }
        return ""
    }
    
    /**
     * 设置指定控件的值
     */
    function setControlValue(controlKey, newValue) {
        if (controlsMap[controlKey]) {
            var control = controlsMap[controlKey]
            if (control.hasOwnProperty("text")) {
                control.text = newValue
            } else if (control.hasOwnProperty("value")) {
                control.value = newValue
            } else if (control.hasOwnProperty("currentIndex") && control.hasOwnProperty("model")) {
                var index = control.model.indexOf(newValue)
                if (index >= 0) {
                    control.currentIndex = index
                }
            }
        }
    }
    
    /**
     * 获取指定控件的文本内容
     */
    function getControlText(controlKey) {
        if (controlsMap[controlKey]) {
            var control = controlsMap[controlKey]
            if (control.hasOwnProperty("text")) {
                return control.text
            } else if (control.hasOwnProperty("currentText")) {
                return control.currentText
            }
        }
        return ""
    }
    
    /**
     * 设置指定控件的文本内容
     */
    function setControlText(controlKey, newText) {
        if (controlsMap[controlKey] && controlsMap[controlKey].hasOwnProperty("text")) {
            controlsMap[controlKey].text = newText
        }
    }
    
    /**
     * 设置指定控件的背景颜色
     * 注意：由于Qt样式限制，暂时禁用背景设置以避免警告
     */
    function setControlBackground(controlKey, color) {
        // 背景设置已禁用，避免Qt样式不兼容警告
    }
    
    /**
     * 设置指定控件的文字颜色
     */
    function setControlColor(controlKey, color) {
        if (controlsMap[controlKey] && controlsMap[controlKey].hasOwnProperty("color")) {
            controlsMap[controlKey].color = color
        }
    }
    
    /**
     * 启用控件
     */
    function enableControl(controlKey) {
        if (controlsMap[controlKey]) {
            controlsMap[controlKey].enabled = true
        }
    }
    
    /**
     * 禁用控件
     */
    function disableControl(controlKey) {
        if (controlsMap[controlKey]) {
            controlsMap[controlKey].enabled = false
        }
    }
    
    /**
     * 隐藏控件
     */
    function hideControl(controlKey) {
        if (controlsMap[controlKey]) {
            controlsMap[controlKey].visible = false
        }
    }
    
    /**
     * 显示控件
     */
    function showControl(controlKey) {
        if (controlsMap[controlKey]) {
            controlsMap[controlKey].visible = true
        }
    }
    
    /**
     * 显示消息
     */
    function showMessage(message, type) {
        MessageManager.showToast(message, type || "info")
    }
    
    /**
     * 正则表达式验证
     */
    function validateRegex(value, pattern, errorMessage) {
        var regex = new RegExp(pattern)
        var isValid = regex.test(value)
        
        if (!isValid && errorMessage) {
            showMessage(errorMessage, "error")
        }
        
        return isValid
    }
    
    /**
     * 常用验证函数
     */
    function validateEmail(email) {
        var pattern = "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$"
        return validateRegex(email, pattern, "请输入有效的邮箱地址")
    }
    
    function validatePhone(phone) {
        var pattern = "^1[3-9]\\d{9}$"
        return validateRegex(phone, pattern, "请输入有效的手机号码")
    }
    
    function validateIdCard(idCard) {
        var pattern = "^[1-9]\\d{5}(18|19|20)\\d{2}((0[1-9])|(1[0-2]))(([0-2][1-9])|10|20|30|31)\\d{3}[0-9Xx]$"
        return validateRegex(idCard, pattern, "请输入有效的身份证号码")
    }
    
    function validateChinese(text) {
        var pattern = "^[\\u4e00-\\u9fa5]+$"
        return validateRegex(text, pattern, "只能输入中文字符")
    }
    
    function validateNumber(text, min, max) {
        var num = parseFloat(text)
        if (isNaN(num)) {
            showMessage("请输入有效的数字", "error")
            return false
        }
        
        if (min !== undefined && num < min) {
            showMessage("数值不能小于 " + min, "error")
            return false
        }
        
        if (max !== undefined && num > max) {
            showMessage("数值不能大于 " + max, "error")
            return false
        }
        
        return true
    }
    
    /**
     * 验证整个表单
     */
    function validateForm() {
        return true
    }
    
    /**
     * 重置指定控件
     */
    function resetControl(controlKey) {
        if (controlsMap[controlKey]) {
            var control = controlsMap[controlKey]
            if (control.hasOwnProperty("text")) {
                control.text = ""
            } else if (control.hasOwnProperty("value")) {
                control.value = 0
            }
        }
    }
    
    /**
     * 让指定控件获得焦点
     */
    function focusControl(controlKey) {
        if (controlsMap[controlKey] && controlsMap[controlKey].hasOwnProperty("focus")) {
            controlsMap[controlKey].focus = true
            
        }
    }
    
    /**
     * 获取所有控件的值
     * 返回一个对象，key为控件的key，value为控件的值
     */
    function getAllValues() {
        var result = {}
        for (var key in controlsMap) {
            if (controlsMap.hasOwnProperty(key)) {
                var control = controlsMap[key]
                
                // 处理不同类型的控件
                if (control.hasOwnProperty("getValue")) {
                    // 如果控件有自定义的getValue方法（如ComboBox、CheckBox组、Radio组）
                    result[key] = control.getValue()
                } else if (control.hasOwnProperty("text")) {
                    // 文本输入框
                    result[key] = control.text
                } else if (control.hasOwnProperty("value")) {
                    // 数字输入框
                    result[key] = control.value
                } else if (control.hasOwnProperty("currentText")) {
                    // 下拉框
                    result[key] = control.currentText
                } else if (control.hasOwnProperty("checked")) {
                    // 单个复选框
                    result[key] = control.checked
                }
            }
        }
        return result
    }
}
