import QtQuick 6.5
import QtQuick.Controls 6.5
import QtQuick.Layouts 1.15
import "../Common" as Common

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
    // property alias color: control.color // Removed to avoid conflict with StyledBase handling

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

        // [修改] 支持空函数生成和注释
        if (events && events.hasOwnProperty("onEditingFinished")) {
            var funcName = (props.key && props.key.trim() !== "") ? (props.key + "_EditingFinished") : "";

            if (funcName && functions) {
                code += indent + "    onEditingFinished: " + funcName + "()\n";
                var comment = props.label ? (" // " + props.label + " 编辑完成") : "";
                var body = events.onEditingFinished ? ("        " + wrapCode(events.onEditingFinished)) : "";
                var funcCode = "    function " + funcName + "() {" + comment + "\n" + body + "\n    }";
                functions.push(funcCode);
            } else if (events.onEditingFinished) {
                code += indent + "    onEditingFinished: {\n" + indent + "        " + wrapCode(events.onEditingFinished) + "\n" + indent + "    }\n";
            }
        }

        if (events && events.hasOwnProperty("onTextEdited")) {
            var funcName = (props.key && props.key.trim() !== "") ? (props.key + "_TextEdited") : "";

            if (funcName && functions) {
                code += indent + "    onTextEdited: " + funcName + "()\n";
                var comment = props.label ? (" // " + props.label + " 文本改变") : "";
                var body = events.onTextEdited ? ("        " + wrapCode(events.onTextEdited)) : "";
                var funcCode = "    function " + funcName + "() {" + comment + "\n" + body + "\n    }";
                functions.push(funcCode);
            } else if (events.onTextEdited) {
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

        // property bool hasError: false // 移除，使用 root.hasError

        height: Common.AppStyles.inputHeight
        font.pixelSize: Common.AppStyles.fontSizeMedium
        font.family: Common.AppStyles.fontFamily
        color: Common.AppStyles.textPrimary
        placeholderTextColor: Common.AppStyles.textPlaceholder
        selectByMouse: true

        leftPadding: Common.AppStyles.inputPadding
        rightPadding: Common.AppStyles.inputPadding

        onEditingFinished: root.editingFinished()
        onTextEdited: root.textEdited()

        background: Rectangle {
            color: control.enabled ? Common.AppStyles.inputBackground : Common.AppStyles.backgroundColor
            border.color: {
                // [修改] 优先判断错误状态
                if (root.hasError)
                    return "red"; // 验证失败变红
                if (control.activeFocus)
                    return Common.AppStyles.inputBorderFocus;
                return Common.AppStyles.inputBorder;
            }
            border.width: (control.activeFocus || root.hasError) ? 2 : Common.AppStyles.inputBorderWidth
            radius: Common.AppStyles.inputRadius

            Behavior on border.color {
                ColorAnimation {
                    duration: Common.AppStyles.animationDuration
                }
            }

            Behavior on border.width {
                NumberAnimation {
                    duration: Common.AppStyles.animationDuration
                }
            }
        }
    }

    signal editingFinished
    signal textEdited
}
