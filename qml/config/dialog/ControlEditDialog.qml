import QtQuick 6.5
import QtQuick.Controls 6.5
import QtQuick.Layouts 1.4

/**
 * 控件编辑对话框组件 (重构版)
 * 
 * 功能描述：
 * - 提供完整的控件配置编辑界面
 * - 集成基本属性、类型特定属性和事件配置
 * - 支持多种控件类型的统一编辑
 * - 提供配置验证和保存功能
 * 
 * 主要组成部分：
 * 1. 基本属性面板 - 编辑通用属性（位置、标签等）
 * 2. 类型特定属性面板 - 根据控件类型动态加载相应编辑器
 * 3. 事件配置面板 - 配置控件事件处理函数
 * 4. 函数帮助对话框 - 辅助编写事件处理代码
 * 
 * 工作流程：
 * 1. 接收外部传入的控件配置和索引
 * 2. 根据控件类型加载相应的编辑界面
 * 3. 用户编辑配置后点击确定
 * 4. 收集所有配置并通过信号返回给调用者
 * 
 * 作者：系统生成
 * 版本：2.0 (重构版)
 */
Dialog {
    id: editDialog
    title: "编辑控件"
    width: 800
    height: 700
    anchors.centerIn: Overlay.overlay
    modal: true                          // 模态对话框，阻止与其他窗口交互

    // ========== 属性定义 ==========
    property int editIndex: -1           // 正在编辑的控件在列表中的索引，-1表示新建
    property var editConfig: ({})        // 当前编辑的控件配置对象
    property var gridConfig: ({})        // 网格配置，用于位置验证
    
    // ========== 信号定义 ==========
    signal controlSaved(int index, var config)  // 控件保存完成信号

    // ========== 类型管理器 ==========
    // 使用Loader动态加载类型管理器，避免循环依赖
    property var typeManagerLoader: Loader {
        source: "../managers/ControlTypeManager.qml"
    }
    property var typeManager: typeManagerLoader.item  // 控件类型管理器实例

    // ========== 事件处理 ==========
    
    /**
     * 对话框打开时的处理
     * 刷新所有编辑字段的显示
     */
    onOpened: {
        refreshFields();
    }
    
    /**
     * 编辑配置变化时的处理
     * 当外部设置新的editConfig时自动刷新界面
     */
    onEditConfigChanged: {
        refreshFields();
    }

    // ========== 主界面布局 ==========
    ScrollView {
        anchors.fill: parent
        anchors.margins: 20
        clip: true                       // 启用裁剪，防止内容溢出

        Column {
            width: 700                   // 固定宽度，确保布局一致性
            spacing: 20

            // ========== 基本属性编辑面板 ==========
            BasicPropertiesPanel {
                id: basicPropertiesPanel
                width: parent.width
                editConfig: editDialog.editConfig    // 绑定当前编辑配置
                gridConfig: editDialog.gridConfig    // 绑定网格配置用于验证
            }

            // ========== 类型特定属性编辑面板 ==========
            GroupBox {
                title: "类型特定属性"
                width: parent.width
                // 只有当控件类型有特定属性时才显示此面板
                visible: typeSpecificLoader.source !== ""

                Loader {
                    id: typeSpecificLoader
                    width: parent.width
                    source: getTypeSpecificComponent()  // 动态加载类型特定编辑器
                    
                    /**
                     * 获取类型特定组件的路径
                     * 根据控件类型和类型管理器判断是否需要加载特定编辑器
                     */
                    function getTypeSpecificComponent() {
                        // 检查类型管理器是否存在且当前类型是否有特定属性
                        if (!typeManager || !typeManager.hasTypeSpecificProps(editConfig.type)) {
                            return "";  // 返回空字符串表示不加载任何组件
                        }
                        return "../ControlTypeEditor.qml";  // 加载通用类型编辑器
                    }
                    
                    /**
                     * 组件加载完成后的处理
                     * 将当前编辑配置传递给加载的组件
                     */
                    onLoaded: {
                        if (item) {
                            item.controlConfig = editConfig;
                        }
                    }
                }
            }

            // ========== 校验配置面板 ==========
            Loader {
                id: validationPanelLoader
                width: parent.width
                source: "ValidationPanel.qml"
                active: true  // 始终加载
                visible: editConfig.type !== "button"  // 按钮不需要校验
                
                onLoaded: {
                    if (item) {
                        item.editConfig = editDialog.editConfig
                    }
                }
            }
            


            // ========== 事件配置面板 ==========
            EventConfigPanel {
                id: eventConfigPanel
                width: parent.width
                editConfig: editDialog.editConfig        // 绑定当前编辑配置
                typeManager: editDialog.typeManager      // 传递类型管理器
                
                /**
                 * 事件编辑请求处理
                 * 当用户点击编写函数按钮时，打开相应的函数帮助对话框
                 */
                onEventEditRequested: function(eventType, currentCode) {
                    if (eventType === "focusLost") {
                        // 打开焦点丢失事件编辑对话框
                        functionHelpDialog.showFocusLostHelp(currentCode);
                    } else if (eventType === "clicked") {
                        // 打开按钮点击事件编辑对话框
                        functionHelpDialog.showClickedEventHelp(currentCode);
                    } else if (eventType === "change") {
                        // 打开变化事件编辑对话框，传入控件类型以提供相应帮助
                        functionHelpDialog.showChangeEventHelp(editConfig.type, currentCode);
                    }
                }
            }
        }
    }

    // ========== 对话框按钮配置 ==========
    standardButtons: Dialog.Ok | Dialog.Cancel

    /**
     * 确定按钮点击处理
     * 收集所有配置并发出保存信号
     */
    onAccepted: {
        var newConfig = buildControlConfig();
        console.log("ControlEditDialog onAccepted - emitting controlSaved signal with index:", editIndex);
        controlSaved(editIndex, newConfig);  // 发出控件保存信号
    }
    
    // ========== 核心功能函数 ==========
    
    /**
     * 构建完整的控件配置对象
     * 
     * 功能：
     * - 收集基本属性配置
     * - 收集类型特定属性配置
     * - 保持现有的事件配置
     * - 组装成完整的控件配置对象
     * 
     * 返回值：
     * - 完整的控件配置对象
     */
    function buildControlConfig() {
        console.log("Building control config...");
        
        // 初始化配置对象，保留控件类型
        var newConfig = {
            "type": editConfig.type
        };

        // ========== 收集基本属性配置 ==========
        var basicConfig = basicPropertiesPanel.getConfig();
        for (var key in basicConfig) {
            newConfig[key] = basicConfig[key];
        }
        console.log("Basic config built:", JSON.stringify(newConfig));

        // ========== 收集类型特定属性配置 ==========
        if (typeSpecificLoader.item && typeSpecificLoader.item.getTypeSpecificConfig) {
            var typeConfig = typeSpecificLoader.item.getTypeSpecificConfig();
            console.log("Type specific config:", JSON.stringify(typeConfig));
            // 合并类型特定配置
            for (var key in typeConfig) {
                newConfig[key] = typeConfig[key];
            }
        } else {
            console.log("No type specific loader or getTypeSpecificConfig function");
        }
        
        // ========== 收集验证配置 ==========
        if (validationPanelLoader.item && validationPanelLoader.visible) {
            var validationConfig = validationPanelLoader.item.getConfig()
            newConfig.validationFunction = validationConfig.validationFunction
        }
        
        // ========== 保持事件配置 ==========
        // 事件配置由EventConfigPanel直接修改editConfig.events
        // 这里直接复制现有的事件配置
        if (editConfig.events) {
            newConfig.events = editConfig.events;
        }

        console.log("Final config built:", JSON.stringify(newConfig));
        return newConfig;
    }
    
    /**
     * 刷新所有编辑字段的显示
     * 
     * 功能：
     * - 将当前editConfig的值同步到各个编辑面板
     * - 确保界面显示与数据一致
     * 
     * 调用时机：
     * - 对话框打开时
     * - editConfig属性变化时
     */
    function refreshFields() {
        if (!editConfig) return;  // 防止空配置导致错误
        
        console.log("Refreshing fields with config:", JSON.stringify(editConfig));
        
        // 刷新基本属性面板 - 通过属性绑定自动更新
        basicPropertiesPanel.editConfig = editConfig;
        
        // 刷新验证配置面板 - 通过属性绑定自动更新
        if (validationPanelLoader.item) {
            validationPanelLoader.item.editConfig = editConfig;
        }
        
        // 刷新事件配置面板 - 通过属性绑定自动更新
        eventConfigPanel.editConfig = editConfig;
        
        // 刷新类型特定属性面板 - 需要手动设置
        if (typeSpecificLoader.item) {
            typeSpecificLoader.item.controlConfig = editConfig;
        }
    }

    // ========== 子对话框 ==========
    
    /**
     * 函数编写帮助对话框
     * 提供事件处理函数的编写界面和API帮助
     */
    FunctionHelpDialog {
        id: functionHelpDialog
        
        /**
         * 函数保存完成处理
         * 将编写的代码更新到事件配置中
         */
        onFunctionSaved: function(eventType, code) {
            eventConfigPanel.updateEvent(eventType, code);
        }
    }
}