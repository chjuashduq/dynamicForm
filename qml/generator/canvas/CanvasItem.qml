import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../components"

Rectangle {
    id: itemRoot

    property var itemData
    property int index: -1
    property var parentModel
    property var parentItemData
    radius: 4

    property bool isSelected: {
        var selected = generatorRoot && generatorRoot.selectedItem && itemData && generatorRoot.selectedItem.id === itemData.id;
        return selected;
    }
    onIsSelectedChanged: console.log("CanvasItem", itemData ? itemData.id : "null", "isSelected:", isSelected)
    property bool isContainer: itemData && itemData.type === "StyledRow"

    property var generatorRoot: null
    onParentChanged: {
        if (parent) {
            generatorRoot = findGeneratorRoot(itemRoot);
        }
    }
    Component.onCompleted: {
        if (parent) {
            generatorRoot = findGeneratorRoot(itemRoot);
        }
    }

    function findGeneratorRoot(item) {
        if (!item)
            return null;
        var p = item.parent;
        while (p) {
            if (p.objectName === "FormGeneratorRoot")
                return p;
            p = p.parent;
        }
        return null;
    }

    property bool isNested: false

    width: {
        if (!itemData || !itemData.props)
            return 800;
        var w = 800;
        var pWidth = parent ? parent.width : 800;
        if (itemData.props.layoutType === "percent") {
            w = pWidth * ((itemData.props.widthPercent || 100) / 100);
        } else if (itemData.props.layoutType === "fixed") {
            w = itemData.props.width || 100;
        } else {
            w = pWidth;
        }
        return w;
    }
    height: contentLoader.height + 20
    color: isSelected ? "#e6f7ff" : "transparent"
    border.color: isSelected ? "#1890ff" : "transparent"
    border.width: 2

    property bool previewMode: generatorRoot ? generatorRoot.previewMode : false

    MouseArea {
        id: selectionArea
        anchors.fill: parent
        // If container, put below content (z=0) so content can be clicked.
        // If atomic, put above content (z=2) to intercept clicks.
        // In preview mode, disable this area to allow interaction with content
        enabled: !previewMode
        z: itemRoot.isContainer ? 0 : 2
        propagateComposedEvents: true
        onClicked: mouse => {
            console.log("CanvasItem MouseArea 点击，ID:", itemRoot.itemData ? itemRoot.itemData.id : "null");
            if (itemRoot.generatorRoot) {
                itemRoot.generatorRoot.selectedItem = itemRoot.itemData;
            }
            // Accept the event to prevent it from propagating to parent CanvasItem
            mouse.accepted = true;
        }
    }

    Loader {
        id: contentLoader
        z: 1 // Content always at z=1
        width: isNested ? itemRoot.width : Math.max(itemRoot.width - 20, 100)
        anchors.centerIn: parent
        asynchronous: false

        onStatusChanged: {
            console.log("CanvasItem Loader status:", status, "for type:", itemData ? itemData.type : "null");
            if (status === Loader.Error) {
                console.error("CanvasItem: Error loading component");
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

    property var eventHandlers: ({})

    onItemDataChanged: {
        console.log("CanvasItem: itemData changed to:", itemData ? itemData.type : "null");
        eventHandlers = {}; // Reset handlers
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
            var path = "../../components/" + name + ".qml";
            console.log("CanvasItem: Component path:", path);
            contentLoader.source = path;
        }
    }

    // Monitor deep property changes by stringifying props
    property string propsSnapshot: itemData && itemData.props ? JSON.stringify(itemData.props) : ""
    property string eventsSnapshot: itemData && itemData.events ? JSON.stringify(itemData.events) : ""

    onPropsSnapshotChanged: {
        console.log("CanvasItem: Props changed, re-applying to component");
        if (contentLoader.status === Loader.Ready && contentLoader.item) {
            applyPropertiesToItem();
        }
    }

    onEventsSnapshotChanged: {
        console.log("CanvasItem: Events changed, re-applying to component");
        if (contentLoader.status === Loader.Ready && contentLoader.item) {
            applyEventsToItem();
        }
    }

    onPreviewModeChanged: {
        if (previewMode) {
            console.log("CanvasItem: Entering preview mode, applying events");
            applyEventsToItem();
        }
    }

    function applyPropertiesToItem() {
        if (!contentLoader.item || !itemData || !itemData.props) {
            return;
        }

        console.log("CanvasItem: Applying properties to", itemData.type);
        for (var key in itemData.props) {
            if (contentLoader.item.hasOwnProperty(key)) {
                try {
                    contentLoader.item[key] = itemData.props[key];
                    console.log("  - Set", key, "=", itemData.props[key]);
                } catch (e) {
                    console.warn("Could not set property", key, "on", contentLoader.item);
                }
            }
        }
    }

    function applyEventsToItem() {
        if (!contentLoader.item || !itemData || !itemData.events) {
            return;
        }

        if (!previewMode)
            return;
        var item = contentLoader.item;

        // Register to FormAPI if key exists (for getControlValue etc.)
        if (itemData.props && itemData.props.key && generatorRoot && generatorRoot.formAPI) {
            console.log("CanvasItem: Registering control", itemData.props.key, "to FormAPI");
            generatorRoot.formAPI.controlsMap[itemData.props.key] = item;
        }

        // Use local property eventHandlers instead of attaching to item
        if (!eventHandlers) {
            eventHandlers = {};
        }

        for (var eventName in itemData.events) {
            var code = itemData.events[eventName];
            if (!code)
                continue;
            var signalName = eventName;
            if (signalName.startsWith("on")) {
                signalName = signalName.substring(2);
                signalName = signalName.charAt(0).toLowerCase() + signalName.slice(1);
            }

            // Check if signal exists
            var signal = item[signalName];
            if (signal && typeof signal.connect === "function") {
                // Disconnect old handler if exists
                if (eventHandlers[eventName]) {
                    try {
                        signal.disconnect(eventHandlers[eventName]);
                    } catch (e) {
                        console.log("Error disconnecting", eventName, e);
                    }
                }

                // Create new handler
                var handler = (function (c, name) {
                        return function () {
                            console.log("Triggering event:", name);
                            if (generatorRoot && generatorRoot.scriptEngine) {
                                // Use ScriptEngine
                                try {
                                    var val = undefined;
                                    if (item.hasOwnProperty("value"))
                                        val = item.value;
                                    else if (item.hasOwnProperty("text"))
                                        val = item.text;
                                    else if (item.hasOwnProperty("checked"))
                                        val = item.checked;

                                    generatorRoot.scriptEngine.executeFunction(c, {
                                        self: item,
                                        value: val,
                                        root: {
                                            isAdd: true
                                        } // Mock root object for preview
                                        ,
                                        isAdd: true // Direct access if needed
                                    });
                                } catch (err) {
                                    console.error("Error executing event code via ScriptEngine for", name, ":", err);
                                }
                            } else {
                                // Fallback
                                try {
                                    var func = new Function(c);
                                    func.call(this);
                                } catch (err) {
                                    console.error("Error executing event code for", name, ":", err);
                                }
                            }
                        };
                    })(code, eventName);

                eventHandlers[eventName] = handler;
                try {
                    signal.connect(handler);
                    console.log("Connected", eventName, "to signal", signalName, "on", item);
                } catch (e) {
                    console.warn("Could not connect signal", signalName, e);
                }
            } else {
                console.warn("Signal not found or not connectable:", signalName, "on", item);
            }
        }
    }

    Component {
        id: rowComp
        Rectangle {
            id: rowContainer
            width: parent.width
            implicitHeight: {
                // [修复] 获取详细的 padding 值，如果未定义则回退到 padding 或 0
                var pt = (itemData.props && (itemData.props.paddingTop !== undefined ? itemData.props.paddingTop : (itemData.props.padding || 0))) || 0;
                var pb = (itemData.props && (itemData.props.paddingBottom !== undefined ? itemData.props.paddingBottom : (itemData.props.padding || 0))) || 0;

                if (previewMode) {
                    // In preview mode, height is determined by content
                    // If no children, height is 0
                    if (!itemData.children || itemData.children.length === 0)
                        return 0;
                    return rowLayout.childrenRect.height + pt + pb;
                } else {
                    // In edit mode, ensure minimum height for drop area
                    return Math.max(100, rowLayout.childrenRect.height + pt + pb + 40);
                }
            }
            height: implicitHeight
            color: previewMode ? "transparent" : (dropArea.containsDrag ? "#e6f7ff" : "#f5f5f5")
            border.color: previewMode ? "transparent" : (dropArea.containsDrag ? "#40a9ff" : "#1890ff")
            border.width: previewMode ? 0 : 2
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
                enabled: !previewMode // Disable dropping in preview mode

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

                    if (itemRoot.generatorRoot) {
                        itemRoot.generatorRoot.handleDrop(drop, itemRoot.itemData, targetIndex);
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
                width: (itemData.props.alignment === Qt.AlignHCenter) ? Math.min(implicitWidth, parent.width) : parent.width
                anchors.horizontalCenter: (itemData.props.alignment === Qt.AlignHCenter) ? parent.horizontalCenter : undefined

                layoutDirection: (itemData.props.alignment === Qt.AlignRight) ? Qt.RightToLeft : Qt.LeftToRight

                anchors.top: parent.top
                // [修复] 优先使用 paddingTop
                anchors.topMargin: (itemData.props && (itemData.props.paddingTop !== undefined ? itemData.props.paddingTop : (itemData.props.padding || 0))) || 0

                anchors.left: (itemData.props.alignment === Qt.AlignHCenter) ? undefined : parent.left
                // [修复] 优先使用 paddingLeft
                anchors.leftMargin: (itemData.props && (itemData.props.paddingLeft !== undefined ? itemData.props.paddingLeft : (itemData.props.padding || 0))) || 0

                anchors.right: (itemData.props.alignment === Qt.AlignHCenter) ? undefined : parent.right
                // [修复] 优先使用 paddingRight
                anchors.rightMargin: (itemData.props && (itemData.props.paddingRight !== undefined ? itemData.props.paddingRight : (itemData.props.padding || 0))) || 0

                spacing: (itemData.props && itemData.props.spacing) || 0

                Repeater {
                    id: repeater
                    model: itemData.children
                    delegate: Loader {
                        width: {
                            var containerWidth = rowLayout.width;
                            if (modelData.props.layoutType === "fixed")
                                return modelData.props.width || 350;
                            if (modelData.props.layoutType === "percent")
                                return containerWidth * ((modelData.props.widthPercent || 100) / 100);
                            return containerWidth;
                        }

                        source: "CanvasItem.qml"
                        onLoaded: {
                            item.itemData = modelData;
                            item.index = index;
                            item.parentModel = itemData.children;
                            item.isNested = true;
                        }
                        Binding {
                            target: item
                            property: "itemData"
                            value: modelData
                            when: item !== null
                        }
                    }
                }
            }

            Text {
                anchors.centerIn: parent
                text: "拖拽组件到此处 (横向布局)"
                color: "#999"
                font.pixelSize: 14
                visible: (!itemData.children || itemData.children.length === 0) && !previewMode
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
        visible: isSelected && !previewMode

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
            if (itemRoot.generatorRoot) {
                itemRoot.generatorRoot.deleteItem(itemRoot.itemData, itemRoot.parentModel);
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
        visible: isSelected && !previewMode

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
                parent: itemRoot.generatorRoot
            }
            AnchorChanges {
                target: dragHandle
                anchors.right: undefined
                anchors.top: undefined
            }
        }
    }
}
