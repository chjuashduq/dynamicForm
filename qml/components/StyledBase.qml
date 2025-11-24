import QtQuick
import QtQuick.Layouts
import Common 1.0

RowLayout {
    id: baseRoot
    spacing: 10

    property string label: "Label"
    property int labelWidth: 80
    property bool showLabel: true

    // Expose the label item for customization
    property alias labelItem: labelText
    property alias labelColor: labelText.color
    property alias labelFont: labelText.font

    // Expose Text alignment properties
    property alias labelHorizontalAlignment: labelText.horizontalAlignment
    property alias labelVerticalAlignment: labelText.verticalAlignment
    property alias labelElide: labelText.elide

    // Common default properties for all components
    readonly property var baseDefaultProps: ({
            "label": "Label",
            "labelWidth": 80,
            "showLabel": true,
            "layoutType": "fill",
            "flex": 1,
            "widthPercent": 100,
            "visible": true,
            "enabled": true
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
            // For fill, only use Layout properties (Flow will auto-size)
            code += indent + "    Layout.fillWidth: true\n";
        } else if (props.layoutType === "fixed") {
            // For fixed width, set both width and Layout.preferredWidth
            var fixedWidth = props.width || 100;
            code += indent + "    width: " + fixedWidth + "\n";
            code += indent + "    Layout.preferredWidth: " + fixedWidth + "\n";
        } else if (props.layoutType === "flex") {
            // For flex, use Layout properties
            code += indent + "    Layout.fillWidth: true\n";
            // Note: Layout.flex is not a standard property, commenting out
            // code += indent + "    Layout.flex: " + (props.flex || 1) + "\n";
        } else if (props.layoutType === "percent") {
            // For percentage width, use parent.width * ratio
            // This works in both Flow and Layout
            var widthPercent = props.widthPercent || 100;
            var ratio = widthPercent / 100;
            code += indent + "    width: parent.width * " + ratio + "\n";
            code += indent + "    Layout.preferredWidth: parent.width * " + ratio + "\n";
        }

        if (props.visible === false) {
            code += indent + "    visible: false\n";
        }

        return code;
    }

    // Label Component
    Text {
        id: labelText
        text: baseRoot.label
        visible: baseRoot.showLabel
        Layout.preferredWidth: baseRoot.labelWidth
        Layout.alignment: Qt.AlignVCenter
        font.pixelSize: AppStyles.fontSizeMedium
        color: AppStyles.textPrimary
    }

    // Content Item (Children will be added here by default)
}
