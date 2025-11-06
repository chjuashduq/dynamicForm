import QtQuick 6.5
import QtQuick.Controls 6.5
import QtQuick.Layouts 1.4

/**
 * 事件配置面板组件
 * 
 * 功能描述：
 * - 提供控件事件处理函数的配置界面
 * - 支持焦点丢失事件和控件特定变化事件的配置
 * - 根据控件类型动态显示相应的事件配置选项
 * - 提供事件编辑入口，集成函数编写对话框
 * 
 * 支持的事件类型：
 * 1. 焦点丢失事件 (onFocusLost) - 所有控件通用
 * 2. 文本变化事件 (onTextChanged) - 文本输入控件
 * 3. 数值变化事件 (onValueChanged) - 数字、下拉框控件
 * 4. 点击事件 (onClicked) - 按钮控件
 * 
 * 工作流程：
 * 1. 根据控件类型显示相应的事件配置项
 * 2. 显示当前事件的配置状态（已配置/未配置）
 * 3. 用户点击"编写函数"按钮时发出编辑请求信号
 * 4. 接收编写完成的代码并更新到配置中
 * 
 * 作者：系统生成
 * 版本：1.0
 */
GroupBox {
    id: eventConfigPanel
    title: "事件配置"
    
    // ========== 属性定义 ==========
    property var editConfig: ({})        // 当前编辑的控件配置
    property var typeManager: null       // 控件类型管理器，用于判断控件支持的事件
    
    // ========== 信号定义 ==========
    signal eventEditRequested(string eventType, string currentCode)  // 请求编辑事件信号

    // ========== 主界面布局 ==========
    Column {
        width: parent.width
        spacing: 15

        // ========== 焦点丢失事件配置 ==========
        RowLayout {
            width: parent.width
            spacing: 10

            Label { 
                text: "焦点丢失事件:"
                Layout.preferredWidth: 120
                ToolTip.text: "控件失去焦点时触发，常用于验证输入内容"
                ToolTip.visible: hovered
                
                MouseArea {
                    id: focusLostHover
                    anchors.fill: parent
                    hoverEnabled: true
                    property bool hovered: containsMouse
                }
            }
            
            Button {
                text: "编写函数"
                ToolTip.text: "点击打开函数编写对话框"
                onClicked: {
                    // 获取当前已配置的焦点丢失事件代码
                    var currentCode = (editConfig.events && editConfig.events.onFocusLost) || "";
                    eventEditRequested("focusLost", currentCode);
                }
            }
            
            Label {
                // 根据是否已配置显示状态
                text: (editConfig.events && editConfig.events.onFocusLost) ? "已配置" : "未配置"
                // 已配置显示绿色，未配置显示灰色
                color: (editConfig.events && editConfig.events.onFocusLost) ? "#28a745" : "#6c757d"
                Layout.fillWidth: true
            }
        }

        // ========== 控件特定变化事件配置 ==========
        RowLayout {
            width: parent.width
            // 只有当类型管理器存在且当前控件类型支持变化事件时才显示
            visible: typeManager && typeManager.hasChangeEvent(editConfig.type)
            spacing: 10

            Label { 
                // 根据控件类型显示相应的事件标签
                text: typeManager ? typeManager.getChangeEventLabel(editConfig.type) : "变化事件:"
                Layout.preferredWidth: 120
                ToolTip.text: getChangeEventTooltip()
                ToolTip.visible: changeEventHover.hovered
                
                MouseArea {
                    id: changeEventHover
                    anchors.fill: parent
                    hoverEnabled: true
                    property bool hovered: containsMouse
                }
            }
            
            Button {
                text: "编写函数"
                ToolTip.text: "点击打开函数编写对话框"
                onClicked: {
                    // 获取当前已配置的变化事件代码
                    var currentCode = getChangeEventText();
                    eventEditRequested("change", currentCode);
                }
            }
            
            Label {
                // 根据是否已配置显示状态
                text: getChangeEventText() ? "已配置" : "未配置"
                color: getChangeEventText() ? "#28a745" : "#6c757d"
                Layout.fillWidth: true
            }
        }
    }

    // ========== 辅助函数 ==========
    
    /**
     * 获取变化事件的提示文本
     * 根据控件类型返回相应的事件说明
     */
    function getChangeEventTooltip() {
        switch (editConfig.type) {
        case "text":
        case "password":
            return "文本内容发生变化时触发";
        case "number":
            return "数值发生变化时触发";
        case "dropdown":
            return "选择项发生变化时触发";
        case "button":
            return "按钮被点击时触发";
        default:
            return "控件值发生变化时触发";
        }
    }
    
    /**
     * 获取当前控件类型对应的变化事件代码
     * 
     * 功能：
     * - 根据控件类型从editConfig.events中获取相应的事件代码
     * - 不同控件类型对应不同的事件属性名
     * 
     * 返回值：
     * - 当前配置的事件代码字符串，如果未配置则返回空字符串
     */
    function getChangeEventText() {
        if (!editConfig.events) return "";
        
        // 根据控件类型返回相应的事件代码
        switch (editConfig.type) {
        case "text":
        case "password":
            return editConfig.events.onTextChanged || "";  // 文本变化事件
        case "number":
        case "dropdown":
            return editConfig.events.onValueChanged || ""; // 数值变化事件
        case "button":
            return editConfig.events.onClicked || "";      // 点击事件
        default:
            return "";
        }
    }

    /**
     * 更新事件配置
     * 
     * 功能：
     * - 将编写完成的事件代码保存到editConfig中
     * - 根据事件类型和控件类型确定正确的属性名
     * - 自动清理空的事件配置
     * 
     * 参数：
     * - eventType: 事件类型 ("focusLost" 或 "change")
     * - code: 事件处理代码
     */
    function updateEvent(eventType, code) {
        // 确保editConfig.events对象存在
        if (!editConfig.events) {
            editConfig.events = {};
        }
        
        // 根据事件类型保存代码到相应属性
        switch (eventType) {
        case "focusLost":
            // 焦点丢失事件处理
            if (code.trim() !== "") {
                editConfig.events.onFocusLost = code.trim();
            } else {
                delete editConfig.events.onFocusLost;  // 删除空的事件配置
            }
            break;
            
        case "change":
            // 变化事件处理 - 根据控件类型设置相应的事件属性
            switch (editConfig.type) {
            case "text":
            case "password":
                if (code.trim() !== "") {
                    editConfig.events.onTextChanged = code.trim();
                } else {
                    delete editConfig.events.onTextChanged;
                }
                break;
            case "number":
            case "dropdown":
                if (code.trim() !== "") {
                    editConfig.events.onValueChanged = code.trim();
                } else {
                    delete editConfig.events.onValueChanged;
                }
                break;
            case "button":
                if (code.trim() !== "") {
                    editConfig.events.onClicked = code.trim();
                } else {
                    delete editConfig.events.onClicked;
                }
                break;
            }
            break;
        }
        
        // 如果events对象为空，删除整个events属性
        if (Object.keys(editConfig.events).length === 0) {
            delete editConfig.events;
        }
        
        // 触发配置变更通知（如果需要的话）
        // editConfigChanged();  // 注释掉，因为直接修改了引用对象
    }
}