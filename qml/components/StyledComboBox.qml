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

    function generateCode(props, childrenCode, indent) {
        var layoutProps = generateLayoutCode(props, indent);
        var modelStr = JSON.stringify(props.model, null, 4).replace(/\n/g, "\n" + indent + "    ");
        return "StyledComboBox {\n" + indent + "    label: \"" + props.label + "\"\n" + indent + "    labelWidth: " + props.labelWidth + "\n" + indent + "    showLabel: " + props.showLabel + "\n" + indent + "    textRole: \"label\"\n" + indent + "    valueRole: \"value\"\n" + indent + "    model: " + modelStr + "\n" + indent + "    enabled: " + props.enabled + "\n" + layoutProps + indent + "}";
    }

    ComboBox {
        id: control
        Layout.fillWidth: true
        textRole: "label"
        valueRole: "value"
    }
}
