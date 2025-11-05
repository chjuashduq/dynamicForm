import QtQuick 6.5
import QtQuick.Controls 6.5
import QtQuick.Layouts 1.4
import "../core"

/**
 * 控件工厂
 * 负责创建各种类型的表单控件，支持label/value格式的options
 */
QtObject {
    id: controlFactory
    
    // 预编译的组件，提高性能
    property Component rowLayoutComponent: Component { RowLayout { spacing: 5 } }
    property Component labelComponent: Component { Label { elide: Text.ElideRight } }
    property Component textFieldComponent: Component { TextField {} }
    property Component spinBoxComponent: Component { SpinBox {} }
    property Component comboBoxComponent: Component { 
        ComboBox { 
            property var optionValues: []
            function getValue() {
                return optionValues && currentIndex >= 0 && currentIndex < optionValues.length ? 
                       optionValues[currentIndex] : currentText
            }
        } 
    }
    property Component buttonComponent: Component { Button {} }
    
    // 外部依赖
    property var parentGrid: null
    property var controlsMap: ({})
    property var scriptEngine: null
    property var formConfig: null
    
    /**
     * 创建单个控件
     * @param config - 控件配置对象
     */
    function createControl(config) {
        if (!parentGrid) {
            return
        }
        
        // 创建行布局容器 (Label + Input)
        var container = rowLayoutComponent.createObject(parentGrid)
        container.Layout.row = config.row
        container.Layout.column = config.column
        container.Layout.rowSpan = config.rowSpan
        container.Layout.columnSpan = config.colSpan
        container.Layout.fillWidth = true
        container.Layout.fillHeight = true
        container.spacing = 5
        
        // 设置行高
        _setRowHeight(container, config)
        
        // 设置列宽
        _setColumnWidth(container, config)
        
        // 创建Label
        var label = _createLabel(container, config)
        
        // 创建输入控件
        var input = _createInput(container, config)
        
        if (input) {
            // 注册控件
            var controlKey = config.key || config.label
            controlsMap[controlKey] = input
            
            // 设置样式
            _applyStyles(input, config)
            
            // 绑定事件
            _bindEvents(input, config)
        }
    }
    
    /**
     * 设置容器行高
     */
    function _setRowHeight(container, config) {
        if (formConfig.grid && formConfig.grid.rowHeights && config.row < formConfig.grid.rowHeights.length) {
            var minHeight = 25
            var preferredHeight = 40
            var maxHeight = 60
            var rowHeightRatio = formConfig.grid.rowHeights[config.row]
            container.Layout.minimumHeight = minHeight * rowHeightRatio
            container.Layout.preferredHeight = preferredHeight * rowHeightRatio
            container.Layout.maximumHeight = maxHeight * rowHeightRatio
        }
    }
    
    /**
     * 设置容器列宽
     */
    function _setColumnWidth(container, config) {
        if (formConfig.grid && formConfig.grid.columnWidths && config.column < formConfig.grid.columnWidths.length) {
            var baseWidth = 200
            var columnWidthRatio = formConfig.grid.columnWidths[config.column]
            container.Layout.preferredWidth = baseWidth * columnWidthRatio
        }
    }
    
    /**
     * 创建标签
     */
    function _createLabel(container, config) {
        var label = labelComponent.createObject(container)
        label.text = config.label
        label.Layout.fillWidth = true
        label.Layout.preferredWidth = config.labelRatio * 1000
        
        if (config.style) {
            if (config.style.labelColor) label.color = config.style.labelColor
            if (config.style.labelBold) label.font.bold = config.style.labelBold
        }
        
        return label
    }
    
    /**
     * 创建输入控件
     */
    function _createInput(container, config) {
        var input = null
        
        switch(config.type) {
            case "text":
                input = textFieldComponent.createObject(container)
                input.placeholderText = config.placeholder || ""
                input.text = config.value || ""
                break
            case "number":
                input = spinBoxComponent.createObject(container)
                input.value = config.value || 0
                break
            case "dropdown":
                input = comboBoxComponent.createObject(container)
                _setupDropdownOptions(input, config)
                break
            case "checkbox":
                input = _createCheckboxGroup(container, config)
                break
            case "radio":
                input = _createRadioGroup(container, config)
                break
            case "button":
                input = buttonComponent.createObject(container)
                input.text = config.text || config.label
                break
            case "password":
                input = textFieldComponent.createObject(container)
                input.placeholderText = config.placeholder
                input.text = config.value
                input.echoMode = TextInput.Password
                break
            case "date":
                input = textFieldComponent.createObject(container)
                input.text = config.value
                input.placeholderText = "YYYY-MM-DD"
                input.inputMask = "9999-99-99"
                break
            case "time":
                input = textFieldComponent.createObject(container)
                input.text = config.value
                input.placeholderText = "HH:MM"
                input.inputMask = "99:99"
                break
            case "textarea":
                input = _createTextArea(container, config)
                break
            case "slider":
                input = _createSlider(container, config)
                break
            case "switch":
                input = _createSwitch(container, config)
                break
            case "progress":
                input = _createProgressBar(container, config)
                break
            case "label":
                input = _createLabelControl(container, config)
                break
            case "separator":
                input = _createSeparator(container, config)
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
        
        if (!config.events) {
            return
        }
        
        // 焦点丢失事件
        if (config.events && config.events.onFocusLost) {
            
            // 检查控件是否支持focusChanged信号
            if (input.hasOwnProperty("focusChanged")) {
                input.focusChanged.connect(function() {
                    if (!input.focus) {
                        scriptEngine.executeFunction(config.events.onFocusLost, {
                            self: input
                        })
                    }
                })
            } else {
                
                // 对于SpinBox，尝试使用其他事件
                if (config.type === "number") {
                    // 使用Keys.onTabPressed和其他键盘事件
                    input.Keys.onTabPressed.connect(function() {
                        scriptEngine.executeFunction(config.events.onFocusLost, {
                            self: input
                        })
                    })
                    
                    // 使用鼠标点击其他地方的方式
                    input.onActiveFocusChanged.connect(function() {
                        if (!input.activeFocus) {
                            scriptEngine.executeFunction(config.events.onFocusLost, {
                                self: input
                            })
                        }
                    })
                }
            }
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
        
        // SpinBox特殊处理：编辑完成事件
        if (config.type === "number" && config.events && config.events.onFocusLost) {
            // 检查是否有editingFinished信号
            if (input.hasOwnProperty("editingFinished")) {
                input.editingFinished.connect(function() {
                    scriptEngine.executeFunction(config.events.onFocusLost, {
                        self: input
                    })
                })
            }
        }
    }
    
    /**
     * 创建文本域
     */
    function _createTextArea(container, config) {
        var input = Qt.createQmlObject(
            'import QtQuick.Controls 6.5; ScrollView { ' +
            'property alias text: textArea.text; ' +
            'property alias placeholderText: textArea.placeholderText; ' +
            'TextArea { ' +
                'id: textArea; ' +
                'wrapMode: TextArea.Wrap; ' +
            '} ' +
            '}',
            container
        )
        input.text = config.value || ""
        input.placeholderText = config.placeholder || ""
        return input
    }
    
    /**
     * 创建滑块
     */
    function _createSlider(container, config) {
        var input = Qt.createQmlObject(
            'import QtQuick.Controls 6.5; import QtQuick.Layouts 1.4; RowLayout { ' +
            'property alias value: slider.value; ' +
            'property alias from: slider.from; ' +
            'property alias to: slider.to; ' +
            'Slider { ' +
                'id: slider; ' +
                'Layout.fillWidth: true; ' +
            '} ' +
            'Label { ' +
                'text: Math.round(slider.value); ' +
                'Layout.minimumWidth: 30; ' +
            '} ' +
            '}',
            container
        )
        input.from = config.min || 0
        input.to = config.max || 100
        input.value = config.value || 50
        return input
    }
    
    /**
     * 创建开关
     */
    function _createSwitch(container, config) {
        var input = Qt.createQmlObject(
            'import QtQuick.Controls 6.5; Switch { ' +
            'property alias value: checked; ' +
            '}',
            container
        )
        input.checked = config.value || false
        return input
    }
    
    /**
     * 创建进度条
     */
    function _createProgressBar(container, config) {
        var input = Qt.createQmlObject(
            'import QtQuick.Controls 6.5; import QtQuick.Layouts 1.4; RowLayout { ' +
            'property alias value: progressBar.value; ' +
            'property alias from: progressBar.from; ' +
            'property alias to: progressBar.to; ' +
            'ProgressBar { ' +
                'id: progressBar; ' +
                'Layout.fillWidth: true; ' +
            '} ' +
            'Label { ' +
                'text: Math.round(progressBar.value) + "%"; ' +
                'Layout.minimumWidth: 40; ' +
            '} ' +
            '}',
            container
        )
        input.from = config.min || 0
        input.to = config.max || 100
        input.value = config.value || 0
        return input
    }
    
    /**
     * 创建标签控件
     */
    function _createLabelControl(container, config) {
        var input = Qt.createQmlObject(
            'import QtQuick.Controls 6.5; Label { ' +
            'property alias value: text; ' +
            'wrapMode: Text.WordWrap; ' +
            '}',
            container
        )
        input.text = config.text || ""
        return input
    }
    
    /**
     * 创建分隔线
     */
    function _createSeparator(container, config) {
        var input = Qt.createQmlObject(
            'import QtQuick.Controls 6.5; Rectangle { ' +
            'property var value: ""; ' +
            'height: 2; ' +
            'color: "#dee2e6"; ' +
            '}',
            container
        )
        return input
    }
}