import QtQuick
import QtQuick.Layouts
import Common 1.0

RowLayout {
    id: baseRoot
    spacing: 10

    property string label: "Label"
    property int labelWidth: 80
    // [修改] 标签宽度比例，默认 0.2 (20%)
    property real labelRatio: 0.2
    property bool showLabel: true

    property alias labelItem: labelText
    // 颜色由内部逻辑控制
    property color labelColor: AppStyles.textPrimary
    property alias labelFont: labelText.font

    property alias labelHorizontalAlignment: labelText.horizontalAlignment
    property alias labelVerticalAlignment: labelText.verticalAlignment
    property alias labelElide: labelText.elide

    property string key: ""

    // [修复] valid 初始化为 undefined
    // 当 valid 为 undefined 时，isControlValid() 返回 false，validateAll() 也会视为失败
    property var valid: undefined

    // [新增] 错误状态计算属性，用于 UI 绑定 (只在明确为 false 时标红，undefined 不标红)
    property bool hasError: valid === false

    readonly property var baseDefaultProps: ({
            "label": "Label",
            "labelWidth": 80,
            "labelRatio": 0.2 // 默认为 0.2
            ,
            "showLabel": true,
            "layoutType": "fill",
            "flex": 1,
            "widthPercent": 100,
            "visible": true,
            "enabled": true,
            "key": "",
            "valid": undefined // [修复] 默认配置中也为 undefined
        })

    function mergeProps(specificProps) {
        var props = JSON.parse(JSON.stringify(baseDefaultProps));
        for (var key in specificProps) {
            props[key] = specificProps[key];
        }
        return props;
    }

    function generateLayoutCode(props, indent) {
        var code = "";
        if (props.layoutType === "fill") {
            code += indent + "    Layout.fillWidth: true\n";
        } else if (props.layoutType === "fixed") {
            var fixedWidth = props.width || 100;
            code += indent + "    width: " + fixedWidth + "\n";
            code += indent + "    Layout.preferredWidth: " + fixedWidth + "\n";
        } else if (props.layoutType === "flex") {
            code += indent + "    Layout.fillWidth: true\n";
            code += indent + "    Layout.preferredWidth: " + (props.flex || 1) + "\n";
        } else if (props.layoutType === "percent") {
            var widthPercent = props.widthPercent || 100;
            var ratio = widthPercent / 100;
            code += indent + "    width: parent.width * " + ratio + "\n";
            code += indent + "    Layout.preferredWidth: parent.width * " + ratio + "\n";
        }

        if (props.visible === false) {
            code += indent + "    visible: false\n";
        }

        if (props.labelRatio !== undefined) {
            code += indent + "    labelRatio: " + props.labelRatio + "\n";
        }

        return code;
    }

    function generateCommonEventsCode(props, events, indent, functions) {
        var code = "";
        function wrapCode(eventCode, args) {
            var contextObj = "{self: root" + (args ? ", " + args : "") + "}";
            var codeStr = JSON.stringify(eventCode);
            return "scriptEngine.executeFunction(" + codeStr + ", " + contextObj + ")";
        }

        if (events && events.hasOwnProperty("onVisibleChanged")) {
            var funcName = (props.key && props.key.trim() !== "") ? (props.key + "_VisibleChanged") : "";
            if (funcName && functions) {
                code += indent + "    onVisibleChanged: " + funcName + "()\n";
                var funcCode = "    function " + funcName + "() {\n" + "        " + wrapCode(events.onVisibleChanged) + "\n" + "    }";
                functions.push(funcCode);
            } else if (events.onVisibleChanged) {
                code += indent + "    onVisibleChanged: {\n" + indent + "        " + wrapCode(events.onVisibleChanged) + "\n" + indent + "    }\n";
            }
        }

        if (events && events.hasOwnProperty("onEnabledChanged")) {
            var funcName = (props.key && props.key.trim() !== "") ? (props.key + "_EnabledChanged") : "";
            if (funcName && functions) {
                code += indent + "    onEnabledChanged: " + funcName + "()\n";
                var funcCode = "    function " + funcName + "() {\n" + "        " + wrapCode(events.onEnabledChanged) + "\n" + "    }";
                functions.push(funcCode);
            } else if (events.onEnabledChanged) {
                code += indent + "    onEnabledChanged: {\n" + indent + "        " + wrapCode(events.onEnabledChanged) + "\n" + indent + "    }\n";
            }
        }

        return code;
    }

    Text {
        id: labelText
        text: baseRoot.label
        visible: baseRoot.showLabel

        Layout.preferredWidth: {
            if (baseRoot.labelRatio > 0 && baseRoot.width > 0) {
                return Math.max(20, baseRoot.width * baseRoot.labelRatio);
            }
            return baseRoot.labelWidth;
        }

        Layout.alignment: Qt.AlignVCenter
        font.pixelSize: AppStyles.fontSizeMedium

        // [修复] 只有当 hasError (valid===false) 时才标红，undefined 不标红
        color: baseRoot.hasError ? "red" : baseRoot.labelColor

        Behavior on color {
            ColorAnimation {
                duration: 200
            }
        }
    }
}
