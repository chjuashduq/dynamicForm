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

    // Legacy padding support
    property int padding: 0
    onPaddingChanged: {
        if (padding > 0) {
            paddingLeft = padding;
            paddingRight = padding;
            paddingTop = padding;
            paddingBottom = padding;
        }
    }

    // [修复] 边距计算修复：Flow 的 implicitHeight 已经包含了 padding，不需要额外加
    implicitWidth: rowLayout.implicitWidth
    implicitHeight: rowLayout.implicitHeight

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

        // 布局处理
        if (props.layoutType === "fixed") {
            code += indent + "    width: " + (props.width || 350) + "\n";
        } else if (props.layoutType === "percent") {
            code += indent + "    width: parent.width * " + ((props.widthPercent || 100) / 100) + "\n";
        } else {
            code += indent + "    width: parent.width\n";
        }

        // 居中/对齐处理
        var align = props.alignment;
        if (align === Qt.AlignRight) {
            code += indent + "    layoutDirection: Qt.RightToLeft\n";
        } else if (align === 4) { // Qt.AlignHCenter
            // [修复] 生成代码也加入宽度适应逻辑
            code += indent + "    width: implicitWidth\n";
            code += indent + "    anchors.horizontalCenter: parent.horizontalCenter\n";
            code += indent + "    layoutDirection: Qt.LeftToRight\n";
        } else {
            code += indent + "    layoutDirection: Qt.LeftToRight\n";
        }

        if (props.key && props.key.trim() !== "") {
            code += indent + "    objectName: \"" + props.key + "\"\n";
        }

        // Padding
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

        // [修复] 核心逻辑：如果是居中对齐，宽度设为适应内容(implicitWidth)，让父级Anchor生效
        // 否则占满父宽 (parent.width)
        width: (root.alignment === Qt.AlignHCenter) ? Math.min(implicitWidth, parent.width) : parent.width

        flow: Flow.LeftToRight

        // Alignment logic
        layoutDirection: (root.alignment === Qt.AlignRight) ? Qt.RightToLeft : Qt.LeftToRight

        // [修复] 居中对齐时，锚定到父容器水平中心
        anchors.horizontalCenter: (root.alignment === Qt.AlignHCenter) ? parent.horizontalCenter : undefined

        // Margins/Padding
        topPadding: root.paddingTop
        leftPadding: root.paddingLeft
        rightPadding: root.paddingRight
        bottomPadding: root.paddingBottom

        spacing: root.spacing
    }
}
