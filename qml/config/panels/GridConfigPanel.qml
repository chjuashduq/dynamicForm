import QtQuick 6.5
import QtQuick.Controls 6.5
import QtQuick.Layouts 1.4

/**
 * 网格配置面板
 * 负责网格布局的配置和管理
 */
Rectangle {
    id: gridConfigPanel
    
    property var gridConfig: ({
        "rows": 4,
        "columns": 2,
        "rowSpacing": 5,
        "columnSpacing": 10,
        "rowHeights": [ 1, 1, 1, 2],
        "columnWidths": [1, 2]
    })
    
    property bool isUpdating: false  // 防止循环更新的标志
    
    onGridConfigChanged: {
        // 更新UI控件的值
        if (gridConfig && !isUpdating) {
            isUpdating = true;
            rowsSpinBox.value = gridConfig.rows || 4;
            columnsSpinBox.value = gridConfig.columns || 2;
            rowSpacingSpinBox.value = gridConfig.rowSpacing || 5;
            columnSpacingSpinBox.value = gridConfig.columnSpacing || 10;
            rowHeightsField.text = formatArrayForEdit(gridConfig.rowHeights || []);
            columnWidthsField.text = formatArrayForEdit(gridConfig.columnWidths || []);
            isUpdating = false;
        }
    }
    
    signal configChanged(var newConfig)
    
    width: parent ? parent.width - 40 : 400
    height: 280
    anchors.horizontalCenter: parent ? parent.horizontalCenter : undefined
    color: "#f8f9fa"
    border.color: "#dee2e6"
    border.width: 1
    radius: 8

    Column {
        anchors.fill: parent
        anchors.margins: 15
        spacing: 10

        Text {
            text: "网格配置"
            font.pixelSize: 16
            font.bold: true
        }

        Grid {
            columns: 4
            spacing: 15

            Column {
                Text { text: "行数" }
                SpinBox {
                    id: rowsSpinBox
                    from: 1
                    to: 20
                    value: gridConfig.rows || 4
                    onValueChanged: updateConfig()
                }
            }

            Column {
                Text { text: "列数" }
                SpinBox {
                    id: columnsSpinBox
                    from: 1
                    to: 10
                    value: gridConfig.columns || 2
                    onValueChanged: updateConfig()
                }
            }

            Column {
                Text { text: "行间距" }
                SpinBox {
                    id: rowSpacingSpinBox
                    from: 0
                    to: 50
                    value: gridConfig.rowSpacing || 5
                    onValueChanged: updateConfig()
                }
            }

            Column {
                Text { text: "列间距" }
                SpinBox {
                    id: columnSpacingSpinBox
                    from: 0
                    to: 50
                    value: gridConfig.columnSpacing || 10
                    onValueChanged: updateConfig()
                }
            }
        }

        // 行高和列宽配置
        Column {
            width: parent.width
            spacing: 10

            Text {
                text: "行高列宽配置"
                font.pixelSize: 14
                font.bold: true
            }

            Column {
                width: parent.width
                spacing: 5

                Text {
                    text: "行高比例 (用逗号分隔，如: 1,1,2,1)"
                    font.pixelSize: 12
                    color: "#666666"
                }
                TextField {
                    id: rowHeightsField
                    width: Math.max(parent.width - 20, 300)
                    placeholderText: "1,1,1,2"
                    text: formatArrayForEdit(gridConfig.rowHeights || [])
                    onEditingFinished: updateConfig()
                }
            }

            Column {
                width: parent.width
                spacing: 5

                Text {
                    text: "列宽比例 (用逗号分隔，如: 1,2)"
                    font.pixelSize: 12
                    color: "#666666"
                }
                TextField {
                    id: columnWidthsField
                    width: Math.max(parent.width - 20, 300)
                    placeholderText: "1,2"
                    text: formatArrayForEdit(gridConfig.columnWidths || [])
                    onEditingFinished: updateConfig()
                }
            }
        }
    }
    
    Timer {
        id: updateTimer
        interval: 100
        onTriggered: {
            var rowHeights = parseArrayFromEdit(rowHeightsField.text);
            var columnWidths = parseArrayFromEdit(columnWidthsField.text);

            // 补充或截取数组长度
            rowHeights = adjustArrayLength(rowHeights, rowsSpinBox.value, 1);
            columnWidths = adjustArrayLength(columnWidths, columnsSpinBox.value, 
                columnsSpinBox.value === 2 ? [1, 2] : [1]);

            var newConfig = {
                "rows": rowsSpinBox.value,
                "columns": columnsSpinBox.value,
                "rowSpacing": rowSpacingSpinBox.value,
                "columnSpacing": columnSpacingSpinBox.value,
                "rowHeights": rowHeights,
                "columnWidths": columnWidths
            };

            // 更新显示文本
            isUpdating = true;
            if (rowHeightsField.text !== formatArrayForEdit(rowHeights)) {
                rowHeightsField.text = formatArrayForEdit(rowHeights);
            }
            if (columnWidthsField.text !== formatArrayForEdit(columnWidths)) {
                columnWidthsField.text = formatArrayForEdit(columnWidths);
            }
            gridConfig = newConfig;
            isUpdating = false;
            
            // 发出配置变化信号
            console.log("GridConfigPanel: configChanged signal emitted", JSON.stringify(newConfig));
            configChanged(newConfig);
        }
    }
    
    function updateConfig() {
        if (!isUpdating) {
            updateTimer.restart();
        }
    }
    
    function formatArrayForEdit(array) {
        if (!array || !Array.isArray(array)) return "";
        return array.join(",");
    }
    
    function parseArrayFromEdit(text) {
        if (!text || text.trim() === "") return [];
        
        return text.split(",").map(function(item) {
            var num = parseFloat(item.trim());
            return isNaN(num) ? 1 : Math.max(0.1, num);
        }).filter(function(num) {
            return num > 0;
        });
    }
    
    function adjustArrayLength(array, targetLength, defaultValue) {
        if (array.length === 0) {
            return Array.isArray(defaultValue) ? defaultValue.slice(0, targetLength) : 
                   new Array(targetLength).fill(defaultValue);
        }
        
        if (array.length < targetLength) {
            var fillValue = Array.isArray(defaultValue) ? 1 : defaultValue;
            while (array.length < targetLength) {
                array.push(fillValue);
            }
        } else if (array.length > targetLength) {
            array = array.slice(0, targetLength);
        }
        
        return array;
    }
}
