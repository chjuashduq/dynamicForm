import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Common 1.0

CollapsePanel {
    title: "容器设置"
    Layout.fillWidth: true

    property var targetItem
    signal propertyChanged(string name, var value)

    function hasProp(name) {
        return targetItem && targetItem.props && targetItem.props.hasOwnProperty(name);
    }

    function getProp(name) {
        return hasProp(name) ? targetItem.props[name] : null;
    }

    function updateProp(name, value) {
        propertyChanged(name, value);
    }

    visible: hasProp("spacing") || hasProp("wrap") || hasProp("padding")

    // Spacing
    RowLayout {
        visible: hasProp("spacing")
        Layout.fillWidth: true
        spacing: 10
        Text {
            text: "间距 (px)"
            color: AppStyles.textPrimary
            Layout.preferredWidth: 70
        }
        SpinBox {
            Layout.fillWidth: true
            from: 0
            to: 50
            value: (getProp("spacing") != null) ? getProp("spacing") : 10
            onValueModified: updateProp("spacing", value)
        }
    }

    // Padding
    RowLayout {
        visible: hasProp("padding")
        Layout.fillWidth: true
        spacing: 10
        Text {
            text: "内边距 (px)"
            color: AppStyles.textPrimary
            Layout.preferredWidth: 70
        }
        SpinBox {
            Layout.fillWidth: true
            from: 0
            to: 50
            value: (getProp("padding") != null) ? getProp("padding") : 0
            onValueModified: updateProp("padding", value)
        }
    }

    // Wrap
    RowLayout {
        visible: hasProp("wrap")
        Layout.fillWidth: true
        spacing: 10
        Text {
            text: "自动换行"
            color: AppStyles.textPrimary
            Layout.preferredWidth: 70
        }
        CheckBox {
            checked: getProp("wrap") !== false
            onToggled: updateProp("wrap", checked)
        }
    }
}
