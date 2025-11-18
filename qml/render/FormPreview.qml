import QtQuick 6.5
import QtQuick.Controls 6.5
import QtQuick.Layouts 1.4
import Common 1.0
import "../core"
import "../components"
/*
 * 表单预览组件
 * 显示根据JSON配置生成的表单
 */
Item {
    id: formPreview
    
    property var formConfig: ({})
    property var controlsMap: ({})
    property var labelsMap: ({})
    property var stackViewRef: ({})
    property var loaderInstanceRef: ({})
    property string formName: ""
    property int recordId: -1
    property int dataRecordId: -1  // 数据记录ID（编辑模式）
    property var initialData: ({})  // 初始数据（编辑模式）
    property bool isEditMode: false // 是否为编辑模式
    property bool fromDataRecordList: false // 是否从数据记录列表进入
    
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
        labelsMap: formPreview.labelsMap
        scriptEngine: scriptEngine
    }
    
    ScriptEngine {
        id: scriptEngine
        formId: formPreview.recordId
        dataRecordId: formPreview.dataRecordId
        isEditMode: formPreview.isEditMode
    }
    
    Component.onCompleted: {
        scriptEngine.formAPI = formAPI
    }
    
    // 当recordId变化时更新scriptEngine的formId
    onRecordIdChanged: {
        scriptEngine.formId = recordId
    }
    
    // 当dataRecordId变化时更新scriptEngine
    onDataRecordIdChanged: {
        scriptEngine.dataRecordId = dataRecordId
    }
    
    // 当isEditMode变化时更新scriptEngine
    onIsEditModeChanged: {
        scriptEngine.isEditMode = isEditMode
    }
    
    ControlFactory {
        id: controlFactory
        parentGrid: grid
        controlsMap: formPreview.controlsMap
        labelsMap: formPreview.labelsMap
        scriptEngine: scriptEngine
        formConfig: formPreview.formConfig
        formAPI: formAPI
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
        color: AppStyles.backgroundColor
        
        Column {
            anchors.fill: parent
            anchors.margins: AppStyles.spacingXLarge
            spacing: AppStyles.spacingLarge
            
            // 标题栏
            Rectangle {
                width: parent.width
                height: 60
                color: AppStyles.primaryColor
                radius: AppStyles.radiusLarge
                visible: recordId >= 0  // 只有在新增记录时显示
                
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: AppStyles.paddingMedium
                    spacing: AppStyles.spacingMedium
                    
                    StyledButton {
                        text: "返回列表"
                        buttonType: "secondary"
                        onClicked: {
                            if (loaderInstanceRef && loaderInstanceRef.formPreviewLoader) {
                                loaderInstanceRef.formPreviewLoader.visible = false
                                
                                // 如果是从数据记录列表进入的，返回数据记录列表并刷新
                                if (fromDataRecordList && loaderInstanceRef.dataRecordListLoader) {
                                    loaderInstanceRef.dataRecordListLoader.visible = true
                                    if (loaderInstanceRef.dataRecordListLoader.item) {
                                        loaderInstanceRef.dataRecordListLoader.item.loadData()
                                    }
                                } else {
                                    // 否则返回表单列表
                                    loaderInstanceRef.dynamicListLoadingLoader.visible = true
                                }
                                
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
                height: recordId >= 0 ? parent.height - 80 : parent.height
                color: AppStyles.surfaceColor
                border.color: AppStyles.borderColor
                border.width: recordId >= 0 ? AppStyles.cardBorderWidth : 0
                radius: recordId >= 0 ? AppStyles.cardRadius : 0
                
                // 主网格布局
                GridLayout {
                    id: grid
                    anchors.fill: parent
                    anchors.margins: recordId >= 0 ? AppStyles.cardPadding : AppStyles.spacingSmall
                    rows: formConfig.grid ? formConfig.grid.rows : 1
                    columns: formConfig.grid ? formConfig.grid.columns : 1
                    rowSpacing: formConfig.grid && formConfig.grid.rowSpacing ? formConfig.grid.rowSpacing : AppStyles.spacingMedium
                    columnSpacing: formConfig.grid && formConfig.grid.columnSpacing ? formConfig.grid.columnSpacing : AppStyles.spacingMedium

                    Component.onCompleted: {
                        loadTimer.start()
                    }

                    // 占位符组件（不显示边框和坐标）
                    Component {
                        id: placeholderComponent
                        Rectangle {
                            property int rowIndex: 0
                            property int colIndex: 0
                            color: "transparent"
                            border.width: 0
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
            
            // 底部操作按钮已移除，使用配置的按钮来提交和重置
        }
    }
    
    // 重新加载表单的公共方法
    function reloadForm() {
        loadTimer.restart()
    }
    
    // 初始化表单（用于新增记录）
    function initForm(id, name, configJson, fromRecordList) {
        recordId = id
        formName = name
        isEditMode = false
        dataRecordId = -1
        initialData = {}
        fromDataRecordList = fromRecordList || false
        
        if (configJson && configJson !== "") {
            formConfig = JSON.parse(configJson)
        }
    }
    
    // 初始化表单（用于编辑记录）
    function initFormForEdit(id, name, configJson, recordDataId, dataJson) {
        recordId = id
        formName = name
        isEditMode = true
        dataRecordId = recordDataId
        fromDataRecordList = true  // 编辑模式一定是从数据记录列表进入的
        
        // 解析初始数据
        if (dataJson && dataJson !== "") {
            try {
                initialData = typeof dataJson === "string" ? JSON.parse(dataJson) : dataJson
            } catch(e) {
                initialData = {}
            }
        } else {
            initialData = {}
        }
        
        if (configJson && configJson !== "") {
            formConfig = JSON.parse(configJson)
        }
        
        // 使用 Timer 延迟填充数据，确保表单完全加载
        fillDataTimer.start()
    }
    
    // 填充数据的定时器
    Timer {
        id: fillDataTimer
        interval: 200
        repeat: false
        onTriggered: fillFormData()
    }
    
    // 填充表单数据
    function fillFormData() {
        if (!initialData || Object.keys(initialData).length === 0) {
            return
        }
        
        for (var key in initialData) {
            if (initialData.hasOwnProperty(key)) {
                formAPI.setControlValue(key, initialData[key])
            }
        }
    }
}
