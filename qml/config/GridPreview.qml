import QtQuick 6.5
import QtQuick.Controls 6.5

/**
 * 网格预览组件
 * 负责显示控件在网格中的布局预览
 */
Rectangle {
    id: gridPreview
    
    property var gridConfig: ({})
    property var controls: []
    
    onGridConfigChanged: {
        console.log("GridPreview gridConfig changed:", JSON.stringify(gridConfig));
        refresh();
    }
    
    onControlsChanged: {
        console.log("GridPreview controls changed, count:", controls ? controls.length : 0);
        // 强制刷新Repeater以显示新的控件
        cellRepeater.model = 0;
        cellRepeater.model = (gridConfig.rows || 8) * (gridConfig.columns || 2);
    }
    
    signal controlClicked(int row, int col, var control)
    signal controlRightClicked(int row, int col, var control)
    
    width: parent ? parent.width - 20 : 400
    height: calculateTotalHeight()
    anchors.horizontalCenter: parent ? parent.horizontalCenter : undefined
    
    function calculateTotalHeight() {
        var totalHeight = 20; // 上下边距
        if (gridConfig.rowHeights && gridConfig.rowHeights.length > 0) {
            for (var i = 0; i < (gridConfig.rows || 8); i++) {
                totalHeight += getCellHeight(i);
                if (i < (gridConfig.rows || 8) - 1) {
                    totalHeight += (gridConfig.rowSpacing || 5);
                }
            }
        } else {
            totalHeight += (gridConfig.rows || 8) * 80 + ((gridConfig.rows || 8) - 1) * (gridConfig.rowSpacing || 5);
        }
        return Math.max(200, totalHeight);
    }
    color: "#f8f9fa"
    border.color: "#ff0000"  // 临时使用红色边框便于调试
    border.width: 2
    radius: 4

    property var typeManagerLoader: Loader {
        source: "ControlTypeManager.qml"
    }
    property var typeManager: typeManagerLoader.item

    Grid {
        id: gridLayout
        anchors.fill: parent
        anchors.margins: 10
        
        rows: gridConfig.rows || 8
        columns: gridConfig.columns || 2
        rowSpacing: gridConfig.rowSpacing || 5
        columnSpacing: gridConfig.columnSpacing || 10

        Repeater {
            id: cellRepeater
            model: (gridConfig.rows || 8) * (gridConfig.columns || 2)

            Rectangle {
                property int cellRow: Math.floor(index / (gridConfig.columns || 2))
                property int cellCol: index % (gridConfig.columns || 2)
                property var cellControl: getControlAtPosition(cellRow, cellCol)
                
                width: getCellWidth(cellCol)
                height: getCellHeight(cellRow)
                
                color: {
                    if (cellControl && typeManager) {
                        return mouseArea.containsMouse ? 
                               Qt.lighter(typeManager.getControlTypeInfo(cellControl.type).color, 1.2) :
                               typeManager.getControlTypeInfo(cellControl.type).color;
                    }
                    return mouseArea.containsMouse ? "#f0f0f0" : "#ffffff";
                }
                border.color: {
                    if (cellControl && typeManager) {
                        return mouseArea.containsMouse ? 
                               Qt.darker(typeManager.getControlTypeInfo(cellControl.type).borderColor, 1.2) :
                               typeManager.getControlTypeInfo(cellControl.type).borderColor;
                    }
                    return mouseArea.containsMouse ? "#cccccc" : "#e9ecef";
                }
                border.width: mouseArea.containsMouse ? 2 : 1
                radius: 4

                Column {
                    anchors.centerIn: parent
                    spacing: 2
                    
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: cellControl && typeManager ? 
                              (typeManager.getControlTypeInfo(cellControl.type).icon + " " + cellControl.label) : 
                              ("Cell " + index)
                        font.pixelSize: cellControl ? 12 : 10
                        color: cellControl ? "#333333" : "#666666"
                        font.bold: cellControl ? true : false
                    }
                    
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "(" + cellRow + "," + cellCol + ")"
                        font.pixelSize: 9
                        color: "#999999"
                    }
                }

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    hoverEnabled: true
                    
                    onClicked: function(mouse) {
                        console.log("Cell clicked:", cellRow, cellCol, "hasControl:", !!cellControl);
                        if (cellControl) {
                            if (mouse.button === Qt.RightButton) {
                                console.log("Right click - delete control:", cellControl.label);
                                controlRightClicked(cellRow, cellCol, cellControl);
                            } else {
                                console.log("Left click - edit control:", cellControl.label);
                                controlClicked(cellRow, cellCol, cellControl);
                            }
                        } else {
                            console.log("Empty cell clicked - no action");
                        }
                    }
                }
                
                // 操作提示文本（仅在有控件且鼠标悬停时显示）
                Rectangle {
                    anchors.bottom: parent.bottom
                    anchors.right: parent.right
                    anchors.margins: 2
                    width: tipText.width + 6
                    height: tipText.height + 4
                    color: "#333333"
                    radius: 2
                    visible: cellControl && mouseArea.containsMouse
                    
                    Text {
                        id: tipText
                        anchors.centerIn: parent
                        text: "左键配置 右键删除"
                        font.pixelSize: 8
                        color: "#ffffff"
                    }
                }
            }
        }
    }
    
    function getCellWidth(col) {
        if (gridConfig.columnWidths && col < gridConfig.columnWidths.length) {
            var width = gridConfig.columnWidths[col] * 180;
            return width;
        }
        return 180;
    }
    
    function getCellHeight(row) {
        if (gridConfig.rowHeights && row < gridConfig.rowHeights.length) {
            var height = gridConfig.rowHeights[row] * 80;
            return height;
        }
        return 80;
    }
    
    function getControlAtPosition(row, col) {
        if (!controls) return null;

        for (var i = 0; i < controls.length; i++) {
            var ctrl = controls[i];
            var ctrlRow = ctrl.row || 0;
            var ctrlCol = ctrl.column || 0;
            var ctrlRowSpan = ctrl.rowSpan || 1;
            var ctrlColSpan = ctrl.colSpan || 1;

            if (row >= ctrlRow && row < ctrlRow + ctrlRowSpan && 
                col >= ctrlCol && col < ctrlCol + ctrlColSpan) {
                return ctrl;
            }
        }
        return null;
    }
    
    Component.onCompleted: {
        console.log("GridPreview Component.onCompleted");
        console.log("Initial gridConfig:", JSON.stringify(gridConfig));
        console.log("Initial controls:", controls ? controls.length : "null");
        refresh();
    }
    
    function refresh() {
        console.log("GridPreview refresh called");
        console.log("Current gridConfig:", JSON.stringify(gridConfig));
        
        // 强制更新Grid属性
        gridLayout.rows = gridConfig.rows || 8;
        gridLayout.columns = gridConfig.columns || 2;
        gridLayout.rowSpacing = gridConfig.rowSpacing || 5;
        gridLayout.columnSpacing = gridConfig.columnSpacing || 10;
        
        var newModel = (gridConfig.rows || 8) * (gridConfig.columns || 2);
        console.log("Setting cellRepeater model to:", newModel, "rows:", gridLayout.rows, "columns:", gridLayout.columns);
        cellRepeater.model = 0;
        cellRepeater.model = newModel;
        
        // 更新GridPreview的高度
        var newHeight = calculateTotalHeight();
        console.log("Updating GridPreview height to:", newHeight);
        gridPreview.height = newHeight;
    }
}