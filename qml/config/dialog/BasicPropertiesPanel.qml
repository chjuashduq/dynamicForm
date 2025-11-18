import QtQuick 6.5
import QtQuick.Controls 6.5
import QtQuick.Layouts 1.4

/**
 * 基本属性面板组件
 * 
 * 功能描述：
 * - 提供控件基本属性的编辑界面
 * - 包括标识、标签、位置、跨度、标签比例等属性
 * - 实时验证控件位置是否超出网格范围
 * - 支持配置变更通知机制
 * 
 * 主要属性：
 * - editConfig: 当前编辑的控件配置对象
 * - gridConfig: 网格配置信息，用于位置验证
 * 
 * 主要信号：
 * - configChanged: 配置发生变更时发出
 * 
 * 作者：系统生成
 * 版本：1.0
 */
GroupBox {
    id: basicPropertiesPanel
    title: "基本属性"
    
    // ========== 属性定义 ==========
    property var editConfig: ({})        // 当前编辑的控件配置
    property var gridConfig: ({})        // 网格配置，用于验证位置合法性
    
    // ========== 信号定义 ==========
    signal configChanged()               // 配置变更信号

    // ========== 主界面布局 ==========
    Column {
        anchors.fill: parent
        spacing: 10

        // 属性编辑网格布局
        GridLayout {
            columns: 4                   // 4列布局：标签-输入框-标签-输入框
            columnSpacing: 20
            rowSpacing: 15
            width: parent.width

            // ========== 第一行：标识和标签 ==========
            Label { text: "标识:" }
            TextField {
                id: editKeyField
                text: editConfig.key || ""
                Layout.preferredWidth: 150
                placeholderText: "控件唯一标识符"
                onTextChanged: configChanged()  // 文本变化时通知配置更改
            }

            Label { 
                text: "标签:" 
                visible: editConfig.type !== "button"  // 按钮不需要标签
            }
            TextField {
                id: editLabelField
                text: editConfig.label || ""
                Layout.preferredWidth: 150
                placeholderText: "显示给用户的标签文本"
                visible: editConfig.type !== "button"  // 按钮不需要标签
                onTextChanged: configChanged()
            }

            // ========== 第二行：位置设置 ==========
            Label { text: "行:" }
            SpinBox {
                id: editRowSpinBox
                from: 0                  // 最小行号
                to: 20                   // 最大行号
                value: editConfig.row || 0
                onValueChanged: {
                    validatePosition();  // 验证位置合法性
                    configChanged();
                }
            }

            Label { text: "列:" }
            SpinBox {
                id: editColSpinBox
                from: 0                  // 最小列号
                to: 10                   // 最大列号
                value: editConfig.column || 0
                onValueChanged: {
                    validatePosition();
                    configChanged();
                }
            }

            // ========== 第三行：跨度设置 ==========
            Label { text: "行跨度:" }
            SpinBox {
                id: editRowSpanSpinBox
                from: 1                  // 最小跨度为1
                to: 10                   // 最大跨度为10
                value: editConfig.rowSpan || 1
                onValueChanged: {
                    validatePosition();  // 跨度变化时需要重新验证位置
                    configChanged();
                }
            }

            Label { text: "列跨度:" }
            SpinBox {
                id: editColSpanSpinBox
                from: 1
                to: 10
                value: editConfig.colSpan || 1
                onValueChanged: {
                    validatePosition();
                    configChanged();
                }
            }

            // ========== 第四行：标签比例设置 ==========
            Label { 
                text: "标签比例:" 
                visible: editConfig.type !== "button"  // 按钮不需要标签比例
            }
            RowLayout {
                visible: editConfig.type !== "button"  // 按钮不需要标签比例
                SpinBox {
                    id: editLabelRatioSpinBox
                    from: 0              // 0%：不显示标签
                    to: 100              // 100%：全部为标签
                    value: (editConfig.labelRatio || 0.3) * 100  // 默认30%
                    onValueChanged: configChanged()
                }
                Label { text: "%" }
            }
        }

        // ========== 位置验证提示区域 ==========
        Rectangle {
            id: validationArea
            width: parent.width
            height: 40
            // 根据验证结果动态设置颜色：绿色表示有效，红色表示无效
            color: isValid ? "#d4edda" : "#f8d7da"
            border.color: isValid ? "#c3e6cb" : "#f5c6cb"
            border.width: 1
            radius: 4
            visible: validationMessage !== ""  // 只有在有验证消息时才显示

            // 验证状态属性
            property bool isValid: true           // 验证是否通过
            property string validationMessage: "" // 验证消息文本

            // 验证消息标签
            Label {
                anchors.centerIn: parent
                text: parent.validationMessage
                // 根据验证结果设置文字颜色
                color: parent.isValid ? "#155724" : "#721c24"
            }
        }
    }

    // ========== 函数定义 ==========
    
    /**
     * 验证控件位置是否合法
     * 
     * 功能：
     * - 检查控件位置和跨度是否超出网格范围
     * - 更新验证提示区域的显示状态和消息
     * 
     * 返回值：
     * - true: 位置合法
     * - false: 位置超出范围
     */
    function validatePosition() {
        // 获取当前设置的位置和跨度
        var row = editRowSpinBox.value;
        var col = editColSpinBox.value;
        var rowSpan = editRowSpanSpinBox.value;
        var colSpan = editColSpanSpinBox.value;

        // 获取网格配置，使用默认值作为后备
        var gridRows = gridConfig.rows || 8;      // 默认8行
        var gridCols = gridConfig.columns || 2;   // 默认2列

        // 检查控件是否超出网格边界
        // 控件的结束位置 = 起始位置 + 跨度
        if (row + rowSpan > gridRows || col + colSpan > gridCols) {
            validationArea.isValid = false;
            validationArea.validationMessage = "控件位置超出网格范围";
            return false;
        }

        // 位置合法
        validationArea.isValid = true;
        validationArea.validationMessage = "位置有效";
        return true;
    }

    /**
     * 刷新界面字段显示
     * 
     * 功能：
     * - 根据editConfig更新所有输入控件的值
     * - 重新验证位置合法性
     * 
     * 调用时机：
     * - editConfig属性变化时
     * - 外部需要重置界面时
     */
    function refreshFields() {
        if (!editConfig) return;  // 防止空配置导致错误
        
        // 更新各个输入控件的值，使用默认值作为后备
        editKeyField.text = editConfig.key || "";
        editLabelField.text = editConfig.label || "";
        editRowSpinBox.value = editConfig.row || 0;
        editColSpinBox.value = editConfig.column || 0;
        editRowSpanSpinBox.value = editConfig.rowSpan || 1;
        editColSpanSpinBox.value = editConfig.colSpan || 1;
        // 标签比例从小数转换为百分比显示
        editLabelRatioSpinBox.value = (editConfig.labelRatio || 0.3) * 100;
        
        // 刷新后重新验证位置
        validatePosition();
    }

    /**
     * 获取当前配置
     * 
     * 功能：
     * - 收集所有输入控件的当前值
     * - 组装成配置对象返回
     * 
     * 返回值：
     * - 包含所有基本属性的配置对象
     */
    function getConfig() {
        var config = {
            "key": editKeyField.text,                           // 控件标识
            "row": editRowSpinBox.value,                        // 行位置
            "column": editColSpinBox.value,                     // 列位置
            "rowSpan": editRowSpanSpinBox.value,                // 行跨度
            "colSpan": editColSpanSpinBox.value                 // 列跨度
        };
        
        // 按钮类型不需要标签和标签比例
        if (editConfig.type === "button") {
            config.label = "";                                  // 按钮标签为空
            config.labelRatio = 0;                              // 按钮标签比例为0
        } else {
            config.label = editLabelField.text;                 // 显示标签
            config.labelRatio = editLabelRatioSpinBox.value / 100.0;  // 标签比例（转换为小数）
        }
        
        return config;
    }

    // ========== 事件处理 ==========
    
    /**
     * editConfig属性变化处理
     * 当外部设置新的编辑配置时，自动刷新界面显示
     */
    onEditConfigChanged: {
        console.log("BasicPropertiesPanel editConfig changed:", JSON.stringify(editConfig));
        refreshFields();
    }
}