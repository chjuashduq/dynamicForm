import QtQuick 6.5                                    // 导入Qt Quick 6.5核心模块
import QtQuick.Controls 6.5                            // 导入Qt Quick Controls 6.5控件模块
import QtQuick.Layouts 1.4                             // 导入Qt Quick Layouts 1.4布局模块
import "../Common"                                       // 导入全局样式和消息管理器
import "../core"                                        // 导入核心功能模块
import "../components"                                  // 导入美化组件

/**
 * 控件工厂
 *
 * 主要功能：
 * - 根据JSON配置动态创建各种类型的表单控件
 * - 处理控件的布局、样式和事件绑定
 * - 注入必填(required)和验证状态(valid)属性
 */
QtObject {                                               // 控件工厂对象
    id: controlFactory                                  // 工厂唯一标识符

    // ===== 预编译组件定义 =====
    property Component rowLayoutComponent: Component {  // 行布局组件模板
        RowLayout {
            spacing: AppStyles.spacingSmall             // 使用全局样式的间距
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
                return optionValues && currentIndex >= 0 && currentIndex < optionValues.length ? optionValues[currentIndex] : currentText; // 返回对应的值或显示文本
            }
        }
    }
    property Component buttonComponent: Component {     // 按钮组件模板
        StyledButton {                                  // 使用美化的按钮
            buttonType: "primary"                       // 默认为主要按钮
        }
    }

    // ===== 外部依赖属性 =====
    property var parentGrid: null                       // 父网格容器引用
    property var controlsMap: ({})                      // 控件映射表
    property var labelsMap: ({})                        // 标签映射表
    property var scriptEngine: null                     // 脚本引擎引用
    property var formConfig: null                       // 表单配置对象
    property var formAPI: null                          // FormAPI引用

    /**
     * 创建单个表单控件的主函数
     * @param config 控件配置对象，包含类型、位置、样式、事件等信息
     */
    function createControl(config) {                    // 创建控件的主函数
        if (!parentGrid) {                              // 检查父网格容器是否存在
            return;
        }

        // ===== 第一步：创建行布局容器 =====
        var container = rowLayoutComponent.createObject(parentGrid);
        container.Layout.row = config.row;              // 设置控件在网格中的行位置
        container.Layout.column = config.column;        // 设置控件在网格中的列位置
        container.Layout.rowSpan = config.rowSpan;      // 设置控件跨越的行数
        container.Layout.columnSpan = config.colSpan;   // 设置控件跨越的列数
        container.Layout.fillWidth = true;              // 水平方向填充可用空间
        container.Layout.fillHeight = true;             // 垂直方向填充可用空间
        container.spacing = 5;                          // 设置标签和输入控件之间的间距

        // ===== 第二步：设置尺寸约束 =====
        _setRowHeight(container, config);               // 根据网格配置设置行高
        _setColumnWidth(container, config);             // 根据网格配置设置列宽

        // ===== 第三步：创建子组件 =====
        var label = _createLabel(container, config);    // 创建标签组件
        var input = _createInput(container, config);    // 创建输入控件组件

        if (input) {                                    // 如果输入控件创建成功
            // ===== 第四步：注册控件 =====
            var controlKey = config.key || config.label; // 使用key或label作为控件的唯一标识
            controlsMap[controlKey] = input;            // 将控件注册到映射表中

            if (label) {
                labelsMap[controlKey] = label;          // 注册标签（用于验证失败时标红）
            }

            // ===== 第五步：注册控件配置（包含验证信息）=====
            if (formAPI) {
                formAPI.registerControlConfig(controlKey, config);
            }

            // ===== 第六步：应用配置 =====

            // [新增] 应用 required 属性 (影响 valid 初始状态)
            // 适用于 StyledBase 组件 (TextField, SpinBox 等)
            if (config.required !== undefined) {
                try {
                    // 如果控件有 required 属性（StyledBase组件），直接赋值
                    input.required = config.required;

                    // 如果是动态创建的对象（没有继承 StyledBase），需要手动设置 valid 初始值
                    // 0: Unchecked, 1: Valid
                    if (!input.hasOwnProperty("baseDefaultProps")) {
                        input.valid = config.required ? 0 : 1;
                    }
                } catch (e) {
                    console.warn("ControlFactory: Cannot set required property on control", controlKey);
                }
            }

            _applyStyles(input, config);                // 应用样式配置
            _bindEvents(input, config);                 // 绑定事件处理函数
        }
    }

    /**
     * 设置控件容器的行高约束
     */
    function _setRowHeight(container, config) {         // 设置行高的私有函数
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

    /**
     * 设置控件容器的列宽约束
     */
    function _setColumnWidth(container, config) {       // 设置列宽的私有函数
        if (formConfig.grid && formConfig.grid.columnWidths && config.column < formConfig.grid.columnWidths.length) {
            var baseWidth = 200;
            var columnWidthRatio = formConfig.grid.columnWidths[config.column];

            container.Layout.preferredWidth = baseWidth * columnWidthRatio;
        }
    }

    /**
     * 创建标签组件
     */
    function _createLabel(container, config) {          // 创建标签的私有函数
        if (config.type === "button") {
            return null;
        }

        var label = labelComponent.createObject(container);
        label.text = config.label;
        label.Layout.fillWidth = true;
        label.Layout.preferredWidth = config.labelRatio * 1000;

        // 应用标签样式配置
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
    function _createInput(container, config) {          // 创建输入控件的私有函数
        var input = null;

        switch (config.type) {
        case "text":                                // 文本输入框类型
            input = textFieldComponent.createObject(container);
            input.placeholderText = config.placeholder || "";
            input.text = config.value || "";
            break;
        case "number":                              // 数字输入框类型
            input = spinBoxComponent.createObject(container);
            input.value = config.value || 0;
            break;
        case "dropdown":                            // 下拉选择框类型
            input = comboBoxComponent.createObject(container);
            _setupDropdownOptions(input, config);
            break;
        case "checkbox":                            // 复选框组类型
            input = _createCheckboxGroup(container, config);
            break;
        case "radio":                               // 单选框组类型
            input = _createRadioGroup(container, config);
            break;
        case "button":                              // 按钮类型
            input = buttonComponent.createObject(container);
            input.text = config.text || config.label;
            break;
        case "password":                            // 密码输入框类型
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

    /**
     * 设置下拉框选项
     */
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

        // 设置当前选中项
        if (config.value) {
            var valueIndex = values.indexOf(config.value);
            if (valueIndex >= 0) {
                comboBox.currentIndex = valueIndex;
            }
        }
    }

    /**
     * 创建复选框组
     */
    function _createCheckboxGroup(container, config) {
        var layoutType = (config.direction === "horizontal") ? "RowLayout" : "ColumnLayout";

        // [新增] 注入 required 和 valid 属性
        // 0: Unchecked (待验证), 1: Valid (合格)
        var properties = "property var checkboxList: []; " + "property var valuesList: []; " + "property bool required: false; " + "property int valid: required ? 0 : 1; ";

        var qmlString = 'import QtQuick.Controls 6.5; import QtQuick.Layouts 1.4; ' + layoutType + ' { ' + 'spacing: 10; ' + properties + 'function getValue() { ' + 'var selectedValues = []; ' + 'for (var i = 0; i < checkboxList.length; i++) { ' + 'if (checkboxList[i].checked) { ' + 'selectedValues.push(checkboxList[i].optionValue); ' + '} ' + '} ' + 'return selectedValues; ' + '} ' + '}';

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

    /**
     * 创建单选按钮组
     */
    function _createRadioGroup(container, config) {
        // [新增] 注入 required 和 valid 属性
        var properties = "property var radioList: []; " + "property var valuesList: []; " + "property bool required: false; " + "property int valid: required ? 0 : 1; ";

        var qmlString = 'import QtQuick.Controls 6.5; import QtQuick.Layouts 1.4; ColumnLayout { ' + properties + 'function getValue() { ' + 'for (var i = 0; i < radioList.length; i++) { ' + 'if (radioList[i].checked) { ' + 'return radioList[i].optionValue; ' + '} ' + '} ' + 'return ""; ' + '} ' + '}';

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

    /**
     * 应用样式
     */
    function _applyStyles(input, config) {
        if (config.style) {
            if (config.style.inputColor && input.hasOwnProperty("color")) {
                input.color = config.style.inputColor;
            }
            if (config.style.inputFontSize && input.hasOwnProperty("font") && input.font) {
                input.font.pointSize = config.style.inputFontSize;
            }
            // 注意：背景样式在某些Qt样式下不支持自定义，暂时注释掉避免警告
        }
    }

    /**
     * 绑定事件
     */
    function _bindEvents(input, config) {
        if (!scriptEngine) {
            return;
        }

        var controlKey = config.key || config.label;

        // [重构] 提取通用的验证执行逻辑
        var performValidation = function () {
            if (formAPI) {
                var result = formAPI.validateControl(controlKey, false);
                var label = labelsMap[controlKey];

                // 验证结果直接反映在控件的 valid 属性上 (0, 1, 2)
                // 仅需处理标签颜色
                if (label) {
                    if (result.valid) { // valid === 1 (合格)
                        // 验证成功：恢复原始颜色
                        label.color = config.style && config.style.labelColor ? config.style.labelColor : "#000000";
                    } else { // valid === 2 (不合格)
                        label.color = "#ff0000";  // 验证失败：标红
                    }
                }
                return result.valid;
            }
            return true;
        };

        // ===== 焦点丢失事件 - 自动验证 + 用户自定义事件 =====
        // 对于 TextField (text, password 类型)
        if (config.type === "text" || config.type === "password") {
            if (input.hasOwnProperty("focusChanged")) {
                input.focusChanged.connect(function () {
                    if (!input.focus) {
                        var passed = performValidation();
                        // 只有验证通过时才执行用户自定义的焦点丢失事件
                        if (passed && config.events && config.events.onFocusLost) {
                            scriptEngine.executeFunction(config.events.onFocusLost, {
                                self: input
                            });
                        }
                    }
                });
            }
        }

        // 对于 SpinBox (number 类型)
        if (config.type === "number") {
            // 使用activeFocusChanged（更可靠）
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

        // 对于 ComboBox (dropdown 类型)
        if (config.type === "dropdown") {
            // 使用popup关闭事件监听（避免与currentIndexChanged重复触发）
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

        // ===== 其他事件（需要 config.events 存在）=====
        if (!config.events) {
            return;
        }

        // 文本变化事件
        if (input.hasOwnProperty("textChanged") && config.events.onTextChanged) {
            input.textChanged.connect(function () {
                scriptEngine.executeFunction(config.events.onTextChanged, {
                    self: input
                });
            });
        }

        // 数值变化事件
        if (input.hasOwnProperty("valueChanged") && config.events.onValueChanged) {
            input.valueChanged.connect(function () {
                scriptEngine.executeFunction(config.events.onValueChanged, {
                    self: input
                });
            });
        }

        // 下拉框选择变化事件
        if (input.hasOwnProperty("currentIndexChanged") && config.events.onValueChanged) {
            input.currentIndexChanged.connect(function () {
                scriptEngine.executeFunction(config.events.onValueChanged, {
                    self: input
                });
            });
        }

        // 按钮点击事件
        if (input.hasOwnProperty("clicked") && config.events.onClicked) {
            input.clicked.connect(function () {
                scriptEngine.executeFunction(config.events.onClicked, {
                    self: input
                });
            });
        }
    }
}
