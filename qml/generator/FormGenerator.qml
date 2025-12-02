import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt.labs.folderlistmodel
import QtQuick.Dialogs

import "../utils"
import "../Common"
import "../components"
import "properties"
import "library"
import "logic/FormGeneratorLogic.js" as Logic
import "json/FormSerializer.js" as Serializer
import "../core"

Item {
    id: root
    objectName: "FormGeneratorRoot"
    anchors.fill: parent

    FormAPI { id: formAPI; scriptEngine: scriptEngine }
    ScriptEngine { id: scriptEngine; formAPI: formAPI }

    property alias formAPI: formAPI
    property alias scriptEngine: scriptEngine

    property var formModel: []
    property var selectedItem: null
    property bool previewMode: false
    property var componentGroups: undefined

    Component.onCompleted: {
        if (typeof componentJson !== "undefined") {
            componentGroups = JSON.parse(componentJson);
        } else {
            // Default fallback
            var defaultJson = '[{"group":"布局组件","items":[{"type":"StyledRow","label":"横向布局","icon":"▤"}]},{"group":"基础组件","items":[{"type":"StyledTextField","label":"文本输入","icon":"✎","supportFormConfig":true},{"type":"StyledSpinBox","label":"数字输入","icon":"123","supportFormConfig":true},{"type":"StyledDateTime","label":"日期时间","icon":"🕒","supportFormConfig":true},{"type":"StyledComboBox","label":"下拉选择","icon":"▼","supportFormConfig":true},{"type":"StyledButton","label":"按钮","icon":"ok"},{"type":"StyledLabel","label":"文本标签","icon":"T"}]}]';
            componentGroups = JSON.parse(defaultJson);
        }
    }

    // [保留] 仅返回代码字符串，不显示对话框
    function getGeneratedCode() {
        return Logic.generateCode(root);
    }

    function handleDrop(drop, targetParent, targetIndex) {
        Logic.handleDrop(drop, root, targetParent, targetIndex);
    }

    function deleteItem(item, parentList) {
        Logic.deleteItem(item, parentList, root);
    }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        // Left Panel
        Rectangle {
            Layout.preferredWidth: 250
            Layout.fillHeight: true
            visible: !root.previewMode
            gradient: Gradient { GradientStop { position: 0.0; color: "#f8f9fa" } GradientStop { position: 1.0; color: "#e9ecef" } }
            border.color: "#dee2e6"; border.width: 1

            ColumnLayout {
                anchors.fill: parent; anchors.margins: 15; spacing: 15
                Rectangle { Layout.fillWidth: true; height: 40; color: "#1890ff"; radius: 8; Text { anchors.centerIn: parent; text: "📦 组件库"; font.bold: true; font.pixelSize: 18; color: "white" } }
                ScrollView {
                    Layout.fillWidth: true; Layout.fillHeight: true; clip: true
                    Column {
                        width: parent.width; spacing: 12
                        Repeater {
                            model: componentGroups
                            delegate: Column {
                                width: parent.width; spacing: 10
                                Text { text: modelData.group; font.bold: true }
                                Flow {
                                    width: parent.width; spacing: 10
                                    Repeater {
                                        model: modelData.items
                                        delegate: DraggableComponent { componentType: modelData.type; label: modelData.label; icon: modelData.icon }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        // Center Panel
        Rectangle {
            Layout.fillWidth: true; Layout.fillHeight: true
            color: "white"

            RowLayout {
                id: toolbar; height: 40; width: parent.width; anchors.top: parent.top; spacing: 10
                Button { text: root.previewMode ? "退出预览" : "预览模式"; onClicked: { root.previewMode = !root.previewMode; if (root.previewMode) root.selectedItem = null; } }
                Button { text: "清空"; visible: !root.previewMode; onClicked: { root.formModel = []; root.selectedItem = null; } }
                // [移除] 所有生成/导出按钮
                Item { Layout.fillWidth: true }
            }

            ScrollView {
                anchors.top: toolbar.bottom; anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right
                Flickable {
                    id: canvasFlickable; anchors.fill: parent; contentHeight: canvasColumn.height + 100; contentWidth: width
                    Column {
                        id: canvasColumn; width: parent.width - 40; anchors.horizontalCenter: parent.horizontalCenter; spacing: 10
                        DropArea {
                            id: rootDropArea; width: parent.width; height: Math.max(canvasFlickable.height - 20, 500)
                            onDropped: drop => {
                                var targetIndex = -1;
                                var yPos = canvasContent.mapFromItem(rootDropArea, drop.x, drop.y).y;
                                var visualChildren = [];
                                for (var i = 0; i < canvasContent.children.length; i++) {
                                    var child = canvasContent.children[i];
                                    if (child.item && child.item.hasOwnProperty("itemData")) visualChildren.push(child);
                                }
                                for (var i = 0; i < visualChildren.length; i++) {
                                    var child = visualChildren[i];
                                    if (yPos < child.y + child.height / 2) { targetIndex = i; break; }
                                }
                                handleDrop(drop, null, targetIndex);
                            }
                            Rectangle {
                                anchors.fill: parent; color: "#f5f7fa"; border.color: "#e4e7ed"
                                Flow {
                                    id: canvasContent; width: parent.width - 40; anchors.top: parent.top; anchors.topMargin: 20; anchors.horizontalCenter: parent.horizontalCenter; spacing: 0; flow: Flow.LeftToRight
                                    Repeater {
                                        model: root.formModel
                                        delegate: Loader {
                                            width: { if(!modelData.props)return canvasContent.width; var t=modelData.props.layoutType; if(t==="fixed")return modelData.props.width||100; if(t==="percent")return(canvasContent.width-10)*((modelData.props.widthPercent||100)/100); return canvasContent.width; }
                                            source: "canvas/CanvasItem.qml"
                                            onLoaded: { item.itemData=modelData; item.index=index; item.parentModel=root.formModel; }
                                            Binding { target: item; property: "itemData"; value: modelData; when: item !== null }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        // Right Panel
        Rectangle {
            Layout.preferredWidth: 350; Layout.fillHeight: true; color: "#f0f2f5"; border.color: "#dcdfe6"
            ColumnLayout {
                anchors.fill: parent; anchors.margins: 10
                Text { text: "属性设置"; font.bold: true; font.pixelSize: 16 }
                PropertyEditor {
                    Layout.fillWidth: true; Layout.fillHeight: true; targetItem: root.selectedItem; visible: !root.previewMode
                    onPropertyChanged: (key, value) => { Logic.updateItemProperty(root, key, value); }
                }
            }
        }
    }
}
