import QtQuick 6.5
import "../Common"

/**
 * 表单控件操作API库
 */
QtObject {
    id: formAPI

    property var controlsMap: ({})
    property var labelsMap: ({})
    property var controlConfigs: ({})
    property var validationStates: ({})
    property var tempStorage: ({})
    property var scriptEngine: null

    // [新增] 验证状态常量
    readonly property int statusUnchecked: 0
    readonly property int statusValid: 1
    readonly property int statusInvalid: 2

    function initializeForm() {
        validationStates = {};
        tempStorage = {};
        console.log("FormAPI: 表单已初始化");
    }

    function getControlValue(controlKey) {
        if (controlsMap[controlKey]) {
            var control = controlsMap[controlKey];
            if (control.getValue && typeof control.getValue === "function")
                return control.getValue();
            if (control.text !== undefined)
                return control.text;
            if (control.value !== undefined)
                return control.value;
            if (control.currentText !== undefined)
                return control.currentText;
            if (control.checked !== undefined)
                return control.checked;
        }
        return "";
    }

    function setControlValue(controlKey, newValue) {
        if (controlsMap[controlKey]) {
            var control = controlsMap[controlKey];
            if (control.text !== undefined)
                control.text = newValue;
            else if (control.value !== undefined)
                control.value = newValue;
            else if (control.checked !== undefined)
                control.checked = newValue;
            else if (control.currentIndex !== undefined && control.optionValues !== undefined) {
                var index = control.optionValues.indexOf(newValue);
                if (index >= 0)
                    control.currentIndex = index;
                else {
                    index = control.model.indexOf(newValue);
                    if (index >= 0)
                        control.currentIndex = index;
                }
            } else if (control.currentIndex !== undefined && control.model !== undefined) {
                var idx = control.model.indexOf(newValue);
                if (idx >= 0)
                    control.currentIndex = idx;
            }
        }
    }

    function getControlText(controlKey) {
        if (controlsMap[controlKey]) {
            var control = controlsMap[controlKey];
            if (control.text !== undefined)
                return control.text;
            if (control.currentText !== undefined)
                return control.currentText;
        }
        return "";
    }

    function setControlText(controlKey, newText) {
        if (controlsMap[controlKey] && controlsMap[controlKey].text !== undefined) {
            controlsMap[controlKey].text = newText;
        }
    }

    function setControlBackground(controlKey, color) {
    }

    function setControlColor(controlKey, color) {
        if (controlsMap[controlKey] && controlsMap[controlKey].color !== undefined) {
            controlsMap[controlKey].color = color;
        }
    }

    function enableControl(controlKey) {
        if (controlsMap[controlKey])
            controlsMap[controlKey].enabled = true;
    }

    function disableControl(controlKey) {
        if (controlsMap[controlKey])
            controlsMap[controlKey].enabled = false;
    }

    function hideControl(controlKey) {
        if (controlsMap[controlKey])
            controlsMap[controlKey].visible = false;
    }

    function showControl(controlKey) {
        if (controlsMap[controlKey])
            controlsMap[controlKey].visible = true;
    }

    function showMessage(message, type) {
        MessageManager.showToast(message, type || "info");
    }

    function validateRegex(value, pattern, errorMessage) {
        var regex = new RegExp(pattern);
        var isValid = regex.test(value);
        if (!isValid && errorMessage) {
            showMessage(errorMessage, "error");
        }
        return isValid;
    }

    function validateEmail(email) {
        return validateRegex(email, "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", "请输入有效的邮箱地址");
    }

    function validatePhone(phone) {
        return validateRegex(phone, "^1[3-9]\\d{9}$", "请输入有效的手机号码");
    }

    function validateIdCard(idCard) {
        return validateRegex(idCard, "^[1-9]\\d{5}(18|19|20)\\d{2}((0[1-9])|(1[0-2]))(([0-2][1-9])|10|20|30|31)\\d{3}[0-9Xx]$", "请输入有效的身份证号码");
    }

    function validateChinese(text) {
        return validateRegex(text, "^[\\u4e00-\\u9fa5]+$", "只能输入中文字符");
    }

    function validateNumber(text, min, max) {
        var num = parseFloat(text);
        if (isNaN(num)) {
            showMessage("请输入有效的数字", "error");
            return false;
        }
        if (min !== undefined && num < min) {
            showMessage("数值不能小于 " + min, "error");
            return false;
        }
        if (max !== undefined && num > max) {
            showMessage("数值不能大于 " + max, "error");
            return false;
        }
        return true;
    }

    function validateForm() {
        return true;
    }

    /**
     * 重置控件
     * 恢复 valid 状态为初始值 (0 或 1)
     */
    function resetControl(controlKey) {
        if (!controlsMap[controlKey])
            return;

        var config = controlConfigs[controlKey];
        if (config && config.type === "button")
            return;

        var control = controlsMap[controlKey];

        // [关键修改] 根据必填状态重置 valid
        // 如果控件有 valid 属性 (不是 undefined)，则重置
        if (control.valid !== undefined) {
            var isRequired = (config && config.required === true);
            // 必填 -> 0 (Unchecked), 非必填 -> 1 (Valid)
            control.valid = isRequired ? statusUnchecked : statusValid;
        }

        if (control.text !== undefined && control.placeholderText !== undefined)
            control.text = "";
        else if (control.value !== undefined && control.text === undefined)
            control.value = 0;
        else if (control.checked !== undefined)
            control.checked = false;
        else if (control.currentIndex !== undefined)
            control.currentIndex = 0;
    }

    function resetForm() {
        for (var key in controlsMap) {
            resetControl(key);
        }
    }

    function focusControl(controlKey) {
        if (controlsMap[controlKey])
            controlsMap[controlKey].forceActiveFocus();
    }

    function getAllValues() {
        var result = {};
        for (var key in controlsMap) {
            if (controlsMap[key]) {
                var control = controlsMap[key];
                var config = controlConfigs[key];
                if (config && config.type === "button")
                    continue;

                if (control.getValue && typeof control.getValue === "function")
                    result[key] = control.getValue();
                else if (control.text !== undefined)
                    result[key] = control.text;
                else if (control.value !== undefined)
                    result[key] = control.value;
                else if (control.currentText !== undefined)
                    result[key] = control.currentText;
                else if (control.checked !== undefined)
                    result[key] = control.checked;
            }
        }
        return result;
    }

    function registerControlConfig(controlKey, config) {
        if (!controlConfigs) {
            controlConfigs = {};
        }
        controlConfigs[controlKey] = config;
    }

    /**
     * 验证单个控件
     * 修改 valid 属性为 1 (合格) 或 2 (不合格)
     */
    function validateControl(controlKey, showError) {
        if (showError === undefined)
            showError = true;

        var config = controlConfigs[controlKey];
        if (!config)
            return {
                valid: true,
                message: ""
            }; // 配置不存在视为通过

        var control = controlsMap[controlKey];

        // [关键修改] 检查 valid 是否为 undefined
        // 如果是 undefined，说明该控件不参与验证（例如 Button 或 Layout），直接返回通过
        if (control && control.valid === undefined) {
            return {
                valid: true,
                message: ""
            };
        }

        var value = getControlValue(controlKey);
        var isValid = true;
        var errorMsg = "";

        // 0. 检查必填属性
        if (config.required === true) {
            var isEmpty = (value === null || value === undefined || String(value).trim() === "");
            if (Array.isArray(value))
                isEmpty = (value.length === 0);

            if (isEmpty) {
                isValid = false;
                errorMsg = config.label ? (config.label + " 不能为空") : "此项不能为空";
            }
        }

        // 1. 自定义验证函数 (仅当必填检查通过后执行)
        if (isValid && config.validationFunction && config.validationFunction.trim() !== "") {
            if (scriptEngine) {
                try {
                    var result = scriptEngine.executeFunction(config.validationFunction, {
                        value: value,
                        formAPI: formAPI
                    });
                    if (result === false) {
                        isValid = false;
                        errorMsg = config.label ? (config.label + " 验证失败") : "验证失败";
                    }
                } catch (e) {
                    console.error("验证函数执行错误:", e);
                    isValid = false;
                    errorMsg = "验证函数执行错误";
                    if (showError)
                        showMessage("验证函数执行错误: " + e, "error");
                }
            }
        }

        // [关键修改] 更新控件状态
        // 验证通过 -> 1 (Valid)
        // 验证失败 -> 2 (Invalid)
        if (control) {
            try {
                control.valid = isValid ? statusValid : statusInvalid;
            } catch (e) {
                console.warn("Cannot set valid property on control " + controlKey);
            }
        }

        return {
            valid: isValid,
            message: errorMsg
        };
    }

    /**
     * 检查单个控件是否验证通过
     * 只有 valid === 1 才算通过
     * undefined 视为跳过（返回 true）
     * 0 (Unchecked) 和 2 (Invalid) 均视为 false
     */
    function isControlValid(controlKey) {
        var control = controlsMap[controlKey];
        if (control) {
            if (control.valid === undefined)
                return true; // 不参与验证的控件
            return control.valid === statusValid; // 只有状态为 1 才算通过
        }
        return true;
    }

    function areControlsValid(controlKeys) {
        if (!controlKeys || !Array.isArray(controlKeys))
            return false;
        for (var i = 0; i < controlKeys.length; i++) {
            if (!isControlValid(controlKeys[i]))
                return false;
        }
        return true;
    }

    /**
     * 验证所有控件
     * 遍历所有控件配置，触发验证，并检查最终状态
     */
    function validateAll() {
        var errors = [];
        for (var key in controlConfigs) {
            if (controlConfigs[key]) {
                var config = controlConfigs[key];
                var control = controlsMap[key];

                // 跳过不参与验证的控件 (valid === undefined)
                if (!control || control.valid === undefined)
                    continue;

                // 触发验证，更新状态
                var result = validateControl(key, false);

                // 检查结果 (result.valid === false 表示验证不通过)
                if (!result.valid) {
                    errors.push({
                        key: key,
                        label: config.label || key,
                        message: result.message
                    });
                }
            }
        }

        if (errors.length > 0) {
            var errorMsg = "表单验证失败，请检查以下字段：\n";
            for (var i = 0; i < Math.min(errors.length, 3); i++) {
                errorMsg += "• " + errors[i].label + "\n";
            }
            if (errors.length > 3)
                errorMsg += "...等 " + errors.length + " 个字段";
            showMessage(errorMsg, "error");

            if (errors[0].key && controlsMap[errors[0].key]) {
                focusControl(errors[0].key);
            }
        }

        return {
            valid: errors.length === 0,
            errors: errors
        };
    }

    function getValidationState(controlKey) {
        if (!validationStates || !validationStates[controlKey])
            return null;
        return validationStates[controlKey];
    }

    function clearValidationState(controlKey) {
        if (!validationStates)
            return;
        if (controlKey)
            delete validationStates[controlKey];
        else
            validationStates = {};
    }

    function setTempValue(key, value) {
        if (!tempStorage)
            tempStorage = {};
        tempStorage[key] = value;
    }

    function getTempValue(key) {
        if (!tempStorage)
            return undefined;
        return tempStorage[key];
    }

    function clearTempStorage(key) {
        if (!tempStorage)
            return;
        if (key)
            delete tempStorage[key];
        else
            tempStorage = {};
    }
}
