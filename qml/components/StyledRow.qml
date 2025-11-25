import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Common 1.0

Item {
    id: root

    // RowLayout Properties
    property int spacing: 0
    property int alignment: Qt.AlignLeft // Horizontal alignment of the row content
    property int padding: 0

    // Size properties
    implicitWidth: rowLayout.implicitWidth + padding * 2
    implicitHeight: rowLayout.implicitHeight + padding * 2

    property var defaultProps: {
        "spacing": 0,
        "alignment": Qt.AlignLeft,
        "padding": 0,
        "layoutType": "percent",
        "widthPercent": 100
    }

    function generateCode(props, childrenCode, indent) {
        var code = indent + "Flow {\n";
        code += indent + "    spacing: " + (props.spacing || 0) + "\n";
        code += indent + "    flow: Flow.LeftToRight\n";

        // Generate width/layout properties (for the Flow itself)
        if (props.layoutType === "fixed") {
            code += indent + "    width: " + (props.width || 350) + "\n";
        } else if (props.layoutType === "percent") {
            code += indent + "    width: parent.width * " + ((props.widthPercent || 100) / 100) + "\n";
        } else {
            // Default / Fill
            code += indent + "    width: parent.width\n";
        }

        // Alignment via layoutDirection
        var align = props.alignment;
        if (align === Qt.AlignRight) {
            code += indent + "    layoutDirection: Qt.RightToLeft\n";
        } else {
            code += indent + "    layoutDirection: Qt.LeftToRight\n";
        }

        // Padding
        if (props.padding) {
            code += indent + "    topPadding: " + props.padding + "\n";
            code += indent + "    leftPadding: " + props.padding + "\n";
            code += indent + "    rightPadding: " + props.padding + "\n";
            code += indent + "    bottomPadding: " + props.padding + "\n";
        }

        // Children
        if (childrenCode && childrenCode.trim().length > 0) {
            code += childrenCode;
        }

        code += indent + "}";
        return code;
    }

    Flow {
        id: rowLayout

        width: parent.width
        flow: Flow.LeftToRight

        // Alignment
        layoutDirection: (root.alignment === Qt.AlignRight) ? Qt.RightToLeft : Qt.LeftToRight

        // Margins/Padding
        topPadding: root.padding
        leftPadding: root.padding
        rightPadding: root.padding
        bottomPadding: root.padding

        spacing: root.spacing
    }
}
