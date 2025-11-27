import QtQuick 6.5
import QtQuick.Controls 6.5
import QtQuick.Layouts 1.4
import Common 1.0

/**
 * 动态表单主组件
 * 职责：界面布局和组件协调
 */
Item {
    id: root
    width: 800
    height: 600

    // 从外部JSON解析表单配置
    property var formConfig: JSON.parse(formJson)

    // 控件映射表
    property var controlsMap: ({})

    property var loaderInstance: ({})

    signal editorLoaded(var loader)

    StackView {
        id: stackView
        anchors.fill: parent
        initialItem: homeComponent
        pushEnter: Transition {
            PropertyAnimation {
                property: "opacity"
                from: 0
                to: 1
                duration: 200
            }
        }
        pushExit: Transition {
            PropertyAnimation {
                property: "opacity"
                from: 1
                to: 0
                duration: 200
            }
        }
        popEnter: Transition {
            PropertyAnimation {
                property: "opacity"
                from: 0
                to: 1
                duration: 200
            }
        }
        popExit: Transition {
            PropertyAnimation {
                property: "opacity"
                from: 1
                to: 0
                duration: 200
            }
        }
    }

    // Top Bar for Navigation
    Rectangle {
        id: topBar
        width: parent.width
        height: 40
        color: "white"
        z: 100
        visible: stackView.depth > 1

        // Shadow
        Rectangle {
            anchors.bottom: parent.bottom
            width: parent.width
            height: 1
            color: "#e8e8e8"
        }

        Button {
            text: "← 返回首页"
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 10
            height: 32

            background: Rectangle {
                color: "transparent"
                border.width: 0
            }

            contentItem: Text {
                text: parent.text
                color: parent.hovered ? "#1890ff" : "#666"
                font.pixelSize: 14
                verticalAlignment: Text.AlignVCenter
            }

            onClicked: stackView.pop()
        }
    }

    // Adjust StackView to be below topBar when visible
    // Since StackView fills parent, we can use top margin binding
    Binding {
        target: stackView
        property: "anchors.topMargin"
        value: topBar.visible ? topBar.height : 0
    }

    property var dynamicRoutes: (
        // "sys_user": "pages/SysUserList.qml"
        {})

    function navigateTo(target) {
        console.log("Navigating to:", target);

        // 1. Static/System Routes (Keep-Alive)
        var staticRoutes = {
            "generator": root.loaderInstance.generatorLoader,
            "config": root.loaderInstance.configEditorLoader,
            "db_tables": root.loaderInstance.dbTableListLoader
        };

        if (staticRoutes[target]) {
            var loader = staticRoutes[target];
            if (loader) {
                loader.visible = true;
                stackView.push(loader.parent);
            } else {
                console.error("Loader not ready for:", target);
            }
            return;
        }

        // 2. Special Cases
        if (target === "list") {
            stackView.push(dynamicListLoadingTab);
            return;
        }

        // 3. Dynamic Routes (URL or Map)
        if (root.dynamicRoutes[target]) {
            stackView.push(Qt.resolvedUrl(root.dynamicRoutes[target]));
            return;
        }

        // 4. Direct Path
        if (target.indexOf("/") >= 0) {
            stackView.push(Qt.resolvedUrl(target));
            return;
        }

        console.warn("Unknown route:", target);
    }

    Component {
        id: homeComponent
        Home {
            onNavigate: target => root.navigateTo(target)
        }
    }

    Component {
        id: dynamicListLoadingTab
        Item {
            // 页面根节点
            Loader {
                id: dynamicListLoadingLoader
                width: parent.width
                height: parent.height
                source: "dynamic/dynamicList.qml"
                onLoaded: {
                    root.loaderInstance.dynamicListLoadingLoader = dynamicListLoadingLoader;
                    if (item) {
                        item.stackViewRef = stackView;
                        item.loaderInstanceRef = root.loaderInstance;

                        root.editorLoaded.connect(function (loader) {
                            item.loaderInstanceRef.configEditorLoader = loader;
                        });
                    }
                }
            }
        }
    }
    // Tab 1: 表单预览
    Component {
        id: formPreviewTab
        Item {
            // 页面根节点
            Loader {
                id: formPreviewLoader
                width: parent.width
                height: parent.height
                source: "render/FormPreview.qml"
                asynchronous: true
                active: true
                visible: false // Managed by navigation
                onLoaded: {
                    root.loaderInstance.formPreviewLoader = formPreviewLoader;
                    if (item) {
                        item.formConfig = root.formConfig;
                        item.controlsMap = root.controlsMap;
                        item.stackViewRef = stackView;
                        item.loaderInstanceRef = root.loaderInstance;
                    }
                }
            }

            Loader {
                id: dataRecordListLoader
                width: parent.width
                height: parent.height
                source: "dynamic/dataRecordList.qml"
                asynchronous: true
                active: true
                visible: false
                onLoaded: {
                    root.loaderInstance.dataRecordListLoader = dataRecordListLoader;
                    if (item) {
                        item.stackViewRef = stackView;
                        item.loaderInstanceRef = root.loaderInstance;
                    }
                }
            }
        }
    }

    // Tab 2: 配置编辑器
    Component {
        id: configEditorTab
        Item {
            // 页面根节点
            Loader {
                id: configEditorLoader
                width: parent.width
                height: parent.height
                source: "config/ConfigEditor.qml"
                asynchronous: true   // 异步加载
                active: true        // 始终加载（后台加载）
                visible: false       // Managed by navigation
                onLoaded: {
                    root.loaderInstance.configEditorLoader = configEditorLoader;
                    root.editorLoaded(configEditorLoader);
                    if (item) {
                        item.stackViewRef = stackView;
                        item.loaderInstanceRef = root.loaderInstance;
                        // 连接配置管理器的信号
                        if (item.configManager) {
                            item.configManager.internalConfigChanged.connect(function (newConfig) {
                                root.formConfig = newConfig;
                                // 通过 loaderInstance 访问 formPreviewLoader
                                if (root.loaderInstance.formPreviewLoader && root.loaderInstance.formPreviewLoader.item) {
                                    root.loaderInstance.formPreviewLoader.item.formConfig = newConfig;
                                    root.loaderInstance.formPreviewLoader.item.reloadForm();
                                }
                            });
                        }
                    }
                }
            }
        }
    }

    // Tab 3: 代码生成器
    Component {
        id: generatorTab
        Item {
            Loader {
                id: generatorLoader
                width: parent.width
                height: parent.height
                source: "generator/FormGenerator.qml"
                asynchronous: true
                active: true
                visible: false // Managed by navigation
                onLoaded: {
                    root.loaderInstance.generatorLoader = generatorLoader;
                    // item.stackViewRef = stackView;
                }
            }
        }
    }

    // Tab 4: 数据库表列表
    Component {
        id: dbTableListTab
        Item {
            // StackView manages the size of this Item, so no anchors here.
            Loader {
                id: dbTableListLoader
                anchors.fill: parent // Loader fills the Item
                source: "database/DbTableList.qml"
                asynchronous: false // Disable async to debug
                active: true
                visible: false // Managed by navigation

                Component.onCompleted: {
                    console.log("dbTableListLoader created. Registering instance. Status:", status);
                    root.loaderInstance.dbTableListLoader = dbTableListLoader;
                }

                onLoaded: {
                    console.log("dbTableListLoader content loaded successfully");
                    if (item) {
                        item.editTable.connect(function (tableName) {
                            console.log("Edit table requested:", tableName);
                            if (root.loaderInstance.genEditLoader) {
                                var loader = root.loaderInstance.genEditLoader;
                                loader.visible = true;
                                if (loader.item) {
                                    loader.item.tableName = tableName;
                                } else {
                                    // If not loaded yet, set it when loaded
                                    loader.loaded.connect(function () {
                                        loader.item.tableName = tableName;
                                    });
                                }
                                stackView.push(loader.parent);
                            }
                        });
                    }
                }
                onStatusChanged: {
                    console.log("dbTableListLoader status changed to:", status);
                    if (status === Loader.Error) {
                        console.error("Error loading DbTableList.qml. Status:", status);
                        console.error("Source:", source);
                    }
                }
            }
        }
    }

    // Tab 5: 生成配置编辑
    Component {
        id: genEditTab
        Item {
            Loader {
                id: genEditLoader
                anchors.fill: parent
                source: "database/GenEdit.qml"
                asynchronous: false
                active: true
                visible: false

                Component.onCompleted: {
                    root.loaderInstance.genEditLoader = genEditLoader;
                }

                onLoaded: {
                    if (item) {
                        item.back.connect(function () {
                            stackView.pop();
                        });
                    }
                }
            }
        }
    }

    Component.onCompleted: {
        // Instantiate tabs for background loading/state preservation
        var a = configEditorTab.createObject(root);
        var b = formPreviewTab.createObject(root);
        var c = generatorTab.createObject(root);
        var d = dbTableListTab.createObject(root);
        var e = genEditTab.createObject(root);
        MessageManager.registerRootItem(root);
    }
}
