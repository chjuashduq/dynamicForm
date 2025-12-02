import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../Common"

ColumnLayout {
    id: root
    Layout.fillWidth: true
    spacing: 0

    property var targetItem
    property var onPropertyChanged

    function hasEvents(type) {
        return ["StyledButton", "StyledTextField", "StyledComboBox", "StyledSpinBox"].indexOf(type) !== -1;
    }

    // API Documentation Popup
    Popup {
        id: apiHelpPopup
        width: 600
        height: 500
        anchors.centerIn: Overlay.overlay
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        background: Rectangle {
            color: AppStyles.backgroundColor
            border.color: AppStyles.borderColor
            border.width: 1
            radius: 8
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 10

            Text {
                text: "API 函数使用说明"
                font.pixelSize: 18
                font.bold: true
                color: AppStyles.textPrimary
            }

            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true

                TextArea {
                    readOnly: true
                    textFormat: Text.MarkdownText
                    wrapMode: Text.WordWrap
                    color: AppStyles.textPrimary
                    text: `
### 全局对象
- **self**: 当前触发事件的控件对象
  - **self.valid**: (var) 设置控件验证状态，true:合格, false:不合格, "unchecked":待验证
- **formAPI**: 表单操作API对象
- **MySqlHelper**: 数据库操作对象
- **MessageManager**: 消息管理器 (显示Toast消息)

### FormAPI 常用函数
- **getControlValue(key)**: 获取指定控件的值
- **setControlValue(key, value)**: 设置指定控件的值
- **getControlText(key)**: 获取指定控件的文本
- **setControlText(key, text)**: 设置指定控件的文本
- **enableControl(key)**: 启用指定控件
- **disableControl(key)**: 禁用指定控件
- **showControl(key)**: 显示指定控件
- **hideControl(key)**: 隐藏指定控件
- **showMessage(msg, type)**: 显示消息提示 (type: "info", "success", "error", "warning")
- **validateAll()**: 验证所有控件
- **resetControl(key)**: 重置指定控件
- **resetForm()**: 重置整个表单
- **setTempValue(key, value)**: 设置临时变量
- **getTempValue(key)**: 获取临时变量
- **isControlValid(key)**: 检查单个控件是否验证通过
- **areControlsValid(keys)**: 检查多个控件是否都验证通过 (keys为数组)
`
                }
            }

            Button {
                text: "关闭"
                Layout.alignment: Qt.AlignRight
                onClicked: apiHelpPopup.close()
            }
        }
    }

    Button {
        text: "查看 API 文档"
        Layout.alignment: Qt.AlignRight
        Layout.rightMargin: 10
        onClicked: apiHelpPopup.open()
    }

    // [修复] 增加非空检查
    function getEventCode(eventName) {
        if (targetItem && targetItem.events && targetItem.events[eventName]) {
            return targetItem.events[eventName];
        }
        return "";
    }

    // [修复] 增加非空检查
    function updateEvent(eventName, code) {
        if (!targetItem)
            return;

        var events = targetItem.events ? JSON.parse(JSON.stringify(targetItem.events)) : {};
        events[eventName] = code;

        if (onPropertyChanged) {
            onPropertyChanged("events", events);
        }
    }

    // StyledButton: onClicked
    CollapsePanel {
        visible: targetItem && targetItem.type === "StyledButton"
        Layout.fillWidth: true
        title: "点击事件 (onClicked)"
        isExpanded: false

        TextArea {
            Layout.fillWidth: true
            Layout.preferredHeight: 200
            text: getEventCode("onClicked")
            placeholderText: "console.log('Clicked');"
            background: Rectangle {
                border.color: parent.activeFocus ? AppStyles.primaryColor : AppStyles.borderColor
                radius: 4
            }
            onTextChanged: {
                if (activeFocus)
                    updateEvent("onClicked", text);
            }
        }
    }

    // StyledTextField: onEditingFinished
    CollapsePanel {
        visible: targetItem && targetItem.type === "StyledTextField"
        Layout.fillWidth: true
        title: "编辑完成 (onEditingFinished)"
        isExpanded: false

        TextArea {
            Layout.fillWidth: true
            Layout.preferredHeight: 200
            text: getEventCode("onEditingFinished")
            placeholderText: "console.log('Finished');"
            background: Rectangle {
                border.color: parent.activeFocus ? AppStyles.primaryColor : AppStyles.borderColor
                radius: 4
            }
            onTextChanged: {
                if (activeFocus)
                    updateEvent("onEditingFinished", text);
            }
        }
    }

    // StyledTextField: onTextEdited
    CollapsePanel {
        visible: targetItem && targetItem.type === "StyledTextField"
        Layout.fillWidth: true
        title: "文本改变 (onTextEdited)"
        isExpanded: false

        TextArea {
            Layout.fillWidth: true
            Layout.preferredHeight: 200
            text: getEventCode("onTextEdited")
            placeholderText: "console.log('Edited');"
            background: Rectangle {
                border.color: parent.activeFocus ? AppStyles.primaryColor : AppStyles.borderColor
                radius: 4
            }
            onTextChanged: {
                if (activeFocus)
                    updateEvent("onTextEdited", text);
            }
        }
    }

    // StyledComboBox: onActivated
    CollapsePanel {
        visible: targetItem && targetItem.type === "StyledComboBox"
        Layout.fillWidth: true
        title: "选中改变 (onActivated)"
        isExpanded: false

        TextArea {
            Layout.fillWidth: true
            Layout.preferredHeight: 200
            text: getEventCode("onActivated")
            placeholderText: "console.log('Activated: ' + index);"
            background: Rectangle {
                border.color: parent.activeFocus ? AppStyles.primaryColor : AppStyles.borderColor
                radius: 4
            }
            onTextChanged: {
                if (activeFocus)
                    updateEvent("onActivated", text);
            }
        }
    }

    // StyledComboBox: onCurrentIndexChanged
    CollapsePanel {
        visible: targetItem && targetItem.type === "StyledComboBox"
        Layout.fillWidth: true
        title: "值改变 (onCurrentIndexChanged)"
        isExpanded: false

        TextArea {
            Layout.fillWidth: true
            Layout.preferredHeight: 200
            text: getEventCode("onCurrentIndexChanged")
            placeholderText: "console.log('Index Changed: ' + currentIndex);"
            background: Rectangle {
                border.color: parent.activeFocus ? AppStyles.primaryColor : AppStyles.borderColor
                radius: 4
            }
            onTextChanged: {
                if (activeFocus)
                    updateEvent("onCurrentIndexChanged", text);
            }
        }
    }

    // StyledSpinBox: onValueModified
    CollapsePanel {
        visible: targetItem && targetItem.type === "StyledSpinBox"
        Layout.fillWidth: true
        title: "值改变 (onValueModified)"
        isExpanded: false

        TextArea {
            Layout.fillWidth: true
            Layout.preferredHeight: 200
            text: getEventCode("onValueModified")
            placeholderText: "console.log('Value: ' + value);"
            background: Rectangle {
                border.color: parent.activeFocus ? AppStyles.primaryColor : AppStyles.borderColor
                radius: 4
            }
            onTextChanged: {
                if (activeFocus)
                    updateEvent("onValueModified", text);
            }
        }
    }

    // 通用事件
    CollapsePanel {
        visible: targetItem
        Layout.fillWidth: true
        title: "可见性改变 (onVisibleChanged)"
        isExpanded: false

        TextArea {
            Layout.fillWidth: true
            Layout.preferredHeight: 200
            text: getEventCode("onVisibleChanged")
            placeholderText: "console.log('Visible: ' + visible);"
            background: Rectangle {
                border.color: parent.activeFocus ? AppStyles.primaryColor : AppStyles.borderColor
                radius: 4
            }
            onTextChanged: {
                if (activeFocus)
                    updateEvent("onVisibleChanged", text);
            }
        }
    }

    CollapsePanel {
        visible: targetItem
        Layout.fillWidth: true
        title: "启用状态改变 (onEnabledChanged)"
        isExpanded: false

        TextArea {
            Layout.fillWidth: true
            Layout.preferredHeight: 200
            text: getEventCode("onEnabledChanged")
            placeholderText: "console.log('Enabled: ' + enabled);"
            background: Rectangle {
                border.color: parent.activeFocus ? AppStyles.primaryColor : AppStyles.borderColor
                radius: 4
            }
            onTextChanged: {
                if (activeFocus)
                    updateEvent("onEnabledChanged", text);
            }
        }
    }
}
