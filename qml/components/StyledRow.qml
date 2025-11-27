import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Common 1.0

Item {
    id: root

    // Key property for identification
    property string key: ""

    // RowLayout Properties
    property int spacing: 0
    property int alignment: Qt.AlignLeft

    // Detailed Padding
    property int paddingLeft: 0
    property int paddingRight: 0
    property int paddingTop: 0
    property int paddingBottom: 0

    // Legacy padding support (setter only)
    property int padding: 0
    onPaddingChanged: {
        if (padding > 0) {
            paddingLeft = padding;
            paddingRight = padding;
            paddingTop = padding;
            paddingBottom = padding;
        }
    }

    // Size properties
    implicitWidth: rowLayout.implicitWidth + paddingLeft + paddingRight
    implicitHeight: rowLayout.implicitHeight + paddingTop + paddingBottom

    property var defaultProps: {
        "key": "",
        "spacing": 15,
        "alignment": Qt.AlignLeft,
        "paddingLeft": 0,
        "paddingRight": 0,
        "paddingTop": 0,
        "paddingBottom": 0,
        "layoutType": "fill",
        "widthPercent": 100
    }

    function generateCode(props, childrenCode, indent) {
        var code = indent + "Flow {\n";
        code += indent + "    spacing: " + (props.spacing || 0) + "\n";
        code += indent + "    flow: Flow.LeftToRight\n";

        if (props.layoutType === "fixed") {
            code += indent + "    width: " + (props.width || 350) + "\n";
        } else if (props.layoutType === "percent") {
            code += indent + "    width: parent.width * " + ((props.widthPercent || 100) / 100) + "\n";
        } else {
            code += indent + "    width: parent.width\n";
        }

        var align = props.alignment;
        if (align === Qt.AlignRight) {
            code += indent + "    layoutDirection: Qt.RightToLeft\n";
        } else if (align === 4) { // Qt.AlignHCenter
            // Flow 本身不支持 Content Alignment Center，对于按钮行，通常是希望整体居中
            // 在生成的代码中，我们让 Flow 本身在父容器中居中
            code += indent + "    anchors.horizontalCenter: parent.horizontalCenter\n";
            code += indent + "    layoutDirection: Qt.LeftToRight\n";
        } else {
            code += indent + "    layoutDirection: Qt.LeftToRight\n";
        }

        if (props.key && props.key.trim() !== "") {
            code += indent + "    objectName: \"" + props.key + "\"\n";
        }

        // Generate specific padding
        if (props.paddingTop)
            code += indent + "    topPadding: " + props.paddingTop + "\n";
        if (props.paddingBottom)
            code += indent + "    bottomPadding: " + props.paddingBottom + "\n";
        if (props.paddingLeft)
            code += indent + "    leftPadding: " + props.paddingLeft + "\n";
        if (props.paddingRight)
            code += indent + "    rightPadding: " + props.paddingRight + "\n";

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

        // Alignment logic
        layoutDirection: (root.alignment === Qt.AlignRight) ? Qt.RightToLeft : Qt.LeftToRight

        // 可视化编辑器中的居中效果
        anchors.horizontalCenter: (root.alignment === Qt.AlignHCenter) ? parent.horizontalCenter : undefined

        // Margins/Padding
        topPadding: root.paddingTop
        leftPadding: root.paddingLeft
        rightPadding: root.paddingRight
        bottomPadding: root.paddingBottom

        spacing: root.spacing
    }
}
