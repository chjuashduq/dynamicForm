import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Common 1.0

StyledBase {
    id: root
    label: "下拉框"

    // Aliases
    property alias model: control.model
    property alias currentIndex: control.currentIndex
    property alias currentText: control.currentText
    property alias editable: control.editable
    // Note: ComboBox doesn't expose a simple color property

    property var defaultProps: mergeProps({
        "label": "下拉框",
        "model": [
            {
                "label": "选项1",
                "value": "opt1"
            },
            {
                "label": "选项2",
                "value": "opt2"
            }
        ]
    })

    function generateCode(props, childrenCode, indent, events, functions) {
        var layoutProps = generateLayoutCode(props, indent);
        var modelStr = JSON.stringify(props.model, null, 4).replace(/\n/g, "\n" + indent + "    ");
        var code = "StyledComboBox {\n" + indent + "    label: \"" + props.label + "\"\n" + indent + "    labelWidth: " + props.labelWidth + "\n" + indent + "    showLabel: " + props.showLabel + "\n" + indent + "    textRole: \"label\"\n" + indent + "    valueRole: \"value\"\n" + indent + "    model: " + modelStr + "\n" + indent + "    enabled: " + props.enabled + "\n" + layoutProps;

        if (props.key && props.key.trim() !== "") {
            code += indent + "    key: \"" + props.key + "\"\n";
        }

        if (events && events.onActivated) {
            if (props.key && props.key.trim() !== "" && functions) {
                var funcName = props.key + "_Activated";
                code += indent + "    onActivated: " + funcName + "(index)\n";

                var funcCode = "    function " + funcName + "(index) {\n" + "        " + events.onActivated.replace(/\n/g, "\n        ") + "\n" + "    }";
                functions.push(funcCode);
            } else {
                code += indent + "    onActivated: {\n" + indent + "        " + events.onActivated.replace(/\n/g, "\n" + indent + "        ") + "\n" + indent + "    }\n";
            }
        }
        if (events && events.onCurrentIndexChanged) {
            if (props.key && props.key.trim() !== "" && functions) {
                var funcName = props.key + "_CurrentIndexChanged";
                code += indent + "    onCurrentIndexChanged: " + funcName + "()\n";

                var funcCode = "    function " + funcName + "() {\n" + "        " + events.onCurrentIndexChanged.replace(/\n/g, "\n        ") + "\n" + "    }";
                functions.push(funcCode);
            } else {
                code += indent + "    onCurrentIndexChanged: {\n" + indent + "        " + events.onCurrentIndexChanged.replace(/\n/g, "\n" + indent + "        ") + "\n" + indent + "    }\n";
            }
        }

        code += indent + "}";
        return code;
    }

    ComboBox {
        id: control
        Layout.fillWidth: true
        textRole: "label"
        valueRole: "value"
        onActivated: index => root.activated(index)
    }

    signal activated(int index)
}
