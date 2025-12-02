import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../Common"

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

    property bool wrap: true

    implicitWidth: layoutLoader.item ? layoutLoader.item.implicitWidth : 0
    implicitHeight: layoutLoader.item ? layoutLoader.item.implicitHeight : 0

    property var defaultProps: {
        "key": "",
        "spacing": 15,
        "alignment": Qt.AlignLeft,
        "paddingLeft": 0,
        "paddingRight": 0,
        "paddingTop": 0,
        "paddingBottom": 0,
        "layoutType": "fill",
        "widthPercent": 100,
        "wrap": true
    }

    function generateCode(props, childrenCode, indent) {
        var isWrap = (props.wrap !== false); // Default true
        var compName = isWrap ? "Flow" : "Row";
        var code = indent + compName + " {\n";

        // [修复] 使用 objectName 替代 id，防止 id 冲突或不合法
        if (props.key && props.key.trim() !== "") {
            code += indent + "    objectName: \"" + props.key + "\"\n";
        }

        code += indent + "    spacing: " + (props.spacing || 0) + "\n";

        if (isWrap) {
            code += indent + "    flow: Flow.LeftToRight\n";
        }

        // 布局宽度处理
        if (props.layoutType === "fixed") {
            code += indent + "    width: " + (props.width || 350) + "\n";
            code += indent + "    Layout.preferredWidth: " + (props.width || 350) + "\n";
        } else if (props.layoutType === "percent") {
            code += indent + "    Layout.fillWidth: true\n";
            // Flow 内部百分比宽度通常依赖父容器
            code += indent + "    width: parent.width * " + ((props.widthPercent || 100) / 100) + "\n";
        } else {
            code += indent + "    Layout.fillWidth: true\n";
            if (!isWrap && props.alignment === 4) { // Center
                code += indent + "    width: implicitWidth\n";
            } else {
                code += indent + "    width: parent.width\n";
            }
        }

        // [关键修复] 对齐方式处理：使用 Layout.alignment 而不是 anchors
        // 因为生成的代码通常被包含在 ColumnLayout 或其他 Layout 中
        var align = props.alignment;

        // 1. 内部元素的排列方向
        if (align === Qt.AlignRight) {
            code += indent + "    layoutDirection: Qt.RightToLeft\n";
        } else {
            code += indent + "    layoutDirection: Qt.LeftToRight\n";
        }

        // 2. 容器自身的对齐 (在父 Layout 中)
        if (align === Qt.AlignRight) {
            code += indent + "    Layout.alignment: Qt.AlignRight\n";
        } else if (align === 4) { // Qt.AlignHCenter
            code += indent + "    Layout.alignment: Qt.AlignHCenter\n";
        } else {
            code += indent + "    Layout.alignment: Qt.AlignLeft\n";
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

    Loader {
        id: layoutLoader
        anchors.fill: parent
        sourceComponent: root.wrap ? flowComponent : rowComponent
    }

    Component {
        id: flowComponent
        Flow {
            // 预览时的逻辑
            width: (root.alignment === Qt.AlignHCenter) ? Math.min(implicitWidth, parent.width) : parent.width
            flow: Flow.LeftToRight
            layoutDirection: (root.alignment === Qt.AlignRight) ? Qt.RightToLeft : Qt.LeftToRight

            // 预览组件使用 anchors 是安全的，因为 CanvasItem 内部结构是 Rectangle
            anchors.horizontalCenter: (root.alignment === Qt.AlignHCenter) ? parent.horizontalCenter : undefined

            topPadding: root.paddingTop
            leftPadding: root.paddingLeft
            rightPadding: root.paddingRight
            bottomPadding: root.paddingBottom
            spacing: root.spacing
        }
    }

    Component {
        id: rowComponent
        Row {
            spacing: root.spacing
            layoutDirection: (root.alignment === Qt.AlignRight) ? Qt.RightToLeft : Qt.LeftToRight
            anchors.horizontalCenter: (root.alignment === Qt.AlignHCenter) ? parent.horizontalCenter : undefined

            topPadding: root.paddingTop
            leftPadding: root.paddingLeft
            rightPadding: root.paddingRight
            bottomPadding: root.paddingBottom
            width: (root.alignment === Qt.AlignHCenter) ? implicitWidth : parent.width
        }
    }
}
