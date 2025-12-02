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
            // console.log("CanvasItem Loader status:", status, "for type:", itemData ? itemData.type : "null");
            if (status === Loader.Error) {
                console.error("CanvasItem: Error loading component");
            }
        }

        onLoaded: {
            // console.log("CanvasItem: Component loaded for type:", itemData ? itemData.type : "null");
            if (item) {
                // console.log("CanvasItem: Item created, height:", item.height, "width:", item.width);
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
        // 兼容 StyledDateTime，确保首字母大写
        if (name.charAt(0) === name.charAt(0).toLowerCase()) {
            name = name.charAt(0).toUpperCase() + name.slice(1);
        }

        // console.log("CanvasItem: Loading component for type:", itemData.type, "-> name:", name);
        if (name === "StyledRow") {
            // console.log("CanvasItem: Using sourceComponent for StyledRow");
            contentLoader.sourceComponent = rowComp;
        } else {
            var path = "../../components/" + name + ".qml";
            // console.log("CanvasItem: Component path:", path);
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

        // console.log("CanvasItem: Applying properties to", itemData.type);
        for (var key in itemData.props) {
            if (contentLoader.item.hasOwnProperty(key)) {
                try {
                    contentLoader.item[key] = itemData.props[key];
                    // console.log("  - Set", key, "=", itemData.props[key]);
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
            // console.log("CanvasItem: Registering control", itemData.props.key, "to FormAPI");
            generatorRoot.formAPI.controlsMap[itemData.props.key] = item;

            // [新增] 注册控件配置，确保 validateAll 能遍历到此控件
            generatorRoot.formAPI.registerControlConfig(itemData.props.key, itemData.props);
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
                    return layoutLoader.item ? (layoutLoader.item.height + pt + pb) : 0;
                } else {
                    // In edit mode, ensure minimum height for drop area
                    return Math.max(100, (layoutLoader.item ? layoutLoader.item.height : 0) + pt + pb + 40);
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

                    // 使用 Loader 的 item 作为参照
                    if (layoutLoader.item) {
                        var point = layoutLoader.item.mapFromItem(dropArea, drop.x, drop.y);
                        var visualIndex = 0;
                        for (var i = 0; i < layoutLoader.item.children.length; i++) {
                            var child = layoutLoader.item.children[i];
                            // Skip Repeater or other non-visual items
                            if (!child.item || !child.item.hasOwnProperty("itemData"))
                                continue;
                            // Check if point is before this child
                            if (point.y < child.y + child.height && point.x < child.x + child.width / 2) {
                                targetIndex = visualIndex;
                                break;
                            }
                            visualIndex++;
                        }
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

            // [修改] 核心：布局管理器 Loader
            // 修复：直接在 Loader 上设置定位，而不是在子组件上使用非法锚点
            Loader {
                id: layoutLoader
                property bool isWrap: (itemData.props && itemData.props.wrap !== undefined) ? itemData.props.wrap : true

                // 属性提取
                property int align: itemData.props.alignment || 0
                property int padTop: (itemData.props && (itemData.props.paddingTop !== undefined ? itemData.props.paddingTop : (itemData.props.padding || 0))) || 0
                property int padBottom: (itemData.props && (itemData.props.paddingBottom !== undefined ? itemData.props.paddingBottom : (itemData.props.padding || 0))) || 0
                property int padLeft: (itemData.props && (itemData.props.paddingLeft !== undefined ? itemData.props.paddingLeft : (itemData.props.padding || 0))) || 0
                property int padRight: (itemData.props && (itemData.props.paddingRight !== undefined ? itemData.props.paddingRight : (itemData.props.padding || 0))) || 0
                property int space: (itemData.props && itemData.props.spacing) || 0

                // [策略] 如果是居中对齐，强制使用Row布局(不换行)，实现整体居中
                property bool useRowLayout: (align === Qt.AlignHCenter) || (!isWrap)

                sourceComponent: useRowLayout ? rowLayoutComp : flowLayoutComp

                // === 定位逻辑 ===

                // 1. 顶部定位 (相对于 rowContainer)
                anchors.top: parent.top
                anchors.topMargin: padTop

                // 2. 水平定位
                // 如果居中：Loader 宽度自适应内容 (undefined)，并锚定到父容器中点
                // 否则：Loader 填满父容器(减去padding)，左对齐

                anchors.horizontalCenter: (useRowLayout && align === Qt.AlignHCenter) ? parent.horizontalCenter : undefined
                anchors.left: (useRowLayout && align === Qt.AlignHCenter) ? undefined : parent.left
                anchors.leftMargin: (useRowLayout && align === Qt.AlignHCenter) ? 0 : padLeft

                // 3. 宽度控制
                width: (useRowLayout && align === Qt.AlignHCenter) ? undefined : (parent.width - padLeft - padRight)
            }

            // Flow 布局组件 (换行)
            Component {
                id: flowLayoutComp
                Flow {
                    id: flowImpl
                    // 宽度跟随 Loader
                    width: parent.width
                    spacing: layoutLoader.space
                    flow: Flow.LeftToRight
                    layoutDirection: (layoutLoader.align === Qt.AlignRight) ? Qt.RightToLeft : Qt.LeftToRight

                    Repeater {
                        model: itemData.children
                        delegate: childDelegate
                    }
                }
            }

            // Row 布局组件 (不换行)
            Component {
                id: rowLayoutComp
                Row {
                    id: rowImpl
                    // 宽度为隐式宽度，无需设置 width，由 Loader 的 anchors.horizontalCenter 进行居中
                    spacing: layoutLoader.space
                    layoutDirection: (layoutLoader.align === Qt.AlignRight) ? Qt.RightToLeft : Qt.LeftToRight

                    Repeater {
                        model: itemData.children
                        delegate: childDelegate
                    }
                }
            }

            // 统一的子组件 Delegate
            Component {
                id: childDelegate
                Loader {
                    // 宽度计算修正：使用 rowContainer.width 作为基准，因为 Loader/Flow 宽度可能变化
                    width: {
                        var containerWidth = rowContainer.width;
                        var pl = (itemData.props && (itemData.props.paddingLeft !== undefined ? itemData.props.paddingLeft : (itemData.props.padding || 0))) || 0;
                        var pr = (itemData.props && (itemData.props.paddingRight !== undefined ? itemData.props.paddingRight : (itemData.props.padding || 0))) || 0;
                        var availableWidth = containerWidth - pl - pr;

                        if (availableWidth <= 0)
                            availableWidth = 350;

                        if (modelData.props.layoutType === "fixed")
                            return modelData.props.width || 100;
                        if (modelData.props.layoutType === "percent")
                            return availableWidth * ((modelData.props.widthPercent || 100) / 100);

                        // 默认宽度
                        return 150;
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

            Text {
                anchors.centerIn: parent
                text: "拖拽组件到此处 (" + (layoutLoader.useRowLayout ? "单行模式" : "自动换行") + ")"
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
