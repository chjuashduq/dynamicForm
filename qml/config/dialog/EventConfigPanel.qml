import QtQuick 6.5
import QtQuick.Controls 6.5
import QtQuick.Layouts 1.4

/**
 * 事件配置面板
 * 负责控件事件的配置
 */
GroupBox {
    id: eventConfigPanel
    title: "事件配置"
    
    property var editConfig: ({})
    property var typeManager: null
    
    signal eventEditRequested(string eventType, string currentCode)

    Column {
        width: parent.width
        spacing: 15

        // 焦点丢失事件
        RowLayout {
            width: parent.width
            spacing: 10

            Label { 
                text: "焦点丢失事件:"
                Layout.preferredWidth: 120
            }
            
            Button {
                text: "编写函数"
                onClicked: {
                    var currentCode = (editConfig.events && editConfig.events.onFocusLost) || "";
                    eventEditRequested("focusLost", currentCode);
                }
            }
            
            Label {
                text: (editConfig.events && editConfig.events.onFocusLost) ? "已配置" : "未配置"
                color: (editConfig.events && editConfig.events.onFocusLost) ? "#28a745" : "#6c757d"
                Layout.fillWidth: true
            }
        }

        // 变化事件
        RowLayout {
            width: parent.width
            visible: typeManager && typeManager.hasChangeEvent(editConfig.type)
            spacing: 10

            Label { 
                text: typeManager ? typeManager.getChangeEventLabel(editConfig.type) : "变化事件:"
                Layout.preferredWidth: 120
            }
            
            Button {
                text: "编写函数"
                onClicked: {
                    var currentCode = getChangeEventText();
                    eventEditRequested("change", currentCode);
                }
            }
            
            Label {
                text: getChangeEventText() ? "已配置" : "未配置"
                color: getChangeEventText() ? "#28a745" : "#6c757d"
                Layout.fillWidth: true
            }
        }
    }

    function getChangeEventText() {
        if (!editConfig.events) return "";
        
        switch (editConfig.type) {
        case "text":
        case "password":
            return editConfig.events.onTextChanged || "";
        case "number":
        case "dropdown":
            return editConfig.events.onValueChanged || "";
        case "button":
            return editConfig.events.onClicked || "";
        default:
            return "";
        }
    }

    function updateEvent(eventType, code) {
        // 确保editConfig.events存在
        if (!editConfig.events) {
            editConfig.events = {};
        }
        
        // 根据事件类型保存代码
        switch (eventType) {
        case "focusLost":
            if (code.trim() !== "") {
                editConfig.events.onFocusLost = code.trim();
            } else {
                delete editConfig.events.onFocusLost;
            }
            break;
        case "change":
            // 根据控件类型设置相应的事件
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
        
        // 如果events对象为空，删除它
        if (Object.keys(editConfig.events).length === 0) {
            delete editConfig.events;
        }
        
        // 触发更新
        editConfigChanged();
    }
}