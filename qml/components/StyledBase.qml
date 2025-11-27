import QtQuick
import QtQuick.Layouts
import Common 1.0

RowLayout {
    id: baseRoot
    spacing: 10

    property string label: "Label"
    property int labelWidth: 80
    // 新增：标签宽度比例，默认 0.3 (30%)
    property real labelRatio: 0.3
    property bool showLabel: true

    // Expose the label item for customization
    property alias labelItem: labelText
    property alias labelColor: labelText.color
    property alias labelFont: labelText.font

    // Expose Text alignment properties
    property alias labelHorizontalAlignment: labelText.horizontalAlignment
    property alias labelVerticalAlignment: labelText.verticalAlignment
    property alias labelElide: labelText.elide

    property string key: ""
    property bool valid: true

    // Common default properties for all components
    readonly property var baseDefaultProps: ({
            "label": "Label",
            "labelWidth": 80,
            "labelRatio": 0.3,
            "showLabel": true,
            "layoutType": "fill",
            "flex": 1,
            "widthPercent": 100,
            "visible": true,
            "enabled": true,
            "key": "",
            "valid": true
        })

    // Helper to merge specific props with base props
    function mergeProps(specificProps) {
        var props = JSON.parse(JSON.stringify(baseDefaultProps));
        for (var key in specificProps) {
            props[key] = specificProps[key];
        }
        return props;
    }

    // Helper to generate common layout code
    function generateLayoutCode(props, indent) {
        var code = "";
        // Generate width properties based on layoutType
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

        // Generate label ratio code
        if (props.labelRatio !== undefined) {
            code += indent + "    labelRatio: " + props.labelRatio + "\n";
        }

        return code;
    }

    // Helper to generate common events code
    function generateCommonEventsCode(props, events, indent, functions) {
        var code = "";
        function wrapCode(eventCode, args) {
            var contextObj = "{self: root" + (args ? ", " + args : "") + "}";
            var codeStr = JSON.stringify(eventCode);
            return "scriptEngine.executeFunction(" + codeStr + ", " + contextObj + ")";
        }

        if (events && events.onVisibleChanged) {
            if (props.key && props.key.trim() !== "" && functions) {
                var funcName = props.key + "_VisibleChanged";
                code += indent + "    onVisibleChanged: " + funcName + "()\n";
                var funcCode = "    function " + funcName + "() {\n" + "        " + wrapCode(events.onVisibleChanged) + "\n" + "    }";
                functions.push(funcCode);
            } else {
                code += indent + "    onVisibleChanged: {\n" + indent + "        " + wrapCode(events.onVisibleChanged) + "\n" + indent + "    }\n";
            }
        }

        if (events && events.onEnabledChanged) {
            if (props.key && props.key.trim() !== "" && functions) {
                var funcName = props.key + "_EnabledChanged";
                code += indent + "    onEnabledChanged: " + funcName + "()\n";
                var funcCode = "    function " + funcName + "() {\n" + "        " + wrapCode(events.onEnabledChanged) + "\n" + "    }";
                functions.push(funcCode);
            } else {
                code += indent + "    onEnabledChanged: {\n" + indent + "        " + wrapCode(events.onEnabledChanged) + "\n" + indent + "    }\n";
            }
        }

        return code;
    }

    // Label Component
    Text {
        id: labelText
        text: baseRoot.label
        visible: baseRoot.showLabel

        // Calculate width: prefer ratio, fallback to fixed
        Layout.preferredWidth: {
            if (baseRoot.labelRatio > 0 && baseRoot.width > 0) {
                return Math.max(20, baseRoot.width * baseRoot.labelRatio);
            }
            return baseRoot.labelWidth;
        }

        Layout.alignment: Qt.AlignVCenter
        font.pixelSize: AppStyles.fontSizeMedium
        color: AppStyles.textPrimary
    }
}
