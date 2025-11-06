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
    
    Component.onCompleted: {
    }
    
    // Tab视图
    TabBar {
        id: tabBar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 40
        
        TabButton {
            text: "表单预览"
        }
        TabButton {
            text: "配置编辑器"
        }
    }
    
    StackLayout {
        id: stackLayout
        anchors.top: tabBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        currentIndex: tabBar.currentIndex
        
        // Tab 1: 表单预览
        Item {
            id: formPreviewTab
            
            Loader {
                id: formPreviewLoader
                anchors.fill: parent
                source: "render/FormPreview.qml"
                onLoaded: {
                    item.formConfig = root.formConfig
                    item.controlsMap = root.controlsMap
                }
            }
        }
        
        // Tab 2: 配置编辑器
        Item {
            id: configEditorTab
            
            Loader {
                id: configEditorLoader
                anchors.fill: parent
                source: "config/ConfigEditor.qml"
                onLoaded: {
                    // 只有在用户主动应用配置时才更新表单预览
                    item.configChanged.connect(function(newConfig) {
                        root.formConfig = newConfig
                        if (formPreviewLoader.item) {
                            formPreviewLoader.item.formConfig = newConfig
                            formPreviewLoader.item.reloadForm()
                        }
                    })
                }
            }
        }
    }
    
}