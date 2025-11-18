import QtQuick 6.5                                    // 导入Qt Quick 6.5核心模块
import QtQuick.Controls 6.5                            // 导入Qt Quick Controls 6.5控件模块
import QtQuick.Layouts 1.4                             // 导入Qt Quick Layouts 1.4布局模块
import Common 1.0                                       // 导入全局样式和消息管理器
import "../core"                                        // 导入核心功能模块（FormAPI、ScriptEngine等）
import "../components"                                  // 导入美化组件

/**
 * 控件工厂
 * 
 * 主要功能：
 * - 根据JSON配置动态创建各种类型的表单控件
 * - 支持文本框、数字框、下拉框、复选框、单选框、按钮等控件类型
 * - 处理控件的布局、样式和事件绑定
 * - 支持label/value格式的选项配置
 * - 管理控件在网格中的位置和尺寸
 * 
 * 设计模式：
 * - 工厂模式：根据类型创建不同的控件
 * - 组件预编译：提高控件创建性能
 * - 职责分离：将创建、样式、事件分别处理
 */
QtObject {                                              // 控件工厂对象
    id: controlFactory                                  // 工厂唯一标识符
    
    // ===== 预编译组件定义 =====
    // 预编译组件可以提高运行时创建控件的性能，避免重复解析QML
    property Component rowLayoutComponent: Component {  // 行布局组件模板
        RowLayout { 
            spacing: AppStyles.spacingSmall            // 使用全局样式的间距
        }
    }
    property Component labelComponent: Component {      // 标签组件模板
        StyledLabel {}                                  // 使用美化的标签组件
    }
    property Component textFieldComponent: Component {  // 文本输入框组件模板
        StyledTextField {}                              // 使用美化的文本输入框
    }
    property Component spinBoxComponent: Component {    // 数字输入框组件模板
        StyledSpinBox {}                                // 使用美化的数字输入框
    }
    property Component comboBoxComponent: Component {   // 下拉框组件模板
        StyledComboBox {                                // 使用美化的下拉框
            property var optionValues: []               // 存储选项值的数组
            function getValue() {                       // 获取当前选中值的函数
                return optionValues && currentIndex >= 0 && currentIndex < optionValues.length ? 
                       optionValues[currentIndex] : currentText // 返回对应的值或显示文本
            }
        } 
    }
    property Component buttonComponent: Component {     // 按钮组件模板
        StyledButton {                                  // 使用美化的按钮
            buttonType: "primary"                       // 默认为主要按钮
        }
    }
    
    // ===== 外部依赖属性 =====
    property var parentGrid: null                       // 父网格容器引用，控件将被添加到此容器中
    property var controlsMap: ({})                      // 控件映射表，用于通过key访问控件实例
    property var labelsMap: ({})                        // 标签映射表，用于通过key访问标签实例（用于验证失败时标红）
    property var scriptEngine: null                     // 脚本引擎引用，用于执行用户自定义的JavaScript代码
    property var formConfig: null                       // 表单配置对象，包含网格布局等信息
    property var formAPI: null                          // FormAPI引用，用于访问表单操作API
    
    /**
     * 创建单个表单控件的主函数
     * 
     * 处理流程：
     * 1. 创建行布局容器（包含标签和输入控件）
     * 2. 设置控件在网格中的位置和跨度
     * 3. 应用行高和列宽设置
     * 4. 创建标签和输入控件
     * 5. 注册控件到映射表
     * 6. 应用样式和绑定事件
     * 
     * @param config 控件配置对象，包含类型、位置、样式、事件等信息
     */
    function createControl(config) {                    // 创建控件的主函数
        if (!parentGrid) {                              // 检查父网格容器是否存在
            return                                      // 如果没有父容器，直接返回
        }
        
        // ===== 第一步：创建行布局容器 =====
        // 每个控件都包含在一个水平布局中，通常包含标签和输入控件
        var container = rowLayoutComponent.createObject(parentGrid) // 创建行布局容器实例
        container.Layout.row = config.row               // 设置控件在网格中的行位置
        container.Layout.column = config.column         // 设置控件在网格中的列位置
        container.Layout.rowSpan = config.rowSpan       // 设置控件跨越的行数
        container.Layout.columnSpan = config.colSpan    // 设置控件跨越的列数
        container.Layout.fillWidth = true               // 水平方向填充可用空间
        container.Layout.fillHeight = true              // 垂直方向填充可用空间
        container.spacing = 5                           // 设置标签和输入控件之间的间距
        
        // ===== 第二步：设置尺寸约束 =====
        _setRowHeight(container, config)                // 根据网格配置设置行高
        _setColumnWidth(container, config)              // 根据网格配置设置列宽
        
        // ===== 第三步：创建子组件 =====
        var label = _createLabel(container, config)     // 创建标签组件
        var input = _createInput(container, config)     // 创建输入控件组件
        
        if (input) {                                    // 如果输入控件创建成功
            // ===== 第四步：注册控件 =====
            var controlKey = config.key || config.label // 使用key或label作为控件的唯一标识
            controlsMap[controlKey] = input             // 将控件注册到映射表中，供API访问
            
            // 注册标签（用于验证失败时标红）
            if (label) {
                labelsMap[controlKey] = label
            }
            
            // ===== 第五步：注册控件配置（包含验证信息）=====
            if (formAPI) {
                formAPI.registerControlConfig(controlKey, config)
            }
            
            // ===== 第六步：应用配置 =====
            _applyStyles(input, config)                 // 应用样式配置（颜色、字体等）
            _bindEvents(input, config)                  // 绑定事件处理函数
        }
    }
    
    /**
     * 设置控件容器的行高约束
     * 
     * 根据网格配置中的行高比例设置容器的最小、首选和最大高度
     * 这样可以实现不同行具有不同的高度比例
     * 
     * @param container 要设置高度的容器
     * @param config 控件配置对象，包含行位置信息
     */
    function _setRowHeight(container, config) {         // 设置行高的私有函数
        // 检查表单配置、网格配置、行高数组是否存在，且当前行索引有效
        if (formConfig.grid && formConfig.grid.rowHeights && config.row < formConfig.grid.rowHeights.length) {
            var minHeight = 25                          // 基础最小高度25像素
            var preferredHeight = 40                    // 基础首选高度40像素
            var maxHeight = 60                          // 基础最大高度60像素
            var rowHeightRatio = formConfig.grid.rowHeights[config.row] // 获取当前行的高度比例
            container.Layout.minimumHeight = minHeight * rowHeightRatio     // 设置最小高度 = 基础高度 × 比例
            container.Layout.preferredHeight = preferredHeight * rowHeightRatio // 设置首选高度 = 基础高度 × 比例
            container.Layout.maximumHeight = maxHeight * rowHeightRatio     // 设置最大高度 = 基础高度 × 比例
        }
    }
    
    /**
     * 设置控件容器的列宽约束
     * 
     * 根据网格配置中的列宽比例设置容器的首选宽度
     * 这样可以实现不同列具有不同的宽度比例
     * 
     * @param container 要设置宽度的容器
     * @param config 控件配置对象，包含列位置信息
     */
    function _setColumnWidth(container, config) {       // 设置列宽的私有函数
        // 检查表单配置、网格配置、列宽数组是否存在，且当前列索引有效
        if (formConfig.grid && formConfig.grid.columnWidths && config.column < formConfig.grid.columnWidths.length) {
            var baseWidth = 200                         // 基础宽度200像素
            var columnWidthRatio = formConfig.grid.columnWidths[config.column] // 获取当前列的宽度比例
            container.Layout.preferredWidth = baseWidth * columnWidthRatio // 设置首选宽度 = 基础宽度 × 比例
        }
    }
    
    /**
     * 创建标签组件
     * 
     * 为控件创建描述性标签，显示控件的名称或说明文字
     * 支持标签宽度比例设置和样式自定义
     * 注意：按钮类型不创建标签
     * 
     * @param container 标签的父容器
     * @param config 控件配置对象，包含标签文本和样式信息
     * @return 返回创建的标签组件实例，按钮类型返回null
     */
    function _createLabel(container, config) {          // 创建标签的私有函数
        // 按钮类型不创建标签
        if (config.type === "button") {
            return null
        }
        
        var label = labelComponent.createObject(container) // 从预编译组件创建标签实例
        label.text = config.label                       // 设置标签显示文本
        label.Layout.fillWidth = true                  // 标签水平填充可用空间
        label.Layout.preferredWidth = config.labelRatio * 1000 // 设置标签首选宽度，基于标签比例
        
        // 应用标签样式配置
        if (config.style) {                            // 如果配置中包含样式设置
            if (config.style.labelColor) label.color = config.style.labelColor // 设置标签文字颜色
            if (config.style.labelBold) label.font.bold = config.style.labelBold // 设置标签文字粗细
        }
        
        return label                                    // 返回创建的标签实例
    }
    
    /**
     * 创建输入控件组件
     * 
     * 根据控件类型创建相应的输入控件，支持多种控件类型：
     * - text: 文本输入框
     * - number: 数字输入框
     * - password: 密码输入框
     * - dropdown: 下拉选择框
     * - checkbox: 复选框组
     * - radio: 单选框组
     * - button: 按钮
     * 
     * @param container 输入控件的父容器
     * @param config 控件配置对象，包含类型、默认值等信息
     * @return 返回创建的输入控件实例，如果类型不支持则返回null
     */
    function _createInput(container, config) {          // 创建输入控件的私有函数
        var input = null                                // 初始化输入控件变量
        
        // 根据控件类型创建相应的输入控件
        switch(config.type) {                           // 根据配置中的控件类型进行分支处理
            case "text":                                // 文本输入框类型
                input = textFieldComponent.createObject(container) // 创建文本输入框实例
                input.placeholderText = config.placeholder || "" // 设置占位符文本
                input.text = config.value || ""        // 设置初始文本值
                break
            case "number":                              // 数字输入框类型
                input = spinBoxComponent.createObject(container) // 创建数字输入框实例
                input.value = config.value || 0        // 设置初始数值
                break
            case "dropdown":                            // 下拉选择框类型
                input = comboBoxComponent.createObject(container) // 创建下拉框实例
                _setupDropdownOptions(input, config)   // 设置下拉框选项
                break
            case "checkbox":                            // 复选框组类型
                input = _createCheckboxGroup(container, config) // 创建复选框组
                break
            case "radio":                               // 单选框组类型
                input = _createRadioGroup(container, config) // 创建单选框组
                break
            case "button":                              // 按钮类型
                input = buttonComponent.createObject(container) // 创建按钮实例
                input.text = config.text || config.label // 设置按钮文本
                break
            case "password":                            // 密码输入框类型
                input = textFieldComponent.createObject(container) // 创建文本输入框实例
                input.placeholderText = config.placeholder
                input.text = config.value
                input.echoMode = TextInput.Password
                break

        }
        
        if (input) {
            input.Layout.fillWidth = true
            input.Layout.preferredWidth = (1 - config.labelRatio) * 1000
        }
        
        return input
    }
    
    /**
     * 设置下拉框选项（支持label/value格式）
     */
    function _setupDropdownOptions(comboBox, config) {
        if (!config.options || !Array.isArray(config.options)) return
        
        var labels = []
        var values = []
        
        for (var i = 0; i < config.options.length; i++) {
            var option = config.options[i]
            if (typeof option === "string") {
                labels.push(option)
                values.push(option)
            } else if (option && option.label && option.value) {
                labels.push(option.label)
                values.push(option.value)
            }
        }
        
        comboBox.model = labels
        comboBox.optionValues = values
        
        // 设置当前选中项
        if (config.value) {
            var valueIndex = values.indexOf(config.value)
            if (valueIndex >= 0) {
                comboBox.currentIndex = valueIndex
            }
        }
    }
    
    /**
     * 创建复选框组
     */
    function _createCheckboxGroup(container, config) {
        var layoutType = (config.direction === "horizontal") ? "RowLayout" : "ColumnLayout"
        var input = Qt.createQmlObject(
            'import QtQuick.Controls 6.5; import QtQuick.Layouts 1.4; ' + layoutType + ' { ' +
            'spacing: 10; ' +
            'property var checkboxList: []; ' +
            'property var valuesList: []; ' +
            'function getValue() { ' +
                'var selectedValues = []; ' +
                'for (var i = 0; i < checkboxList.length; i++) { ' +
                    'if (checkboxList[i].checked) { ' +
                        'selectedValues.push(checkboxList[i].optionValue); ' +
                    '} ' +
                '} ' +
                'return selectedValues; ' +
            '} ' +
            '}',
            container
        )
        
        if (!config.options || !Array.isArray(config.options)) return input
        
        var checkboxes = []
        var values = []
        
        for (var j = 0; j < config.options.length; j++) {
            var option = config.options[j]
            var label, value
            
            if (typeof option === "string") {
                label = value = option
            } else if (option && option.label && option.value) {
                label = option.label
                value = option.value
            } else {
                continue
            }
            
            var cb = Qt.createQmlObject(
                'import QtQuick.Controls 6.5; CheckBox { property var optionValue }',
                input
            )
            cb.text = label
            cb.optionValue = value
            cb.checked = config.value && Array.isArray(config.value) && config.value.indexOf(value) >= 0
            
            checkboxes.push(cb)
            values.push(value)
        }
        
        // 设置属性
        input.checkboxList = checkboxes
        input.valuesList = values
        
        return input
    }
    
    /**
     * 创建单选按钮组
     */
    function _createRadioGroup(container, config) {
        var input = Qt.createQmlObject(
            'import QtQuick.Controls 6.5; import QtQuick.Layouts 1.4; ColumnLayout { ' +
            'property var radioList: []; ' +
            'property var valuesList: []; ' +
            'function getValue() { ' +
                'for (var i = 0; i < radioList.length; i++) { ' +
                    'if (radioList[i].checked) { ' +
                        'return radioList[i].optionValue; ' +
                    '} ' +
                '} ' +
                'return ""; ' +
            '} ' +
            '}',
            container
        )
        var group = Qt.createQmlObject(
            'import QtQuick.Controls 6.5; ButtonGroup {}',
            container
        )
        
        if (!config.options || !Array.isArray(config.options)) return input
        
        var radioButtons = []
        var values = []
        
        for (var j = 0; j < config.options.length; j++) {
            var option = config.options[j]
            var label, value
            
            if (typeof option === "string") {
                label = value = option
            } else if (option && option.label && option.value) {
                label = option.label
                value = option.value
            } else {
                continue
            }
            
            var rb = Qt.createQmlObject(
                'import QtQuick.Controls 6.5; RadioButton { property var optionValue }',
                input
            )
            rb.text = label
            rb.optionValue = value
            rb.checked = config.value === value
            rb.group = group
            
            radioButtons.push(rb)
            values.push(value)
        }
        
        // 设置属性
        input.radioList = radioButtons
        input.valuesList = values
        
        return input
    }
    
    /**
     * 应用样式
     */
    function _applyStyles(input, config) {
        if (config.style) {
            if (config.style.inputColor) input.color = config.style.inputColor
            if (config.style.inputFontSize) input.font.pointSize = config.style.inputFontSize
            
            // 注意：背景样式在某些Qt样式下不支持自定义，暂时注释掉避免警告
            // if (config.style.inputBackground) {
            //     input.background = Qt.createQmlObject(
            //         'import QtQuick 6.5; Rectangle {}',
            //         input
            //     )
            //     input.background.color = config.style.inputBackground
            //     input.background.radius = config.style.inputRadius || 0
            // }
        }
    }
    
    /**
     * 绑定事件
     */
    function _bindEvents(input, config) {
        if (!scriptEngine) {
            return
        }
        
        var controlKey = config.key || config.label;
        
        // ===== 焦点丢失事件 - 自动验证 + 用户自定义事件 =====
        // 对于 TextField (text, password 类型)
        if (config.type === "text" || config.type === "password") {
            if (input.hasOwnProperty("focusChanged")) {
                input.focusChanged.connect(function() {
                    if (!input.focus) {
                        var validationPassed = true;
                        
                        // 1. 先执行自动验证
                        if (formAPI && config.validationFunction) {
                            var result = formAPI.validateControl(controlKey, false);
                            validationPassed = result.valid;
                            
                            // 根据验证结果标红或恢复标签颜色
                            var label = labelsMap[controlKey];
                            if (label) {
                                if (!result.valid) {
                                    label.color = "#ff0000";  // 验证失败：标红
                                } else {
                                    // 验证成功：恢复原始颜色
                                    label.color = config.style && config.style.labelColor ? config.style.labelColor : "#000000";
                                }
                            }
                        }
                        
                        // 2. 只有验证通过时才执行用户自定义的焦点丢失事件
                        if (validationPassed && config.events && config.events.onFocusLost) {
                            scriptEngine.executeFunction(config.events.onFocusLost, {
                                self: input
                            })
                        }
                    }
                })
            }
        }
        
        // 对于 SpinBox (number 类型)
        if (config.type === "number") {
            // 使用activeFocusChanged（更可靠）
            if (input.hasOwnProperty("activeFocusChanged")) {
                input.activeFocusChanged.connect(function() {
                    if (!input.activeFocus) {
                        var validationPassed = true;
                        
                        // 自动验证
                        if (formAPI && config.validationFunction) {
                            var result = formAPI.validateControl(controlKey, false);
                            validationPassed = result.valid;
                            
                            // 根据验证结果标红或恢复标签颜色
                            var label = labelsMap[controlKey];
                            if (label) {
                                if (!result.valid) {
                                    label.color = "#ff0000";  // 验证失败：标红
                                } else {
                                    // 验证成功：恢复原始颜色
                                    label.color = config.style && config.style.labelColor ? config.style.labelColor : "#000000";
                                }
                            }
                        }
                        
                        // 只有验证通过时才执行用户自定义事件
                        if (validationPassed && config.events && config.events.onFocusLost) {
                            scriptEngine.executeFunction(config.events.onFocusLost, {
                                self: input
                            })
                        }
                    }
                })
            }
        }
        
        // ===== 其他事件（需要 config.events 存在）=====
        if (!config.events) {
            return
        }
        
        // 文本变化事件
        if (input.hasOwnProperty("textChanged") && config.events && config.events.onTextChanged) {
            input.textChanged.connect(function() {
                scriptEngine.executeFunction(config.events.onTextChanged, {
                    self: input
                })
            })
        }
        
        // 数值变化事件
        if (input.hasOwnProperty("valueChanged") && config.events && config.events.onValueChanged) {
            input.valueChanged.connect(function() {
                scriptEngine.executeFunction(config.events.onValueChanged, {
                    self: input
                })
            })
        }
        
        // 下拉框选择变化事件
        if (input.hasOwnProperty("currentIndexChanged") && config.events && config.events.onValueChanged) {
            input.currentIndexChanged.connect(function() {
                var actualValue = input.getValue ? input.getValue() : input.currentText
                scriptEngine.executeFunction(config.events.onValueChanged, {
                    self: input
                })
            })
        }
        
        // 按钮点击事件
        if (input.hasOwnProperty("clicked") && config.events && config.events.onClicked) {
            input.clicked.connect(function() {
                scriptEngine.executeFunction(config.events.onClicked, {
                    self: input
                })
            })
        }
        

    }
    

}