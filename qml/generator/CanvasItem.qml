import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"

Rectangle {
    id: itemRoot

    property var itemData
    property int index
    property var parentModel
    property var parentItemData
    property var generatorRoot: findGeneratorRoot(this)

    width: parent ? parent.width : 800
    height: contentLoader.height + 20
    color: isSelected ? "#e6f7ff" : "transparent"
    border.color: isSelected ? "#1890ff" : "transparent"
    border.width: 2
    radius: 4

    property bool isSelected: {
        var selected = generatorRoot && generatorRoot.selectedItem && itemData && generatorRoot.selectedItem.id === itemData.id;
        return selected;
    }
    onIsSelectedChanged: console.log("CanvasItem", itemData ? itemData.id : "null", "isSelected:", isSelected)
    property bool isContainer: itemData && itemData.type === "StyledRow"

    function findGeneratorRoot(item) {
        var p = item.parent;
        while (p) {
            if (p.objectName === "FormGeneratorRoot")
                return p;
            p = p.parent;
        }
        return null;
    }

    MouseArea {
        id: selectionArea
        anchors.fill: parent
        // If container, put below content (z=0) so content can be clicked.
        // If atomic, put above content (z=2) to intercept clicks.
        z: isContainer ? 0 : 2
        propagateComposedEvents: true
        onClicked: mouse => {
            console.log("CanvasItem MouseArea 点击，ID:", itemData ? itemData.id : "null");
            if (generatorRoot) {
                generatorRoot.selectedItem = itemData;
            }
            // Accept the event to prevent it from propagating to parent CanvasItem
            mouse.accepted = true;
        }
    }

    Loader {
        id: contentLoader
        z: 1 // Content always at z=1
        width: Math.max(itemRoot.width - 20, 100)
        anchors.centerIn: parent
        asynchronous: false

        onStatusChanged: {
            console.log("CanvasItem Loader status:", status, "for type:", itemData ? itemData.type : "null");
            if (status === Loader.Error) {
                console.error("CanvasItem: Error loading component:", errorString());
            }
        }

        onLoaded: {
            console.log("CanvasItem: Component loaded for type:", itemData ? itemData.type : "null");
            if (item) {
                console.log("CanvasItem: Item created, height:", item.height, "width:", item.width);
                applyPropertiesToItem();
            }
        }
    }

    onItemDataChanged: {
        console.log("CanvasItem: itemData changed to:", itemData ? itemData.type : "null");
        if (!itemData) {
            contentLoader.source = "";
            return;
        }

        var name = itemData.type;
        if (name.charAt(0) === name.charAt(0).toLowerCase()) {
            name = name.charAt(0).toUpperCase() + name.slice(1);
        }

        console.log("CanvasItem: Loading component for type:", itemData.type, "-> name:", name);

        if (name === "StyledRow") {
            console.log("CanvasItem: Using sourceComponent for StyledRow");
            contentLoader.sourceComponent = rowComp;
        } else {
            var path = "../components/" + name + ".qml";
            console.log("CanvasItem: Component path:", path);
            contentLoader.source = path;
        }
    }

    function applyPropertiesToItem() {
        if (!contentLoader.item || !itemData || !itemData.props) {
            return;
        }

        for (var key in itemData.props) {
            if (contentLoader.item.hasOwnProperty(key)) {
                try {
                    contentLoader.item[key] = itemData.props[key];
                } catch (e) {
                    console.warn("Could not set property", key, "on", contentLoader.item);
                }
            }
        }
    }

    Component {
        id: rowComp
        Rectangle {
            id: rowContainer
            width: parent.width
            implicitHeight: Math.max(100, rowLayout.childrenRect.height + 40)
            height: implicitHeight
            color: dropArea.containsDrag ? "#e6f7ff" : "#f5f5f5"
            border.color: dropArea.containsDrag ? "#40a9ff" : "#1890ff"
            border.width: 2
            radius: 4

            Behavior on color {
                ColorAnimation {
                    duration: 200
                }
            }

            Behavior on border.color {
                ColorAnimation {
                    duration: 200
                }
            }

            DropArea {
                id: dropArea
                anchors.fill: parent

                onDropped: drop => {
                    console.log("容器内部 DropArea 触发");
                    var targetIndex = -1;

                    var point = rowLayout.mapFromItem(dropArea, drop.x, drop.y);
                    var visualIndex = 0;

                    for (var i = 0; i < rowLayout.children.length; i++) {
                        var child = rowLayout.children[i];

                        // Skip Repeater or other non-visual items
                        // We can check if it has 'itemData' property which we set on Loaders
                        // Check if it is a Loader with a loaded item that has itemData
                        if (!child.item || !child.item.hasOwnProperty("itemData"))
                            continue;

                        // Check if point is before this child
                        // For Flow (LeftToRight), we check X primarily, but also Y for wrapping
                        if (point.y < child.y + child.height && point.x < child.x + child.width / 2) {
                            targetIndex = visualIndex;
                            break;
                        }
                        visualIndex++;
                    }

                    if (generatorRoot) {
                        generatorRoot.handleDrop(drop, itemData, targetIndex);
                    }
                    drop.accept(Qt.CopyAction);
                }

                onEntered: {
                    console.log("拖拽进入容器");
                }

                onExited: {
                    console.log("拖拽离开容器");
                }
            }

            Flow {
                id: rowLayout
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 10

                spacing: itemData.props.spacing
                flow: (itemData.props.flowDirection === "TopToBottom") ? Flow.TopToBottom : Flow.LeftToRight

                Repeater {
                    id: repeater
                    model: itemData.children
                    delegate: Loader {
                        width: {
                            if (modelData.props.layoutType === "fixed")
                                return modelData.props.width || 100;
                            if (modelData.props.layoutType === "percent")
                                return rowLayout.width * ((modelData.props.widthPercent || 100) / 100);
                            if (modelData.props.layoutType === "fill")
                                return rowLayout.width - rowLayout.spacing * (itemData.children.length - 1);
                            // Default width for flex
                            return 150;
                        }

                        source: "CanvasItem.qml"
                        onLoaded: {
                            item.itemData = modelData;
                            item.index = index;
                            item.parentModel = itemData.children;
                        }
                    }
                }
            }

            Text {
                anchors.centerIn: parent
                text: "拖拽组件到此处 (横向布局)"
                color: "#999"
                font.pixelSize: 14
                visible: !itemData.children || itemData.children.length === 0
            }
        }
    }

    Button {
        id: deleteBtn
        z: 20 // Ensure above everything
        anchors.right: parent.right
        anchors.top: parent.top
        width: 20
        height: 20
        text: "×"
        visible: isSelected

        background: Rectangle {
            color: "red"
            radius: 10
        }

        contentItem: Text {
            text: "×"
            color: "white"
            font.pixelSize: 14
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        onClicked: {
            if (generatorRoot) {
                generatorRoot.deleteItem(itemData, parentModel);
            }
        }
    }
    Rectangle {
        id: dragHandle
        z: 20 // Ensure above everything
        width: 24
        height: 24
        anchors.right: deleteBtn.left
        anchors.rightMargin: 5
        anchors.top: parent.top
        color: "#1890ff"
        radius: 4
        visible: isSelected

        Text {
            anchors.centerIn: parent
            text: "✥"
            color: "white"
            font.pixelSize: 14
        }

        // Expose properties for DropArea
        property var itemData: itemRoot.itemData
        property var parentModel: itemRoot.parentModel
        property int itemIndex: itemRoot.index
        property bool isExistingComponent: true

        Drag.active: dragMouseArea.drag.active
        Drag.supportedActions: Qt.MoveAction
        Drag.dragType: Drag.Automatic
        Drag.mimeData: {
            "text/plain": "existing"
        }

        MouseArea {
            id: dragMouseArea
            anchors.fill: parent
            drag.target: dragHandle

            onReleased: {
                dragHandle.Drag.drop();
                dragHandle.parent = itemRoot;
                dragHandle.anchors.right = deleteBtn.left;
                dragHandle.anchors.rightMargin = 5;
                dragHandle.anchors.top = itemRoot.top;
            }
        }

        states: State {
            when: dragMouseArea.drag.active
            ParentChange {
                target: dragHandle
                parent: generatorRoot
            }
            AnchorChanges {
                target: dragHandle
                anchors.right: undefined
                anchors.top: undefined
            }
        }
    }
}
