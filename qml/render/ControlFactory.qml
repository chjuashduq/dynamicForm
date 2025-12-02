import QtQuick 6.5
import QtQuick.Controls 6.5
import QtQuick.Layouts 1.4
import "../Common"
import "../core"
import "../components"

/**
 * 控件工厂
 *
 * 主要功能：
 * - 根据JSON配置动态创建各种类型的表单控件
 * - 处理控件的布局、样式和事件绑定
 * - 注入必填(required)和验证状态(valid)属性
 */
QtObject {
    id: controlFactory

    // ===== 预编译组件定义 =====
    property Component rowLayoutComponent: Component {
        RowLayout {
            spacing: AppStyles.spacingSmall
        }
    }

    property Component labelComponent: Component {
        StyledLabel {}
    }
    property Component textFieldComponent: Component {
        StyledTextField {}
    }
    property Component spinBoxComponent: Component {
        StyledSpinBox {}
    }
    // [新增] 日期时间组件模板
    property Component dateTimeComponent: Component {
        StyledDateTime {}
    }
    property Component comboBoxComponent: Component {
        StyledComboBox {
            property var optionValues: []
            function getValue() {
                return optionValues && currentIndex >= 0 && currentIndex < optionValues.length ? optionValues[currentIndex] : currentText;
            }
        }
    }
    property Component buttonComponent: Component {
        StyledButton {
            buttonType: "primary"
        }
    }

    // ===== 外部依赖属性 =====
    property var parentGrid: null
    property var controlsMap: ({})
    property var labelsMap: ({})
    property var scriptEngine: null
    property var formConfig: null
    property var formAPI: null

    /**
     * 创建单个表单控件的主函数
     */
    function createControl(config) {
        if (!parentGrid)
            return;

        // ===== 第一步：创建行布局容器 =====
        var container = rowLayoutComponent.createObject(parentGrid);
        container.Layout.row = config.row;
        container.Layout.column = config.column;
        container.Layout.rowSpan = config.rowSpan;
        container.Layout.columnSpan = config.colSpan;
        container.Layout.fillWidth = true;
        container.Layout.fillHeight = true;
        container.spacing = 5;

        // ===== 第二步：设置尺寸约束 =====
        _setRowHeight(container, config);
        _setColumnWidth(container, config);

        // ===== 第三步：创建子组件 =====
        var label = _createLabel(container, config);
        var input = _createInput(container, config);

        if (input) {
            // ===== 第四步：注册控件 =====
            var controlKey = config.key || config.label;
            controlsMap[controlKey] = input;

            if (label) {
                labelsMap[controlKey] = label;
            }

            // ===== 第五步：注册控件配置（包含验证信息）=====
            if (formAPI) {
                formAPI.registerControlConfig(controlKey, config);
            }

            // ===== 第六步：应用配置 =====
            if (config.required !== undefined) {
                try {
                    input.required = config.required;
                    if (!input.hasOwnProperty("baseDefaultProps")) {
                        input.valid = config.required ? "unchecked" : true;
                    }
                } catch (e) {
                    console.warn("ControlFactory: Cannot set required property on control", controlKey);
                }
            }

            _applyStyles(input, config);
            _bindEvents(input, config);
        }
    }

    function _setRowHeight(container, config) {
        if (formConfig.grid && formConfig.grid.rowHeights && config.row < formConfig.grid.rowHeights.length) {
            var minHeight = 25;
            var preferredHeight = 40;
            var maxHeight = 60;
            var rowHeightRatio = formConfig.grid.rowHeights[config.row];

            container.Layout.minimumHeight = minHeight * rowHeightRatio;
            container.Layout.preferredHeight = preferredHeight * rowHeightRatio;
            container.Layout.maximumHeight = maxHeight * rowHeightRatio;
        }
    }

    function _setColumnWidth(container, config) {
        if (formConfig.grid && formConfig.grid.columnWidths && config.column < formConfig.grid.columnWidths.length) {
            var baseWidth = 200;
            var columnWidthRatio = formConfig.grid.columnWidths[config.column];

            container.Layout.preferredWidth = baseWidth * columnWidthRatio;
        }
    }

    function _createLabel(container, config) {
        if (config.type === "button")
            return null;

        var label = labelComponent.createObject(container);
        label.text = config.label;
        label.Layout.fillWidth = true;
        label.Layout.preferredWidth = config.labelRatio * 1000;

        if (config.style) {
            if (config.style.labelColor)
                label.color = config.style.labelColor;
            if (config.style.labelBold)
                label.font.bold = config.style.labelBold;
        }

        return label;
    }

    /**
     * 创建输入控件组件
     */
    function _createInput(container, config) {
        var input = null;

        // 兼容处理：统一类型名称
        var type = config.type;
        if (type === "StyledDateTime")
            type = "datetime";

        switch (type) {
        case "text":
            input = textFieldComponent.createObject(container);
            input.placeholderText = config.placeholder || "";
            input.text = config.value || "";
            break;
        case "number":
            input = spinBoxComponent.createObject(container);
            input.value = config.value || 0;
            break;
        case "datetime": // [新增] 日期时间控件
            input = dateTimeComponent.createObject(container);
            input.placeholderText = config.placeholder || "请选择时间";
            if (config.displayFormat)
                input.displayFormat = config.displayFormat;
            if (config.outputFormat)
                input.outputFormat = config.outputFormat;
            input.text = config.value || "";
            break;
        case "dropdown":
            input = comboBoxComponent.createObject(container);
            _setupDropdownOptions(input, config);
            break;
        case "checkbox":
            input = _createCheckboxGroup(container, config);
            break;
        case "radio":
            input = _createRadioGroup(container, config);
            break;
        case "button":
            input = buttonComponent.createObject(container);
            input.text = config.text || config.label;
            break;
        case "password":
            input = textFieldComponent.createObject(container);
            input.placeholderText = config.placeholder;
            input.text = config.value;
            input.echoMode = TextInput.Password;
            break;
        }

        if (input) {
            input.Layout.fillWidth = true;
            input.Layout.preferredWidth = (1 - config.labelRatio) * 1000;
        }

        return input;
    }

    function _setupDropdownOptions(comboBox, config) {
        if (!config.options || !Array.isArray(config.options))
            return;
        var labels = [];
        var values = [];

        for (var i = 0; i < config.options.length; i++) {
            var option = config.options[i];
            if (typeof option === "string") {
                labels.push(option);
                values.push(option);
            } else if (option && option.label && option.value) {
                labels.push(option.label);
                values.push(option.value);
            }
        }

        comboBox.model = labels;
        comboBox.optionValues = values;

        if (config.value) {
            var valueIndex = values.indexOf(config.value);
            if (valueIndex >= 0) {
                comboBox.currentIndex = valueIndex;
            }
        }
    }

    function _createCheckboxGroup(container, config) {
        var layoutType = (config.direction === "horizontal") ? "RowLayout" : "ColumnLayout";
        var properties = "property var checkboxList: []; property var valuesList: []; property bool required: false; property var valid: required ? \"unchecked\" : true; ";
        var qmlString = 'import QtQuick.Controls 6.5; import QtQuick.Layouts 1.4; ' + layoutType + ' { spacing: 10; ' + properties + 'function getValue() { var selectedValues = []; for (var i = 0; i < checkboxList.length; i++) { if (checkboxList[i].checked) { selectedValues.push(checkboxList[i].optionValue); } } return selectedValues; } }';
        var input = Qt.createQmlObject(qmlString, container);

        if (!config.options || !Array.isArray(config.options))
            return input;
        var checkboxes = [];
        var values = [];

        for (var j = 0; j < config.options.length; j++) {
            var option = config.options[j];
            var label, value;

            if (typeof option === "string") {
                label = value = option;
            } else if (option && option.label && option.value) {
                label = option.label;
                value = option.value;
            } else {
                continue;
            }

            var cb = Qt.createQmlObject('import QtQuick.Controls 6.5; CheckBox { property var optionValue }', input);
            cb.text = label;
            cb.optionValue = value;
            cb.checked = config.value && Array.isArray(config.value) && config.value.indexOf(value) >= 0;

            checkboxes.push(cb);
            values.push(value);
        }

        input.checkboxList = checkboxes;
        input.valuesList = values;

        return input;
    }

    function _createRadioGroup(container, config) {
        var properties = "property var radioList: []; property var valuesList: []; property bool required: false; property var valid: required ? \"unchecked\" : true; ";
        var qmlString = 'import QtQuick.Controls 6.5; import QtQuick.Layouts 1.4; ColumnLayout { ' + properties + 'function getValue() { for (var i = 0; i < radioList.length; i++) { if (radioList[i].checked) { return radioList[i].optionValue; } } return ""; } }';
        var input = Qt.createQmlObject(qmlString, container);
        var group = Qt.createQmlObject('import QtQuick.Controls 6.5; ButtonGroup {}', container);
        if (!config.options || !Array.isArray(config.options))
            return input;
        var radioButtons = [];
        var values = [];

        for (var j = 0; j < config.options.length; j++) {
            var option = config.options[j];
            var label, value;

            if (typeof option === "string") {
                label = value = option;
            } else if (option && option.label && option.value) {
                label = option.label;
                value = option.value;
            } else {
                continue;
            }

            var rb = Qt.createQmlObject('import QtQuick.Controls 6.5; RadioButton { property var optionValue }', input);
            rb.text = label;
            rb.optionValue = value;
            rb.checked = config.value === value;
            rb.group = group;

            radioButtons.push(rb);
            values.push(value);
        }

        input.radioList = radioButtons;
        input.valuesList = values;

        return input;
    }

    function _applyStyles(input, config) {
        if (config.style) {
            if (config.style.inputColor && input.hasOwnProperty("color")) {
                input.color = config.style.inputColor;
            }
            if (config.style.inputFontSize && input.hasOwnProperty("font") && input.font) {
                input.font.pointSize = config.style.inputFontSize;
            }
        }
    }

    /**
     * 绑定事件
     */
    function _bindEvents(input, config) {
        if (!scriptEngine)
            return;

        var controlKey = config.key || config.label;
        var performValidation = function () {
            if (formAPI) {
                var result = formAPI.validateControl(controlKey, false);
                var label = labelsMap[controlKey];

                if (label) {
                    if (result.valid) {
                        label.color = config.style && config.style.labelColor ? config.style.labelColor : "#000000";
                    } else {
                        label.color = "#ff0000";
                    }
                }
                return result.valid;
            }
            return true;
        };

        // 焦点丢失事件
        if (config.type === "text" || config.type === "password" || config.type === "datetime" || config.type === "StyledDateTime") {
            if (input.hasOwnProperty("focusChanged")) {
                input.focusChanged.connect(function () {
                    if (!input.focus) {
                        var passed = performValidation();
                        if (passed && config.events && config.events.onFocusLost) {
                            scriptEngine.executeFunction(config.events.onFocusLost, {
                                self: input
                            });
                        }
                    }
                });
            }
        }

        // Number
        if (config.type === "number") {
            if (input.hasOwnProperty("activeFocusChanged")) {
                input.activeFocusChanged.connect(function () {
                    if (!input.activeFocus) {
                        var passed = performValidation();
                        if (passed && config.events && config.events.onFocusLost) {
                            scriptEngine.executeFunction(config.events.onFocusLost, {
                                self: input
                            });
                        }
                    }
                });
            }
        }

        // Dropdown
        if (config.type === "dropdown") {
            if (input.hasOwnProperty("popup")) {
                input.popup.closed.connect(function () {
                    var passed = performValidation();
                    if (passed && config.events && config.events.onFocusLost) {
                        scriptEngine.executeFunction(config.events.onFocusLost, {
                            self: input
                        });
                    }
                });
            }
        }

        if (!config.events)
            return;

        // 通用变化事件
        if (input.hasOwnProperty("textChanged") && config.events.onTextChanged) {
            input.textChanged.connect(function () {
                scriptEngine.executeFunction(config.events.onTextChanged, {
                    self: input
                });
            });
        }
        if (input.hasOwnProperty("valueChanged") && config.events.onValueChanged) {
            input.valueChanged.connect(function () {
                scriptEngine.executeFunction(config.events.onValueChanged, {
                    self: input
                });
            });
        }
        if (input.hasOwnProperty("currentIndexChanged") && config.events.onValueChanged) {
            input.currentIndexChanged.connect(function () {
                scriptEngine.executeFunction(config.events.onValueChanged, {
                    self: input
                });
            });
        }
        if (input.hasOwnProperty("clicked") && config.events.onClicked) {
            input.clicked.connect(function () {
                scriptEngine.executeFunction(config.events.onClicked, {
                    self: input
                });
            });
        }
    }
}
