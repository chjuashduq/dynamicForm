import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Common 1.0

ColumnLayout {
    id: root
    Layout.fillWidth: true
    spacing: 0

    property var targetItem
    property var onPropertyChanged

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
  - **self.valid**: (bool) 设置控件验证状态，false表示验证失败
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

### 详细使用说明

#### 1. 消息提示 (MessageManager)
虽然可以直接使用 \`showMessage(msg, type)\` 快捷函数，但也可以通过 \`MessageManager\` 对象调用更多功能：
- **MessageManager.showToast(msg, type)**: 显示自动消失的提示消息
  - type: "info" (默认), "success" (成功), "error" (错误), "warning" (警告)
- **MessageManager.showDialog(msg, type, callback)**: 显示带确认按钮的对话框
  - callback: 点击确定后的回调函数

\`\`\`javascript
// 显示确认对话框
MessageManager.showDialog("确定要提交吗？", "warning", function() {
    showMessage("正在提交...", "info");
    // 执行提交逻辑
});
\`\`\`

#### 2. 数据库操作 (MySqlHelper)
提供直接操作数据库的能力：
- **MySqlHelper.select(table, columns, where)**: 查询数据
- **MySqlHelper.insert(table, data)**: 插入数据
- **MySqlHelper.update(table, data, where)**: 更新数据
- **MySqlHelper.remove(table, where)**: 删除数据

\`\`\`javascript
// 查询示例
var result = MySqlHelper.select("users", ["name", "email"], "age > 18");
if (result.length > 0) {
    var user = result[0];
    console.log(user.name);
}

// 插入示例
var data = { name: "张三", age: 20 };
MySqlHelper.insert("users", data);
\`\`\`

#### 3. 验证功能
- **self.valid**: 在事件中设置 \`self.valid = false\` 可标记当前控件验证失败。
- **isControlValid(key)**: 判断指定控件是否已通过验证。
- **areControlsValid(['key1', 'key2'])**: 判断一组控件是否都通过验证。

\`\`\`javascript
// 验证多个控件
if (areControlsValid(['username', 'password'])) {
    showMessage("验证通过", "success");
} else {
    showMessage("请检查输入", "error");
}
\`\`\`
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

    function getEventCode(eventName) {
        if (targetItem && targetItem.events && targetItem.events.hasOwnProperty(eventName)) {
            return targetItem.events[eventName] || "";
        }
        return "";
    }

    // [修改] 检查事件是否启用（存在key）
    function isEventEnabled(eventName) {
        return !!(targetItem && targetItem.events && targetItem.events.hasOwnProperty(eventName));
    }

    function updateEvent(eventName, code, isEnabled) {
        if (!targetItem)
            return;

        // 深拷贝 events 对象
        var events = targetItem.events ? JSON.parse(JSON.stringify(targetItem.events)) : {};

        if (isEnabled) {
            // 启用时，保存代码（即使为空）
            events[eventName] = code;
        } else {
            // 禁用时，删除 key
            if (events.hasOwnProperty(eventName)) {
                delete events[eventName];
            }
        }

        if (onPropertyChanged) {
            // 作为一个整体属性更新 "events"
            onPropertyChanged("events", events);
        }
    }

    // [新增] 封装事件编辑项组件
    component EventItem: CollapsePanel {
        property string eventName: ""
        property string titleText: ""
        property string placeholder: ""

        visible: targetItem
        Layout.fillWidth: true
        isExpanded: false

        // 自定义标题显示启用状态
        title: titleText + (isEventEnabled(eventName) ? " (已启用)" : "")

        ColumnLayout {
            spacing: 5
            Layout.fillWidth: true

            // [新增] 启用复选框
            CheckBox {
                text: "启用此事件" + (targetItem.props.label ? (" - " + targetItem.props.label) : "")
                checked: isEventEnabled(eventName)
                onToggled: {
                    updateEvent(eventName, codeArea.text, checked);
                }
            }

            // [修改] 支持滚动
            ScrollView {
                Layout.fillWidth: true
                Layout.preferredHeight: 200
                clip: true
                // 只有启用时才显示编辑框
                visible: isEventEnabled(eventName)

                TextArea {
                    id: codeArea
                    text: getEventCode(eventName)
                    placeholderText: placeholder
                    background: Rectangle {
                        border.color: parent.activeFocus ? AppStyles.primaryColor : AppStyles.borderColor
                        radius: 4
                    }
                    onTextChanged: {
                        if (activeFocus) {
                            // 文本变化时更新，保持启用状态
                            updateEvent(eventName, text, true);
                        }
                    }
                }
            }
        }
    }

    // StyledButton: onClicked
    EventItem {
        visible: targetItem && targetItem.type === "StyledButton"
        eventName: "onClicked"
        titleText: "点击事件 (onClicked)"
        placeholder: "console.log('Clicked');"
    }

    // StyledTextField: onEditingFinished
    EventItem {
        visible: targetItem && targetItem.type === "StyledTextField"
        eventName: "onEditingFinished"
        titleText: "编辑完成 (onEditingFinished)"
        placeholder: "console.log('Finished');"
    }

    // StyledTextField: onTextEdited
    EventItem {
        visible: targetItem && targetItem.type === "StyledTextField"
        eventName: "onTextEdited"
        titleText: "文本改变 (onTextEdited)"
        placeholder: "console.log('Edited');"
    }

    // StyledComboBox: onActivated
    EventItem {
        visible: targetItem && targetItem.type === "StyledComboBox"
        eventName: "onActivated"
        titleText: "选中改变 (onActivated)"
        placeholder: "console.log('Activated: ' + index);"
    }

    // StyledComboBox: onCurrentIndexChanged
    EventItem {
        visible: targetItem && targetItem.type === "StyledComboBox"
        eventName: "onCurrentIndexChanged"
        titleText: "值改变 (onCurrentIndexChanged)"
        placeholder: "console.log('Index Changed: ' + currentIndex);"
    }

    // StyledSpinBox: onValueModified
    EventItem {
        visible: targetItem && targetItem.type === "StyledSpinBox"
        eventName: "onValueModified"
        titleText: "值改变 (onValueModified)"
        placeholder: "console.log('Value: ' + value);"
    }

    // Common Events
    EventItem {
        visible: targetItem
        eventName: "onVisibleChanged"
        titleText: "可见性改变 (onVisibleChanged)"
        placeholder: "console.log('Visible: ' + visible);"
    }

    EventItem {
        visible: targetItem
        eventName: "onEnabledChanged"
        titleText: "启用状态改变 (onEnabledChanged)"
        placeholder: "console.log('Enabled: ' + enabled);"
    }
}
