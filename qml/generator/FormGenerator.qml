import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt.labs.folderlistmodel
import Common 1.0
import "../components"

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
            Layout.preferredWidth: 350
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

                ScrollView {

                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    PropertyEditor {
                        targetItem: root.selectedItem
                        onPropertyChanged: (key, value) => {
                            console.log("PropertyEditor - 属性变更:", key, "=", value, "当前项:", root.selectedItem ? root.selectedItem.id : "null");
                            if (root.selectedItem) {
                                // Find the real object in formModel
                                var realItem = findItemInModel(root.formModel, root.selectedItem.id);
                                if (realItem) {
                                    console.log("找到真实对象，修改属性");
                                    realItem.props[key] = value;

                                    // Force UI update by deep copying the formModel
                                    root.formModel = deepCopyFormModel(root.formModel);
                                    console.log("formModel 已强制更新, 新值:", realItem.props[key]);

                                    // Update selectedItem reference to the new object
                                    root.selectedItem = findItemInModel(root.formModel, root.selectedItem.id);
                                } else {
                                    console.error("错误：无法在 formModel 中找到项目", root.selectedItem.id);
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    function handleDrop(drop, targetParent, targetIndex) {
        console.log("=== 拖放事件触发 ===");
        if (!drop.source) {
            console.error("错误：无法获取拖拽源");
            return;
        }

        // Handle Move Existing Component
        if (drop.source.isExistingComponent) {
            moveItem(drop.source.itemData, drop.source.parentModel, targetParent, targetIndex);
            drop.accept(Qt.MoveAction);
            return;
        }

        if (!drop.source.componentType) {
            console.error("错误：无法获取组件类型");
            return;
        }

        var type = drop.source.componentType;
        console.log("添加新组件:", type);

        var newItem = createItem(type);

        if (targetParent) {
            console.log("添加到容器:", targetParent.id, "索引:", targetIndex);

            // Find the REAL container in the formModel
            var realContainer = findItemInModel(root.formModel, targetParent.id);
            if (!realContainer) {
                console.error("错误：无法在 formModel 中找到容器", targetParent.id);
                return;
            }

            // Create a new children array from the REAL container
            var newChildren = [].concat(realContainer.children || []);

            if (typeof targetIndex === "number" && targetIndex >= 0) {
                newChildren.splice(targetIndex, 0, newItem);
            } else {
                newChildren.push(newItem);
            }

            // Update the REAL container's children
            realContainer.children = newChildren;

            // Force formModel update by creating a deep copy
            root.formModel = deepCopyFormModel(root.formModel);
        } else {
            console.log("添加到根节点", "索引:", targetIndex);
            var newModel = [].concat(root.formModel);

            if (typeof targetIndex === "number" && targetIndex >= 0) {
                newModel.splice(targetIndex, 0, newItem);
            } else {
                newModel.push(newItem);
            }

            root.formModel = newModel;
        }

        drop.accept(Qt.CopyAction);
    }

    // Deep copy function to ensure formModel changes trigger updates
    function deepCopyFormModel(model) {
        var newModel = [];
        for (var i = 0; i < model.length; i++) {
            newModel.push(deepCopyItem(model[i]));
        }
        return newModel;
    }

    function deepCopyItem(item) {
        var newItem = {
            type: item.type,
            id: item.id,
            props: JSON.parse(JSON.stringify(item.props)),
            children: []
        };

        if (item.children && item.children.length > 0) {
            for (var i = 0; i < item.children.length; i++) {
                newItem.children.push(deepCopyItem(item.children[i]));
            }
        }

        return newItem;
    }

    // Helper function to recursively find an item in the model tree by ID
    function findItemInModel(model, itemId) {
        for (var i = 0; i < model.length; i++) {
            if (model[i].id === itemId) {
                return model[i];
            }

            // Recursively search in children
            if (model[i].children && model[i].children.length > 0) {
                var found = findItemInModel(model[i].children, itemId);
                if (found) {
                    return found;
                }
            }
        }
        return null;
    }

    function createItem(type) {
        var id = type + "_" + Math.floor(Math.random() * 10000);
        var props = {};
        var children = [];

        // Map type to component name - handle both lowercase and capitalized
        var componentName = type;
        if (type.charAt(0) === type.charAt(0).toLowerCase()) {
            // If lowercase, capitalize first letter
            componentName = type.charAt(0).toUpperCase() + type.slice(1);
        }

        var componentUrl = "../components/" + componentName + ".qml";
        var component = Qt.createComponent(componentUrl);

        if (component.status === Component.Ready) {
            var tempObject = component.createObject(root);
            if (tempObject) {
                if (tempObject.defaultProps) {
                    // Deep copy to avoid reference issues
                    props = JSON.parse(JSON.stringify(tempObject.defaultProps));
                }
                tempObject.destroy();
            }
        } else {
            console.error("Error loading component for creation:", componentUrl, component.errorString());
            // Fallback for safety
            props = {
                visible: true
            };
        }

        return {
            type: type,
            id: id,
            props: props,
            children: children
        };
    }

    function deleteItem(item, parentList) {
        // Find the real parent list in the current model
        // parentList passed from CanvasItem might be stale due to model updates

        var found = findParentListAndIndex(root.formModel, item.id);
        if (!found) {
            console.error("错误：无法在模型中找到要删除的组件");
            return;
        }

        var realParentList = found.list;
        var index = found.index;

        if (index !== -1) {
            realParentList.splice(index, 1);
            if (root.selectedItem && root.selectedItem.id === item.id) {
                root.selectedItem = null;
            }
            root.formModel = deepCopyFormModel(root.formModel);
        }
    }

    // Helper to find list and index
    function findParentListAndIndex(currentList, itemId) {
        for (var i = 0; i < currentList.length; i++) {
            if (currentList[i].id === itemId) {
                return {
                    list: currentList,
                    index: i
                };
            }
            if (currentList[i].children && currentList[i].children.length > 0) {
                var result = findParentListAndIndex(currentList[i].children, itemId);
                if (result)
                    return result;
            }
        }
        return null;
    }

    function moveItem(itemData, sourceParentList, targetParent, targetIndex) {
        console.log("移动组件:", itemData.type, "到索引:", targetIndex);

        // Find real source list and index
        var sourceInfo = findParentListAndIndex(root.formModel, itemData.id);
        if (!sourceInfo) {
            console.error("错误：无法在源列表中找到组件");
            return;
        }

        var realSourceList = sourceInfo.list;
        var sourceIndex = sourceInfo.index;

        // Determine target children list
        var targetChildren;
        if (targetParent) {
            var realTargetParent = findItemInModel(root.formModel, targetParent.id);
            if (!realTargetParent) {
                console.error("错误：无法找到目标容器");
                return;
            }
            targetChildren = realTargetParent.children;
        } else {
            targetChildren = root.formModel;
        }

        // Check if we are moving within the same list
        // Note: We compare the arrays themselves, assuming they are references to the same object in the current model tree
        // But since we found them via traversal, they should be correct.
        // However, targetChildren might be the root.formModel array.

        var sameList = (realSourceList === targetChildren);

        if (sameList) {
            console.log("在同一容器内移动");
            if (targetIndex === -1)
                targetIndex = targetChildren.length;

            // If moving down, adjust index because removal shifts subsequent items
            if (sourceIndex < targetIndex) {
                targetIndex--;
            }

            // Remove and Insert
            var movedItem = realSourceList.splice(sourceIndex, 1)[0];
            targetChildren.splice(targetIndex, 0, movedItem);
        } else {
            console.log("跨容器移动");
            // Remove from source
            var movedItem = realSourceList.splice(sourceIndex, 1)[0];

            // Add to target
            if (targetIndex === -1) {
                targetChildren.push(movedItem);
            } else {
                targetChildren.splice(targetIndex, 0, movedItem);
            }
        }

        // Force update
        root.formModel = deepCopyFormModel(root.formModel);
        // Restore selection
        root.selectedItem = findItemInModel(root.formModel, itemData.id);
    }

    function generateCode() {
        var code = "import QtQuick\nimport QtQuick.Controls\nimport QtQuick.Layouts\nimport Common 1.0\nimport \"../components\"\n\nItem {\n    width: 800\n    height: 600\n\n    ColumnLayout {\n        anchors.fill: parent\n        anchors.margins: 20\n        spacing: 10\n\n";
        code += generateChildrenCode(root.formModel, 2);
        code += "    }\n}";
        console.log(code);
        codeDialog.code = code;
        codeDialog.open();
    }

    function generateChildrenCode(children, indentLevel) {
        var code = "";
        for (var i = 0; i < children.length; i++) {
            var item = children[i];
            code += generateItemCode(item, indentLevel) + "\n";
        }
        return code;
    }

    function generateItemCode(item, indentLevel) {
        var indent = "    ".repeat(indentLevel);
        var code = "";

        // Map type to component name - handle both lowercase and capitalized
        var componentName = item.type;
        if (item.type.charAt(0) === item.type.charAt(0).toLowerCase()) {
            componentName = item.type.charAt(0).toUpperCase() + item.type.slice(1);
        }

        var componentUrl = "../components/" + componentName + ".qml";
        var component = Qt.createComponent(componentUrl);

        if (component.status === Component.Ready) {
            var tempObject = component.createObject(root);
            if (tempObject) {
                if (typeof tempObject.generateCode === "function") {
                    var childrenCode = "";
                    // Only generate children code if it's a container (like StyledRow)
                    if (item.children && item.children.length > 0) {
                        childrenCode = generateChildrenCode(item.children, indentLevel + 1);
                    }

                    code = tempObject.generateCode(item.props, childrenCode, indent);
                } else {
                    code = indent + "// Error: generateCode not implemented for " + item.type;
                }
                tempObject.destroy();
            }
        } else {
            code = indent + "// Error loading " + item.type + ": " + component.errorString();
        }

        return code;
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
