import QtQuick 6.5
import QtQuick.Controls 6.5
import QtQuick.Layouts 1.4

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

    property var editorLoaderInstance: null

    signal editorLoaded(var loader)

    Component.onCompleted: {
        var a = configEditorTab.createObject(root);
    }

    StackView {
        id: stackView
        anchors.fill: parent
        initialItem: dynamicListLoadingTab
    }
    Component {
        id: dynamicListLoadingTab
        Item {
            // 页面根节点
            width: parent.width
            height: parent.height
            Loader {
                id: dynamicListLoadingLoader
                anchors.fill: parent
                source: "dynamic/dynamicList.qml"
                onLoaded: {
                    item.stackViewRef = stackView;
                    item.configEditorLoaderRef = root.editorLoaderInstance;
                    item.dynamicListLoadingLoader = dynamicListLoadingLoader;
                    root.editorLoaded.connect(function (loader) {
                        item.configEditorLoaderRef = loader;
                    });
                }
            }
        }
    }
    // Tab 1: 表单预览
    Component {
        id: formPreviewTab
        Item {
            // 页面根节点
            width: parent.width
            height: parent.height
            Loader {
                id: formPreviewLoader
                anchors.fill: parent
                source: "render/FormPreview.qml"
                onLoaded: {
                    item.formConfig = root.formConfig;
                    item.controlsMap = root.controlsMap;
                }
            }
        }
    }

    // Tab 2: 配置编辑器
    Component {
        id: configEditorTab
        Item {
            // 页面根节点
            width: parent.width
            height: parent.height
            Loader {
                id: configEditorLoader
                anchors.fill: parent
                source: "config/ConfigEditor.qml"
                asynchronous: true   // 异步加载
                active: true        // 始终加载（后台加载）
                visible: false       // 不显示
                onLoaded: {
                    root.editorLoaderInstance = configEditorLoader;
                    root.editorLoaded(configEditorLoader);
                    // 只有在用户主动应用配置时才更新表单预览
                    item.configChanged.connect(function (newConfig) {
                        root.formConfig = newConfig;
                        if (formPreviewLoader.item) {
                            formPreviewLoader.item.formConfig = newConfig;
                            formPreviewLoader.item.reloadForm();
                        }
                    });
                }
            }
        }
    }
}
