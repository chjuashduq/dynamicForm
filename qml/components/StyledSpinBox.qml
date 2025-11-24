import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Common 1.0

StyledBase {
    id: root
    label: "数字输入"

    // Aliases
    property alias from: control.from
    property alias to: control.to
    property alias value: control.value
    property alias stepSize: control.stepSize
    property alias editable: control.editable
    // Note: SpinBox doesn't expose a simple color property, so we don't alias it

    property var defaultProps: mergeProps({
        "label": "数字输入",
        "from": 0,
        "to": 100,
        "value": 0
    })

    function generateCode(props, childrenCode, indent) {
        var layoutProps = generateLayoutCode(props, indent);
        return "StyledSpinBox {\n" + indent + "    label: \"" + props.label + "\"\n" + indent + "    labelWidth: " + props.labelWidth + "\n" + indent + "    showLabel: " + props.showLabel + "\n" + indent + "    from: " + props.from + "\n" + indent + "    to: " + props.to + "\n" + indent + "    value: " + props.value + "\n" + indent + "    enabled: " + props.enabled + "\n" + layoutProps + indent + "}";
    }

    SpinBox {
        id: control
        Layout.fillWidth: true
        editable: true
    }
}
