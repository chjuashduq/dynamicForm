import QtQuick 6.5
import QtQuick.Controls 6.5
import QtQuick.Layouts 1.4

// 根组件，整个动态表单的容器
Item {
    id: root
    width: 600
    height: 400

    // 从外部 JSON 文本解析得到表单配置对象
    property var formConfig: JSON.parse(formJson)
    
    // ------------------------------
    // 延迟加载定时器，保证界面先渲染再创建控件，避免启动时卡顿
    // ------------------------------
    Timer {
        id: loadTimer
        interval: 50  // 延迟 50ms 触发
        onTriggered: grid.loadForm() // 定时到后加载表单内容
    }

    // ------------------------------
    // 调试边框，用于显示网格信息和边界辅助开发
    // ------------------------------
    Rectangle {
        anchors.fill: parent
        color: "transparent"          // 透明背景，不遮挡内容
        border.color: "#ff0000"       // 红色边框用于调试
        border.width: 2

        // 左下角显示当前网格的行列数
        Text {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.margins: 5
            text: "网格: " + grid.rows + "行 × " + grid.columns + "列"
            color: "#ff0000"
            font.bold: true
            font.pixelSize: 12
        }
    }

    // ------------------------------
    // 预编译的组件（Component），用于快速创建控件
    // 避免使用 Qt.createQmlObject 动态解析字符串，提高性能
    // ------------------------------
    Component { id: rowLayoutComponent; RowLayout { spacing: 5 } }
    Component { id: labelComponent; Label { elide: Text.ElideRight } }
    Component { id: textFieldComponent; TextField {} }
    Component { id: spinBoxComponent; SpinBox {} }
    Component { id: comboBoxComponent; ComboBox {} }

    // ------------------------------
    // 占位符组件（仅在空白网格单元中显示坐标，方便调试）
    // ------------------------------
    Component {
        id: placeholderComponent
        Rectangle {
            property int rowIndex: 0
            property int colIndex: 0
            color: "transparent"
            border.color: "#cccccc"
            border.width: 1

            // 在中心显示单元格坐标 (行,列)
            Text {
                anchors.centerIn: parent
                text: "(" + parent.rowIndex + "," + parent.colIndex + ")"
                color: "#999999"
                font.pixelSize: 10
            }
        }
    }

    // ------------------------------
    // 表单的网格布局容器
    // 动态生成各行各列的表单控件
    // ------------------------------
    GridLayout {
        id: grid
        anchors.fill: parent
        anchors.margins: 5

        // 从配置中读取网格参数（默认1行1列）
        rows: formConfig.grid ? formConfig.grid.rows : 1
        columns: formConfig.grid ? formConfig.grid.columns : 1
        rowSpacing: formConfig.grid && formConfig.grid.rowSpacing ? formConfig.grid.rowSpacing : 10
        columnSpacing: formConfig.grid && formConfig.grid.columnSpacing ? formConfig.grid.columnSpacing : 10

        // 初始化完成后启动延迟加载
        Component.onCompleted: loadTimer.start()

        // --------------------------
        // 加载表单配置主函数
        // --------------------------
        function loadForm() {
            if (!formConfig.controls) return;

            // 先创建一个完整的网格占位符，使空白行/列也能保持显示比例
            for (var r = 0; r < grid.rows; r++) {
                for (var c = 0; c < grid.columns; c++) {
                    var placeholder = placeholderComponent.createObject(grid, {
                        "rowIndex": r,
                        "colIndex": c
                    })
                    placeholder.Layout.row = r
                    placeholder.Layout.column = c
                    placeholder.Layout.fillWidth = true
                    placeholder.Layout.fillHeight = true
                    
                    // 设置列宽比例（根据配置的 columnWidths）
                    if (formConfig.grid && formConfig.grid.columnWidths && c < formConfig.grid.columnWidths.length) {
                        placeholder.Layout.preferredWidth = formConfig.grid.columnWidths[c] * 200
                    }
                    
                    // 设置行高比例（根据 rowHeights）
                    if (formConfig.grid && formConfig.grid.rowHeights && r < formConfig.grid.rowHeights.length) {
                        var minHeight = 25, maxHeight = 60
                        var ratio = formConfig.grid.rowHeights[r]
                        placeholder.Layout.minimumHeight = minHeight * ratio
                        placeholder.Layout.preferredHeight = 40 * ratio
                        placeholder.Layout.maximumHeight = maxHeight * ratio
                    }
                }
            }

            // 批量创建控件（减少多次布局刷新）
            var controls = formConfig.controls
            for (var i = 0; i < controls.length; i++) {
                createControl(controls[i])
            }
        }

        // --------------------------
        // 创建单个控件
        // --------------------------
        function createControl(config) {
            // 创建行布局容器 (Label + Input)
            var container = rowLayoutComponent.createObject(grid)
            container.Layout.row = config.row
            container.Layout.column = config.column
            container.Layout.rowSpan = config.rowSpan
            container.Layout.columnSpan = config.colSpan
            container.Layout.fillWidth = true
            container.Layout.fillHeight = true
            container.spacing = 5
            
            // 统一行高控制（根据行比例调整）
            if (formConfig.grid && formConfig.grid.rowHeights && config.row < formConfig.grid.rowHeights.length) {
                var minHeight = 25
                var preferredHeight = 40
                var maxHeight = 60
                var rowHeightRatio = formConfig.grid.rowHeights[config.row]
                container.Layout.minimumHeight = minHeight * rowHeightRatio
                container.Layout.preferredHeight = preferredHeight * rowHeightRatio
                container.Layout.maximumHeight = maxHeight * rowHeightRatio
            }

            // 创建 Label
            var label = labelComponent.createObject(container)
            label.text = config.label
            label.Layout.fillWidth = true
            label.Layout.preferredWidth = config.labelRatio * 1000  // 宽度比例放大控制
            if (config.style) {
                if (config.style.labelColor) label.color = config.style.labelColor
                if (config.style.labelBold) label.font.bold = config.style.labelBold
            }

            // ----------------------
            // 创建输入控件 Input
            // ----------------------
            var input
            switch(config.type) {
                case "text":
                    input = textFieldComponent.createObject(container)
                    input.placeholderText = config.placeholder
                    input.text = config.value
                    break
                case "number":
                    input = spinBoxComponent.createObject(container)
                    input.value = config.value
                    break
                case "dropdown":
                    input = comboBoxComponent.createObject(container)
                    input.model = config.options
                    input.currentIndex = config.options.indexOf(config.value)
                    break
                case "checkbox":
                    // 支持横向或纵向布局的复选框组
                    var layoutType = (config.direction === "horizontal") ? "RowLayout" : "ColumnLayout"
                    input = Qt.createQmlObject(
                        'import QtQuick.Controls 6.5; import QtQuick.Layouts 1.4; ' + layoutType + ' { spacing: 10; }',
                        container
                    )
                    for (var j = 0; j < config.options.length; j++) {
                        var cb = Qt.createQmlObject(
                            'import QtQuick.Controls 6.5; CheckBox {}',
                            input
                        )
                        cb.text = config.options[j]
                        cb.checked = config.value.indexOf(config.options[j]) >= 0
                    }
                    break
                case "radio":
                    // 单选按钮组（默认纵向）
                    input = Qt.createQmlObject(
                        'import QtQuick.Controls 6.5; import QtQuick.Layouts 1.4; ColumnLayout {}',
                        container
                    )
                    var group = Qt.createQmlObject(
                        'import QtQuick.Controls 6.5; ButtonGroup {}',
                        container
                    )
                    for (var j = 0; j < config.options.length; j++) {
                        var rb = Qt.createQmlObject(
                            'import QtQuick.Controls 6.5; RadioButton {}',
                            input
                        )
                        rb.text = config.options[j]
                        rb.checked = config.value === config.options[j]
                        rb.group = group
                    }
                    break
            }

            // ----------------------
            // 样式与事件绑定
            // ----------------------
            if (input) {
                input.Layout.fillWidth = true
                input.Layout.preferredWidth = (1 - config.labelRatio) * 1000  // 占用剩余宽度
                
                // 支持基础样式配置
                if (config.style) {
                    if (config.style.inputColor) input.color = config.style.inputColor
                    if (config.style.inputFontSize) input.font.pointSize = config.style.inputFontSize
                    
                    // 背景矩形样式（例如圆角、背景色）
                    if (config.style.inputBackground) {
                        input.background = Qt.createQmlObject(
                            'import QtQuick 6.5; Rectangle {}',
                            input
                        )
                        input.background.color = config.style.inputBackground
                        input.background.radius = config.style.inputRadius || 0
                    }

                    // 外边距
                    if (config.style.margin) container.anchors.margins = config.style.margin
                }

                // 事件绑定（调试或业务扩展接口）
                input.focusChanged.connect(function() { console.log(config.label + " focus changed"); })
                if (input.hasOwnProperty("textChanged"))
                    input.textChanged.connect(function() { console.log(config.label + " value changed"); })
                if (input.hasOwnProperty("valueChanged"))
                    input.valueChanged.connect(function() { console.log(config.label + " value changed"); })
            }
        }
    }
}
