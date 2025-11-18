import QtQuick 6.5
import mysqlhelper 1.0
import Common 1.0

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
            return
        }
        
        try {
            // 创建函数执行环境，提供丰富的API给用户函数使用
            var func = new Function(
                'self',                    // 当前触发事件的控件对象
                'formAPI',                // FormAPI对象
                'formId',                 // 表单ID
                'formData',               // 表单数据（JSON格式）
                'value',                  // 当前控件的值（用于验证函数）
                'dataRecordId',           // 数据记录ID（编辑模式）
                'isEditMode',             // 是否为编辑模式
                'MySqlHelper',            // 数据库操作对象
                'MessageManager',         // 消息管理器
                'controlsMap',            // 所有控件的映射表
                'getControlValue',        // 获取指定控件的值
                'setControlValue',        // 设置指定控件的值
                'getControlText',         // 获取指定控件的文本
                'setControlText',         // 设置指定控件的文本
                'setControlBackground',   // 设置指定控件的背景色
                'setControlColor',        // 设置指定控件的文字颜色
                'enableControl',          // 启用指定控件
                'disableControl',         // 禁用指定控件
                'showMessage',            // 显示消息提示
                'hideControl',            // 隐藏指定控件
                'showControl',            // 显示指定控件
                'validateAll',            // 验证所有控件
                'resetControl',           // 重置指定控件
                'resetForm',              // 重置整个表单
                'focusControl',           // 让指定控件获得焦点
                'getAllValues',           // 获取所有控件的值
                'validateRegex',          // 正则验证
                'validateEmail',          // 邮箱验证
                'validatePhone',          // 手机号验证
                'validateIdCard',         // 身份证验证
                'validateChinese',        // 中文验证
                'validateNumber',         // 数字验证
                'formatDateTime',         // 格式化日期时间
                funcCode                  // 用户编写的函数代码
            )
            
            // 准备表单数据
            var formData = formAPI.getAllValues()
            
            // 获取全局对象
            var mySqlHelperObj = getMySqlHelper();
            var messageManagerObj = getMessageManager();
            
            // 执行函数，传入完整的API环境
            var result = func(
                context.self,
                formAPI,
                formId,
                formData,
                context.value,
                dataRecordId,
                isEditMode,
                mySqlHelperObj,
                messageManagerObj,
                formAPI.controlsMap,
                formAPI.getControlValue,
                formAPI.setControlValue,
                formAPI.getControlText,
                formAPI.setControlText,
                formAPI.setControlBackground,
                formAPI.setControlColor,
                formAPI.enableControl,
                formAPI.disableControl,
                formAPI.showMessage,
                formAPI.hideControl,
                formAPI.showControl,
                formAPI.validateAll,
                formAPI.resetControl,
                formAPI.resetForm,
                formAPI.focusControl,
                formAPI.getAllValues,
                formAPI.validateRegex,
                formAPI.validateEmail,
                formAPI.validatePhone,
                formAPI.validateIdCard,
                formAPI.validateChinese,
                formAPI.validateNumber,
                formatDateTime
            )
            
            return result
        } catch (error) {
            console.error("ScriptEngine execution error:", error);
            console.error("Function code:", funcCode);
            if (formAPI && formAPI.showMessage) {
                formAPI.showMessage("脚本执行错误: " + error, "error");
            }
        }
    }
}