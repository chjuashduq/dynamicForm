import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../Common"

/**
 * 美化的下拉框组件
 */
StyledBase {
    id: root
    label: "下拉框"

    // 导出属性
    property alias model: control.model
    property alias currentIndex: control.currentIndex
    property alias currentText: control.currentText
    property alias editable: control.editable

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
        // 格式化模型数据
        var modelStr = JSON.stringify(props.model, null, 4).replace(/\n/g, "\n" + indent + "    ");
        var code = "StyledComboBox {\n" + indent + "    label: \"" + props.label + "\"\n" + indent + "    labelWidth: " + props.labelWidth + "\n" + indent + "    showLabel: " + props.showLabel + "\n" + indent + "    textRole: \"label\"\n" + indent + "    valueRole: \"value\"\n" + indent + "    model: " + modelStr + "\n" + indent + "    enabled: " + props.enabled + "\n" + layoutProps;
        if (props.key && props.key.trim() !== "") {
            code += indent + "    key: \"" + props.key + "\"\n";
        }

        function wrapCode(c, args) {
            var contextObj = "{self: root" + (args ? ", " + args : "") + "}";
            return "scriptEngine.executeFunction(" + JSON.stringify(c) + ", " + contextObj + ")";
        }

        // 处理选中项改变事件 (Activated)
        if (events && events.hasOwnProperty("onActivated")) {
            if (props.key && props.key.trim() !== "" && functions) {
                var funcName = props.key + "_Activated";
                code += indent + "    onActivated: " + funcName + "(index)\n";
                var comment = props.label ? (" // " + props.label + " 选中改变") : "";
                var body = events.onActivated ? ("        " + wrapCode(events.onActivated, "index: index")) : "";
                var funcCode = "    function " + funcName + "(index) {" + comment + "\n" + body + "\n    }";
                functions.push(funcCode);
            } else if (events.onActivated) {
                code += indent + "    onActivated: {\n" + indent + "        " + wrapCode(events.onActivated, "index: index") + "\n" + indent + "    }\n";
            }
        }

        // 处理索引改变事件 (CurrentIndexChanged)
        if (events && events.hasOwnProperty("onCurrentIndexChanged")) {
            if (props.key && props.key.trim() !== "" && functions) {
                var funcName = props.key + "_CurrentIndexChanged";
                code += indent + "    onCurrentIndexChanged: " + funcName + "()\n";
                var comment = props.label ? (" // " + props.label + " 索引改变") : "";
                var body = events.onCurrentIndexChanged ? ("        " + wrapCode(events.onCurrentIndexChanged)) : "";
                var funcCode = "    function " + funcName + "() {" + comment + "\n" + body + "\n    }";
                functions.push(funcCode);
            } else if (events.onCurrentIndexChanged) {
                code += indent + "    onCurrentIndexChanged: {\n" + indent + "        " + wrapCode(events.onCurrentIndexChanged) + "\n" + indent + "    }\n";
            }
        }

        code += generateCommonEventsCode(props, events, indent, functions);
        code += indent + "}";
        return code;
    }

    ComboBox {
        id: control
        Layout.fillWidth: true
        textRole: "label"
        valueRole: "value"
        onActivated: index => root.activated(index)

        // 自定义背景，支持错误状态显示
        background: Rectangle {
            implicitWidth: 120
            implicitHeight: 40
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

    signal activated(int index)
}
