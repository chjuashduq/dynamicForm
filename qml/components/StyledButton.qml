import QtQuick 6.5
import QtQuick.Controls 6.5
import QtQuick.Layouts 1.15
import Common 1.0

/**
 * 美化的按钮
 */
StyledBase {
    id: root
    showLabel: false // Buttons usually don't have a side label

    // Set implicit size so the RowLayout sizes correctly
    implicitWidth: control.implicitWidth
    implicitHeight: control.implicitHeight

    property alias text: control.text
    property alias checkable: control.checkable
    property alias checked: control.checked
    property string buttonType: "primary"  // primary, secondary, danger
    // Note: Button's contentItem color is managed by buttonType, not directly exposed

    // Expose clicked signal
    signal clicked

    property var defaultProps: {
        "text": "Styled Button",
        "width": 120,
        "layoutType": "fill",
        "flex": 1,
        "widthPercent": 100,
        "visible": true,
        "enabled": true,
        "key": "",
        "valid": true
    }

    function generateCode(props, childrenCode, indent, events, functions) {
        var layoutProps = generateLayoutCode(props, indent);
        var code = "StyledButton {\n" + indent + "    text: \"" + props.text + "\"\n" + indent + "    enabled: " + props.enabled + "\n" + layoutProps;

        if (props.key && props.key.trim() !== "") {
            code += indent + "    key: \"" + props.key + "\"\n";
        }

        if (events && events.onClicked) {
            // Helper to wrap code
            function wrapCode(c) {
                return "scriptEngine.executeFunction(" + JSON.stringify(c) + ", {self: root})";
            }

            if (props.key && props.key.trim() !== "" && functions) {
                var funcName = props.key + "_Clicked";
                code += indent + "    onClicked: " + funcName + "()\n";

                var funcCode = "    function " + funcName + "() {\n" + "        " + wrapCode(events.onClicked) + "\n" + "    }";
                functions.push(funcCode);
            } else {
                code += indent + "    onClicked: {\n" + indent + "        " + wrapCode(events.onClicked) + "\n" + indent + "    }\n";
            }
        }

        code += generateCommonEventsCode(props, events, indent, functions);

        code += indent + "}";
        return code;
    }

    Button {
        id: control
        // Layout.fillWidth only when explicitly needed
        // If layoutType is fixed, StyledBase handles the container width,
        // but Button inside should probably fill the container.

        text: "Button" // Default, overwritten by alias

        // Styling logic from original StyledButton
        height: AppStyles.buttonHeight
        font.pixelSize: AppStyles.fontSizeMedium
        font.family: AppStyles.fontFamily
        font.bold: true

        leftPadding: AppStyles.buttonPadding
        rightPadding: AppStyles.buttonPadding

        contentItem: Text {
            text: control.text
            font: control.font
            color: root.buttonType === "secondary" ? AppStyles.textPrimary : "white"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        background: Rectangle {
            color: {
                if (!control.enabled)
                    return AppStyles.textDisabled;
                if (control.pressed) {
                    if (root.buttonType === "primary")
                        return AppStyles.buttonPrimaryPressed;
                    if (root.buttonType === "danger")
                        return AppStyles.buttonDangerHover;
                    return AppStyles.buttonSecondaryHover;
                }
                if (control.hovered) {
                    if (root.buttonType === "primary")
                        return AppStyles.buttonPrimaryHover;
                    if (root.buttonType === "danger")
                        return AppStyles.buttonDangerHover;
                    return AppStyles.buttonSecondaryHover;
                }
                if (root.buttonType === "primary")
                    return AppStyles.buttonPrimary;
                if (root.buttonType === "danger")
                    return AppStyles.buttonDanger;
                return AppStyles.buttonSecondary;
            }
            radius: AppStyles.buttonRadius

            Behavior on color {
                ColorAnimation {
                    duration: AppStyles.animationDuration
                }
            }
        }

        // Hover effect
        HoverHandler {
            cursorShape: Qt.PointingHandCursor
        }

        // Forward clicked signal
        onClicked: root.clicked()
    }
}
