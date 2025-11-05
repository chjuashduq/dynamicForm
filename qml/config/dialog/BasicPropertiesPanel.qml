import QtQuick 6.5
import QtQuick.Controls 6.5
import QtQuick.Layouts 1.4

/**
 * 基本属性面板
 * 负责控件基本属性的编辑
 */
GroupBox {
    id: basicPropertiesPanel
    title: "基本属性"
    
    property var editConfig: ({})
    property var gridConfig: ({})
    
    signal configChanged()

    Column {
        anchors.fill: parent
        spacing: 10

        GridLayout {
            columns: 4
            columnSpacing: 20
            rowSpacing: 15
            width: parent.width

            Label { text: "标识:" }
            TextField {
                id: editKeyField
                text: editConfig.key || ""
                Layout.preferredWidth: 150
                onTextChanged: configChanged()
            }

            Label { text: "标签:" }
            TextField {
                id: editLabelField
                text: editConfig.label || ""
                Layout.preferredWidth: 150
                onTextChanged: configChanged()
            }

            Label { text: "行:" }
            SpinBox {
                id: editRowSpinBox
                from: 0
                to: 20
                value: editConfig.row || 0
                onValueChanged: {
                    validatePosition();
                    configChanged();
                }
            }

            Label { text: "列:" }
            SpinBox {
                id: editColSpinBox
                from: 0
                to: 10
                value: editConfig.column || 0
                onValueChanged: {
                    validatePosition();
                    configChanged();
                }
            }

            Label { text: "行跨度:" }
            SpinBox {
                id: editRowSpanSpinBox
                from: 1
                to: 10
                value: editConfig.rowSpan || 1
                onValueChanged: {
                    validatePosition();
                    configChanged();
                }
            }

            Label { text: "列跨度:" }
            SpinBox {
                id: editColSpanSpinBox
                from: 1
                to: 10
                value: editConfig.colSpan || 1
                onValueChanged: {
                    validatePosition();
                    configChanged();
                }
            }

            Label { text: "标签比例:" }
            RowLayout {
                SpinBox {
                    id: editLabelRatioSpinBox
                    from: 0
                    to: 100
                    value: (editConfig.labelRatio || 0.3) * 100
                    onValueChanged: configChanged()
                }
                Label { text: "%" }
            }
        }

        // 位置验证提示
        Rectangle {
            id: validationArea
            width: parent.width
            height: 40
            color: isValid ? "#d4edda" : "#f8d7da"
            border.color: isValid ? "#c3e6cb" : "#f5c6cb"
            border.width: 1
            radius: 4
            visible: validationMessage !== ""

            property bool isValid: true
            property string validationMessage: ""

            Label {
                anchors.centerIn: parent
                text: parent.validationMessage
                color: parent.isValid ? "#155724" : "#721c24"
            }
        }
    }

    function validatePosition() {
        var row = editRowSpinBox.value;
        var col = editColSpinBox.value;
        var rowSpan = editRowSpanSpinBox.value;
        var colSpan = editColSpanSpinBox.value;

        var gridRows = gridConfig.rows || 8;
        var gridCols = gridConfig.columns || 2;

        // 检查是否超出网格范围
        if (row + rowSpan > gridRows || col + colSpan > gridCols) {
            validationArea.isValid = false;
            validationArea.validationMessage = "控件位置超出网格范围";
            return false;
        }

        validationArea.isValid = true;
        validationArea.validationMessage = "位置有效";
        return true;
    }

    function refreshFields() {
        if (!editConfig) return;
        
        editKeyField.text = editConfig.key || "";
        editLabelField.text = editConfig.label || "";
        editRowSpinBox.value = editConfig.row || 0;
        editColSpinBox.value = editConfig.column || 0;
        editRowSpanSpinBox.value = editConfig.rowSpan || 1;
        editColSpanSpinBox.value = editConfig.colSpan || 1;
        editLabelRatioSpinBox.value = (editConfig.labelRatio || 0.3) * 100;
        
        validatePosition();
    }

    function getConfig() {
        return {
            "key": editKeyField.text,
            "label": editLabelField.text,
            "row": editRowSpinBox.value,
            "column": editColSpinBox.value,
            "rowSpan": editRowSpanSpinBox.value,
            "colSpan": editColSpanSpinBox.value,
            "labelRatio": editLabelRatioSpinBox.value / 100.0
        };
    }

    onEditConfigChanged: {
        console.log("BasicPropertiesPanel editConfig changed:", JSON.stringify(editConfig));
        refreshFields();
    }
}