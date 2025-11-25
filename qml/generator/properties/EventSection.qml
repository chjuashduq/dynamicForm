import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Common 1.0

ColumnLayout {
    id: root
    Layout.fillWidth: true
    spacing: 0 // Spacing handled by CollapsePanels themselves or parent

    property var targetItem
    property var onPropertyChanged

    function hasEvents(type) {
        return ["StyledButton", "StyledTextField", "StyledComboBox", "StyledSpinBox"].indexOf(type) !== -1;
    }

    function getEventCode(eventName) {
        if (targetItem && targetItem.events && targetItem.events[eventName]) {
            return targetItem.events[eventName];
        }
        return "";
    }

    function updateEvent(eventName, code) {
        if (!targetItem)
            return;

        // Create a copy of events object or new one
        var events = targetItem.events || {};
        events[eventName] = code;

        if (onPropertyChanged) {
            // We pass the entire events object as a single property "events"
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
}
