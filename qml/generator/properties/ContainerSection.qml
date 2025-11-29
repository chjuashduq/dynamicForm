import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../Common"

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

    visible: hasProp("spacing") || hasProp("wrap") || hasProp("paddingTop")

    // Spacing
    RowLayout {
        visible: hasProp("spacing")
        Layout.fillWidth: true
        spacing: 5
        Text {
            text: "间距"
            color: AppStyles.textPrimary
            Layout.preferredWidth: 60
        }
        Slider {
            Layout.fillWidth: true
            from: 0
            to: 100
            value: getProp("spacing") || 0
            onMoved: updateProp("spacing", Math.round(value))
        }
        SpinBox {
            // [修复] 设置固定宽度并关闭自动填充，防止被压缩
            Layout.preferredWidth: 80
            Layout.fillWidth: false
            from: 0
            to: 200
            value: getProp("spacing") || 0
            editable: true
            onValueModified: updateProp("spacing", value)
        }
    }

    // Padding Controls Helper
    component PaddingControl: RowLayout {
        property string label: ""
        property string propName: ""
        Layout.fillWidth: true
        spacing: 5
        Text {
            text: label
            color: AppStyles.textPrimary
            Layout.preferredWidth: 60
        }
        Slider {
            Layout.fillWidth: true
            from: 0
            to: 100
            value: getProp(propName) || 0
            onMoved: updateProp(propName, Math.round(value))
        }
        SpinBox {
            // [修复] 设置固定宽度
            Layout.preferredWidth: 80
            Layout.fillWidth: false
            from: 0
            to: 200
            value: getProp(propName) || 0
            editable: true
            onValueModified: updateProp(propName, value)
        }
    }

    PaddingControl {
        visible: hasProp("paddingTop")
        label: "上边距"
        propName: "paddingTop"
    }
    PaddingControl {
        visible: hasProp("paddingBottom")
        label: "下边距"
        propName: "paddingBottom"
    }
    PaddingControl {
        visible: hasProp("paddingLeft")
        label: "左边距"
        propName: "paddingLeft"
    }
    PaddingControl {
        visible: hasProp("paddingRight")
        label: "右边距"
        propName: "paddingRight"
    }

    // Wrap
    RowLayout {
        visible: hasProp("wrap")
        Layout.fillWidth: true
        spacing: 10
        Text {
            text: "自动换行"
            color: AppStyles.textPrimary
            Layout.preferredWidth: 60
        }
        CheckBox {
            checked: getProp("wrap") !== false
            onToggled: updateProp("wrap", checked)
        }
    }
}
