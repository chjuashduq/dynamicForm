import QtQuick 6.5                                    // 导入Qt Quick 6.5核心模块
import QtQuick.Controls 6.5                            // 导入Qt Quick Controls 6.5控件模块
import QtQuick.Layouts 1.4                             // 导入Qt Quick Layouts 1.4布局模块
import "." as Config                                    // 导入当前目录下的QML文件作为Config命名空间

/**
 * 动态表单配置编辑器 (重构版)
 *
 * 主要功能：
 * - 提供可视化的表单配置编辑界面
 * - 管理网格布局配置（行数、列数、间距等）
 * - 提供控件工具栏，支持添加各种类型的表单控件
 * - 实时预览配置效果
 * - 支持控件的编辑、删除操作
 * - 提供配置的导入、导出、重置功能
 *
 * 重构改进：
 * - 按单一职责原则拆分组件
 * - 删除重复代码
 * - 提高代码可维护性
 * - 优化组件结构
 *
 * @author Dynamic Form QML Team
 * @version 2.0
 */
Item {                                                  // 配置编辑器主容器
    id: configEditor                                    // 组件唯一标识符

    anchors.fill: parent                                // 填充父容器
    width: parent ? parent.width : 800                  // 宽度：如果有父容器则填充，否则默认800像素
    height: parent ? parent.height : 600                // 高度：如果有父容器则填充，否则默认600像素

    signal configChanged(var newConfig)                 // 配置变化信号，用于通知外部组件配置已更新

    // 配置管理器加载器，动态加载配置管理器组件
    Loader {                                            // 动态加载器，用于按需加载配置管理器
        id: configManagerLoader                         // 配置管理器加载器的唯一标识符
        source: "managers/ConfigManager.qml"           // 配置管理器组件的文件路径
        onLoaded: {                                     // 当配置管理器加载完成时的回调函数
            // 监听内部配置变化（用于更新预览界面）
            item.internalConfigChanged.connect(function (newConfig) { // 连接内部配置变化信号
                if (gridPreviewLoader.item) {          // 如果网格预览组件已加载
                    gridPreviewLoader.item.controls = newConfig.controls;     // 更新预览组件的控件列表
                    gridPreviewLoader.item.gridConfig = newConfig.grid;       // 更新预览组件的网格配置
                    gridPreviewLoader.item.refresh();  // 刷新预览组件显示
                }
            });

            // 监听外部配置变化（用于应用配置到表单预览）
            item.configChanged.connect(function (newConfig) { // 连接外部配置变化信号
                configEditor.configChanged(newConfig); // 向外部发送配置变化信号
            });
        }
    }

    property var configManager: configManagerLoader.item // 配置管理器实例的引用，方便其他组件访问

    // 配置管理器加载完成后的初始化连接器
    Connections {                                       // 信号连接器，用于监听配置管理器的加载完成事件
        target: configManagerLoader                     // 监听目标：配置管理器加载器
        function onLoaded() {                           // 当配置管理器加载完成时执行的函数
            // 初始化网格配置面板
            if (gridConfigPanelLoader.item && configManager) { // 如果网格配置面板和配置管理器都已加载
                gridConfigPanelLoader.item.gridConfig = configManager.currentConfig.grid; // 设置面板的初始网格配置
                // 确保网格配置面板的变化能够同步到配置管理器
                gridConfigPanelLoader.item.configChanged.connect(function (newConfig) { // 连接配置变化信号
                    configManager.updateGridConfig(newConfig); // 更新配置管理器中的网格配置
                });
            }
            // 初始化网格预览组件
            if (gridPreviewLoader.item && configManager) { // 如果网格预览组件和配置管理器都已加载
                gridPreviewLoader.item.controls = configManager.currentConfig.controls;   // 设置预览组件的控件列表
                gridPreviewLoader.item.gridConfig = configManager.currentConfig.grid;     // 设置预览组件的网格配置
                gridPreviewLoader.item.refresh();      // 刷新预览组件显示
                // 重新连接GridPreview的交互信号（点击、右键等）
                connectGridPreviewSignals();            // 调用信号连接函数
            }
            
            // 初始化控件编辑对话框
            if (editDialogLoader.item && configManager) { // 如果编辑对话框和配置管理器都已加载
                editDialogLoader.item.gridConfig = configManager.currentConfig.grid; // 设置对话框的网格配置
            }
        }
    }

    /**
     * 连接网格预览组件的交互信号
     * 处理用户在预览区域的点击和右键操作
     */
    function connectGridPreviewSignals() {             // 连接网格预览信号的函数
        if (gridPreviewLoader.item && configManager) { // 确保预览组件和配置管理器都已加载
            // 连接左键点击信号（用于编辑控件）
            gridPreviewLoader.item.controlClicked.connect(function (row, col, control) { // 监听控件左键点击事件
                if (control) {                          // 如果点击的位置有控件
                    var index = configManager.getControlIndex(control); // 获取控件在列表中的索引
                    if (index >= 0) {                   // 如果找到了控件索引
                        // 打开控件编辑对话框
                        if (editDialog) {               // 如果编辑对话框已加载
                            editDialog.editIndex = index;              // 设置要编辑的控件索引
                            editDialog.editConfig = control;           // 设置要编辑的控件配置
                            editDialog.gridConfig = configManager.currentConfig.grid; // 设置网格配置
                            editDialog.open();          // 打开编辑对话框
                        }
                    }
                }
            });

            // 连接右键点击信号（用于删除控件）
            gridPreviewLoader.item.controlRightClicked.connect(function (row, col, control) { // 监听控件右键点击事件
                if (control) {                          // 如果右键点击的位置有控件
                    configManager.removeControlAtPosition(row, col); // 删除指定位置的控件
                }
            });
        }
    }

    // 延迟信号连接定时器，确保所有组件都已完全加载后再连接信号
    Timer {                                             // 定时器组件
        id: signalConnectionTimer                       // 信号连接定时器的唯一标识符
        interval: 100                                   // 延迟100毫秒执行
        onTriggered: {                                  // 定时器触发时执行的函数
            connectGridPreviewSignals();                // 连接网格预览组件的交互信号
        }
    }

    // 主界面容器，包含所有配置编辑界面元素
    Rectangle {                                         // 主背景容器
        anchors.fill: parent                            // 填充整个父容器
        color: "#f0f0f0"                               // 设置浅灰色背景
        
        // 滚动视图，支持内容超出时的滚动显示
        ScrollView {                                    // 滚动视图容器
            anchors.fill: parent                        // 填充整个背景容器
            anchors.margins: 20                         // 设置20像素的外边距
            clip: true                                  // 启用内容裁剪，超出部分不显示
            
            // 垂直布局列，包含所有配置面板
            Column {                                    // 垂直列布局
                width: parent.width                     // 宽度填充父容器
                spacing: 20                             // 子元素间距20像素

                // 应用程序标题栏
                Rectangle {                             // 标题栏背景容器
                    width: parent.width                 // 宽度填充父容器
                    height: 60                          // 固定高度60像素
                    color: "#667eea"                    // 设置蓝紫色背景
                    radius: 8                           // 设置8像素圆角

                    Text {                              // 标题文本
                        anchors.centerIn: parent        // 居中显示
                        text: "动态表单配置编辑器"      // 标题文字
                        color: "white"                  // 白色文字
                        font.pixelSize: 20              // 字体大小20像素
                        font.bold: true                 // 粗体显示
                    }
                }

                // 网格配置面板加载器
                Loader {                                // 动态加载网格配置面板
                    id: gridConfigPanelLoader           // 网格配置面板加载器标识符
                    width: parent.width                 // 宽度填充父容器
                    height: 280                         // 固定高度280像素
                    source: "panels/GridConfigPanel.qml" // 网格配置面板组件文件路径
                    onLoaded: {                         // 面板加载完成时的回调函数
                        // 连接配置变化信号，即使配置管理器还未准备好也要连接
                        item.configChanged.connect(function (newConfig) { // 监听面板的配置变化
                            if (configManager) {        // 如果配置管理器已准备好
                                configManager.updateGridConfig(newConfig); // 更新配置管理器中的网格配置
                            }
                        });

                        if (configManager) {            // 如果配置管理器已加载
                            item.gridConfig = configManager.currentConfig.grid; // 设置面板的初始网格配置
                        }
                    }
                }

                // 控件工具栏加载器
                Loader {                                // 动态加载控件工具栏
                    id: controlToolbarLoader            // 控件工具栏加载器标识符
                    width: parent.width                 // 宽度填充父容器
                    height: 120                         // 固定高度120像素
                    source: "panels/ControlToolbar.qml" // 控件工具栏组件文件路径
                    onLoaded: {                         // 工具栏加载完成时的回调函数
                        // 连接控件请求信号，当用户点击工具栏按钮时添加对应类型的控件
                        item.controlRequested.connect(function (type) { // 监听控件添加请求
                            if (configManager) {        // 如果配置管理器已准备好
                                configManager.addControl(type); // 添加指定类型的控件到配置中
                            }
                        });
                    }
                }

                // 控件预览区域容器
                Rectangle {                             // 预览区域背景容器
                    id: previewContainer                // 预览容器标识符
                    width: parent ? parent.width - 40 : 400 // 宽度：父容器宽度减去40像素边距，或默认400像素
                    // 动态高度绑定：根据网格预览组件的实际高度自动调整，增加80像素缓冲空间
                    height: gridPreviewLoader.item ? Math.max(300, gridPreviewLoader.item.gridPreviewHeight + 80) : 400
                    anchors.horizontalCenter: parent ? parent.horizontalCenter : undefined // 水平居中对齐
                    color: "#ffffff"                    // 白色背景
                    border.color: "#dee2e6"             // 浅灰色边框
                    border.width: 1                     // 1像素边框宽度
                    radius: 8                           // 8像素圆角

                    // 预览区域内容布局
                    Column {                            // 垂直列布局
                        anchors.fill: parent            // 填充整个预览容器
                        anchors.margins: 15             // 15像素内边距
                        spacing: 10                     // 子元素间距10像素

                        // 预览区域标题
                        Text {                          // 标题文本
                            text: "控件预览"            // 标题内容
                            font.pixelSize: 16          // 字体大小16像素
                            font.bold: true             // 粗体显示
                        }

                        // 网格预览组件加载器
                        Loader {                        // 动态加载网格预览组件
                            id: gridPreviewLoader       // 网格预览加载器标识符
                            width: parent.width - 20    // 宽度：父容器宽度减去20像素
                            height: item ? item.height : 400 // 高度：根据加载的组件高度自动调整，默认400像素
                            source: "panels/GridPreview.qml" // 网格预览组件文件路径
                            onLoaded: {                 // 预览组件加载完成时的回调函数
                                if (configManager) {    // 如果配置管理器已准备好
                                    item.gridConfig = configManager.currentConfig.grid;   // 设置网格配置
                                    item.controls = configManager.currentConfig.controls; // 设置控件列表
                                    item.refresh();     // 刷新预览显示
                                    // 延迟连接交互信号，确保所有组件都已完全加载
                                    signalConnectionTimer.start(); // 启动信号连接定时器
                                } else {                // 如果配置管理器还未准备好，使用默认配置
                                    var defaultConfig = { // 默认网格配置
                                        "rows": 8,      // 8行
                                        "columns": 2,   // 2列
                                        "rowSpacing": 5, // 行间距5像素
                                        "columnSpacing": 10, // 列间距10像素
                                        "rowHeights": [1,1,1,1,1,1,1,2], // 行高比例
                                        "columnWidths": [1,2] // 列宽比例
                                    };
                                    item.gridConfig = defaultConfig; // 设置默认网格配置
                                    item.controls = [];   // 设置空控件列表
                                    item.refresh();       // 刷新预览显示
                                }
                            }
                        }
                    }
                }

                // 操作按钮区域容器
                Rectangle {                             // 按钮区域背景容器
                    width: parent ? parent.width - 40 : 400 // 宽度：父容器宽度减去40像素边距，或默认400像素
                    height: 80                          // 恢复到80像素高度
                    anchors.horizontalCenter: parent ? parent.horizontalCenter : undefined // 水平居中对齐
                    color: "#f8f9fa"                    // 浅灰色背景
                    border.color: "#dee2e6"             // 浅灰色边框
                    border.width: 1                     // 1像素边框宽度
                    radius: 8                           // 8像素圆角

                    // 按钮水平布局
                    Row {                               // 水平行布局
                        anchors.centerIn: parent        // 在父容器中居中显示
                        spacing: 15                     // 按钮间距15像素

                        // 应用配置按钮
                        Button {                        // 应用配置按钮
                            text: "应用配置"            // 按钮文本
                            onClicked: {                // 按钮点击事件处理
                                if (configManager) {    // 如果配置管理器已准备好
                                    configChanged(configManager.currentConfig); // 发送配置变化信号，应用当前配置到表单预览
                                }
                            }
                        }

                        // 导出配置按钮
                        Button {                        // 导出配置按钮
                            text: "导出配置"            // 按钮文本
                            onClicked: {                // 按钮点击事件处理
                                if (configManager) {    // 如果配置管理器已准备好
                                    var jsonString = configManager.exportConfig();
                                    showConfigContent(jsonString, "config.json");
                                }
                            }
                        }



                        // 重置配置按钮
                        Button {                        // 重置配置按钮
                            text: "重置配置"            // 按钮文本
                            onClicked: {                // 按钮点击事件处理
                                if (configManager) {    // 如果配置管理器已准备好
                                    configManager.resetConfig(); // 重置配置为默认值
                                }
                            }
                        }
                    }
                }
            }                                       // Column布局结束
        }                                           // ScrollView结束
    }                                               // 主Rectangle容器结束

    // 控件编辑对话框加载器 - 动态加载编辑对话框组件
    Loader {                                        // 动态加载器
        id: editDialogLoader                        // 编辑对话框加载器标识符
        source: "dialog/ControlEditDialog.qml"     // 控件编辑对话框组件文件路径

        onLoaded: {                                 // 对话框加载完成时的回调函数
            if (item) {                             // 如果对话框组件已成功加载
                if (configManager) {                // 如果配置管理器已准备好
                    item.gridConfig = configManager.currentConfig.grid; // 设置对话框的网格配置
                }
                // 连接控件保存信号，当用户在对话框中保存控件配置时更新配置管理器
                item.controlSaved.connect(function (index, config) { // 监听控件保存事件
                    if (configManager) {            // 如果配置管理器已准备好
                        configManager.updateControl(index, config); // 更新指定索引的控件配置
                    }
                });
            }
        }
    }

    // 编辑对话框别名属性，提供向后兼容性和便捷访问
    property alias editDialog: editDialogLoader.item // 创建editDialog别名，指向加载的对话框实例


    

    
    // ========== 文件操作函数 ==========
    

    

    
    /**
     * 显示消息提示
     * @param message 消息内容
     * @param type 消息类型 (success, error, info, warning)
     */
    function showMessage(message, type) {
        messageDialog.messageText = message;
        messageDialog.messageType = type || "info";
        messageDialog.open();
    }
    
    // ========== 消息提示对话框 ==========
    
    /**
     * 通用消息提示对话框
     */
    Dialog {
        id: messageDialog
        title: "提示"
        anchors.centerIn: Overlay.overlay
        modal: true
        width: Math.min(400, configEditor.width * 0.8)
        height: Math.min(200, configEditor.height * 0.3)
        
        property string messageText: ""
        property string messageType: "info"
        
        Rectangle {
            anchors.fill: parent
            anchors.margins: 10
            color: getMessageColor()
            radius: 8
            border.width: 1
            border.color: getMessageBorderColor()
            
            function getMessageColor() {
                switch (messageDialog.messageType) {
                case "success": return "#d4edda";
                case "error": return "#f8d7da";
                case "warning": return "#fff3cd";
                default: return "#d1ecf1";
                }
            }
            
            function getMessageBorderColor() {
                switch (messageDialog.messageType) {
                case "success": return "#c3e6cb";
                case "error": return "#f5c6cb";
                case "warning": return "#ffeaa7";
                default: return "#bee5eb";
                }
            }
            
            ScrollView {
                anchors.fill: parent
                anchors.margins: 15
                clip: true
                
                Text {
                    width: parent.width
                    text: messageDialog.messageText
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    color: getTextColor()
                    font.pixelSize: 14
                    
                    function getTextColor() {
                        switch (messageDialog.messageType) {
                        case "success": return "#155724";
                        case "error": return "#721c24";
                        case "warning": return "#856404";
                        default: return "#0c5460";
                        }
                    }
                }
            }
        }
        
        standardButtons: Dialog.Ok
    }
    
    /**
     * 配置内容显示对话框
     * 显示配置内容供用户复制和保存
     */
    Dialog {
        id: configContentDialog
        title: "导出配置"
        anchors.centerIn: Overlay.overlay
        modal: true
        width: Math.min(700, configEditor.width * 0.9)
        height: Math.min(600, configEditor.height * 0.8)
        
        property string configContent: ""
        property string fileName: ""
        
        Column {
            anchors.fill: parent
            anchors.margins: 15
            spacing: 15
            
            // 说明文本
            Rectangle {
                width: parent.width
                height: 60
                color: "#e3f2fd"
                border.color: "#2196f3"
                border.width: 1
                radius: 8
                
                Column {
                    anchors.centerIn: parent
                    spacing: 5
                    
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "📋 配置导出"
                        font.bold: true
                        font.pixelSize: 16
                        color: "#1976d2"
                    }
                    
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "请复制以下配置内容，保存为 " + configContentDialog.fileName + " 文件"
                        font.pixelSize: 12
                        color: "#1976d2"
                    }
                }
            }
            
            // 配置内容区域
            Rectangle {
                width: parent.width
                height: parent.height - 140
                color: "#f8f9fa"
                border.color: "#dee2e6"
                border.width: 1
                radius: 8
                
                ScrollView {
                    anchors.fill: parent
                    anchors.margins: 10
                    clip: true
                    
                    TextArea {
                        id: configTextArea
                        text: configContentDialog.configContent
                        readOnly: true
                        selectByMouse: true
                        selectByKeyboard: true
                        wrapMode: TextArea.Wrap
                        font.family: "Consolas, Monaco, 'Courier New', monospace"
                        font.pixelSize: 11
                        color: "#333333"
                        
                        // 全选功能
                        Component.onCompleted: {
                            selectAll();
                        }
                    }
                }
            }
            
            // 操作按钮
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 15
                
                Button {
                    text: "📋 复制到剪贴板"
                    font.pixelSize: 14
                    onClicked: {
                        if (typeof Qt !== 'undefined' && Qt.application && Qt.application.clipboard) {
                            Qt.application.clipboard.text = configContentDialog.configContent;
                            showMessage("✅ 配置已复制到剪贴板！\n请粘贴到文本编辑器中保存为 " + configContentDialog.fileName, "success");
                        } else {
                            showMessage("❌ 无法访问剪贴板，请手动选择并复制文本", "error");
                        }
                    }
                }
                
                Button {
                    text: "🔄 全选文本"
                    font.pixelSize: 14
                    onClicked: {
                        configTextArea.selectAll();
                        configTextArea.forceActiveFocus();
                    }
                }
                
                Button {
                    text: "❌ 关闭"
                    font.pixelSize: 14
                    onClicked: configContentDialog.close()
                }
            }
        }
    }
    
    /**
     * 显示配置内容对话框
     * @param content 配置内容
     * @param filePath 文件路径
     */
    function showConfigContent(content, filePath) {
        configContentDialog.configContent = content;
        configContentDialog.fileName = filePath;
        configContentDialog.open();
    }
}
