import QtQuick 6.5
import QtQuick.Controls 6.5
import QtQuick.Layouts 1.15
import Common 1.0

/**
 * 美化的文本输入框
 */
StyledBase {
    id: root
    label: "文本输入"

    // Aliases to inner control
    property alias text: control.text
    property alias placeholderText: control.placeholderText
    property alias readOnly: control.readOnly
    property alias echoMode: control.echoMode
    property alias color: control.color

    property var defaultProps: mergeProps({
        "label": "文本输入",
        "placeholder": "请输入内容",
        "text": "",
        "readOnly": false
    })

    function generateCode(props, childrenCode, indent, events, functions) {
        var layoutProps = generateLayoutCode(props, indent);
        var code = "StyledTextField {\n" + indent + "    text: \"" + props.text + "\"\n" + indent + "    placeholderText: \"" + props.placeholder + "\"\n" + indent + "    readOnly: " + props.readOnly + "\n" + indent + "    enabled: " + props.enabled + "\n" + layoutProps;

        if (props.key && props.key.trim() !== "") {
            code += indent + "    key: \"" + props.key + "\"\n";
        }

        // Helper to wrap code
        function wrapCode(c, args) {
            var contextObj = "{self: root" + (args ? ", " + args : "") + "}";
            return "scriptEngine.executeFunction(" + JSON.stringify(c) + ", " + contextObj + ")";
        }

        if (events && events.onEditingFinished) {
            if (props.key && props.key.trim() !== "" && functions) {
                var funcName = props.key + "_EditingFinished";
                code += indent + "    onEditingFinished: " + funcName + "()\n";

                var funcCode = "    function " + funcName + "() {\n" + "        " + wrapCode(events.onEditingFinished) + "\n" + "    }";
                functions.push(funcCode);
            } else {
                code += indent + "    onEditingFinished: {\n" + indent + "        " + wrapCode(events.onEditingFinished) + "\n" + indent + "    }\n";
            }
        }

        if (events && events.onTextEdited) {
            if (props.key && props.key.trim() !== "" && functions) {
                var funcName = props.key + "_TextEdited";
                code += indent + "    onTextEdited: " + funcName + "()\n";

                var funcCode = "    function " + funcName + "() {\n" + "        " + wrapCode(events.onTextEdited) + "\n" + "    }";
                functions.push(funcCode);
            } else {
                code += indent + "    onTextEdited: {\n" + indent + "        " + wrapCode(events.onTextEdited) + "\n" + indent + "    }\n";
            }
        }

        code += generateCommonEventsCode(props, events, indent, functions);

        code += indent + "}";
        return code;
    }

    TextField {
        id: control
        Layout.fillWidth: true

        property bool hasError: false

        height: AppStyles.inputHeight
        font.pixelSize: AppStyles.fontSizeMedium
        font.family: AppStyles.fontFamily
        color: AppStyles.textPrimary
        placeholderTextColor: AppStyles.textPlaceholder
        selectByMouse: true

        leftPadding: AppStyles.inputPadding
        rightPadding: AppStyles.inputPadding

        onEditingFinished: root.editingFinished()
        onTextEdited: root.textEdited()

        background: Rectangle {
            color: control.enabled ? AppStyles.inputBackground : AppStyles.backgroundColor
            border.color: {
                if (control.hasError)
                    return AppStyles.inputBorderError;
                if (control.activeFocus)
                    return AppStyles.inputBorderFocus;
                return AppStyles.inputBorder;
            }
            border.width: control.activeFocus ? 2 : AppStyles.inputBorderWidth
            radius: AppStyles.inputRadius

            Behavior on border.color {
                ColorAnimation {
                    duration: AppStyles.animationDuration
                }
            }

            Behavior on border.width {
                NumberAnimation {
                    duration: AppStyles.animationDuration
                }
            }
        }
    }

    signal editingFinished
    signal textEdited
}
