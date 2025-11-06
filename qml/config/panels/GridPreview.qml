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
        gridPreviewHeight = calculateRequiredHeight();
        refreshTimer.restart();
    }
    
    onControlsChanged: {
        // 强制刷新Repeater以显示新的控件
        cellRepeater.model = 0;
        cellRepeater.model = (gridConfig.rows || 8) * (gridConfig.columns || 2);
    }
    
    signal controlClicked(int row, int col, var control)
    signal controlRightClicked(int row, int col, var control)
    signal gridHeightChanged()
    
    width: parent ? parent.width - 20 : 400
    height: gridPreviewHeight
    anchors.horizontalCenter: parent ? parent.horizontalCenter : undefined
    visible: true
    

    
    property int gridPreviewHeight: 300  // 初始化为最小高度，等待配置加载后更新
    
    onHeightChanged: {
        gridHeightChanged();
    }
    
    onGridPreviewHeightChanged: {
        gridHeightChanged();
    }
    
    // 计算所需的总高度
    function calculateRequiredHeight() {
        var totalHeight = 0;
        var rows = gridConfig.rows || 8;
        var rowHeights = gridConfig.rowHeights || [1,1,1,1,1,1,1,2]; // 使用默认的行高配置
        var rowSpacing = gridConfig.rowSpacing || 5;
        
        // 计算所有行的总高度
        for (var i = 0; i < rows; i++) {
            if (i < rowHeights.length) {
                totalHeight += Math.max(30, rowHeights[i] * 80);
            } else {
                totalHeight += 80; // 默认高度
            }
            
            // 添加行间距（除了最后一行）
            if (i < rows - 1) {
                totalHeight += rowSpacing;
            }
        }
        
        // 添加容器的上下边距和缓冲空间
        totalHeight += 30; // 上下边距各10px + 额外缓冲10px
        
        return Math.max(300, totalHeight);
    }
    

    color: "#f8f9fa"
    border.color: "#dee2e6"
    border.width: 2
    radius: 4

    property var typeManagerLoader: Loader {
        source: "../managers/ControlTypeManager.qml"
    }
    property var typeManager: typeManagerLoader.item


    

    
    Grid {
        id: gridLayout
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.top: parent.top
        anchors.topMargin: 10
        width: parent.width - 20
        visible: true
        
        rows: gridConfig.rows || 8
        columns: gridConfig.columns || 2
        rowSpacing: gridConfig.rowSpacing || 5
        columnSpacing: gridConfig.columnSpacing || 10
        
        onImplicitHeightChanged: {
            // 使用更准确的高度计算
            updateContainerHeight();
        }
        
        // 监听行间距变化
        onRowSpacingChanged: {
            updateContainerHeight();
        }
        
        // 监听列间距变化  
        onColumnSpacingChanged: {
            updateContainerHeight();
        }

        Repeater {
            id: cellRepeater
            model: (gridConfig.rows || 8) * (gridConfig.columns || 2)

            Rectangle {
                property int cellRow: Math.floor(index / (gridConfig.columns || 2))
                property int cellCol: index % (gridConfig.columns || 2)
                property var cellControl: getControlAtPosition(cellRow, cellCol)
                
                width: getCellWidth(cellCol)
                height: getCellHeight(cellRow)
                visible: true
                
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
                        if (cellControl) {
                            if (mouse.button === Qt.RightButton) {
                                controlRightClicked(cellRow, cellCol, cellControl);
                            } else {
                                controlClicked(cellRow, cellCol, cellControl);
                            }
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
            return Math.max(50, width);
        }
        return 180;
    }
    
    function getCellHeight(row) {
        if (gridConfig.rowHeights && row < gridConfig.rowHeights.length) {
            var height = gridConfig.rowHeights[row] * 80;
            return Math.max(30, height);
        }
        return 80;
    }
    
    function calculateEstimatedHeight() {
        var totalHeight = 0;
        var rows = gridConfig.rows || 8;
        var rowHeights = gridConfig.rowHeights || [];
        var rowSpacing = gridConfig.rowSpacing || 5;
        
        // 计算所有行的总高度
        for (var i = 0; i < rows; i++) {
            if (i < rowHeights.length) {
                totalHeight += Math.max(30, rowHeights[i] * 80);
            } else {
                totalHeight += 80; // 默认高度
            }
            
            // 添加行间距（除了最后一行）
            if (i < rows - 1) {
                totalHeight += rowSpacing;
            }
        }
        
        return totalHeight > 0 ? totalHeight : (rows * 80 + (rows - 1) * rowSpacing);
    }
    
    function updateContainerHeight() {
        var calculatedHeight = calculateRequiredHeight();
        var gridImplicitHeight = gridLayout.implicitHeight;
        var finalHeight = Math.max(calculatedHeight, gridImplicitHeight + 30);
        gridPreviewHeight = finalHeight;
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
        gridPreviewHeight = calculateRequiredHeight();
        refreshTimer.start();
    }
    

    
    Timer {
        id: refreshTimer
        interval: 50
        onTriggered: {
            refresh();
        }
    }
    
    Timer {
        id: heightUpdateTimer
        interval: 150  // 增加延迟确保Grid完全布局
        repeat: false
        onTriggered: {
            updateContainerHeight();
        }
    }
    

    
    function refresh() {
        gridLayout.rows = gridConfig.rows || 8;
        gridLayout.columns = gridConfig.columns || 2;
        gridLayout.rowSpacing = gridConfig.rowSpacing || 5;
        gridLayout.columnSpacing = gridConfig.columnSpacing || 10;
        
        var newModel = (gridConfig.rows || 8) * (gridConfig.columns || 2);
        cellRepeater.model = 0;
        cellRepeater.model = newModel;
        
        gridPreviewHeight = calculateRequiredHeight();
        heightUpdateTimer.restart();
    }
}