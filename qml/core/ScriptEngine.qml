import QtQuick 6.5

/**
 * JavaScript函数执行引擎
 * 负责执行用户在JSON中定义的JavaScript函数
 */
QtObject {
    id: scriptEngine
    
    // API对象引用
    property var formAPI: null
    
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
                'validateForm',           // 验证整个表单
                'resetControl',           // 重置指定控件
                'focusControl',           // 让指定控件获得焦点
                'validateRegex',          // 正则验证
                'validateEmail',          // 邮箱验证
                'validatePhone',          // 手机号验证
                'validateIdCard',         // 身份证验证
                'validateChinese',        // 中文验证
                'validateNumber',         // 数字验证
                funcCode                  // 用户编写的函数代码
            )
            
            // 执行函数，传入完整的API环境
            func(
                context.self,
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
                formAPI.validateForm,
                formAPI.resetControl,
                formAPI.focusControl,
                formAPI.validateRegex,
                formAPI.validateEmail,
                formAPI.validatePhone,
                formAPI.validateIdCard,
                formAPI.validateChinese,
                formAPI.validateNumber
            )
        } catch (error) {
            // 静默处理脚本执行错误
        }
    }
}