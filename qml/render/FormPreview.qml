import QtQuick 6.5
import QtQuick.Controls 6.5
import QtQuick.Layouts 1.4
import "../core"

 * 表单预览组件
 * 显示根据JSON配置生成的表单
 */
Item {
    id: formPreview
    
    property var formConfig: ({})
    property var controlsMap: ({})
    
    // 监听配置变化
    onFormConfigChanged: {
        if (formConfig && formConfig.controls) {
            loadTimer.restart()
        }
    }
    
    // ===== 组件实例 =====
    FormAPI {
        id: formAPI
        controlsMap: formPreview.controlsMap
        messageComponent: messageBox
    }
    
    ScriptEngine {
        id: scriptEngine
        formAPI: formAPI
    }
    
    ControlFactory {
        id: controlFactory
        parentGrid: grid
        controlsMap: formPreview.controlsMap
        scriptEngine: scriptEngine
        formConfig: formPreview.formConfig
    }
    
    // 延迟加载定时器
    Timer {
        id: loadTimer
        interval: 50
        onTriggered: grid.loadForm()
    }
    
    // 消息提醒组件
    Rectangle {
        id: messageBox
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 10
        width: Math.min(parent.width - 20, 400)
        height: messageText.height + 20
        color: "#f0f8ff"
        border.color: "#4CAF50"
        border.width: 2
        radius: 8
        visible: false
        z: 1000
        
        Text {
            id: messageText
            anchors.centerIn: parent
            text: ""
            color: "#2E7D32"
            font.pixelSize: 14
            font.bold: true
            wrapMode: Text.WordWrap
            width: parent.width - 20
            horizontalAlignment: Text.AlignHCenter
        }
        
        Timer {
            id: messageTimer
            interval: 3000
            onTriggered: messageBox.visible = false
        }
        
        function showMessage(message, type) {
            messageText.text = message
            
            // 根据消息类型设置颜色
            if (type === "error") {
                messageBox.color = "#ffebee"
                messageBox.border.color = "#f44336"
                messageText.color = "#c62828"
            } else if (type === "warning") {
                messageBox.color = "#fff3e0"
                messageBox.border.color = "#ff9800"
                messageText.color = "#ef6c00"
            } else {
                messageBox.color = "#f0f8ff"
                messageBox.border.color = "#4CAF50"
                messageText.color = "#2E7D32"
            }
            
            messageBox.visible = true
            messageTimer.restart()
        }
    }

    // 主网格布局
    GridLayout {
        id: grid
        anchors.fill: parent
        anchors.margins: 5
        anchors.topMargin: 60  // 为消息框留出空间
        rows: formConfig.grid ? formConfig.grid.rows : 1
        columns: formConfig.grid ? formConfig.grid.columns : 1
        rowSpacing: formConfig.grid && formConfig.grid.rowSpacing ? formConfig.grid.rowSpacing : 10
        columnSpacing: formConfig.grid && formConfig.grid.columnSpacing ? formConfig.grid.columnSpacing : 10

        Component.onCompleted: {
            loadTimer.start()
        }

        // 占位符组件
        Component {
            id: placeholderComponent
            Rectangle {
                property int rowIndex: 0
                property int colIndex: 0
                color: "transparent"
                border.color: "#cccccc"
                border.width: 1
                Text {
                    anchors.centerIn: parent
                    text: "(" + parent.rowIndex + "," + parent.colIndex + ")"
                    color: "#999999"
                    font.pixelSize: 10
                }
            }
        }

        // 加载表单 - 主入口函数
        function loadForm() {
            // 清除现有控件
            clearForm()
            
            if (!formConfig.controls) {
                return;
            }
            
            // 步骤1：创建所有控件
            createAllControls()
            
            // 步骤2：填充空白位置
            fillEmptyGridCells()
        }
        
        // 清除表单
        function clearForm() {
            // 清除控件映射
            formPreview.controlsMap = {}
            
            // 销毁所有子元素
            for (var i = grid.children.length - 1; i >= 0; i--) {
                if (grid.children[i]) {
                    grid.children[i].destroy()
                }
            }
        }
        
        // 创建所有控件
        function createAllControls() {
            var controls = formConfig.controls
            for (var i = 0; i < controls.length; i++) {
                controlFactory.createControl(controls[i])
            }
        }
        
        // 填充空白的网格单元格
        function fillEmptyGridCells() {
            for (var r = 0; r < grid.rows; r++) {
                for (var c = 0; c < grid.columns; c++) {
                    if (!isGridCellOccupied(r, c)) {
                        createPlaceholder(r, c)
                    }
                }
            }
        }
        
        // 检查指定网格位置是否被控件占用
        function isGridCellOccupied(row, col) {
            var controls = formConfig.controls
            for (var i = 0; i < controls.length; i++) {
                var ctrl = controls[i]
                // 检查当前位置是否在控件的占用范围内
                if (ctrl.row <= row && row < ctrl.row + ctrl.rowSpan &&
                    ctrl.column <= col && col < ctrl.column + ctrl.colSpan) {
                    return true
                }
            }
            return false
        }
        
        // 在指定位置创建占位符
        function createPlaceholder(row, col) {
            var placeholder = placeholderComponent.createObject(grid, {
                "rowIndex": row,
                "colIndex": col
            })
            
            // 设置网格位置
            placeholder.Layout.row = row
            placeholder.Layout.column = col
            placeholder.Layout.fillWidth = true
            placeholder.Layout.fillHeight = true
            
            // 应用列宽比例
            applyColumnWidth(placeholder, col)
            
            // 应用行高比例
            applyRowHeight(placeholder, row)
        }
        
        // 应用列宽比例设置
        function applyColumnWidth(element, col) {
            if (formConfig.grid && formConfig.grid.columnWidths && col < formConfig.grid.columnWidths.length) {
                element.Layout.preferredWidth = formConfig.grid.columnWidths[col] * 200
            }
        }
        
        // 应用行高比例设置
        function applyRowHeight(element, row) {
            if (formConfig.grid && formConfig.grid.rowHeights && row < formConfig.grid.rowHeights.length) {
                var minHeight = 25, maxHeight = 60
                var ratio = formConfig.grid.rowHeights[row]
                element.Layout.minimumHeight = minHeight * ratio
                element.Layout.preferredHeight = 40 * ratio
                element.Layout.maximumHeight = maxHeight * ratio
            }
        }
    }
    
    // 重新加载表单的公共方法
    function reloadForm() {
        loadTimer.restart()
    }
}