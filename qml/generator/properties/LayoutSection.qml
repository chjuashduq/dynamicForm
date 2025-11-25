import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Common 1.0

CollapsePanel {
    title: "布局设置"
    Layout.fillWidth: true

    property var targetItem
    signal propertyChanged(string name, var value)

    // Helper to check if property exists
    function hasProp(name) {
        return targetItem && targetItem.props && targetItem.props.hasOwnProperty(name);
    }

    // Helper to get property value
    function getProp(name) {
        return hasProp(name) ? targetItem.props[name] : null;
    }

    // Helper to update property
    function updateProp(name, value) {
        propertyChanged(name, value);
    }

    // Layout Type
    RowLayout {
        visible: true // Always show layout type selection
        Text {
            text: "布局模式"
            color: AppStyles.textPrimary
            Layout.preferredWidth: 70
        }
        ComboBox {
            id: layoutTypeCombo
            Layout.fillWidth: true
            property var typeMap: {
                "填充": "fill",
                "固定": "fixed",
                "弹性": "flex",
                "百分比": "percent"
            }
            property var reverseTypeMap: {
                "fill": "填充",
                "fixed": "固定",
                "flex": "弹性",
                "percent": "百分比"
            }
            model: ["填充", "固定", "弹性", "百分比"]
            currentIndex: {
                if (!hasProp("layoutType"))
                    return 0;
                var cur = getProp("layoutType");
                var display = reverseTypeMap[cur] || "填充";
                return model.indexOf(display);
            }
            onActivated: {
                var eng = typeMap[currentText] || "fill";
                updateProp("layoutType", eng);
            }
        }
    }

    // Flex Value (only when flex)
    RowLayout {
        visible: hasProp("layoutType") && getProp("layoutType") === "flex"
        Text {
            text: "Flex 比例"
            color: AppStyles.textPrimary
            Layout.preferredWidth: 70
        }
        SpinBox {
            Layout.fillWidth: true
            from: 1
            to: 10
            value: (getProp("flex") != null) ? getProp("flex") : 1
            onValueModified: updateProp("flex", value)
        }
    }

    // Width Percent (only when percent)
    RowLayout {
        visible: hasProp("layoutType") && getProp("layoutType") === "percent"
        Text {
            text: "宽度百分比"
            color: AppStyles.textPrimary
            Layout.preferredWidth: 70
        }
        RowLayout {
            Layout.fillWidth: true
            Slider {
                Layout.fillWidth: true
                from: 1
                to: 100
                value: getProp("widthPercent") || 100
                onMoved: updateProp("widthPercent", Math.round(value))
            }
            Text {
                text: (getProp("widthPercent") || 100) + "%"
                color: AppStyles.textPrimary
                Layout.preferredWidth: 40
                horizontalAlignment: Text.AlignRight
            }
        }
    }

    // Fixed Width (fixed or width without layoutType)
    RowLayout {
        visible: (hasProp("layoutType") && getProp("layoutType") === "fixed") || (hasProp("width") && !hasProp("layoutType"))
        Text {
            text: "宽度 (px)"
            color: AppStyles.textPrimary
            Layout.preferredWidth: 70
        }
        SpinBox {
            Layout.fillWidth: true
            from: 10
            to: 2000
            value: (getProp("width") != null) ? getProp("width") : 100
            onValueModified: updateProp("width", value)
        }
    }
    // Alignment
    RowLayout {
        visible: targetItem && targetItem.type === "StyledRow"
        Text {
            text: "对齐方式"
            color: AppStyles.textPrimary
            Layout.preferredWidth: 70
        }
        ComboBox {
            id: alignmentCombo
            Layout.fillWidth: true
            model: ["默认", "左对齐", "居中", "右对齐", "顶部对齐", "底部对齐"]
            property var alignMap: {
                "默认": 0,
                "左对齐": Qt.AlignLeft,
                "居中": Qt.AlignHCenter,
                "右对齐": Qt.AlignRight,
                "顶部对齐": Qt.AlignTop,
                "底部对齐": Qt.AlignBottom
            }
            property var reverseAlignMap: {
                0: "默认",
                1: "左对齐" // Qt.AlignLeft
                ,
                4: "居中"   // Qt.AlignHCenter
                ,
                2: "右对齐" // Qt.AlignRight
                ,
                32: "顶部对齐" // Qt.AlignTop
                ,
                64: "底部对齐"  // Qt.AlignBottom
            }
            currentIndex: {
                var cur = getProp("alignment") || 0;
                // Handle combined flags if necessary, but for now simple mapping
                // Check if it matches any known value
                for (var key in alignMap) {
                    if (alignMap[key] === cur)
                        return model.indexOf(key);
                }
                return 0;
            }
            onActivated: {
                var val = alignMap[currentText];
                updateProp("alignment", val);
            }
        }
    }
}
