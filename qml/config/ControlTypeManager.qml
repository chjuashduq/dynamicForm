import QtQuick 6.5

/**
 * 控件类型管理器
 * 负责控件类型相关的工具函数和配置
 */
QtObject {
    id: controlTypeManager
    
    // 控件类型定义
    readonly property var controlTypes: [
        { type: "text", icon: "📝", label: "文本框", color: "#e3f2fd", borderColor: "#2196f3" },
        { type: "number", icon: "🔢", label: "数字框", color: "#e8f5e8", borderColor: "#4caf50" },
        { type: "password", icon: "🔒", label: "密码框", color: "#f3e5f5", borderColor: "#9c27b0" },
        { type: "dropdown", icon: "📋", label: "下拉框", color: "#fff3e0", borderColor: "#ff9800" },
        { type: "checkbox", icon: "☑️", label: "复选框", color: "#ffebee", borderColor: "#f44336" },
        { type: "radio", icon: "🔘", label: "单选框", color: "#f5f5f5", borderColor: "#9e9e9e" },
        { type: "button", icon: "🎯", label: "按钮", color: "#ffebee", borderColor: "#f44336" }
    ]
    
    function getControlTypeInfo(type) {
        for (var i = 0; i < controlTypes.length; i++) {
            if (controlTypes[i].type === type) {
                return controlTypes[i];
            }
        }
        return { type: type, icon: "❓", label: "未知", color: "#ffffff", borderColor: "#dee2e6" };
    }
    
    function getDefaultLabel(type) {
        var typeInfo = getControlTypeInfo(type);
        return type === "button" ? "" : typeInfo.label.replace("框", "输入").replace("按钮", "");
    }
    
    function createDefaultControl(type) {
        var control = {
            "type": type,
            "key": type + "_" + Date.now(),
            "label": getDefaultLabel(type),
            "rowSpan": 1,
            "colSpan": 1,
            "labelRatio": type === "button" ? 0 : 0.3
        };
        
        addTypeSpecificProperties(control, type);
        return control;
    }
    
    function addTypeSpecificProperties(control, type) {
        var defaultOptions = [
            { "label": "选项1", "value": "option1" },
            { "label": "选项2", "value": "option2" }
        ];

        switch (type) {
        case "text":
            control.placeholder = "请输入文本";
            control.value = "";
            break;
        case "number":
            control.value = 0;
            control.min = 0;
            control.max = 100;
            break;
        case "password":
            control.placeholder = "请输入密码";
            control.value = "";
            break;
        case "dropdown":
            control.options = defaultOptions;
            control.value = "option1";
            break;
        case "checkbox":
            control.options = defaultOptions;
            control.value = [];
            control.direction = "horizontal";
            break;
        case "radio":
            control.options = defaultOptions;
            control.value = "option1";
            break;
        case "button":
            control.text = "按钮";
            break;
        }
    }
    
    function hasChangeEvent(type) {
        return ["text", "number", "password", "button", "dropdown"].indexOf(type) !== -1;
    }
    
    function getChangeEventLabel(type) {
        switch (type) {
        case "text":
        case "password":
            return "文本变化事件:";
        case "number":
            return "数值变化事件:";
        case "button":
            return "点击事件:";
        case "dropdown":
            return "选择变化事件:";
        default:
            return "变化事件:";
        }
    }
    
    function hasTypeSpecificProps(type) {
        return ["text", "number", "dropdown", "checkbox", "radio", "button"].indexOf(type) !== -1;
    }
}