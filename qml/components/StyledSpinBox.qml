import QtQuick 6.5
import QtQuick.Controls 6.5
import QtQuick.Layouts 1.15
import "../Common" as Common

/**
 * 美化的数字输入框
 */
StyledBase {
    id: root
    label: "数字输入"

    property alias from: control.from
    property alias to: control.to
    property alias value: control.value
    property alias stepSize: control.stepSize
    property alias editable: control.editable

    property var defaultProps: mergeProps({
        "label": "数字输入",
        "from": 0,
        "to": 100,
        "value": 0,
        "enabled": true,
        "visible": true,
        "labelWidth": 80,
        "showLabel": true
    })

    function generateCode(props, childrenCode, indent, events, functions) {
        var layoutProps = generateLayoutCode(props, indent);

        // [修复] 增加默认值保护
        var code = "StyledSpinBox {\n" + indent + "    label: \"" + (props.label || "") + "\"\n" + indent + "    labelWidth: " + (props.labelWidth || 80) + "\n" + indent + "    showLabel: " + (props.showLabel !== false) + "\n" + indent + "    from: " + (props.from || 0) + "\n" + indent + "    to: " + (props.to || 100) + "\n" + indent + "    value: " + (props.value || 0) + "\n" + indent + "    enabled: " + (props.enabled !== false) + "\n" + layoutProps;

        if (props.key && props.key.trim() !== "") {
            code += indent + "    key: \"" + props.key + "\"\n";
        }

        if (events && events.hasOwnProperty("onValueModified")) {
            function wrapCode(c, args) {
                var contextObj = "{self: root" + (args ? ", " + args : "") + "}";
                return "scriptEngine.executeFunction(" + JSON.stringify(c) + ", " + contextObj + ")";
            }

            if (props.key && props.key.trim() !== "" && functions) {
                var funcName = props.key + "_ValueModified";
                code += indent + "    onValueModified: " + funcName + "()\n";
                var comment = props.label ? (" // " + props.label + " 值改变") : "";
                var body = events.onValueModified ? ("        " + wrapCode(events.onValueModified)) : "";
                var funcCode = "    function " + funcName + "() {" + comment + "\n" + body + "\n    }";
                functions.push(funcCode);
            } else if (events.onValueModified) {
                code += indent + "    onValueModified: {\n" + indent + "        " + wrapCode(events.onValueModified) + "\n" + indent + "    }\n";
            }
        }

        code += generateCommonEventsCode(props, events, indent, functions);
        code += indent + "}";
        return code;
    }

    SpinBox {
        id: control
        Layout.fillWidth: true
        editable: true
        onValueModified: root.valueModified()

        contentItem: TextInput {
            z: 2
            text: control.textFromValue(control.value, control.locale)
            font: control.font
            color: Common.AppStyles.textPrimary
            selectionColor: "#21be2b"
            selectedTextColor: "#ffffff"
            horizontalAlignment: Qt.AlignHCenter
            verticalAlignment: Qt.AlignVCenter
            readOnly: !control.editable
            validator: control.validator
            inputMethodHints: Qt.ImhFormattedNumbersOnly
        }

        background: Rectangle {
            implicitWidth: 140
            border.color: {
                if (root.hasError)
                    return "red";
                return control.activeFocus ? Common.AppStyles.primaryColor : Common.AppStyles.borderColor;
            }
            border.width: (control.activeFocus || root.hasError) ? 2 : 1
            radius: Common.AppStyles.radiusMedium
        }
    }

    signal valueModified
}
