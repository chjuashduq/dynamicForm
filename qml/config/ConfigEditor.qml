import QtQuick 6.5                                    // 导入Qt Quick 6.5核心模块
import QtQuick.Controls 6.5                            // 导入Qt Quick Controls 6.5控件模块
import QtQuick.Layouts 1.4                             // 导入Qt Quick Layouts 1.4布局模块
import "." as Config                                    // 导入当前目录下的QML文件作为Config命名空间
import mysqlhelper 1.0                                // 导入mysqlhelper 1.0模块，用于数据库操作
import Common 1.0                                    // 导入Common 1.0模块，包含通用组件和功能

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

    property var dynamicNameText: ""    // 组件名称标识符
    property var stackViewRef: ({})
    property var loaderInstanceRef: ({})

    // 配置管理器加载器，动态加载配置管理器组件
    Loader {                                            // 动态加载器，用于按需加载配置管理器
        id: configManagerLoader                         // 配置管理器加载器的唯一标识符
        source: "managers/ConfigManager.qml"           // 配置管理器组件的文件路径
        onLoaded: {
            console.log("ConfigEditor: ConfigManager loaded");
            // 当配置管理器加载完成时的回调函数
            // 监听内部配置变化（用于更新预览界面）
            item.internalConfigChanged.connect(function (newConfig) { // 连接内部配置变化信号
                console.log("ConfigEditor: received internalConfigChanged", JSON.stringify(newConfig.grid));
                if (gridPreviewLoader.item) {
                    // 如果网格预览组件已加载
                    console.log("ConfigEditor: updating GridPreview");
                    gridPreviewLoader.item.controls = newConfig.controls;     // 更新预览组件的控件列表
                    gridPreviewLoader.item.gridConfig = newConfig.grid;       // 更新预览组件的网格配置
                    gridPreviewLoader.item.refresh();  // 刷新预览组件显示
                } else {
                    console.log("ConfigEditor: GridPreview not loaded yet");
                }
            });
            
            // 连接 GridConfigPanel 的信号
            if (gridConfigPanelLoader.item) {
                console.log("ConfigEditor: Connecting GridConfigPanel signal (from ConfigManager.onLoaded)");
                gridConfigPanelLoader.item.configChanged.connect(function(newGridConfig) {
                    console.log("ConfigEditor: received configChanged signal", JSON.stringify(newGridConfig));
                    configManager.updateGridConfig(newGridConfig);
                });
            }
        }
    }

    function initConfigEditor(dynamicName,configData) {
        dynamicNameText = dynamicName?dynamicName:"";
        if (configData && configData!="" && configData.trim().length>0) {
            configManager.initializeFromJson(configData); 
        }else{
            configManager.resetConfig();
        }
        
        // 强制更新所有组件
        Qt.callLater(function() {
            if (gridConfigPanelLoader.item && configManager) {
                gridConfigPanelLoader.item.gridConfig = configManager.currentConfig.grid;
            }
            if (gridPreviewLoader.item && configManager) {
                gridPreviewLoader.item.controls = configManager.currentConfig.controls;
                gridPreviewLoader.item.gridConfig = configManager.currentConfig.grid;
                gridPreviewLoader.item.refresh();
            }
        });
    }

    property var configManager: configManagerLoader.item // 配置管理器实例的引用，方便其他组件访问

    // 配置管理器加载完成后的初始化连接器
    Connections {
        // 信号连接器，用于监听配置管理器的加载完成事件
        target: configManagerLoader                     // 监听目标：配置管理器加载器
        function onLoaded() {                           // 当配置管理器加载完成时执行的函数
            // 初始化网格配置面板
            if (gridConfigPanelLoader.item && configManager) {
                // 如果网格配置面板和配置管理器都已加载
                gridConfigPanelLoader.item.gridConfig = configManager.currentConfig.grid; // 设置面板的初始网格配置

            }
            // 初始化网格预览组件
            if (gridPreviewLoader.item && configManager) {
                // 如果网格预览组件和配置管理器都已加载
                gridPreviewLoader.item.controls = configManager.currentConfig.controls;   // 设置预览组件的控件列表
                gridPreviewLoader.item.gridConfig = configManager.currentConfig.grid;     // 设置预览组件的网格配置
                gridPreviewLoader.item.refresh();      // 刷新预览组件显示
                // 重新连接GridPreview的交互信号（点击、右键等）
                connectGridPreviewSignals();            // 调用信号连接函数
            }

            // 初始化控件编辑对话框
            if (editDialogLoader.item && configManager) {
                // 如果编辑对话框和配置管理器都已加载
                editDialogLoader.item.gridConfig = configManager.currentConfig.grid; // 设置对话框的网格配置
            }
        }
    }

    /**
     * 连接网格预览组件的交互信号
     * 处理用户在预览区域的点击和右键操作
     */
    function connectGridPreviewSignals() {             // 连接网格预览信号的函数
        if (gridPreviewLoader.item && configManager) {
            // 确保预览组件和配置管理器都已加载
            // 连接左键点击信号（用于编辑控件）
            gridPreviewLoader.item.controlClicked.connect(function (row, col, control) { // 监听控件左键点击事件
                if (control) {
                    // 如果点击的位置有控件
                    var index = configManager.getControlIndex(control); // 获取控件在列表中的索引
                    if (index >= 0) {
                        // 如果找到了控件索引
                        // 打开控件编辑对话框
                        if (editDialog) {
                            // 如果编辑对话框已加载
                            editDialog.editIndex = index;              // 设置要编辑的控件索引
                            // 深拷贝控件配置，避免引用问题导致事件被覆盖
                            var deepCopy = JSON.parse(JSON.stringify(control));
                            editDialog.editConfig = deepCopy;
                            editDialog.gridConfig = configManager.currentConfig.grid; // 设置网格配置
                            editDialog.open();          // 打开编辑对话框
                        }
                    }
                }
            });

            // 连接右键点击信号（用于删除控件）
            gridPreviewLoader.item.controlRightClicked.connect(function (row, col, control) { // 监听控件右键点击事件
                if (control) {
                    // 如果右键点击的位置有控件
                    configManager.removeControlAtPosition(row, col); // 删除指定位置的控件
                }
            });
        }
    }

    // 延迟信号连接定时器，确保所有组件都已完全加载后再连接信号
    Timer {                                             // 定时器组件
        id: signalConnectionTimer                       // 信号连接定时器的唯一标识符
        interval: 100                                   // 延迟100毫秒执行
        onTriggered: {
            // 定时器触发时执行的函数
            connectGridPreviewSignals();                // 连接网格预览组件的交互信号
        }
    }

    // 主界面容器，包含所有配置编辑界面元素
    Rectangle {
        // 主背景容器
        anchors.fill: parent                            // 填充整个父容器
        color: "#f0f0f0"                               // 设置浅灰色背景

        // 滚动视图，支持内容超出时的滚动显示
        ScrollView {
            // 滚动视图容器
            anchors.fill: parent                        // 填充整个背景容器
            anchors.margins: 20                         // 设置20像素的外边距
            clip: true                                  // 启用内容裁剪，超出部分不显示

            // 垂直布局列，包含所有配置面板
            Column {
                // 垂直列布局
                width: parent.width                     // 宽度填充父容器
                spacing: 20                             // 子元素间距20像素

                // 应用程序标题栏
                Rectangle {
                    // 标题栏背景容器
                    width: parent.width - 20                 // 宽度填充父容器
                    height: 60                          // 固定高度60像素
                    color: "#667eea"                    // 设置蓝紫色背景
                    radius: 8                           // 设置8像素圆角

                    Item {
                        anchors.fill: parent
                        anchors.margins: 10

                        Button{
                            text: "返回列表"
                            anchors.left: parent.left
                            anchors.leftMargin: 10
                            anchors.verticalCenter: parent.verticalCenter
                            onClicked: {
                                loaderInstanceRef.configEditorLoader.visible = false;
                                loaderInstanceRef.dynamicListLoadingLoader.visible = true;
                                stackViewRef.pop();
                            }
                        }
                        Text {
                            // 标题文本
                            anchors.centerIn: parent        // 居中显示
                            text: "动态表单配置编辑器"      // 标题文字
                            color: "white"                  // 白色文字
                            font.pixelSize: 20              // 字体大小20像素
                            font.bold: true                 // 粗体显示
                        }
                    }
                }

                Rectangle {
                    id: dynamicBasicConfig
                    width: parent.width - 20                 // 宽度填充父容器
                    height: dynamicBasicConfig.item ? Math.max(100, dynamicBasicConfig.item.gridPreviewHeight + 10) : 100                          // 固定高度60像素
                    color: "#ffffff"                    // 白色背景
                    border.color: "#dee2e6"             // 浅灰色边框
                    border.width: 1                     // 1像素边框宽度
                    radius: 8                           // 8像素圆角
                    Column {
                        // 垂直列布局
                        anchors.fill: parent            // 填充整个预览容器
                        anchors.margins: 15             // 15像素内边距
                        spacing: 10                     // 子元素间距10像素
                        Text {
                            // 标题文本
                            text: "表单配置"            // 标题内容
                            font.pixelSize: 16          // 字体大小16像素
                            font.bold: true             // 粗体显示
                        }
                        Row {
                            spacing: 20
                            Text {
                                text: "表单名称"
                            }
                            TextField {
                                id: dynamicName
                                text: dynamicNameText
                                implicitHeight: 35
                                implicitWidth: 300
                                verticalAlignment: TextInput.AlignVCenter

                                // 自定义背景
                                background: Rectangle {
                                    id: bg
                                    color: "white"
                                    border.color: "lightgray"
                                    border.width: 1
                                    radius: 4
                                }
                                onEditingFinished: {
                                    if (text.trim() === "") {
                                        bg.border.color = "red";
                                    } else {
                                        bg.border.color = "lightgray";
                                    }
                                }
                            }
                        }
                    }
                }

                // 网格配置面板加载器
                Loader {                                // 动态加载网格配置面板
                    id: gridConfigPanelLoader           // 网格配置面板加载器标识符
                    width: parent.width - 20                // 宽度填充父容器
                    height: 280                         // 固定高度280像素
                    source: "panels/GridConfigPanel.qml" // 网格配置面板组件文件路径
                    onLoaded: {
                        // 面板加载完成时的回调函数
                        console.log("ConfigEditor: GridConfigPanel loaded");

                        if (configManager) {
                            // 如果配置管理器已加载
                            console.log("ConfigEditor: Connecting configChanged signal (from GridConfigPanel.onLoaded)");
                            item.gridConfig = configManager.currentConfig.grid; // 设置面板的初始网格配置
                            
                            // 连接网格配置变化信号
                            item.configChanged.connect(function(newGridConfig) {
                                console.log("ConfigEditor: received configChanged signal (from GridConfigPanel.onLoaded)", JSON.stringify(newGridConfig));
                                configManager.updateGridConfig(newGridConfig);
                            });
                            console.log("ConfigEditor: Signal connected successfully");
                        } else {
                            console.log("ConfigEditor: configManager not available! Will connect later.");
                        }
                    }
                }

                // 控件工具栏加载器
                Loader {                                // 动态加载控件工具栏
                    id: controlToolbarLoader            // 控件工具栏加载器标识符
                    width: parent.width                // 宽度填充父容器
                    height: 120                         // 固定高度120像素
                    source: "panels/ControlToolbar.qml" // 控件工具栏组件文件路径
                    onLoaded: {
                        // 工具栏加载完成时的回调函数
                        // 连接控件请求信号，当用户点击工具栏按钮时添加对应类型的控件
                        item.controlRequested.connect(function (type) { // 监听控件添加请求
                            if (configManager) {
                                // 如果配置管理器已准备好
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
                    
                    onHeightChanged: {
                        console.log("ConfigEditor: previewContainer height changed to", height);
                    }

                    // 预览区域内容布局
                    Column {
                        // 垂直列布局
                        anchors.fill: parent            // 填充整个预览容器
                        anchors.margins: 15             // 15像素内边距
                        spacing: 10                     // 子元素间距10像素

                        // 预览区域标题
                        Text {
                            // 标题文本
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
                            onLoaded: {
                                // 预览组件加载完成时的回调函数
                                if (configManager) {
                                    // 如果配置管理器已准备好
                                    item.gridConfig = configManager.currentConfig.grid;   // 设置网格配置
                                    item.controls = configManager.currentConfig.controls; // 设置控件列表
                                    item.refresh();     // 刷新预览显示
                                    // 延迟连接交互信号，确保所有组件都已完全加载
                                    signalConnectionTimer.start(); // 启动信号连接定时器
                                } else {
                                    // 如果配置管理器还未准备好，使用默认配置
                                    var defaultConfig = {
                                        // 默认网格配置
                                        "rows": 4,
                                        "columns": 2,
                                        "rowSpacing": 5,
                                        "columnSpacing": 10,
                                        "rowHeights": [1, 1, 1, 2],
                                        "columnWidths": [1, 2]
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
                Rectangle {
                    // 按钮区域背景容器
                    width: parent ? parent.width - 40 : 400 // 宽度：父容器宽度减去40像素边距，或默认400像素
                    height: 80                          // 恢复到80像素高度
                    anchors.horizontalCenter: parent ? parent.horizontalCenter : undefined // 水平居中对齐
                    color: "#f8f9fa"                    // 浅灰色背景
                    border.color: "#dee2e6"             // 浅灰色边框
                    border.width: 1                     // 1像素边框宽度
                    radius: 8                           // 8像素圆角

                    // 按钮水平布局
                    Row {
                        // 水平行布局
                        anchors.centerIn: parent        // 在父容器中居中显示
                        spacing: 15                     // 按钮间距15像素

                        // 导出配置按钮
                        Button {
                            // 导出配置按钮
                            text: "提交表单配置"            // 按钮文本
                            onClicked: {
                                // 按钮点击事件处理
                                if (dynamicName.text == "" || !dynamicName.text) {
                                    MessageManager.showToast("表单名称不能为空！", "error");
                                    return;
                                }

                                if (configManager) {
                                    // 如果配置管理器已准备好
                                    var jsonString = configManager.exportConfig();
                                    var data = ({
                                            dynamicConfig: jsonString,
                                            dynamicName: dynamicName.text
                                        });
                                    try {
                                        var result = MySqlHelper.insert("dynamicForm", data);
                                        if (result) {
                                            MessageManager.showDialog("表单配置提交成功！", "success", function () {
                                                dynamicName.text = "";
                                                configManager.resetConfig();
                                                loaderInstanceRef.configEditorLoader.visible = false;
                                                loaderInstanceRef.dynamicListLoadingLoader.visible = true;
                                                loaderInstanceRef.dynamicListLoadingLoader.item.getData();
                                                stackViewRef.pop();
                                            });
                                        } else {
                                            MessageManager.showToast("提交表单配置失败，请检查数据库连接和表结构", "error");
                                        }
                                    } catch (e) {
                                        MessageManager.showToast("提交表单配置失败: " + e, "error", null);
                                    }
                                }
                            }
                        }

                        // 重置配置按钮
                        Button {
                            // 重置配置按钮
                            text: "重置配置"            // 按钮文本
                            onClicked: {
                                // 按钮点击事件处理
                                if (configManager) {
                                    // 如果配置管理器已准备好
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
        asynchronous: true                          // 异步加载
        active: true                                // 立即加载

        onLoaded: {
            // 对话框加载完成时的回调函数
            if (item) {
                // 如果对话框组件已成功加载
                if (configManager) {
                    // 如果配置管理器已准备好
                    item.gridConfig = configManager.currentConfig.grid; // 设置对话框的网格配置
                }
                // 连接控件保存信号，当用户在对话框中保存控件配置时更新配置管理器
                item.controlSaved.connect(function (index, config) { // 监听控件保存事件
                    if (configManager) {
                        // 如果配置管理器已准备好
                        configManager.updateControl(index, config); // 更新指定索引的控件配置
                    }
                });
            }
        }
    }

    // 编辑对话框别名属性，提供向后兼容性和便捷访问
    property alias editDialog: editDialogLoader.item // 创建editDialog别名，指向加载的对话框实例

}
