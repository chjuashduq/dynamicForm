import QtQuick 6.5
import QtQuick.Controls 6.5
import QtQuick.Layouts 1.15
import "../Common" as Common

/**
 * 美化的按钮组件
 */
StyledBase {
    id: root
    showLabel: false

    implicitWidth: control.implicitWidth
    implicitHeight: control.implicitHeight

    property alias text: control.text
    property alias checkable: control.checkable
    property alias checked: control.checked
    property string buttonType: "primary"

    valid: undefined

    signal clicked

    property bool enableAnimations: false
    resources: [
        Timer {
            interval: 200
            running: true
            repeat: false
            onTriggered: enableAnimations = true
        }
    ]

    property var defaultProps: {
        "text": "Styled Button",
        "width": 120,
        "layoutType": "fill",
        "flex": 1,
        "widthPercent": 100,
        "visible": true,
        "enabled": true,
        "key": "",
        "valid": undefined
    }

    function generateCode(props, childrenCode, indent, events, functions) {
        var layoutProps = generateLayoutCode(props, indent);

        // [修复] 增加默认值保护
        var code = "StyledButton {\n" + indent + "    text: \"" + (props.text || "Button") + "\"\n" + indent + "    enabled: " + (props.enabled !== false) + "\n" + layoutProps;

        if (props.key && props.key.trim() !== "") {
            code += indent + "    key: \"" + props.key + "\"\n";
        }

        if (events && events.hasOwnProperty("onClicked")) {
            function wrapCode(c) {
                return "scriptEngine.executeFunction(" + JSON.stringify(c) + ", {self: root})";
            }

            if (props.key && props.key.trim() !== "" && functions) {
                var funcName = props.key + "_Clicked";
                code += indent + "    onClicked: " + funcName + "()\n";
                var comment = props.label ? (" // " + props.label + " 点击事件") : (props.text ? (" // " + props.text + " 点击事件") : "");
                var body = events.onClicked ? ("        " + wrapCode(events.onClicked)) : "";
                var funcCode = "    function " + funcName + "() {" + comment + "\n" + body + "\n    }";
                functions.push(funcCode);
            } else if (events.onClicked) {
                code += indent + "    onClicked: {\n" + indent + "        " + wrapCode(events.onClicked) + "\n" + indent + "    }\n";
            }
        }

        code += generateCommonEventsCode(props, events, indent, functions);
        code += indent + "}";
        return code;
    }

    Button {
        id: control
        text: "Button"
        height: Common.AppStyles.buttonHeight
        font.pixelSize: Common.AppStyles.fontSizeMedium
        font.family: Common.AppStyles.fontFamily
        font.bold: true
        leftPadding: Common.AppStyles.buttonPadding
        rightPadding: Common.AppStyles.buttonPadding

        contentItem: Text {
            text: control.text
            font: control.font
            color: root.buttonType === "secondary" ? Common.AppStyles.textPrimary : "white"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        background: Rectangle {
            color: {
                if (!control.enabled)
                    return Common.AppStyles.textDisabled;
                if (control.pressed) {
                    if (root.buttonType === "primary")
                        return Common.AppStyles.buttonPrimaryPressed;
                    if (root.buttonType === "danger")
                        return Common.AppStyles.buttonDangerHover;
                    return Common.AppStyles.buttonSecondaryHover;
                }
                if (control.hovered) {
                    if (root.buttonType === "primary")
                        return Common.AppStyles.buttonPrimaryHover;
                    if (root.buttonType === "danger")
                        return Common.AppStyles.buttonDangerHover;
                    return Common.AppStyles.buttonSecondaryHover;
                }
                if (root.buttonType === "primary")
                    return Common.AppStyles.buttonPrimary;
                if (root.buttonType === "danger")
                    return Common.AppStyles.buttonDanger;
                return Common.AppStyles.buttonSecondary;
            }
            radius: Common.AppStyles.buttonRadius

            Behavior on color {
                enabled: root.enableAnimations
                ColorAnimation {
                    duration: Common.AppStyles.animationDuration
                }
            }
        }

        HoverHandler {
            cursorShape: Qt.PointingHandCursor
        }
        onClicked: root.clicked()
    }
}
