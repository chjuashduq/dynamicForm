import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Common 1.0

CollapsePanel {
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

    // Label Ratio (Slider)
    RowLayout {
        visible: hasProp("labelRatio")
        Layout.fillWidth: true
        spacing: 5
        Text {
            text: "标签占比"
            color: AppStyles.textPrimary
            Layout.preferredWidth: 70
        }
        Slider {
            Layout.fillWidth: true
            from: 0.0
            to: 1.0
            stepSize: 0.05
            // [修改] 默认值设为 0.2
            value: (getProp("labelRatio") != null) ? getProp("labelRatio") : 0.2
            onMoved: updateProp("labelRatio", value)
        }
        Text {
            // [修改] 显示百分比默认值改为 0.2
            text: Math.round(((getProp("labelRatio") != null) ? getProp("labelRatio") : 0.2) * 100) + "%"
            color: AppStyles.textPrimary
            Layout.preferredWidth: 40
            horizontalAlignment: Text.AlignRight
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
    CollapsePanel {
        visible: hasProp("model")
        Layout.fillWidth: true
        title: "选项列表配置"
        isExpanded: false

        ColumnLayout {
            width: parent.width
            spacing: 5

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
