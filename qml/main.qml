import QtQuick 6.5
import QtQuick.Controls 6.5
import QtQuick.Layouts 1.4
import Common 1.0
/**
 * 动态表单主组件
 * 职责：界面布局和组件协调
 */
Item  {
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
        var a = configEditorTab.createObject(root);
        var b = formPreviewTab.createObject(root);
        MessageManager.registerRootItem(root);
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
            Loader {
                id: dynamicListLoadingLoader
                width: parent.width
                height: parent.height
                source: "dynamic/dynamicList.qml"
                onLoaded: {
                    root.loaderInstance.dynamicListLoadingLoader = dynamicListLoadingLoader;
                    item.stackViewRef = stackView;
                    item.loaderInstanceRef = root.loaderInstance;
                    
                    root.editorLoaded.connect(function (loader) {
                        item.loaderInstanceRef.configEditorLoader = loader;
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
            Loader {
                id: formPreviewLoader
                width: parent.width
                height: parent.height
                source: "render/FormPreview.qml"
                asynchronous: true
                active: true
                visible: false
                onLoaded: {
                    root.loaderInstance.formPreviewLoader = formPreviewLoader;
                    item.formConfig = root.formConfig;
                    item.controlsMap = root.controlsMap;
                    item.stackViewRef = stackView;
                    item.loaderInstanceRef = root.loaderInstance;
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
                    item.stackViewRef = stackView;
                    item.loaderInstanceRef = root.loaderInstance;
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
                visible: false       // 不显示
                onLoaded: {
                    root.loaderInstance.configEditorLoader = configEditorLoader;
                    root.editorLoaded(configEditorLoader);
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
