import QtQuick 6.5
import QtQuick.Controls 6.5
import QtQuick.Layouts 1.15
import Common 1.0

/**
 * 美化的按钮组件
 */
StyledBase {
    id: root
    showLabel: false

    implicitWidth: control.implicitWidth
    implicitHeight: control.implicitHeight

    // 导出属性
    property alias text: control.text
    property alias checkable: control.checkable
    property alias checked: control.checked
    property string buttonType: "primary"

    // [关键修改] 按钮不需要验证，设置为 undefined
    // 覆盖 StyledBase 的默认逻辑，使其在验证时被跳过
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
        "valid": undefined // 生成代码时也默认为 undefined
    }

    function generateCode(props, childrenCode, indent, events, functions) {
        var layoutProps = generateLayoutCode(props, indent);
        var code = "StyledButton {\n" + indent + "    text: \"" + props.text + "\"\n" + indent + "    enabled: " + props.enabled + "\n" + layoutProps;
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
                enabled: root.enableAnimations
                ColorAnimation {
                    duration: AppStyles.animationDuration
                }
            }
        }

        HoverHandler {
            cursorShape: Qt.PointingHandCursor
        }

        onClicked: root.clicked()
    }
}
