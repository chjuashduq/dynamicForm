import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Common 1.0

Rectangle {
    id: root
    color: AppStyles.backgroundColor
    border.color: AppStyles.borderColor
    border.width: 1

    property var targetItem
    property var onPropertyChanged

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
        if (onPropertyChanged) {
            onPropertyChanged(name, value);
        }
    }
    Text {
        text: targetItem ? "组件属性: " + targetItem.type : "未选中组件"
        font.pixelSize: AppStyles.fontSizeLarge
        font.bold: true
        color: AppStyles.textPrimary
        Layout.alignment: Qt.AlignHCenter
        Layout.bottomMargin: 12
    }
    ColumnLayout {
        anchors.fill: parent
        anchors.topMargin: 30
        spacing: 10

        // Title with bottom margin to avoid overlap

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: AppStyles.borderColor
            visible: !!targetItem
        }

        ScrollView {

            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            visible: !!targetItem

            ColumnLayout {
                width: parent.width - 20 // reserve scrollbar space
                spacing: 15

                // --- Layout Settings ---
                GroupBox {
                    title: "布局设置"

                    Layout.fillWidth: true

                    background: Rectangle {
                        color: "transparent"
                        border.color: AppStyles.borderColor
                        radius: 4
                    }
                    label: Text {
                        text: parent.title
                        color: AppStyles.textSecondary
                        font.bold: true
                    }

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 10

                        // Layout Type
                        RowLayout {
                            visible: hasProp("layoutType")
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
                    }
                }

                // --- Container Settings ---
                GroupBox {
                    title: "容器设置"

                    Layout.fillWidth: true
                    visible: hasProp("spacing") || hasProp("wrap")
                    background: Rectangle {
                        color: "transparent"
                        border.color: AppStyles.borderColor
                        radius: 4
                    }
                    label: Text {
                        text: parent.title
                        color: AppStyles.textSecondary
                        font.bold: true
                    }

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 10

                        // Spacing (ensure fillWidth for internal + button)
                        RowLayout {
                            visible: hasProp("spacing")
                            Layout.fillWidth: true
                            spacing: 10
                            Text {
                                text: "间距 (px)"
                                color: AppStyles.textPrimary
                                Layout.preferredWidth: 70
                            }
                            SpinBox {
                                Layout.fillWidth: true
                                from: 0
                                to: 50
                                value: (getProp("spacing") != null) ? getProp("spacing") : 10
                                onValueModified: updateProp("spacing", value)
                            }
                        }

                        // Padding
                        RowLayout {
                            visible: hasProp("padding")
                            Layout.fillWidth: true
                            spacing: 10
                            Text {
                                text: "内边距 (px)"
                                color: AppStyles.textPrimary
                                Layout.preferredWidth: 70
                            }
                            SpinBox {
                                Layout.fillWidth: true
                                from: 0
                                to: 50
                                value: (getProp("padding") != null) ? getProp("padding") : 0
                                onValueModified: updateProp("padding", value)
                            }
                        }

                        // Wrap
                        RowLayout {
                            visible: hasProp("wrap")
                            Layout.fillWidth: true
                            spacing: 10
                            Text {
                                text: "自动换行"
                                color: AppStyles.textPrimary
                                Layout.preferredWidth: 70
                            }
                            CheckBox {
                                checked: getProp("wrap") !== false
                                onToggled: updateProp("wrap", checked)
                            }
                        }
                    }
                }

                // --- Component Settings ---
                GroupBox {
                    title: "组件设置"
                    Layout.fillWidth: true
                    visible: hasProp("label") || hasProp("text") || hasProp("placeholder") || hasProp("model")
                    background: Rectangle {
                        color: "transparent"
                        border.color: AppStyles.borderColor
                        radius: 4
                    }
                    label: Text {
                        text: parent.title
                        color: AppStyles.textSecondary
                        font.bold: true
                    }

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 10

                        // Label
                        RowLayout {
                            visible: hasProp("label")
                            Layout.fillWidth: true
                            spacing: 10
                            Text {
                                text: "标签文本"
                                color: AppStyles.textPrimary
                                Layout.preferredWidth: 70
                            }
                            TextField {
                                Layout.fillWidth: true
                                text: getProp("label") || ""
                                onEditingFinished: updateProp("label", text)
                            }
                        }

                        // Label Width
                        RowLayout {
                            visible: hasProp("labelWidth")
                            Layout.fillWidth: true
                            spacing: 10
                            Text {
                                text: "标签宽度"
                                color: AppStyles.textPrimary
                                Layout.preferredWidth: 70
                            }
                            SpinBox {
                                Layout.fillWidth: true
                                from: 20
                                to: 300
                                value: (getProp("labelWidth") != null) ? getProp("labelWidth") : 80
                                onValueModified: updateProp("labelWidth", value)
                            }
                        }

                        // Show Label
                        RowLayout {
                            visible: hasProp("showLabel")
                            Layout.fillWidth: true
                            spacing: 10
                            Text {
                                text: "显示标签"
                                color: AppStyles.textPrimary
                                Layout.preferredWidth: 70
                            }
                            CheckBox {
                                checked: getProp("showLabel") !== false
                                onToggled: updateProp("showLabel", checked)
                            }
                        }

                        // Text / Content
                        RowLayout {
                            visible: hasProp("text")
                            Layout.fillWidth: true
                            spacing: 10
                            Text {
                                text: "内容文本"
                                color: AppStyles.textPrimary
                                Layout.preferredWidth: 70
                            }
                            TextField {
                                Layout.fillWidth: true
                                text: getProp("text") || ""
                                onEditingFinished: updateProp("text", text)
                            }
                        }

                        // Placeholder
                        RowLayout {
                            visible: hasProp("placeholder")
                            Layout.fillWidth: true
                            spacing: 10
                            Text {
                                text: "占位提示"
                                color: AppStyles.textPrimary
                                Layout.preferredWidth: 70
                            }
                            TextField {
                                Layout.fillWidth: true
                                text: getProp("placeholder") || ""
                                onEditingFinished: updateProp("placeholder", text)
                            }
                        }

                        // Model (Key-Value List)
                        GroupBox {
                            visible: hasProp("model")
                            Layout.fillWidth: true
                            title: "选项列表配置"
                            background: Rectangle {
                                color: "transparent"
                                border.color: AppStyles.borderColor
                                radius: 4
                            }

                            ColumnLayout {
                                width: parent.width
                                spacing: 5

                                // Header
                                RowLayout {
                                    Layout.fillWidth: true
                                    Text {
                                        text: "显示文本"
                                        font.bold: true
                                        Layout.fillWidth: true
                                        color: AppStyles.textSecondary
                                    }
                                    Text {
                                        text: "值"
                                        font.bold: true
                                        Layout.fillWidth: true
                                        color: AppStyles.textSecondary
                                    }
                                    Item {
                                        width: 30
                                    }
                                }

                                // List Items
                                Repeater {
                                    model: getProp("model") || []
                                    delegate: RowLayout {
                                        Layout.fillWidth: true
                                        property var itemData: modelData
                                        property bool isString: typeof itemData === "string"

                                        TextField {
                                            Layout.fillWidth: true
                                            text: isString ? itemData : (itemData.label || "")
                                            placeholderText: "显示文本"
                                            onEditingFinished: {
                                                var newModel = JSON.parse(JSON.stringify(getProp("model")));
                                                if (isString) {
                                                    newModel[index] = {
                                                        label: text,
                                                        value: text
                                                    };
                                                } else {
                                                    newModel[index].label = text;
                                                }
                                                updateProp("model", newModel);
                                            }
                                        }
                                        TextField {
                                            Layout.fillWidth: true
                                            text: isString ? itemData : (itemData.value || "")
                                            placeholderText: "值"
                                            onEditingFinished: {
                                                var newModel = JSON.parse(JSON.stringify(getProp("model")));
                                                if (isString) {
                                                    newModel[index] = {
                                                        label: itemData,
                                                        value: text
                                                    };
                                                } else {
                                                    newModel[index].value = text;
                                                }
                                                updateProp("model", newModel);
                                            }
                                        }
                                        Button {
                                            text: "×"
                                            Layout.preferredWidth: 30
                                            onClicked: {
                                                var newModel = JSON.parse(JSON.stringify(getProp("model")));
                                                newModel.splice(index, 1);
                                                updateProp("model", newModel);
                                            }
                                        }
                                    }
                                }

                                // Add Button
                                Button {
                                    text: "+ 添加选项"
                                    Layout.fillWidth: true
                                    onClicked: {
                                        var currentModel = getProp("model") || [];
                                        var newModel = JSON.parse(JSON.stringify(currentModel));
                                        newModel.push({
                                            label: "新选项",
                                            value: "new_opt"
                                        });
                                        updateProp("model", newModel);
                                    }
                                }
                            }
                        }
                    }
                }

                // --- Data Settings
                GroupBox {
                    title: "数据控制"
                    Layout.fillWidth: true
                    visible: hasProp("from") || hasProp("to") || hasProp("value") || hasProp("readOnly") || hasProp("enabled")
                    background: Rectangle {
                        color: "transparent"
                        border.color: AppStyles.borderColor
                        radius: 4
                    }
                    label: Text {
                        text: parent.title
                        color: AppStyles.textSecondary
                        font.bold: true
                    }

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 10

                        // From
                        RowLayout {
                            visible: hasProp("from")
                            Text {
                                text: "最小值"
                                color: AppStyles.textPrimary
                                Layout.preferredWidth: 70
                            }
                            SpinBox {
                                Layout.fillWidth: true
                                from: -9999
                                to: 9999
                                value: (getProp("from") != null) ? getProp("from") : 0
                                onValueModified: updateProp("from", value)
                            }
                        }
                        // To
                        RowLayout {
                            visible: hasProp("to")
                            Text {
                                text: "最大值"
                                color: AppStyles.textPrimary
                                Layout.preferredWidth: 70
                            }
                            SpinBox {
                                Layout.fillWidth: true
                                from: -9999
                                to: 9999
                                value: (getProp("to") != null) ? getProp("to") : 100
                                onValueModified: updateProp("to", value)
                            }
                        }
                        // Value
                        RowLayout {
                            visible: hasProp("value")
                            Text {
                                text: "当前值"
                                color: AppStyles.textPrimary
                                Layout.preferredWidth: 70
                            }
                            SpinBox {
                                Layout.fillWidth: true
                                from: -9999
                                to: 9999
                                value: (getProp("value") != null) ? getProp("value") : 0
                                onValueModified: updateProp("value", value)
                            }
                        }
                        // ReadOnly
                        RowLayout {
                            visible: hasProp("readOnly")
                            Text {
                                text: "只读模式"
                                color: AppStyles.textPrimary
                                Layout.preferredWidth: 70
                            }
                            CheckBox {
                                checked: getProp("readOnly") === true
                                onToggled: updateProp("readOnly", checked)
                            }
                        }
                        // Enabled
                        RowLayout {
                            visible: hasProp("enabled")
                            Text {
                                text: "启用状态"
                                color: AppStyles.textPrimary
                                Layout.preferredWidth: 70
                            }
                            CheckBox {
                                checked: getProp("enabled") !== false
                                onToggled: updateProp("enabled", checked)
                            }
                        }
                    }
                }
            }
        }
    }
}
