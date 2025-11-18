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
    
    // 标签映射表的引用（用于验证失败时标红）
    property var labelsMap: ({})
    
    // 控件配置映射表 {controlKey: config}
    property var controlConfigs: ({})
    
    // 控件验证状态缓存 {controlKey: {valid: boolean, lastValidated: timestamp}}
    property var validationStates: ({})
    
    // ScriptEngine引用，用于执行自定义验证函数
    property var scriptEngine: null

    
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
     * 排除按钮类型
     */
    function resetControl(controlKey) {
        if (!controlsMap[controlKey]) {
            return
        }
        
        // 跳过按钮类型
        var config = controlConfigs[controlKey]
        if (config && config.type === "button") {
            return
        }
        
        var control = controlsMap[controlKey]
        
        // 重置文本输入框
        if (control.hasOwnProperty("text") && control.hasOwnProperty("placeholderText")) {
            // 有placeholderText属性说明是文本输入框，不是按钮
            control.text = ""
        } 
        // 重置数字输入框
        else if (control.hasOwnProperty("value") && !control.hasOwnProperty("text")) {
            control.value = 0
        }
        // 重置复选框
        else if (control.hasOwnProperty("checked")) {
            control.checked = false
        }
        // 重置下拉框
        else if (control.hasOwnProperty("currentIndex")) {
            control.currentIndex = 0
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
     * 排除按钮类型的控件
     */
    function getAllValues() {
        var result = {}
        for (var key in controlsMap) {
            if (controlsMap.hasOwnProperty(key)) {
                var control = controlsMap[key]
                
                // 跳过按钮类型
                var config = controlConfigs[key]
                if (config && config.type === "button") {
                    continue
                }
                
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
    
    /**
     * 注册控件配置（包含验证信息）
     */
    function registerControlConfig(controlKey, config) {
        if (!controlConfigs) {
            controlConfigs = {}
        }
        controlConfigs[controlKey] = config
    }
    
    /**
     * 验证单个控件
     * @param controlKey 控件的key
     * @param showError 是否显示错误消息（默认true）
     * @param markLabel 是否标记标签（默认true）
     * @return {valid: boolean, message: string}
     */
    function validateControl(controlKey, showError, markLabel) {
        if (showError === undefined) {
            showError = true
        }
        if (markLabel === undefined) {
            markLabel = true
        }
        
        var config = controlConfigs[controlKey]
        if (!config) {
            return {valid: true, message: ""}
        }
        
        var value = getControlValue(controlKey)
        var isValid = true
        var errorMsg = ""
        
        // 执行自定义验证函数
        if (config.validationFunction && config.validationFunction.trim() !== "") {
            if (scriptEngine) {
                try {
                    var result = scriptEngine.executeFunction(config.validationFunction, {
                        value: value,
                        formAPI: formAPI
                    })
                    if (result === false) {
                        // 验证失败
                        isValid = false
                        errorMsg = config.label ? (config.label + " 验证失败") : "验证失败"
                    }
                } catch (e) {
                    console.error("验证函数执行错误:", e)
                    isValid = false
                    errorMsg = "验证函数执行错误"
                    if (showError) {
                        showMessage("验证函数执行错误: " + e, "error")
                    }
                }
            }
        }
        
        // 标记标签颜色
        if (markLabel && labelsMap[controlKey]) {
            var label = labelsMap[controlKey]
            if (!isValid) {
                label.color = "#ff0000"  // 验证失败：标红
            } else {
                // 验证成功：恢复原始颜色
                label.color = config.style && config.style.labelColor ? config.style.labelColor : "#000000"
            }
        }
        
        // 更新验证状态缓存
        if (!validationStates) {
            validationStates = {}
        }
        validationStates[controlKey] = {
            valid: isValid,
            lastValidated: Date.now()
        }
        
        return {valid: isValid, message: errorMsg}
    }
    
    /**
     * 验证所有控件
     * @return {valid: boolean, errors: [{key, label, message}]}
     */
    function validateAll() {
        var errors = []
        
        // 第一步：验证所有控件并标记失败的标签
        for (var key in controlConfigs) {
            if (controlConfigs.hasOwnProperty(key)) {
                var config = controlConfigs[key];
                
                // 验证控件（不显示消息，但标记标签）
                var result = validateControl(key, false, true)
                
                if (!result.valid) {
                    errors.push({
                        key: key,
                        label: config.label || key,
                        message: result.message
                    })
                }
            }
        }
        
        // 第二步：如果有错误，显示汇总消息
        if (errors.length > 0) {
            var errorMsg = "表单验证失败，请检查以下字段：\n"
            for (var i = 0; i < Math.min(errors.length, 3); i++) {
                errorMsg += "• " + errors[i].label + "\n"
            }
            if (errors.length > 3) {
                errorMsg += "...等 " + errors.length + " 个字段"
            }
            showMessage(errorMsg, "error")
            
            // 让第一个错误的控件获得焦点
            focusControl(errors[0].key)
        } else {
            // 验证成功，恢复所有标签颜色
            for (var k in labelsMap) {
                if (labelsMap.hasOwnProperty(k)) {
                    var cfg = controlConfigs[k]
                    var lbl = labelsMap[k]
                    if (lbl && cfg) {
                        lbl.color = cfg.style && cfg.style.labelColor ? cfg.style.labelColor : "#000000"
                    }
                }
            }
        }
        
        return {
            valid: errors.length === 0,
            errors: errors
        }
    }
    
    /**
     * 重置表单（清空所有控件的值）
     */
    function resetForm() {
        for (var key in controlsMap) {
            if (controlsMap.hasOwnProperty(key)) {
                resetControl(key)
            }
        }
    }
    
    /**
     * 检查单个控件是否验证通过
     * @param controlKey 控件的key
     * @return boolean - true表示验证通过，false表示验证失败或未验证
     */
    function isControlValid(controlKey) {
        // 如果没有验证状态缓存，返回false
        if (!validationStates || !validationStates[controlKey]) {
            return false
        }
        
        return validationStates[controlKey].valid === true
    }
    
    /**
     * 检查多个控件是否都验证通过
     * @param controlKeys 控件key的数组，例如：["name", "age", "email"]
     * @return boolean - true表示所有控件都验证通过，false表示至少有一个验证失败
     */
    function areControlsValid(controlKeys) {
        if (!controlKeys || !Array.isArray(controlKeys)) {
            console.error("areControlsValid: controlKeys must be an array");
            return false
        }
        
        for (var i = 0; i < controlKeys.length; i++) {
            var key = controlKeys[i]
            if (!isControlValid(key)) {
                return false
            }
        }
        
        return true
    }
    
    /**
     * 获取控件的验证状态信息
     * @param controlKey 控件的key
     * @return {valid: boolean, lastValidated: timestamp} 或 null
     */
    function getValidationState(controlKey) {
        if (!validationStates || !validationStates[controlKey]) {
            return null
        }
        
        return validationStates[controlKey]
    }
    
    /**
     * 清除控件的验证状态
     * @param controlKey 控件的key，如果不提供则清除所有
     */
    function clearValidationState(controlKey) {
        if (!validationStates) {
            return
        }
        
        if (controlKey) {
            delete validationStates[controlKey]
        } else {
            validationStates = {}
        }
    }
}
