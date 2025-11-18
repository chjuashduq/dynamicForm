import QtQuick 6.5
import QtQuick.Controls 6.5
import QtQuick.Layouts 1.4
import "../core"
import Common 1.0
/*
 * 表单预览组件
 * 显示根据JSON配置生成的表单
 */
Item {
    id: formPreview
    
    property var formConfig: ({})
    property var controlsMap: ({})
    property var stackViewRef: ({})
    property var loaderInstanceRef: ({})
    property string formName: ""
    property int recordId: -1
    
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

    // 主容器
    Rectangle {
        anchors.fill: parent
        color: "#f0f0f0"
        
        Column {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 20
            
            // 标题栏
            Rectangle {
                width: parent.width
                height: 60
                color: "#667eea"
                radius: 8
                visible: recordId >= 0  // 只有在新增记录时显示
                
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 10
                    
                    Button {
                        text: "返回列表"
                        onClicked: {
                            if (loaderInstanceRef && loaderInstanceRef.formPreviewLoader) {
                                loaderInstanceRef.formPreviewLoader.visible = false
                                loaderInstanceRef.dynamicListLoadingLoader.visible = true
                                stackViewRef.pop()
                            }
                        }
                    }
                    
                    Text {
                        text: "新增记录 - " + formName
                        color: "white"
                        font.pixelSize: 20
                        font.bold: true
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
            }
            
            // 表单区域
            Rectangle {
                width: parent.width
                height: recordId >= 0 ? parent.height - 160 : parent.height
                color: "#ffffff"
                border.color: "#dee2e6"
                border.width: recordId >= 0 ? 1 : 0
                radius: recordId >= 0 ? 8 : 0
                
                // 主网格布局
                GridLayout {
                    id: grid
                    anchors.fill: parent
                    anchors.margins: recordId >= 0 ? 15 : 5
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
            }
            
            // 操作按钮区域
            Rectangle {
                width: parent.width
                height: 80
                color: "#f8f9fa"
                border.color: "#dee2e6"
                border.width: 1
                radius: 8
                visible: recordId >= 0  // 只有在新增记录时显示
                
                Row {
                    anchors.centerIn: parent
                    spacing: 15
                    
                    Button {
                        text: "提交"
                        onClicked: {
                            // 收集表单数据
                            var formData = formAPI.getAllValues()
                            console.log("表单数据:", JSON.stringify(formData))
                            
                            // TODO: 这里可以添加数据验证和保存逻辑
                            MessageManager.showDialog("数据提交成功！", "success", function() {
                                loaderInstanceRef.formPreviewLoader.visible = false
                                loaderInstanceRef.dynamicListLoadingLoader.visible = true
                                stackViewRef.pop()
                            })
                        }
                    }
                    
                    Button {
                        text: "重置"
                        onClicked: {
                            grid.loadForm()
                        }
                    }
                    
                    Button {
                        text: "取消"
                        onClicked: {
                            loaderInstanceRef.formPreviewLoader.visible = false
                            loaderInstanceRef.dynamicListLoadingLoader.visible = true
                            stackViewRef.pop()
                        }
                    }
                }
            }
        }
    }
    
    // 重新加载表单的公共方法
    function reloadForm() {
        loadTimer.restart()
    }
    
    // 初始化表单（用于新增记录）
    function initForm(id, name, configJson) {
        recordId = id
        formName = name
        if (configJson && configJson !== "") {
            formConfig = JSON.parse(configJson)
        }
    }
}
