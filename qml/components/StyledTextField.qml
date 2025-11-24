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

    function generateCode(props, childrenCode, indent) {
        var layoutProps = generateLayoutCode(props, indent);
        return "StyledTextField {\n" + indent + "    label: \"" + props.label + "\"\n" + indent + "    labelWidth: " + props.labelWidth + "\n" + indent + "    showLabel: " + props.showLabel + "\n" + indent + "    placeholderText: \"" + props.placeholder + "\"\n" + indent + "    text: \"" + props.text + "\"\n" + indent + "    readOnly: " + props.readOnly + "\n" + indent + "    enabled: " + props.enabled + "\n" + layoutProps + indent + "}";
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
}
