import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Common 1.0

Item {
    id: root

    // Flow Properties
    property int spacing: 10
    property bool wrap: true  // 是否支持换行
    property string flowDirection: "LeftToRight"  // Flow direction: LeftToRight, TopToBottom
    property int padding: 0  // 内边距

    // Size properties
    implicitWidth: flowLayout.implicitWidth
    implicitHeight: flowLayout.childrenRect.height + padding * 2

    // StyledRow is a container, so we need to handle children code generation specially
    property var defaultProps: {
        "spacing": 10,
        "showLabel": false,
        "wrap": true,
        "flowDirection": "LeftToRight",
        "padding": 0,
        "layoutType": "percent",
        "widthPercent": 100
    }

    function generateCode(props, childrenCode, indent) {
        var code = indent + "Flow {\n";
        code += indent + "    spacing: " + (props.spacing || 10) + "\n";

        // 生成宽度代码
        if (props.layoutType === "fixed") {
            code += indent + "    width: " + (props.width || 100) + "\n";
        } else if (props.layoutType === "percent") {
            code += indent + "    width: parent.width * " + ((props.widthPercent || 100) / 100) + "\n";
        } else {
            // Default to fill
            code += indent + "    width: parent.width\n";
        }

        // Layout attached properties for when it's inside a Layout
        if (props.layoutType === "fixed") {
            code += indent + "    Layout.preferredWidth: " + (props.width || 100) + "\n";
        } else if (props.layoutType === "percent") {
            code += indent + "    Layout.preferredWidth: parent.width * " + ((props.widthPercent || 100) / 100) + "\n";
        } else {
            code += indent + "    Layout.fillWidth: true\n";
        }

        // Flow direction
        var flowDir = props.flowDirection || "LeftToRight";
        if (flowDir === "LeftToRight") {
            code += indent + "    flow: Flow.LeftToRight\n";
        } else if (flowDir === "TopToBottom") {
            code += indent + "    flow: Flow.TopToBottom\n";
        }

        // Padding
        if (props.padding && props.padding > 0) {
            code += indent + "    topPadding: " + props.padding + "\n";
            code += indent + "    leftPadding: " + props.padding + "\n";
            code += indent + "    rightPadding: " + props.padding + "\n";
            code += indent + "    bottomPadding: " + props.padding + "\n";
        }

        // 添加子元素代码（如果存在）
        if (childrenCode && childrenCode.trim().length > 0) {
            code += childrenCode;
        }

        code += indent + "}";
        return code;
    }

    Flow {
        id: flowLayout
        anchors.fill: parent
        anchors.margins: root.padding
        spacing: root.spacing
        flow: root.flowDirection === "TopToBottom" ? Flow.TopToBottom : Flow.LeftToRight
    }
}
