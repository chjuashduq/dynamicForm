import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt.labs.folderlistmodel
import Common 1.0
import "../components"
import "FormGeneratorLogic.js" as Logic

Item {
    id: root
    objectName: "FormGeneratorRoot"
    anchors.fill: parent

    // Model to store the form structure
    property var formModel: []
    property var selectedItem: null

    // Component Library Model
    property var componentGroups: undefined
    Component.onCompleted: {
        componentGroups = JSON.parse(componentJson);
    }
    RowLayout {
        anchors.fill: parent
        spacing: 0

        // Left Panel: Component Library
        Rectangle {
            Layout.preferredWidth: 250
            Layout.fillHeight: true

            gradient: Gradient {
                GradientStop {
                    position: 0.0
                    color: "#f8f9fa"
                }
                GradientStop {
                    position: 1.0
                    color: "#e9ecef"
                }
            }

            border.color: "#dee2e6"
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 15

                // Title
                Rectangle {
                    Layout.fillWidth: true
                    height: 40
                    color: "#1890ff"
                    radius: 8

                    Text {
                        anchors.centerIn: parent
                        text: "📦 组件库"
                        font.bold: true
                        font.pixelSize: 18
                        color: "white"
                    }
                }

                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true

                    Column {
                        width: parent.width
                        spacing: 12

                        Repeater {
                            model: componentGroups
                            delegate: Column {
                                width: parent.width
                                spacing: 10

                                Text {
                                    text: modelData.group
                                    font.bold: true
                                    color: "#666"
                                    topPadding: 10
                                }

                                Flow {
                                    width: parent.width
                                    spacing: 10
                                    Repeater {
                                        model: modelData.items
                                        delegate: DraggableComponent {
                                            componentType: modelData.type
                                            label: modelData.label
                                            icon: modelData.icon
                                            dragParent: root
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        // Center Panel: Canvas
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredWidth: 100 // Allow it to shrink/grow
            Layout.minimumWidth: 300   // Minimum usable width
            color: "white"

            // Toolbar
            RowLayout {
                id: toolbar
                height: 40
                width: parent.width
                anchors.top: parent.top
                spacing: 10

                Button {
                    text: "清空"
                    onClicked: {
                        root.formModel = [];
                        root.selectedItem = null;
                    }
                }

                Button {
                    text: "生成代码"
                    onClicked: generateCode()
                }

                Item {
                    Layout.fillWidth: true
                }
            }

            // Canvas Area
            ScrollView {
                anchors.top: toolbar.bottom
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right

                Flickable {
                    id: canvasFlickable
                    anchors.fill: parent
                    contentHeight: canvasColumn.height + 100
                    contentWidth: width

                    Column {
                        id: canvasColumn
                        width: parent.width - 40
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 10

                        // Drop Area for Root (Append)
                        DropArea {
                            id: rootDropArea
                            width: parent.width
                            height: Math.max(canvasFlickable.height - 20, 500)

                            onDropped: drop => {
                                console.log("根节点 DropArea 触发");
                                var targetIndex = -1;
                                var yPos = canvasContent.mapFromItem(rootDropArea, drop.x, drop.y).y;

                                // Calculate index based on Y position
                                // canvasContent children includes the Repeater and the loaded items
                                var visualChildren = [];
                                for (var i = 0; i < canvasContent.children.length; i++) {
                                    var child = canvasContent.children[i];
                                    // Filter out Repeater or non-visual items if any
                                    // Check if it is a Loader with a loaded item that has itemData
                                    if (child.item && child.item.hasOwnProperty("itemData")) {
                                        visualChildren.push(child);
                                    }
                                }

                                for (var i = 0; i < visualChildren.length; i++) {
                                    var child = visualChildren[i];
                                    if (yPos < child.y + child.height / 2) {
                                        targetIndex = i;
                                        break;
                                    }
                                }

                                handleDrop(drop, null, targetIndex);
                            }

                            Rectangle {
                                anchors.fill: parent
                                color: "#f5f7fa"
                                border.color: "#e4e7ed"

                                ColumnLayout {
                                    id: canvasContent
                                    width: parent.width - 40
                                    anchors.top: parent.top
                                    anchors.topMargin: 20
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    spacing: 10

                                    Repeater {
                                        model: root.formModel
                                        delegate: Loader {
                                            Layout.fillWidth: true
                                            source: "CanvasItem.qml"
                                            onLoaded: {
                                                item.itemData = modelData;
                                                item.index = index;
                                                item.parentModel = root.formModel;
                                                item.parentItemData = null; // Root has no parent item object
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        // Right Panel: Properties
        Rectangle {
            Layout.preferredWidth: 300
            Layout.fillHeight: true
            color: "#f0f2f5"
            border.color: "#dcdfe6"

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 10

                Text {
                    text: "属性设置"
                    font.bold: true
                    font.pixelSize: 16
                }

                PropertyEditor {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    targetItem: root.selectedItem
                    onPropertyChanged: (key, value) => {
                        Logic.updateItemProperty(root, key, value);
                    }
                }
            }
        }
    }

    function handleDrop(drop, targetParent, targetIndex) {
        Logic.handleDrop(drop, root, targetParent, targetIndex);
    }

    function deleteItem(item, parentList) {
        Logic.deleteItem(item, parentList, root);
    }

    function generateCode() {
        Logic.generateCode(root, codeDialog);
    }

    Dialog {
        id: codeDialog
        title: "生成的QML代码"
        width: 600
        height: 500
        anchors.centerIn: parent
        property string code: ""

        ScrollView {
            anchors.fill: parent

            TextArea {
                anchors.fill: parent
                text: codeDialog.code
                readOnly: true
                selectByMouse: true
                wrapMode: TextArea.NoWrap
            }
        }
    }
}
