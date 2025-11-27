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
        var code = indent + "StyledRow {\n";
        code += indent + "    spacing: " + (props.spacing || 0) + "\n";

        // Alignment
        var align = props.alignment;
        if (align === 4) { // Qt.AlignHCenter
            code += indent + "    alignment: Qt.AlignHCenter\n";
        } else if (align === Qt.AlignRight) {
            code += indent + "    alignment: Qt.AlignRight\n";
        } else {
            code += indent + "    alignment: Qt.AlignLeft\n";
        }

        if (props.layoutType === "fixed") {
            code += indent + "    width: " + (props.width || 350) + "\n";
        } else if (props.layoutType === "percent") {
            code += indent + "    width: parent.width * " + ((props.widthPercent || 100) / 100) + "\n";
        } else {
            code += indent + "    width: parent.width\n";
        }

        if (props.key && props.key.trim() !== "") {
            code += indent + "    objectName: \"" + props.key + "\"\n";
        }

        // Generate specific padding
        if (props.paddingTop)
            code += indent + "    paddingTop: " + props.paddingTop + "\n";
        if (props.paddingBottom)
            code += indent + "    paddingBottom: " + props.paddingBottom + "\n";
        if (props.paddingLeft)
            code += indent + "    paddingLeft: " + props.paddingLeft + "\n";
        if (props.paddingRight)
            code += indent + "    paddingRight: " + props.paddingRight + "\n";

        if (childrenCode && childrenCode.trim().length > 0) {
            code += childrenCode;
        }

        code += indent + "}";
        return code;
    }

    Flow {
        id: rowLayout

        // [修改] 修复居中对齐问题
        // 如果是居中对齐，Flow 的宽度适应内容（但不超过父容器），并水平居中
        width: (root.alignment === Qt.AlignHCenter) ? Math.min(implicitWidth, parent.width) : parent.width

        anchors.horizontalCenter: (root.alignment === Qt.AlignHCenter) ? parent.horizontalCenter : undefined

        flow: Flow.LeftToRight

        // Alignment logic (Right alignment is handled by layoutDirection)
        layoutDirection: (root.alignment === Qt.AlignRight) ? Qt.RightToLeft : Qt.LeftToRight

        // Margins/Padding
        topPadding: root.paddingTop
        leftPadding: root.paddingLeft
        rightPadding: root.paddingRight
        bottomPadding: root.paddingBottom

        spacing: root.spacing
    }
}
