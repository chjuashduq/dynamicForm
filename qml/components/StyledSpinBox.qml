import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../Common"

/**
 * 美化的数字输入框
 */
StyledBase {
    id: root
    label: "数字输入"

    // 导出属性
    property alias from: control.from
    property alias to: control.to
    property alias value: control.value
    property alias stepSize: control.stepSize
    property alias editable: control.editable

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

        // 处理数值变化事件
        if (events && events.hasOwnProperty("onValueModified")) {
            function wrapCode(c, args) {
                var contextObj = "{self: root" + (args ? ", " + args : "") + "}";
                return "scriptEngine.executeFunction(" + JSON.stringify(c) + ", " + contextObj + ")";
            }

            if (props.key && props.key.trim() !== "" && functions) {
                var funcName = props.key + "_ValueModified";
                code += indent + "    onValueModified: " + funcName + "()\n";
                // 添加注释
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

        // 自定义内容项以匹配整体风格
        contentItem: TextInput {
            z: 2
            text: control.textFromValue(control.value, control.locale)
            font: control.font
            color: AppStyles.textPrimary
            selectionColor: "#21be2b"
            selectedTextColor: "#ffffff"
            horizontalAlignment: Qt.AlignHCenter
            verticalAlignment: Qt.AlignVCenter
            readOnly: !control.editable
            validator: control.validator
            inputMethodHints: Qt.ImhFormattedNumbersOnly
        }

        // 自定义背景，支持错误状态显示
        background: Rectangle {
            implicitWidth: 140
            border.color: {
                // 优先显示错误状态颜色
                if (root.hasError)
                    return "red";
                return control.activeFocus ? AppStyles.primaryColor : AppStyles.borderColor;
            }
            border.width: (control.activeFocus || root.hasError) ? 2 : 1
            radius: AppStyles.radiusMedium
        }
    }

    signal valueModified
}
