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

    Component.onCompleted: {
        // Instantiate tabs for background loading/state preservation
        var a = configEditorTab.createObject(root);
        var b = formPreviewTab.createObject(root);
        var c = generatorTab.createObject(root);
        MessageManager.registerRootItem(root);
    }

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

    Component {
        id: homeComponent
        Home {
            onNavigate: target => {
                console.log("Navigating to:", target);
                if (target === "generator") {
                    if (root.loaderInstance.generatorLoader) {
                        root.loaderInstance.generatorLoader.visible = true;
                        stackView.push(root.loaderInstance.generatorLoader.parent);
                    }
                } else if (target === "config") {
                    if (root.loaderInstance.configEditorLoader) {
                        root.loaderInstance.configEditorLoader.visible = true;
                        stackView.push(root.loaderInstance.configEditorLoader.parent);
                    }
                } else if (target === "list") {
                    stackView.push(dynamicListLoadingTab);
                }
            }
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
}
