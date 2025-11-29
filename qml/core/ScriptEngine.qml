import QtQuick 6.5
import "../mysqlhelper"
import "../Common"

/**
 * JavaScript函数执行引擎
 * 负责执行用户在JSON中定义的JavaScript函数
 */
QtObject {
    id: scriptEngine

    // API对象引用
    property var formAPI: null

    // 表单ID（用于提交时识别表单）
    property int formId: -1

    // 数据记录ID（编辑模式）
    property int dataRecordId: -1

    // 是否为编辑模式
    property bool isEditMode: false

    /**
     * 初始化脚本引擎（清空临时存储）
     * 每次打开表单时应该调用此函数
     */
    function initializeEngine() {
        if (formAPI) {
            formAPI.initializeForm();
        }
        console.log("ScriptEngine: 引擎已初始化");
    }

    // 获取全局MySqlHelper对象
    function getMySqlHelper() {
        return MySqlHelper;
    }

    // 获取全局MessageManager对象
    function getMessageManager() {
        return MessageManager;
    }

    /**
     * 格式化日期时间为 MySQL DATETIME 格式
     * @param date - Date 对象，如果不传则使用当前时间
     * @return 格式化后的日期时间字符串，如 "2025-11-18 13:31:33"
     */
    function formatDateTime(date) {
        if (!date) {
            date = new Date();
        }

        var year = date.getFullYear();
        var month = String(date.getMonth() + 1).padStart(2, '0');
        var day = String(date.getDate()).padStart(2, '0');
        var hours = String(date.getHours()).padStart(2, '0');
        var minutes = String(date.getMinutes()).padStart(2, '0');
        var seconds = String(date.getSeconds()).padStart(2, '0');

        return year + '-' + month + '-' + day + ' ' + hours + ':' + minutes + ':' + seconds;
    }

    /**
     * 执行用户自定义的JavaScript函数
     * @param funcCode - 函数代码字符串
     * @param context - 执行上下文，包含self等变量
     */
    function executeFunction(funcCode, context) {
        if (!formAPI) {
            return;
        }

        try {
            // 准备完整的上下文对象
            var fullContext = {
                self: context.self,
                formAPI: formAPI,
                formId: formId,
                formData: formAPI.getAllValues(),
                value: context.value,
                dataRecordId: dataRecordId,
                isEditMode: isEditMode,
                MySqlHelper: getMySqlHelper(),
                MessageManager: getMessageManager(),
                controlsMap: formAPI.controlsMap,

                // 绑定 FormAPI 函数，确保 'this' 指向 formAPI
                getControlValue: (formAPI && formAPI.getControlValue) ? formAPI.getControlValue.bind(formAPI) : function () {},
                setControlValue: (formAPI && formAPI.setControlValue) ? formAPI.setControlValue.bind(formAPI) : function () {},
                getControlText: (formAPI && formAPI.getControlText) ? formAPI.getControlText.bind(formAPI) : function () {},
                setControlText: (formAPI && formAPI.setControlText) ? formAPI.setControlText.bind(formAPI) : function () {},
                setControlBackground: (formAPI && formAPI.setControlBackground) ? formAPI.setControlBackground.bind(formAPI) : function () {},
                setControlColor: (formAPI && formAPI.setControlColor) ? formAPI.setControlColor.bind(formAPI) : function () {},
                enableControl: (formAPI && formAPI.enableControl) ? formAPI.enableControl.bind(formAPI) : function () {},
                disableControl: (formAPI && formAPI.disableControl) ? formAPI.disableControl.bind(formAPI) : function () {},
                showMessage: (formAPI && formAPI.showMessage) ? formAPI.showMessage.bind(formAPI) : function () {},
                hideControl: (formAPI && formAPI.hideControl) ? formAPI.hideControl.bind(formAPI) : function () {},
                showControl: (formAPI && formAPI.showControl) ? formAPI.showControl.bind(formAPI) : function () {},
                validateAll: (formAPI && formAPI.validateAll) ? formAPI.validateAll.bind(formAPI) : function () {},
                resetControl: (formAPI && formAPI.resetControl) ? formAPI.resetControl.bind(formAPI) : function () {},
                resetForm: (formAPI && formAPI.resetForm) ? formAPI.resetForm.bind(formAPI) : function () {},
                focusControl: (formAPI && formAPI.focusControl) ? formAPI.focusControl.bind(formAPI) : function () {},
                getAllValues: (formAPI && formAPI.getAllValues) ? formAPI.getAllValues.bind(formAPI) : function () {},
                validateRegex: (formAPI && formAPI.validateRegex) ? formAPI.validateRegex.bind(formAPI) : function () {},
                validateEmail: (formAPI && formAPI.validateEmail) ? formAPI.validateEmail.bind(formAPI) : function () {},
                validatePhone: (formAPI && formAPI.validatePhone) ? formAPI.validatePhone.bind(formAPI) : function () {},
                validateIdCard: (formAPI && formAPI.validateIdCard) ? formAPI.validateIdCard.bind(formAPI) : function () {},
                validateChinese: (formAPI && formAPI.validateChinese) ? formAPI.validateChinese.bind(formAPI) : function () {},
                validateNumber: (formAPI && formAPI.validateNumber) ? formAPI.validateNumber.bind(formAPI) : function () {},
                setTempValue: (formAPI && formAPI.setTempValue) ? formAPI.setTempValue.bind(formAPI) : function () {},
                getTempValue: (formAPI && formAPI.getTempValue) ? formAPI.getTempValue.bind(formAPI) : function () {},
                clearTempStorage: (formAPI && formAPI.clearTempStorage) ? formAPI.clearTempStorage.bind(formAPI) : function () {},
                isControlValid: (formAPI && formAPI.isControlValid) ? formAPI.isControlValid.bind(formAPI) : function () {
                    console.warn("isControlValid not available");
                    return true;
                },
                areControlsValid: (formAPI && formAPI.areControlsValid) ? formAPI.areControlsValid.bind(formAPI) : function () {
                    console.warn("areControlsValid not available");
                    return true;
                },

                // 本地辅助函数
                formatDateTime: formatDateTime
            };

            // 使用 'with' 语句将 context 属性暴露为局部变量
            // 注意：在严格模式下 'with' 是禁止的，但 QML JS 环境通常允许
            var func = new Function('ctx', 'with(ctx) { ' + funcCode + ' }');

            return func(fullContext);
        } catch (error) {
            console.error("ScriptEngine execution error:", error);
            console.error("Function code:", funcCode);
            if (formAPI && formAPI.showMessage) {
                formAPI.showMessage("脚本执行错误: " + error, "error");
            }
        }
    }
}
