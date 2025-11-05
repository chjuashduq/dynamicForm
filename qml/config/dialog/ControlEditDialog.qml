import QtQuick 6.5
import QtQuick.Controls 6.5
import QtQuick.Layouts 1.4

/**
 * 控件编辑对话框 (重构版)
 * 负责单个控件的详细配置编辑
 */
Dialog {
    id: editDialog
    title: "编辑控件"
    width: 800
    height: 700
    anchors.centerIn: Overlay.overlay
    modal: true

    property int editIndex: -1
    property var editConfig: ({})
    property var gridConfig: ({})
    
    signal controlSaved(int index, var config)

    property var typeManagerLoader: Loader {
        source: "../ControlTypeManager.qml"
    }
    property var typeManager: typeManagerLoader.item

    Component.onCompleted: {
        console.log("ControlEditDialog Component.onCompleted");
    }
    
    onOpened: {
        console.log("ControlEditDialog opened with editConfig:", JSON.stringify(editConfig));
        console.log("Dialog size:", width, "x", height);
        refreshFields();
    }
    
    onEditConfigChanged: {
        console.log("EditConfig changed:", JSON.stringify(editConfig));
        refreshFields();
    }

    ScrollView {
        anchors.fill: parent
        anchors.margins: 20
        clip: true

        Column {
            width: 700
            spacing: 20

            // 基本属性面板
            BasicPropertiesPanel {
                id: basicPropertiesPanel
                width: parent.width
                editConfig: editDialog.editConfig
                gridConfig: editDialog.gridConfig
            }

            // 类型特定属性
            GroupBox {
                title: "类型特定属性"
                width: parent.width
                visible: typeSpecificLoader.source !== ""

                Loader {
                    id: typeSpecificLoader
                    width: parent.width
                    source: getTypeSpecificComponent()
                    
                    function getTypeSpecificComponent() {
                        if (!typeManager || !typeManager.hasTypeSpecificProps(editConfig.type)) {
                            return "";
                        }
                        return "../ControlTypeEditor.qml";
                    }
                    
                    onLoaded: {
                        if (item) {
                            item.controlConfig = editConfig;
                        }
                    }
                }
            }

            // 事件配置面板
            EventConfigPanel {
                id: eventConfigPanel
                width: parent.width
                editConfig: editDialog.editConfig
                typeManager: editDialog.typeManager
                
                onEventEditRequested: function(eventType, currentCode) {
                    if (eventType === "focusLost") {
                        functionHelpDialog.showFocusLostHelp(currentCode);
                    } else if (eventType === "change") {
                        functionHelpDialog.showChangeEventHelp(editConfig.type, currentCode);
                    }
                }
            }
        }
    }

    standardButtons: Dialog.Ok | Dialog.Cancel

    onAccepted: {
        var newConfig = buildControlConfig();
        console.log("ControlEditDialog onAccepted - emitting controlSaved signal with index:", editIndex);
        controlSaved(editIndex, newConfig);
    }
    
    function buildControlConfig() {
        console.log("Building control config...");
        
        var newConfig = {
            "type": editConfig.type
        };

        // 获取基本属性
        var basicConfig = basicPropertiesPanel.getConfig();
        for (var key in basicConfig) {
            newConfig[key] = basicConfig[key];
        }

        console.log("Basic config built:", JSON.stringify(newConfig));

        // 添加类型特定属性
        if (typeSpecificLoader.item && typeSpecificLoader.item.getTypeSpecificConfig) {
            var typeConfig = typeSpecificLoader.item.getTypeSpecificConfig();
            console.log("Type specific config:", JSON.stringify(typeConfig));
            for (var key in typeConfig) {
                newConfig[key] = typeConfig[key];
            }
        } else {
            console.log("No type specific loader or getTypeSpecificConfig function");
        }

        // 添加事件配置 - 保持原有的事件配置
        if (editConfig.events) {
            newConfig.events = editConfig.events;
        }

        console.log("Final config built:", JSON.stringify(newConfig));
        return newConfig;
    }
    
    function refreshFields() {
        if (!editConfig) return;
        
        console.log("Refreshing fields with config:", JSON.stringify(editConfig));
        
        // 刷新基本属性面板
        basicPropertiesPanel.editConfig = editConfig;
        
        // 刷新事件配置面板
        eventConfigPanel.editConfig = editConfig;
        
        // 刷新类型特定属性
        if (typeSpecificLoader.item) {
            typeSpecificLoader.item.controlConfig = editConfig;
        }
    }

    // 函数编写对话框
    FunctionHelpDialog {
        id: functionHelpDialog
        
        onFunctionSaved: function(eventType, code) {
            eventConfigPanel.updateEvent(eventType, code);
        }
    }
}