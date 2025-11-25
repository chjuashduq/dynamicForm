import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Common 1.0

GroupBox {
    title: "组件设置"
    Layout.fillWidth: true

    property var targetItem
    signal propertyChanged(string name, var value)

    function hasProp(name) {
        return targetItem && targetItem.props && targetItem.props.hasOwnProperty(name);
    }

    function getProp(name) {
        return hasProp(name) ? targetItem.props[name] : null;
    }

    function updateProp(name, value) {
        propertyChanged(name, value);
    }

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
