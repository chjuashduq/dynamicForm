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

    function generateCode(props, childrenCode, indent, events, functions) {
        var layoutProps = generateLayoutCode(props, indent);
        var code = "StyledSpinBox {\n" + indent + "    label: \"" + props.label + "\"\n" + indent + "    labelWidth: " + props.labelWidth + "\n" + indent + "    showLabel: " + props.showLabel + "\n" + indent + "    from: " + props.from + "\n" + indent + "    to: " + props.to + "\n" + indent + "    value: " + props.value + "\n" + indent + "    enabled: " + props.enabled + "\n" + layoutProps;

        if (props.key && props.key.trim() !== "") {
            code += indent + "    key: \"" + props.key + "\"\n";
        }

        if (events && events.onValueModified) {
            if (props.key && props.key.trim() !== "" && functions) {
                var funcName = props.key + "_ValueModified";
                code += indent + "    onValueModified: " + funcName + "()\n";

                var funcCode = "    function " + funcName + "() {\n" + "        " + events.onValueModified.replace(/\n/g, "\n        ") + "\n" + "    }";
                functions.push(funcCode);
            } else {
                code += indent + "    onValueModified: {\n" + indent + "        " + events.onValueModified.replace(/\n/g, "\n" + indent + "        ") + "\n" + indent + "    }\n";
            }
        }

        code += indent + "}";
        return code;
    }

    SpinBox {
        id: control
        Layout.fillWidth: true
        editable: true
        onValueModified: root.valueModified()
    }

    signal valueModified
}
