import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../Common"

CollapsePanel {
    title: "数据控制"
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

    visible: hasProp("key") || hasProp("from") || hasProp("to") || hasProp("value") || hasProp("readOnly") || hasProp("enabled") || hasProp("required")

    // Key
    RowLayout {
        visible: hasProp("key")
        Text {
            text: "Key (标识)"
            color: AppStyles.textPrimary
            Layout.preferredWidth: 70
        }
        TextField {
            Layout.fillWidth: true
            text: getProp("key") || ""
            onEditingFinished: updateProp("key", text)
        }
    }

    // [新增] Required (必填/不允许为空)
    // 排除按钮和布局类型
    RowLayout {
        visible: targetItem && targetItem.type !== "StyledButton" && targetItem.type !== "StyledRow" && targetItem.type !== "StyledLabel"
        Text {
            text: "必填 (Required)"
            color: AppStyles.textPrimary
            Layout.preferredWidth: 70
        }
        CheckBox {
            checked: getProp("required") === true
            onToggled: updateProp("required", checked)
        }
    }

    // From
    RowLayout {
        visible: hasProp("from")
        Text {
            text: "最小值"
            color: AppStyles.textPrimary
            Layout.preferredWidth: 70
        }
        SpinBox {
            Layout.fillWidth: true
            from: -9999
            to: 9999
            value: (getProp("from") != null) ? getProp("from") : 0
            onValueModified: updateProp("from", value)
        }
    }
    // To
    RowLayout {
        visible: hasProp("to")
        Text {
            text: "最大值"
            color: AppStyles.textPrimary
            Layout.preferredWidth: 70
        }
        SpinBox {
            Layout.fillWidth: true
            from: -9999
            to: 9999
            value: (getProp("to") != null) ? getProp("to") : 100
            onValueModified: updateProp("to", value)
        }
    }
    // Value
    RowLayout {
        visible: hasProp("value")
        Text {
            text: "当前值"
            color: AppStyles.textPrimary
            Layout.preferredWidth: 70
        }
        SpinBox {
            Layout.fillWidth: true
            from: -9999
            to: 9999
            value: (getProp("value") != null) ? getProp("value") : 0
            onValueModified: updateProp("value", value)
        }
    }
    // ReadOnly
    RowLayout {
        visible: hasProp("readOnly")
        Text {
            text: "只读模式"
            color: AppStyles.textPrimary
            Layout.preferredWidth: 70
        }
        CheckBox {
            checked: getProp("readOnly") === true
            onToggled: updateProp("readOnly", checked)
        }
    }
    // Enabled
    RowLayout {
        visible: hasProp("enabled")
        Text {
            text: "启用状态"
            color: AppStyles.textPrimary
            Layout.preferredWidth: 70
        }
        CheckBox {
            checked: getProp("enabled") !== false
            onToggled: updateProp("enabled", checked)
        }
    }
}
