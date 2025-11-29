import QtQuick 6.5
import QtQuick.Layouts 1.15
import "../Common"

RowLayout {
    id: baseRoot
    spacing: 10

    property string label: "Label"
    property int labelWidth: 80
    property real labelRatio: 0.2
    property bool showLabel: true

    // Expose the label item for customization
    property alias labelItem: labelText
    property color labelColor: AppStyles.textPrimary
    property alias labelFont: labelText.font

    // Expose Text alignment properties
    property alias labelHorizontalAlignment: labelText.horizontalAlignment
    property alias labelVerticalAlignment: labelText.verticalAlignment
    property alias labelElide: labelText.elide

    property string key: ""

    // [新增] 是否必填
    property bool required: false

    // [关键修改] valid 状态枚举
    // 0: Unchecked (待验证) - 必填项的初始状态
    // 1: Valid (合格) - 非必填项的初始状态，或验证通过
    // 2: Invalid (不合格) - 验证失败
    // undefined: 不参与验证 (如按钮)
    property var valid: required ? 0 : 1

    // [修改] 错误状态计算属性
    // 只有状态明确为 2 (Invalid) 时才标红
    property bool hasError: valid === 2

    // Common default properties for all components
    readonly property var baseDefaultProps: ({
            "label": "Label",
            "labelWidth": 80,
            "labelRatio": 0.2,
            "showLabel": true,
            "layoutType": "fill",
            "flex": 1,
            "widthPercent": 100,
            "visible": true,
            "enabled": true,
            "key": "",
            "required": false,
            "valid": 1 // 默认合格
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

        if (props.required === true) {
            code += indent + "    required: true\n";
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
                var comment = props.label ? (" // " + props.label + " 可见性变化") : "";
                var body = events.onVisibleChanged ? ("        " + wrapCode(events.onVisibleChanged)) : "";
                var funcCode = "    function " + funcName + "() {" + comment + "\n" + body + "\n    }";
                functions.push(funcCode);
            } else if (events.onVisibleChanged) {
                code += indent + "    onVisibleChanged: {\n" + indent + "        " + wrapCode(events.onVisibleChanged) + "\n" + indent + "    }\n";
            }
        }

        if (events && events.hasOwnProperty("onEnabledChanged")) {
            var funcName = (props.key && props.key.trim() !== "") ? (props.key + "_EnabledChanged") : "";

            if (funcName && functions) {
                code += indent + "    onEnabledChanged: " + funcName + "()\n";
                var comment = props.label ? (" // " + props.label + " 启用状态变化") : "";
                var body = events.onEnabledChanged ? ("        " + wrapCode(events.onEnabledChanged)) : "";
                var funcCode = "    function " + funcName + "() {" + comment + "\n" + body + "\n    }";
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
        // 根据 hasError (valid===2) 变色
        color: baseRoot.hasError ? "red" : baseRoot.labelColor

        Behavior on color {
            ColorAnimation {
                duration: 200
            }
        }

        // 必填项显示红色星号
        Text {
            visible: baseRoot.required
            text: "*"
            color: "red"
            anchors.left: parent.right
            anchors.leftMargin: 2
            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize: parent.font.pixelSize
        }
    }
}
