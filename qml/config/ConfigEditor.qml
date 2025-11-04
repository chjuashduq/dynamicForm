import QtQuick 6.5
import QtQuick.Controls 6.5
import QtQuick.Layouts 1.4

/**
 * 动态表单配置编辑器 (完整功能版)
 *
 * 功能特性：
 * - 可视化网格布局配置
 * - 支持多种控件类型（文本框、数字框、下拉框等）
 * - 实时位置验证和冲突检测
 * - 网格式控件预览和管理
 * - 智能函数提示和代码插入
 * - 事件配置和脚本编辑
 *
 * @author Dynamic Form QML Team
 * @version 1.0
 */
Item {
    id: configEditor
    
    // 确保根Item有正确的尺寸
    anchors.fill: parent
    width: parent ? parent.width : 800
    height: parent ? parent.height : 600

    // ==================== Signal Definitions ====================

    /** 配置变更信号 - 当表单配置发生变化时触发 */
    signal configChanged(var newConfig)

    // ==================== Property Definitions ====================

    /** 当前表单配置对象 */
    property var currentConfig: ({
            "grid": {
                "rows": 8              // 网格行数
                ,
                "columns": 2           // 网格列数
                ,
                "rowSpacing": 5        // 行间距
                ,
                "columnSpacing": 10    // 列间距
                ,
                "rowHeights": [1, 1, 1, 1, 1, 1, 1, 2]  // 行高比例
                ,
                "columnWidths": [1, 2]  // 列宽比例
            },
            "controls": []              // 控件列表
        })

    // ==================== Initialization ====================
    
    Component.onCompleted: {
        console.log("ConfigEditor Component.onCompleted called");
        console.log("ConfigEditor initialization completed");
    }

    // ==================== 内部组件定义 ====================

    /**
     * 函数按钮组件 - 用于函数提示对话框中的可点击函数项
     *
     * @property functionCode 函数代码字符串
     * @property description 函数描述文本
     * @signal clicked 点击事件信号
     */
    component FunctionButton: Rectangle {
        property string functionCode: ""
        property string description: ""
        signal clicked

        width: parent.width
        height: 25
        color: mouseArea.containsMouse ? "#e3f2fd" : "transparent"
        border.color: mouseArea.containsMouse ? "#2196f3" : "transparent"
        border.width: 1
        radius: 3

        Row {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 10
            spacing: 10

            Text {
                text: "📋"
                font.pixelSize: 12
            }

            Text {
                text: functionCode + " - " + description
                font.pixelSize: 11
                color: mouseArea.containsMouse ? "#1976d2" : "#495057"
            }
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: parent.clicked()
        }
    }

    // ==================== 核心业务逻辑函数 ====================

    /**
     * 计算下一个控件的最佳放置位置
     *
     * 算法逻辑：
     * 1. 如果没有控件，返回(0,0)
     * 2. 基于最后一个控件的位置和跨度计算下一个位置
     * 3. 如果超出网格范围，自动换行到下一列的第一行
     *
     * @returns {Object} 包含row和column属性的位置对象
     */
    function getNextPosition() {
        if (!currentConfig.controls || currentConfig.controls.length === 0) {
            return {
                row: 0,
                column: 0
            };
        }

        var gridRows = currentConfig.grid.rows || 8;
        var gridCols = currentConfig.grid.columns || 2;

        // 查找第一个空位置
        for (var row = 0; row < gridRows; row++) {
            for (var col = 0; col < gridCols; col++) {
                if (!getControlAtPosition(row, col)) {
                    return {
                        row: row,
                        column: col
                    };
                }
            }
        }

        // 如果没有空位置，返回无效位置
        return {
            row: -1,
            column: -1
        };
    }

    // ==================== 主界面布局 ====================

    Rectangle {
        anchors.fill: parent
        color: "#f0f0f0"
        
        Column {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 20

            // 标题
            Rectangle {
                width: parent.width
                height: 60
                color: "#667eea"
                radius: 8

                Text {
                    anchors.centerIn: parent
                    text: "动态表单配置编辑器"
                    color: "white"
                    font.pixelSize: 20
                    font.bold: true
                }
            }

            // 网格配置
            Rectangle {
                width: parent.width - 40
                height: 280
                anchors.horizontalCenter: parent.horizontalCenter
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
                            Text {
                                text: "行数"
                            }
                            SpinBox {
                                id: rowsSpinBox
                                from: 1
                                to: 20
                                value: currentConfig.grid.rows || 8
                                onValueChanged: {
                                    console.log("行数变化为: " + value);
                                    updateGridConfig();
                                }
                            }
                        }

                        Column {
                            Text {
                                text: "列数"
                            }
                            SpinBox {
                                id: columnsSpinBox
                                from: 1
                                to: 10
                                value: currentConfig.grid.columns || 2
                                onValueChanged: {
                                    console.log("列数变化为: " + value);
                                    updateGridConfig();
                                }
                            }
                        }

                        Column {
                            Text {
                                text: "行间距"
                            }
                            SpinBox {
                                id: rowSpacingSpinBox
                                from: 0
                                to: 50
                                value: currentConfig.grid.rowSpacing || 5
                                onValueChanged: configEditor.updateGridConfig()
                            }
                        }

                        Column {
                            Text {
                                text: "列间距"
                            }
                            SpinBox {
                                id: columnSpacingSpinBox
                                from: 0
                                to: 50
                                value: currentConfig.grid.columnSpacing || 10
                                onValueChanged: configEditor.updateGridConfig()
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

                        // 行高配置
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
                                width: parent.width
                                placeholderText: "1,1,1,1,1,1,1,2"
                                text: formatArrayForEdit(currentConfig.grid ? currentConfig.grid.rowHeights : [])
                                onEditingFinished: updateGridConfig()
                            }
                        }

                        // 列宽配置
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
                                width: parent.width
                                placeholderText: "1,2"
                                text: formatArrayForEdit(currentConfig.grid ? currentConfig.grid.columnWidths : [])
                                onEditingFinished: updateGridConfig()
                            }
                        }
                    }
                }
            }

            // 添加控件按钮
            Rectangle {
                width: parent.width - 40
                height: 120
                anchors.horizontalCenter: parent.horizontalCenter
                color: "#ffffff"
                border.color: "#dee2e6"
                border.width: 1
                radius: 8

                Column {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 10

                    Text {
                        text: "添加控件"
                        font.pixelSize: 16
                        font.bold: true
                    }

                    // 第一行控件
                    Row {
                        spacing: 15

                        Button {
                            text: "📝 文本框"
                            onClicked: {
                                console.log("添加文本框控件");
                                addControl("text");
                            }
                        }
                        Button {
                            text: "🔢 数字框"
                            onClicked: {
                                console.log("添加数字框控件");
                                addControl("number");
                            }
                        }
                        Button {
                            text: "🔒 密码框"
                            onClicked: {
                                console.log("添加密码框控件");
                                addControl("password");
                            }
                        }
                        Button {
                            text: "📋 下拉框"
                            onClicked: {
                                console.log("添加下拉框控件");
                                addControl("dropdown");
                            }
                        }
                    }

                    // 第二行控件
                    Row {
                        spacing: 15

                        Button {
                            text: "☑️ 复选框"
                            onClicked: {
                                console.log("添加复选框控件");
                                addControl("checkbox");
                            }
                        }
                        Button {
                            text: "🔘 单选框"
                            onClicked: {
                                console.log("添加单选框控件");
                                addControl("radio");
                            }
                        }
                        Button {
                            text: "🎯 按钮"
                            onClicked: {
                                console.log("添加按钮控件");
                                addControl("button");
                            }
                        }
                    }
                }
            }

            // 控件列表
            Rectangle {
                width: parent.width - 40
                height: 800  // 恢复合理高度
                anchors.horizontalCenter: parent.horizontalCenter
                color: "#ffffff"
                border.color: "red"
                border.width: 1
                radius: 8

                Column {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 10

                    Text {
                        text: "控件预览"
                        font.pixelSize: 16
                        font.bold: true
                    }

                    // 网格式布局显示
                    Rectangle {
                        id: gridContainer
                        width: parent.width - 20  // 减去一些边距，确保不超出父容器
                        height: 760  // 8行 * 90像素 + 40边距
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: "#f8f9fa"
                        border.color: "#dee2e6"
                        border.width: 1
                        radius: 4

                        ScrollView {
                            anchors.fill: parent
                            anchors.margins: 10
                            clip: true
                            ScrollBar.horizontal.policy: ScrollBar.AsNeeded
                            ScrollBar.vertical.policy: ScrollBar.AsNeeded
                            
                            Grid {
                                id: gridLayout
                                width: parent.width
                                
                                height: 720  // 8行 * 90像素
                                
                                // 添加总宽度属性供Rectangle使用
                                property real totalWidth: width

                                // 使用Grid而不是GridLayout，更简单直接
                                rows: 8
                                columns: 2
                                rowSpacing: 5
                                columnSpacing: 10

                                property int gridRows: 8
                                property int gridColumns: 2
                                property int gridCellCount: 16

                                Repeater {
                                    id: controlsRepeater
                                    model: gridLayout.gridCellCount

                                    Rectangle {
                                        property int cellRow: Math.floor(index / gridLayout.gridColumns)
                                        property int cellCol: index % gridLayout.gridColumns
                                        property var cellControl: getControlAtPosition(cellRow, cellCol)
                                        
                                        width: {
                                            if (currentConfig.grid && currentConfig.grid.columnWidths && cellCol < currentConfig.grid.columnWidths.length) {
                                                return currentConfig.grid.columnWidths[cellCol] * 200;
                                            }
                                            return 200;
                                        }
                                        height: {
                                            if (currentConfig.grid && currentConfig.grid.rowHeights && cellRow < currentConfig.grid.rowHeights.length) {
                                                return currentConfig.grid.rowHeights[cellRow] * 80;
                                            }
                                            return 80;
                                        }
                                        
                                        color: cellControl ? getControlColor(cellControl.type) : "#ffffff"
                                        border.color: cellControl ? getControlBorderColor(cellControl.type) : "#e9ecef"
                                        border.width: 1
                                        radius: 4

                                        Column {
                                            anchors.centerIn: parent
                                            spacing: 5
                                            
                                            Text {
                                                anchors.horizontalCenter: parent.horizontalCenter
                                                text: cellControl ? (getControlIcon(cellControl.type) + " " + cellControl.label) : ("Cell " + index)
                                                font.pixelSize: cellControl ? 12 : 10
                                                color: cellControl ? "#333333" : "#495057"
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
                                            anchors.fill: parent
                                            acceptedButtons: Qt.LeftButton | Qt.RightButton
                                            onClicked: function(mouse) {
                                                console.log("Clicked cell " + index + " at (" + cellRow + "," + cellCol + ")");
                                                if (mouse.button === Qt.RightButton) {
                                                    // 右键删除控件
                                                    if (cellControl) {
                                                        removeControlAtPosition(cellRow, cellCol);
                                                    }
                                                } else {
                                                    // 左键编辑控件
                                                    if (cellControl) {
                                                        editControlAtPosition(cellRow, cellCol);
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }



                // 底部边距
                Item {
                    width: parent.width
                    height: 20
                }
            }

            // 操作按钮区域
            Rectangle {
                width: parent.width - 40
                height: 80
                anchors.horizontalCenter: parent.horizontalCenter
                color: "#f8f9fa"
                border.color: "#dee2e6"
                border.width: 1
                radius: 8

                Row {
                    anchors.centerIn: parent
                    spacing: 15

                    Button {
                        text: "应用配置"
                        onClicked: applyConfig()
                    }

                    Button {
                        text: "导出配置"
                        onClicked: exportJson()
                    }

                    Button {
                        text: "重置配置"
                        onClicked: resetConfig()
                    }
                }
            }

            // 底部边距
            Item {
                width: parent.width
                height: 20
            }
        }

        // 控件编辑对话框
        Dialog {
            id: editDialog
            title: "编辑控件"
            width: Math.min(parent.width * 0.9, 800)
            height: Math.min(parent.height * 0.9, 700)
            anchors.centerIn: parent
            modal: true

            property int editIndex: -1
            property var editConfig: ({})

            // Validate edit position function
            function validateEditPosition() {
                var row = editRowSpinBox.value;
                var col = editColSpinBox.value;
                var rowSpan = editRowSpanSpinBox.value;
                var colSpan = editColSpanSpinBox.value;

                var gridRows = currentConfig.grid.rows || 8;
                var gridCols = currentConfig.grid.columns || 2;

                // 检查是否超出网格范围
                if (row + rowSpan > gridRows || col + colSpan > gridCols) {
                    positionValidationArea.isValid = false;
                    positionValidationArea.validationMessage = "控件位置超出网格范围";
                    return false;
                }

                // 检查是否与其他控件冲突
                for (var i = 0; i < currentConfig.controls.length; i++) {
                    if (i === editDialog.editIndex)
                        // 跳过自己

                        continue;
                    var ctrl = currentConfig.controls[i];
                    var ctrlRow = ctrl.row || 0;
                    var ctrlCol = ctrl.column || 0;
                    var ctrlRowSpan = ctrl.rowSpan || 1;
                    var ctrlColSpan = ctrl.colSpan || 1;

                    // 检查是否有重叠
                    if (!(row >= ctrlRow + ctrlRowSpan || row + rowSpan <= ctrlRow || col >= ctrlCol + ctrlColSpan || col + colSpan <= ctrlCol)) {
                        positionValidationArea.isValid = false;
                        positionValidationArea.validationMessage = "控件位置与现有控件冲突";
                        return false;
                    }
                }

                positionValidationArea.isValid = true;
                positionValidationArea.validationMessage = "位置有效";
                return true;
            }

            ScrollView {
                anchors.fill: parent
                anchors.margins: 10
                clip: true

                Column {
                    width: parent.width - 20
                    spacing: 15

                    // 基本属性
                    Grid {
                        columns: 4
                        spacing: 15

                        Text {
                            text: "标识:"
                        }
                        TextField {
                            id: editKeyField
                            width: 200
                            text: editDialog.editConfig.key || ""
                        }

                        Text {
                            text: "标签:"
                        }
                        TextField {
                            id: editLabelField
                            width: 200
                            text: editDialog.editConfig.label || ""
                        }

                        Text {
                            text: "行:"
                        }
                        SpinBox {
                            id: editRowSpinBox
                            from: 0
                            to: 20
                            value: editDialog.editConfig.row || 0
                            onValueChanged: editDialog.validateEditPosition()
                        }

                        Text {
                            text: "列:"
                        }
                        SpinBox {
                            id: editColSpinBox
                            from: 0
                            to: 10
                            value: editDialog.editConfig.column || 0
                            onValueChanged: editDialog.validateEditPosition()
                        }

                        Text {
                            text: "行跨度:"
                        }
                        SpinBox {
                            id: editRowSpanSpinBox
                            from: 1
                            to: 10
                            value: editDialog.editConfig.rowSpan || 1
                            onValueChanged: editDialog.validateEditPosition()
                        }

                        Text {
                            text: "列跨度:"
                        }
                        SpinBox {
                            id: editColSpanSpinBox
                            from: 1
                            to: 10
                            value: editDialog.editConfig.colSpan || 1
                            onValueChanged: editDialog.validateEditPosition()
                        }

                        Text {
                            text: "标签比例:"
                        }
                        Row {
                            SpinBox {
                                id: editLabelRatioSpinBox
                                from: 0
                                to: 100
                                value: (editDialog.editConfig.labelRatio || 0.3) * 100
                            }
                            Text {
                                text: "%"
                            }
                        }
                    }

                    // 位置验证提示
                    Rectangle {
                        id: positionValidationArea
                        width: parent.width
                        height: validationText.implicitHeight + 20
                        color: isValid ? "#d4edda" : "#f8d7da"
                        border.color: isValid ? "#c3e6cb" : "#f5c6cb"
                        border.width: 1
                        radius: 4
                        visible: validationMessage !== ""

                        property bool isValid: true
                        property string validationMessage: ""

                        Text {
                            id: validationText
                            anchors.centerIn: parent
                            text: parent.validationMessage
                            color: parent.isValid ? "#155724" : "#721c24"
                            font.pixelSize: 12
                            wrapMode: Text.WordWrap
                            width: parent.width - 20
                        }
                    }

                    // 文本框属性
                    Column {
                        visible: editDialog.editConfig.type === "text"
                        spacing: 8
                        width: parent.width

                        Text {
                            text: "占位符:"
                        }
                        TextField {
                            id: editPlaceholderField
                            width: parent.width
                            text: editDialog.editConfig.placeholder || ""
                        }

                        Text {
                            text: "默认值:"
                        }
                        TextField {
                            id: editValueField
                            width: parent.width
                            text: editDialog.editConfig.value || ""
                        }
                    }

                    // 数字框属性
                    Column {
                        visible: editDialog.editConfig.type === "number"
                        spacing: 8

                        Text {
                            text: "默认值:"
                        }
                        SpinBox {
                            id: editNumberValueSpinBox
                            from: -999999
                            to: 999999
                            value: editDialog.editConfig.value || 0
                        }
                    }

                    // 下拉框属性
                    Column {
                        visible: editDialog.editConfig.type === "dropdown"
                        spacing: 8
                        width: parent.width

                        Text {
                            text: "选项配置 (格式: 显示文本|值):"
                        }
                        TextArea {
                            id: editOptionsArea
                            width: parent.width
                            height: 80
                            text: editDialog.editConfig.options ? formatOptionsForEdit(editDialog.editConfig.options) : ""
                            wrapMode: TextArea.Wrap
                            placeholderText: "例如:\\n选项1|option1\\n选项2|option2"
                        }
                    }

                    // 复选框属性
                    Column {
                        visible: editDialog.editConfig.type === "checkbox"
                        spacing: 8
                        width: parent.width

                        Text {
                            text: "选项配置 (格式: 显示文本|值):"
                        }
                        TextArea {
                            id: editCheckboxOptionsArea
                            width: parent.width
                            height: 80
                            text: editDialog.editConfig.options ? formatOptionsForEdit(editDialog.editConfig.options) : ""
                            wrapMode: TextArea.Wrap
                            placeholderText: "例如:\\n选项1|option1\\n选项2|option2"
                        }

                        Row {
                            spacing: 10
                            Text {
                                text: "排列方向:"
                            }
                            ComboBox {
                                id: editDirectionCombo
                                model: ["horizontal", "vertical"]
                                currentIndex: (editDialog.editConfig.direction === "vertical") ? 1 : 0
                            }
                        }
                    }

                    // 单选框属性
                    Column {
                        visible: editDialog.editConfig.type === "radio"
                        spacing: 8
                        width: parent.width

                        Text {
                            text: "选项配置 (格式: 显示文本|值):"
                        }
                        TextArea {
                            id: editRadioOptionsArea
                            width: parent.width
                            height: 80
                            text: editDialog.editConfig.options ? formatOptionsForEdit(editDialog.editConfig.options) : ""
                            wrapMode: TextArea.Wrap
                            placeholderText: "例如:\\n选项1|option1\\n选项2|option2"
                        }
                    }

                    // 按钮属性
                    Column {
                        visible: editDialog.editConfig.type === "button"
                        spacing: 8
                        width: parent.width

                        Text {
                            text: "按钮文本:"
                        }
                        TextField {
                            id: editButtonTextField
                            width: parent.width
                            text: editDialog.editConfig.text || ""
                        }
                    }

                    // 密码框属性
                    Column {
                        visible: editDialog.editConfig.type === "password"
                        spacing: 8
                        width: parent.width

                        Text {
                            text: "占位符:"
                        }
                        TextField {
                            id: editPasswordPlaceholderField
                            width: parent.width
                            text: editDialog.editConfig.placeholder || ""
                        }
                    }

                    // 事件配置
                    Text {
                        text: "事件配置"
                        font.pixelSize: 16
                        font.bold: true
                    }

                    // 焦点丢失事件
                    Row {
                        width: parent.width

                        Text {
                            text: "焦点丢失事件:"
                            Layout.fillWidth: true
                        }

                        Button {
                            text: "💡 函数提示"
                            onClicked: {
                                focusLostHelpDialog.targetTextArea = editFocusLostArea;
                                focusLostHelpDialog.open();
                            }
                        }
                    }

                    TextArea {
                        id: editFocusLostArea
                        width: parent.width
                        height: 60
                        text: (editDialog.editConfig.events && editDialog.editConfig.events.onFocusLost) || ""
                        wrapMode: TextArea.Wrap
                        placeholderText: "JavaScript代码..."
                    }

                    Row {
                        width: parent.width
                        visible: configEditor.hasChangeEvent(editDialog.editConfig.type)

                        Text {
                            text: configEditor.getChangeEventLabel(editDialog.editConfig.type)
                            Layout.fillWidth: true
                        }

                        Button {
                            text: "💡 函数提示"
                            onClicked: {
                                changeEventHelpDialog.targetTextArea = editChangeArea;
                                changeEventHelpDialog.open();
                            }
                        }
                    }

                    TextArea {
                        id: editChangeArea
                        width: parent.width
                        height: 60
                        visible: configEditor.hasChangeEvent(editDialog.editConfig.type)
                        text: {
                            if (!editDialog.editConfig.events)
                                return "";
                            if (editDialog.editConfig.type === "button")
                                return editDialog.editConfig.events.onClicked || "";
                            if (editDialog.editConfig.type === "switch")
                                return editDialog.editConfig.events.onToggled || "";
                            return editDialog.editConfig.events.onTextChanged || editDialog.editConfig.events.onValueChanged || "";
                        }
                        wrapMode: TextArea.Wrap
                        placeholderText: "JavaScript代码..."
                    }
                }
            }

            standardButtons: Dialog.Ok | Dialog.Cancel

            onAccepted: {
                saveControlEdit();
            }
        }
    }
    // ==================== 界面刷新和性能优化 ====================

    /**
     * 强制刷新界面显示
     *
     * 使用场景：
     * - 添加新控件后
     * - 删除控件后
     * - 修改网格配置后
     *
     * 实现原理：
     * 通过重新设置Repeater的model来触发界面重绘
     */
    function forceRefresh() {
        console.log("强制刷新界面");
        
        // 更新网格布局属性
        var newRows = currentConfig.grid.rows || 8;
        var newColumns = currentConfig.grid.columns || 2;
        
        gridLayout.rows = newRows;
        gridLayout.columns = newColumns;
        gridLayout.rowSpacing = currentConfig.grid.rowSpacing || 5;
        gridLayout.columnSpacing = currentConfig.grid.columnSpacing || 10;
        gridLayout.gridRows = newRows;
        gridLayout.gridColumns = newColumns;
        gridLayout.gridCellCount = newRows * newColumns;

        console.log("网格更新为: " + newRows + "行 x " + newColumns + "列 = " + gridLayout.gridCellCount + "个单元格");

        // 临时清空model然后重新设置
        controlsRepeater.model = 0;
        controlsRepeater.model = gridLayout.gridCellCount;

        // 更新容器高度以适应新的网格尺寸
        gridContainer.height = Math.max(400, newRows * 90 + 40);
    }

    /**
     * 界面刷新延迟定时器
     * 用于控件编辑后的界面刷新
     */
    Timer {
        id: refreshTimer
        interval: 50
        onTriggered: {
            forceRefresh();
        }
    }

    /**
     * 网格配置更新函数
     *
     * 处理流程：
     * 1. 收集UI控件的当前值
     * 2. 解析行高列宽配置
     * 3. 更新配置对象
     * 4. 刷新界面显示
     * 5. 发送配置变更信号
     */
    function updateGridConfig() {
        // 使用延迟更新避免频繁刷新
        updateTimer.restart();
    }

    /**
     * 网格配置延迟更新定时器
     * 100ms延迟确保用户操作完成后再更新，提升用户体验
     */
    Timer {
        id: updateTimer
        interval: 100
        onTriggered: {
            // 解析用户输入的行高和列宽
            var rowHeights = parseArrayFromEdit(rowHeightsField.text);
            var columnWidths = parseArrayFromEdit(columnWidthsField.text);

            // 如果用户输入为空或不足，用默认值补充
            if (rowHeights.length === 0) {
                rowHeights = generateArray(rowsSpinBox.value, 1);
            } else if (rowHeights.length < rowsSpinBox.value) {
                // 补充不足的行高
                for (var i = rowHeights.length; i < rowsSpinBox.value; i++) {
                    rowHeights.push(1);
                }
            } else if (rowHeights.length > rowsSpinBox.value) {
                // 截取多余的行高
                rowHeights = rowHeights.slice(0, rowsSpinBox.value);
            }

            if (columnWidths.length === 0) {
                // 初始化时，如果是2列设置为1,2比例，否则都设置为1
                if (columnsSpinBox.value === 2) {
                    columnWidths = [1, 2];
                } else {
                    columnWidths = generateArray(columnsSpinBox.value, 1);
                }
            } else if (columnWidths.length < columnsSpinBox.value) {
                // 补充不足的列宽，新增的列默认宽度为1
                for (var j = columnWidths.length; j < columnsSpinBox.value; j++) {
                    columnWidths.push(1);
                }
            } else if (columnWidths.length > columnsSpinBox.value) {
                // 截取多余的列宽
                columnWidths = columnWidths.slice(0, columnsSpinBox.value);
            }

            currentConfig.grid = {
                "rows": rowsSpinBox.value,
                "columns": columnsSpinBox.value,
                "rowSpacing": rowSpacingSpinBox.value,
                "columnSpacing": columnSpacingSpinBox.value,
                "rowHeights": rowHeights,
                "columnWidths": columnWidths
            };

            // 强制更新网格布局属性
            var newRows = currentConfig.grid.rows;
            var newColumns = currentConfig.grid.columns;
            
            // 直接设置Grid属性
            gridLayout.rows = newRows;
            gridLayout.columns = newColumns;
            gridLayout.rowSpacing = currentConfig.grid.rowSpacing;
            gridLayout.columnSpacing = currentConfig.grid.columnSpacing;
            gridLayout.gridRows = newRows;
            gridLayout.gridColumns = newColumns;
            gridLayout.gridCellCount = newRows * newColumns;
            
            // 更新Repeater模型，确保与Grid的rows*columns匹配
            controlsRepeater.model = 0;
            // 使用实际的rows*columns而不是gridCellCount
            controlsRepeater.model = newRows * newColumns;
            
            console.log("Grid updated: rows=" + newRows + ", columns=" + newColumns + ", cellCount=" + gridLayout.gridCellCount);

            // 更新容器高度以适应新的网格尺寸
            gridContainer.height = Math.max(400, currentConfig.grid.rows * 90 + 40);
            
            // 更新文本字段显示（避免触发onTextChanged）
            if (rowHeightsField.text !== formatArrayForEdit(rowHeights)) {
                rowHeightsField.text = formatArrayForEdit(rowHeights);
            }
            if (columnWidthsField.text !== formatArrayForEdit(columnWidths)) {
                columnWidthsField.text = formatArrayForEdit(columnWidths);
            }
            
            // 不调用forceRefresh，避免循环
        }
    }

    // ==================== 工具函数 ====================

    /**
     * 生成指定长度和默认值的数组
     * 主要用于创建行高和列宽配置数组
     *
     * @param {number} length 数组长度
     * @param {*} defaultValue 默认值
     * @returns {Array} 生成的数组
     */
    function generateArray(length, defaultValue) {
        var arr = [];
        for (var i = 0; i < length; i++) {
            arr.push(defaultValue);
        }
        return arr;
    }

    /**
     * 格式化数组为编辑文本
     * 将数组转换为逗号分隔的字符串
     *
     * @param {Array} array 要格式化的数组
     * @returns {string} 逗号分隔的字符串
     */
    function formatArrayForEdit(array) {
        if (!array || !Array.isArray(array))
            return "";
        return array.join(",");
    }

    /**
     * 解析编辑文本为数组
     * 将逗号分隔的字符串转换为数字数组
     *
     * @param {string} text 逗号分隔的文本
     * @returns {Array} 数字数组
     */
    function parseArrayFromEdit(text) {
        if (!text || text.trim() === "")
            return [];

        return text.split(",").map(function (item) {
            var num = parseFloat(item.trim());
            return isNaN(num) ? 1 : Math.max(0.1, num); // 最小值0.1，避免0或负数
        }).filter(function (num) {
            return num > 0; // 过滤掉无效值
        });
    }

    /**
     * 添加新控件到表单配置
     *
     * 处理流程：
     * 1. 计算最佳放置位置
     * 2. 创建控件配置对象
     * 3. 根据控件类型设置默认属性
     * 4. 添加到控件列表
     * 5. 刷新界面显示
     *
     * @param {string} type 控件类型 (text|number|password|dropdown|checkbox|radio|button)
     */
    function addControl(type) {
        var nextPos = getNextPosition();

        var newControl = {
            "type": type,
            "key": type + "_" + Date.now(),
            "label": getDefaultLabel(type),
            "row": nextPos.row,
            "column": nextPos.column,
            "rowSpan": 1,
            "colSpan": 1,  // 所有控件默认占用一格
            "labelRatio": type === "button" ? 0 : 0.3
        };

        // 根据类型添加特定属性
        addControlTypeProperties(newControl, type);

        if (!currentConfig.controls) {
            currentConfig.controls = [];
        }
        currentConfig.controls.push(newControl);

        // 强制刷新界面以显示新添加的控件
        forceRefresh();
    }

    /**
     * 为控件添加类型特定的属性
     *
     * @param {Object} control 控件配置对象
     * @param {string} type 控件类型
     */
    function addControlTypeProperties(control, type) {
        var defaultOptions = [
            {
                "label": "选项1",
                "value": "option1"
            },
            {
                "label": "选项2",
                "value": "option2"
            }
        ];

        switch (type) {
        case "text":
            control.placeholder = "请输入文本";
            control.value = "";
            break;
        case "number":
            control.value = 0;
            control.min = 0;
            control.max = 100;
            break;
        case "password":
            control.placeholder = "请输入密码";
            control.value = "";
            break;
        case "dropdown":
            control.options = defaultOptions;
            control.value = "option1";
            break;
        case "checkbox":
            control.options = defaultOptions;
            control.value = [];
            control.direction = "horizontal";
            break;
        case "radio":
            control.options = defaultOptions;
            control.value = "option1";
            break;
        case "button":
            control.text = "按钮";
            break;
        }
    }

    // 保存控件编辑
    function saveControlEdit() {
        if (editDialog.editIndex >= 0) {
            var newConfig = {
                "type": editDialog.editConfig.type,
                "key": editKeyField.text,
                "label": editLabelField.text,
                "row": editRowSpinBox.value,
                "column": editColSpinBox.value,
                "rowSpan": editRowSpanSpinBox.value,
                "colSpan": editColSpanSpinBox.value,
                "labelRatio": editLabelRatioSpinBox.value / 100.0
            };

            // 添加类型特定属性
            switch (editDialog.editConfig.type) {
            case "text":
                newConfig.placeholder = editPlaceholderField.text;
                newConfig.value = editValueField.text;
                break;
            case "number":
                newConfig.value = editNumberValueSpinBox.value;
                break;
            case "password":
                newConfig.placeholder = editPasswordPlaceholderField.text;
                break;
            case "dropdown":
                newConfig.options = parseOptionsFromEdit(editOptionsArea.text);
                break;
            case "checkbox":
                newConfig.options = parseOptionsFromEdit(editCheckboxOptionsArea.text);
                newConfig.direction = editDirectionCombo.currentText;
                break;
            case "radio":
                newConfig.options = parseOptionsFromEdit(editRadioOptionsArea.text);
                break;
            case "button":
                newConfig.text = editButtonTextField.text;
                break;
            }

            // 添加事件配置
            newConfig.events = {};
            if (editFocusLostArea.text.trim() !== "") {
                newConfig.events.onFocusLost = editFocusLostArea.text.trim();
            }

            if (editChangeArea.text.trim() !== "") {
                switch (editDialog.editConfig.type) {
                case "text":
                case "password":
                    newConfig.events.onTextChanged = editChangeArea.text.trim();
                    break;
                case "number":
                    newConfig.events.onValueChanged = editChangeArea.text.trim();
                    break;
                case "button":
                    newConfig.events.onClicked = editChangeArea.text.trim();
                    break;
                case "dropdown":
                    newConfig.events.onValueChanged = editChangeArea.text.trim();
                    break;
                }
            }

            currentConfig.controls[editDialog.editIndex] = newConfig;

            // 使用延迟刷新确保界面正确更新
            refreshTimer.restart();
        }
    }

    // 移除控件
    function removeControl(index) {
        if (currentConfig.controls && index >= 0 && index < currentConfig.controls.length) {
            currentConfig.controls.splice(index, 1);

            // 强制刷新界面以移除已删除的控件
            forceRefresh();

            // 更新Repeater的model
            controlsRepeater.model = currentConfig.controls;
        }
    }

    // 应用配置
    function applyConfig() {
        configChanged(currentConfig);
    }

    // 导出JSON配置
    function exportJson() {
        var jsonString = JSON.stringify(currentConfig, null, 2);
    // 可以在这里添加导出到文件的逻辑
    }

    // 重置配置
    function resetConfig() {
        currentConfig = {
            "grid": {
                "rows": 8,
                "columns": 2,
                "rowSpacing": 5,
                "columnSpacing": 10,
                "rowHeights": [1, 1, 1, 1, 1, 1, 1, 2],
                "columnWidths": [1, 2]
            },
            "controls": []
        };

        // 重置UI控件到默认值
        rowsSpinBox.value = 8;
        columnsSpinBox.value = 2;
        rowSpacingSpinBox.value = 5;
        columnSpacingSpinBox.value = 10;

        // 清空Repeater
        controlsRepeater.model = [];
    }

    // ==================== 位置查找和操作函数 ====================

    /**
     * 获取指定网格位置的控件
     * 支持跨行跨列控件的位置检测
     *
     * @param {number} row 网格行位置
     * @param {number} col 网格列位置
     * @returns {Object|null} 控件配置对象或null
     */
    function getControlAtPosition(row, col) {
        if (!currentConfig.controls)
            return null;

        for (var i = 0; i < currentConfig.controls.length; i++) {
            var ctrl = currentConfig.controls[i];
            var ctrlRow = ctrl.row || 0;
            var ctrlCol = ctrl.column || 0;
            var ctrlRowSpan = ctrl.rowSpan || 1;
            var ctrlColSpan = ctrl.colSpan || 1;

            // 检查点击位置是否在控件的占用范围内
            if (row >= ctrlRow && row < ctrlRow + ctrlRowSpan && col >= ctrlCol && col < ctrlCol + ctrlColSpan) {
                return ctrl;
            }
        }
        return null;
    }

    /**
     * 根据网格位置编辑控件
     * 查找指定位置的控件并打开编辑对话框
     *
     * @param {number} row 网格行位置
     * @param {number} col 网格列位置
     */
    function editControlAtPosition(row, col) {
        if (!currentConfig.controls)
            return;
        for (var i = 0; i < currentConfig.controls.length; i++) {
            var ctrl = currentConfig.controls[i];
            var ctrlRow = ctrl.row || 0;
            var ctrlCol = ctrl.column || 0;
            var ctrlRowSpan = ctrl.rowSpan || 1;
            var ctrlColSpan = ctrl.colSpan || 1;

            if (row >= ctrlRow && row < ctrlRow + ctrlRowSpan && col >= ctrlCol && col < ctrlCol + ctrlColSpan) {
                editControl(i);
                return;
            }
        }
    }

    /**
     * 根据网格位置删除控件
     * 查找指定位置的控件并从配置中移除
     *
     * @param {number} row 网格行位置
     * @param {number} col 网格列位置
     */
    function removeControlAtPosition(row, col) {
        if (!currentConfig.controls)
            return;
        for (var i = 0; i < currentConfig.controls.length; i++) {
            var ctrl = currentConfig.controls[i];
            var ctrlRow = ctrl.row || 0;
            var ctrlCol = ctrl.column || 0;
            var ctrlRowSpan = ctrl.rowSpan || 1;
            var ctrlColSpan = ctrl.colSpan || 1;

            if (row >= ctrlRow && row < ctrlRow + ctrlRowSpan && col >= ctrlCol && col < ctrlCol + ctrlColSpan) {
                removeControl(i);
                return;
            }
        }
    }

    // ==================== 控件编辑和管理函数 ====================

    /**
     * 编辑指定索引的控件
     * 打开编辑对话框并加载控件配置
     *
     * @param {number} index 控件在数组中的索引
     */
    function editControl(index) {
        if (currentConfig.controls && index >= 0 && index < currentConfig.controls.length) {
            editDialog.editIndex = index;
            editDialog.editConfig = currentConfig.controls[index];
            editDialog.open();
        }
    }

    // ==================== 控件样式和显示函数 ====================

    /**
     * 获取控件类型的默认标签文本
     * @param {string} type 控件类型
     * @returns {string} 默认标签文本
     */
    function getDefaultLabel(type) {
        switch (type) {
        case "text":
            return "文本输入";
        case "number":
            return "数字输入";
        case "password":
            return "密码输入";
        case "dropdown":
            return "下拉选择";
        case "checkbox":
            return "复选框";
        case "radio":
            return "单选框";
        case "button":
            return "";
        default:
            return "控件";
        }
    }

    /**
     * 获取控件类型对应的图标
     * @param {string} type 控件类型
     * @returns {string} Unicode图标字符
     */
    function getControlIcon(type) {
        switch (type) {
        case "text":
            return "📝";
        case "number":
            return "🔢";
        case "password":
            return "🔒";
        case "dropdown":
            return "📋";
        case "checkbox":
            return "☑️";
        case "radio":
            return "🔘";
        case "button":
            return "🎯";
        default:
            return "❓";
        }
    }

    /**
     * 获取控件类型对应的背景色
     * 用于网格中控件的视觉区分
     * @param {string} type 控件类型
     * @returns {string} 十六进制颜色值
     */
    function getControlColor(type) {
        switch (type) {
        case "text":
            return "#e3f2fd";      // 浅蓝色
        case "number":
            return "#e8f5e8";    // 浅绿色
        case "password":
            return "#f3e5f5";  // 浅紫色
        case "dropdown":
            return "#fff3e0";  // 浅橙色
        case "checkbox":
            return "#ffebee";  // 浅红色
        case "radio":
            return "#f5f5f5";     // 浅灰色
        case "button":
            return "#ffebee";    // 浅红色
        default:
            return "#ffffff";          // 白色
        }
    }

    /**
     * 获取控件类型对应的边框色
     * 用于网格中控件的边框显示
     * @param {string} type 控件类型
     * @returns {string} 十六进制颜色值
     */
    function getControlBorderColor(type) {
        switch (type) {
        case "text":
            return "#2196f3";      // 蓝色
        case "number":
            return "#4caf50";    // 绿色
        case "password":
            return "#9c27b0";  // 紫色
        case "dropdown":
            return "#ff9800";  // 橙色
        case "checkbox":
            return "#f44336";  // 红色
        case "radio":
            return "#9e9e9e";     // 灰色
        case "button":
            return "#f44336";    // 红色
        default:
            return "#dee2e6";          // 浅灰色
        }
    }

    // ==================== 事件处理相关函数 ====================

    /**
     * 判断控件类型是否支持变化事件
     * @param {string} type 控件类型
     * @returns {boolean} 是否支持变化事件
     */
    function hasChangeEvent(type) {
        return type === "text" || type === "number" || type === "password" || type === "button" || type === "dropdown";
    }

    /**
     * 获取控件类型对应的事件标签文本
     * 用于编辑对话框中的事件配置区域
     * @param {string} type 控件类型
     * @returns {string} 事件标签文本
     */
    function getChangeEventLabel(type) {
        switch (type) {
        case "text":
        case "password":
            return "文本变化事件:";
        case "number":
            return "数值变化事件:";
        case "button":
            return "点击事件:";
        case "dropdown":
            return "选择变化事件:";
        default:
            return "变化事件:";
        }
    }

    // ==================== 选项数据处理函数 ====================

    /**
     * 格式化选项数据用于编辑
     * 将选项数组转换为可编辑的文本格式 (label|value)
     *
     * @param {Array} options 选项数组
     * @returns {string} 格式化后的文本
     */
    function formatOptionsForEdit(options) {
        if (!options || !Array.isArray(options))
            return "";

        return options.map(function (option) {
            if (typeof option === "string") {
                // 字符串类型选项，label和value相同
                return option + "|" + option;
            } else if (option && typeof option === "object") {
                // 对象类型选项，提取label和value
                return (option.label || "") + "|" + (option.value || "");
            }
            return "";
        }).join("\\n");
    }

    /**
     * 解析编辑后的选项文本
     * 将文本格式转换回选项数组
     *
     * @param {string} text 编辑后的文本
     * @returns {Array} 选项数组
     */
    function parseOptionsFromEdit(text) {
        if (!text || text.trim() === "")
            return [];

        // 按行分割并过滤空行
        var lines = text.split("\\n").filter(function (line) {
            return line.trim() !== "";
        });

        // 解析每行为选项对象
        return lines.map(function (line) {
            var parts = line.split("|");
            if (parts.length >= 2) {
                // 包含分隔符，分别设置label和value
                return {
                    "label": parts[0].trim(),
                    "value": parts[1].trim()
                };
            } else {
                // 不包含分隔符，label和value相同
                var value = parts[0].trim();
                return {
                    "label": value,
                    "value": value
                };
            }
        });
    }

    // 焦点丢失事件帮助对话框
    Dialog {
        id: focusLostHelpDialog
        title: "焦点丢失事件 - 可用函数"
        width: 700
        height: 600
        anchors.centerIn: parent
        modal: true

        property var targetTextArea: null

        ScrollView {
            anchors.fill: parent

            Column {
                width: parent.width
                spacing: 20
                padding: 20

                // 事件说明
                Rectangle {
                    width: parent.width - 40
                    height: descColumn.height + 20
                    color: "#e3f2fd"
                    border.color: "#2196f3"
                    border.width: 1
                    radius: 8

                    Column {
                        id: descColumn
                        anchors.centerIn: parent
                        spacing: 10
                        width: parent.width - 20

                        Text {
                            text: "📋 焦点丢失事件说明"
                            font.pixelSize: 14
                            font.bold: true
                            color: "#1976d2"
                        }

                        Text {
                            text: "当用户离开输入框时触发，适合进行数据验证和处理。"
                            font.pixelSize: 12
                            color: "#1565c0"
                            wrapMode: Text.WordWrap
                            width: parent.width
                        }

                        Text {
                            text: "💡 提示：可以使用 self 变量访问当前控件，使用各种API函数操作其他控件。"
                            font.pixelSize: 12
                            color: "#1565c0"
                            wrapMode: Text.WordWrap
                            width: parent.width
                        }
                    }
                }

                // API函数列表
                Rectangle {
                    width: parent.width - 40
                    height: apiColumn.height + 20
                    color: "#f8f9fa"
                    border.color: "#dee2e6"
                    border.width: 1
                    radius: 8

                    Column {
                        id: apiColumn
                        anchors.centerIn: parent
                        spacing: 10
                        width: parent.width - 20

                        Text {
                            text: "🔧 控件操作函数"
                            font.pixelSize: 14
                            font.bold: true
                        }

                        // 控件操作函数
                        FunctionButton {
                            functionCode: "getControlValue('controlKey')"
                            description: "获取控件值"
                            onClicked: insertFunction(functionCode)
                        }

                        FunctionButton {
                            functionCode: "setControlValue('controlKey', value)"
                            description: "设置控件值"
                            onClicked: insertFunction(functionCode)
                        }

                        FunctionButton {
                            functionCode: "enableControl('controlKey')"
                            description: "启用控件"
                            onClicked: insertFunction(functionCode)
                        }

                        FunctionButton {
                            functionCode: "disableControl('controlKey')"
                            description: "禁用控件"
                            onClicked: insertFunction(functionCode)
                        }

                        FunctionButton {
                            functionCode: "showControl('controlKey')"
                            description: "显示控件"
                            onClicked: insertFunction(functionCode)
                        }

                        FunctionButton {
                            functionCode: "hideControl('controlKey')"
                            description: "隐藏控件"
                            onClicked: insertFunction(functionCode)
                        }

                        FunctionButton {
                            functionCode: "setControlBackground('controlKey', '#ff0000')"
                            description: "设置背景色"
                            onClicked: insertFunction(functionCode)
                        }

                        FunctionButton {
                            functionCode: "setControlColor('controlKey', 'blue')"
                            description: "设置文字颜色"
                            onClicked: insertFunction(functionCode)
                        }

                        Text {
                            text: "💬 消息显示函数"
                            font.pixelSize: 14
                            font.bold: true
                        }

                        FunctionButton {
                            functionCode: "showMessage('消息内容', 'info')"
                            description: "显示信息消息"
                            onClicked: insertFunction(functionCode)
                        }

                        FunctionButton {
                            functionCode: "showMessage('错误信息', 'error')"
                            description: "显示错误消息"
                            onClicked: insertFunction(functionCode)
                        }

                        FunctionButton {
                            functionCode: "showMessage('警告信息', 'warning')"
                            description: "显示警告消息"
                            onClicked: insertFunction(functionCode)
                        }
                    }
                }

                // 验证函数
                Rectangle {
                    width: parent.width - 40
                    height: 200
                    color: "#fff3cd"
                    border.color: "#ffeaa7"
                    border.width: 1
                    radius: 8

                    Column {
                        anchors.centerIn: parent
                        spacing: 10
                        width: parent.width - 20

                        Text {
                            text: "✅ 数据验证函数"
                            font.pixelSize: 14
                            font.bold: true
                        }

                        FunctionButton {
                            functionCode: "validateEmail(email)"
                            description: "验证邮箱格式"
                            onClicked: insertFunction(functionCode)
                        }

                        FunctionButton {
                            functionCode: "validatePhone(phone)"
                            description: "验证手机号格式"
                            onClicked: insertFunction(functionCode)
                        }

                        FunctionButton {
                            functionCode: "validateNumber(text, min, max)"
                            description: "验证数字范围"
                            onClicked: insertFunction(functionCode)
                        }

                        FunctionButton {
                            functionCode: "validateChinese(text)"
                            description: "验证中文字符"
                            onClicked: insertFunction(functionCode)
                        }

                        FunctionButton {
                            functionCode: "validateRequired(value, message)"
                            description: "验证必填项"
                            onClicked: insertFunction(functionCode)
                        }
                    }
                }
            }
        }

        standardButtons: Dialog.Close

        function insertFunction(functionCode) {
            if (targetTextArea) {
                var currentText = targetTextArea.text;
                var cursorPosition = targetTextArea.cursorPosition;

                var newText = currentText.substring(0, cursorPosition) + functionCode + currentText.substring(cursorPosition);

                targetTextArea.text = newText;
                targetTextArea.cursorPosition = cursorPosition + functionCode.length;
            }

            close();
        }
    }

    // 变化事件帮助对话框
    Dialog {
        id: changeEventHelpDialog
        title: "变化事件 - 可用函数"
        width: 700
        height: 500
        anchors.centerIn: parent
        modal: true

        property var targetTextArea: null

        ScrollView {
            anchors.fill: parent

            Column {
                width: parent.width
                spacing: 20
                padding: 20

                // 事件说明
                Rectangle {
                    width: parent.width - 40
                    height: changeInfoColumn.height + 20
                    color: "#e3f2fd"
                    border.color: "#2196f3"
                    border.width: 1
                    radius: 8

                    Column {
                        id: changeInfoColumn
                        anchors.centerIn: parent
                        spacing: 10
                        width: parent.width - 20

                        Text {
                            text: "⚡ 变化事件说明"
                            font.pixelSize: 14
                            font.bold: true
                            color: "#1976d2"
                        }

                        Text {
                            text: "📝 文本框：文本内容改变时触发"
                            font.pixelSize: 12
                            color: "#1565c0"
                            wrapMode: Text.WordWrap
                            width: parent.width
                        }

                        Text {
                            text: "🔢 数字框：数值改变时触发"
                            font.pixelSize: 12
                            color: "#1565c0"
                            wrapMode: Text.WordWrap
                            width: parent.width
                        }

                        Text {
                            text: "📋 下拉框：选择改变时触发"
                            font.pixelSize: 12
                            color: "#1565c0"
                            wrapMode: Text.WordWrap
                            width: parent.width
                        }

                        Text {
                            text: ""
                            height: 10
                        }

                        Text {
                            text: "⚠️ 注意：变化事件触发频繁，避免在此执行耗时操作"
                            font.pixelSize: 12
                            color: "#d32f2f"
                            font.bold: true
                            wrapMode: Text.WordWrap
                            width: parent.width
                        }
                    }
                }

                // 常用函数
                Rectangle {
                    width: parent.width - 40
                    height: functionColumn.height + 20
                    color: "#f8f9fa"
                    border.color: "#dee2e6"
                    border.width: 1
                    radius: 8

                    Column {
                        id: functionColumn
                        anchors.centerIn: parent
                        spacing: 10
                        width: parent.width - 20

                        Text {
                            text: "🔧 常用函数"
                            font.pixelSize: 14
                            font.bold: true
                        }

                        FunctionButton {
                            functionCode: "setControlValue('otherControl', self.text)"
                            description: "将当前值设置给其他控件"
                            onClicked: insertFunction(functionCode)
                        }

                        FunctionButton {
                            functionCode: "if(self.text.length > 5) { enableControl('submitBtn') }"
                            description: "条件控制其他控件"
                            onClicked: insertFunction(functionCode)
                        }

                        FunctionButton {
                            functionCode: "showMessage('值已改变: ' + self.text, 'info')"
                            description: "显示变化消息"
                            onClicked: insertFunction(functionCode)
                        }
                    }
                }

                // 使用提示
                Rectangle {
                    width: parent.width - 40
                    height: 150
                    color: "#fff3cd"
                    border.color: "#ffeaa7"
                    border.width: 1
                    radius: 8

                    Column {
                        anchors.centerIn: parent
                        spacing: 10
                        width: parent.width - 20

                        Text {
                            text: "💡 使用提示"
                            font.pixelSize: 14
                            font.bold: true
                        }

                        Text {
                            text: "• 使用 self 变量访问当前控件的属性和方法"
                            font.pixelSize: 12
                            wrapMode: Text.WordWrap
                            width: parent.width
                        }

                        Text {
                            text: "• 控件key是唯一标识，用于API函数中引用其他控件"
                            font.pixelSize: 12
                            wrapMode: Text.WordWrap
                            width: parent.width
                        }

                        Text {
                            text: "• 可以组合多个函数调用，用分号分隔"
                            font.pixelSize: 12
                            wrapMode: Text.WordWrap
                            width: parent.width
                        }

                        Text {
                            text: "• 变化事件适合进行实时响应，但要避免复杂操作"
                            font.pixelSize: 12
                            wrapMode: Text.WordWrap
                            width: parent.width
                        }
                    }
                }
            }
        }

        standardButtons: Dialog.Close

        function insertFunction(functionCode) {
            if (targetTextArea) {
                var currentText = targetTextArea.text;
                var cursorPosition = targetTextArea.cursorPosition;

                var newText = currentText.substring(0, cursorPosition) + functionCode + currentText.substring(cursorPosition);

                targetTextArea.text = newText;
                targetTextArea.cursorPosition = cursorPosition + functionCode.length;
            }

            close();
        }
    }

    // 验证错误对话框
    Dialog {
        id: validationErrorDialog
        title: "位置验证错误"
        width: 400
        height: 200
        anchors.centerIn: parent
        modal: true

        property string errorMessage: ""

        Rectangle {
            anchors.fill: parent
            color: "#fff5f5"
            border.color: "#f5c6cb"
            border.width: 1
            radius: 8

            Column {
                anchors.centerIn: parent
                spacing: 15

                Text {
                    text: "❌ 验证失败"
                    font.pixelSize: 16
                    font.bold: true
                    color: "#721c24"
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Text {
                    text: validationErrorDialog.errorMessage
                    font.pixelSize: 14
                    color: "#721c24"
                    wrapMode: Text.WordWrap
                    width: 300
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }

        standardButtons: Dialog.Ok
    }
}
