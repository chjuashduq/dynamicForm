import QtQuick 6.5
import QtQuick.Controls 6.5
import QtQuick.Layouts 1.4
import "." as Config

/**
 * 动态表单配置编辑器 (重构版)
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
Item {
    id: configEditor

    anchors.fill: parent
    width: parent ? parent.width : 800
    height: parent ? parent.height : 600

    signal configChanged(var newConfig)

    Loader {
        id: configManagerLoader
        source: "ConfigManager.qml"
        onLoaded: {
            // 监听内部配置变化（用于更新预览）
            item.internalConfigChanged.connect(function (newConfig) {
                if (gridPreviewLoader.item) {
                    gridPreviewLoader.item.controls = newConfig.controls;
                    gridPreviewLoader.item.gridConfig = newConfig.grid;
                    gridPreviewLoader.item.refresh();
                }
            });

            // 监听外部配置变化（用于应用配置）
            item.configChanged.connect(function (newConfig) {
                configEditor.configChanged(newConfig);
            });
        }
    }

    property var configManager: configManagerLoader.item

    Component.onCompleted: {
        console.log("ConfigEditor initialized");
    }

    // 当configManager加载完成后初始化其他组件
    Connections {
        target: configManagerLoader
        function onLoaded() {
            console.log("ConfigManager loaded");

            // 配置编辑器使用默认配置，不加载外部form_config.json
            console.log("ConfigManager using default config for editor");

            // 初始化网格配置面板
            if (gridConfigPanelLoader.item && configManager) {
                console.log("Initializing GridConfigPanel with:", JSON.stringify(configManager.currentConfig.grid));
                gridConfigPanelLoader.item.gridConfig = configManager.currentConfig.grid;
                // 确保信号连接
                gridConfigPanelLoader.item.configChanged.connect(function (newConfig) {
                    console.log("GridConfigPanel configChanged received (delayed):", JSON.stringify(newConfig));
                    configManager.updateGridConfig(newConfig);
                });
            }
            // 初始化网格预览
            if (gridPreviewLoader.item && configManager) {
                gridPreviewLoader.item.controls = configManager.currentConfig.controls;
                gridPreviewLoader.item.gridConfig = configManager.currentConfig.grid;
                // 重新连接GridPreview的信号
                connectGridPreviewSignals();
            }
            
            // 初始化编辑对话框
            if (editDialogLoader.item && configManager) {
                editDialogLoader.item.gridConfig = configManager.currentConfig.grid;
                console.log("EditDialog gridConfig updated after ConfigManager loaded");
            }
        }
    }

    // 连接GridPreview信号的函数
    function connectGridPreviewSignals() {
        if (gridPreviewLoader.item && configManager) {
            console.log("Connecting GridPreview signals");

            // 连接左键点击信号（编辑控件）
            try {
                gridPreviewLoader.item.controlClicked.connect(function (row, col, control) {
                    console.log("GridPreview controlClicked signal received:", row, col, control ? control.label : "null");
                    if (control) {
                        var index = configManager.getControlIndex(control);
                        console.log("Control index found:", index);
                        if (index >= 0) {
                            // 直接打开编辑对话框
                            console.log("Opening edit dialog for control:", control.label);
                            if (editDialog) {
                                editDialog.editIndex = index;
                                editDialog.editConfig = control;
                                editDialog.gridConfig = configManager.currentConfig.grid;
                                editDialog.open();
                                console.log("Edit dialog opened successfully");
                            } else {
                                console.log("Edit dialog not loaded yet");
                            }
                        }
                    }
                });
                console.log("Successfully connected controlClicked signal");
            } catch (e) {
                console.log("Failed to connect controlClicked signal:", e);
            }

            // 连接右键点击信号（删除控件）
            try {
                gridPreviewLoader.item.controlRightClicked.connect(function (row, col, control) {
                    console.log("GridPreview controlRightClicked signal received:", row, col, control ? control.label : "null");
                    if (control) {
                        configManager.removeControlAtPosition(row, col);
                        console.log("Control removed at position:", row, col);
                    }
                });
                console.log("Successfully connected controlRightClicked signal");
            } catch (e) {
                console.log("Failed to connect controlRightClicked signal:", e);
            }
        } else {
            console.log("Cannot connect GridPreview signals - components not ready");
            console.log("gridPreviewLoader.item:", !!gridPreviewLoader.item);
            console.log("configManager:", !!configManager);
        }
    }

    // 延迟连接信号的定时器
    Timer {
        id: signalConnectionTimer
        interval: 100
        onTriggered: {
            console.log("Attempting delayed signal connection");
            connectGridPreviewSignals();
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "#f0f0f0"
        
        ScrollView {
            anchors.fill: parent
            anchors.margins: 20
            clip: true
            
            Column {
                width: parent.width
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

                // 网格配置面板
                Loader {
                    id: gridConfigPanelLoader
                    width: parent.width
                    height: 280
                    source: "GridConfigPanel.qml"
                    onLoaded: {
                        console.log("GridConfigPanel loaded");
                        // 总是连接信号，即使configManager还没准备好
                        item.configChanged.connect(function (newConfig) {
                            console.log("GridConfigPanel configChanged received:", JSON.stringify(newConfig));
                            if (configManager) {
                                configManager.updateGridConfig(newConfig);
                            } else {
                                console.log("ConfigManager not ready, storing config for later");
                            }
                        });

                        if (configManager) {
                            console.log("Setting initial gridConfig:", JSON.stringify(configManager.currentConfig.grid));
                            item.gridConfig = configManager.currentConfig.grid;
                        }
                    }
                }

                // 控件工具栏
                Loader {
                    id: controlToolbarLoader
                    width: parent.width
                    height: 120
                    source: "ControlToolbar.qml"
                    onLoaded: {
                        item.controlRequested.connect(function (type) {
                            console.log("添加控件:", type);
                            if (configManager) {
                                configManager.addControl(type);
                            }
                        });
                    }
                }

                // 控件预览区域
                Rectangle {
                    width: parent ? parent.width - 40 : 400
                    height: Math.max(200, (gridPreviewLoader.item ? gridPreviewLoader.item.height + 60 : 400))
                    anchors.horizontalCenter: parent ? parent.horizontalCenter : undefined
                    color: "#ffffff"
                    border.color: "#dee2e6"
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

                        Loader {
                            id: gridPreviewLoader
                            width: parent.width - 20
                            height: 500
                            source: "GridPreview.qml"
                            onLoaded: {
                                console.log("GridPreview loaded successfully");
                                if (configManager) {
                                    console.log("Setting initial gridConfig:", JSON.stringify(configManager.currentConfig.grid));
                                    item.gridConfig = configManager.currentConfig.grid;
                                    item.controls = configManager.currentConfig.controls;
                                    item.refresh();
                                    // 延迟连接信号，确保所有组件都准备好
                                    signalConnectionTimer.start();
                                } else {
                                    console.log("ConfigManager not ready when GridPreview loaded");
                                }
                            }
                        }
                    }
                }

                // 操作按钮区域
                Rectangle {
                    width: parent ? parent.width - 40 : 400
                    height: 80
                    anchors.horizontalCenter: parent ? parent.horizontalCenter : undefined
                    color: "#f8f9fa"
                    border.color: "#dee2e6"
                    border.width: 1
                    radius: 8

                    Row {
                        anchors.centerIn: parent
                        spacing: 15

                        Button {
                            text: "应用配置"
                            onClicked: {
                                if (configManager) {
                                    console.log("Apply config button clicked");
                                    configChanged(configManager.currentConfig);
                                }
                            }
                        }

                        Button {
                            text: "导出配置"
                            onClicked: {
                                if (configManager) {
                                    var jsonString = configManager.exportConfig();
                                    console.log("导出配置:", jsonString);
                                }
                            }
                        }

                        Button {
                            text: "重置配置"
                            onClicked: {
                                if (configManager) {
                                    configManager.resetConfig();
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // 控件编辑对话框 - 使用Loader动态加载
    Loader {
        id: editDialogLoader
        source: "dialog/ControlEditDialog.qml"

        onLoaded: {
            console.log("EditDialog loaded via Loader");
            if (item) {
                if (configManager) {
                    item.gridConfig = configManager.currentConfig.grid;
                }
                item.controlSaved.connect(function (index, config) {
                    console.log("ControlEditDialog controlSaved signal received with index:", index);
                    console.log("ControlEditDialog controlSaved signal received with config:", JSON.stringify(config));
                    if (configManager) {
                        configManager.updateControl(index, config);
                    } else {
                        console.log("ConfigManager not available when controlSaved received");
                    }
                });
                console.log("ControlEditDialog signal connected successfully");
            } else {
                console.log("EditDialog item not available");
            }
        }
    }

    // 提供editDialog别名以保持兼容性
    property alias editDialog: editDialogLoader.item
}
