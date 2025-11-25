
// FormGeneratorLogic.js

function handleDrop(drop, root, targetParent, targetIndex) {
    if (!drop.source) {
        return;
    }

    // Handle Move Existing Component
    if (drop.source.isExistingComponent) {
        moveItem(drop.source.itemData, drop.source.parentModel, targetParent, targetIndex, root);
        drop.accept(Qt.MoveAction);
        return;
    }

    if (!drop.source.componentType) {
        return;
    }

    var type = drop.source.componentType;
    var newItem = createItem(type, root);

    if (targetParent) {
        // Find the REAL container in the formModel
        var realContainer = findItemInModel(root.formModel, targetParent.id);
        if (!realContainer) {
            console.error("Error: Could not find container in formModel", targetParent.id);
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

function createItem(type, root) {
    var id = type + "_" + Math.floor(Math.random() * 10000);
    var props = {};
    var children = [];

    // Map type to component name - handle both lowercase and capitalized
    var componentName = type;
    if (type.charAt(0) === type.charAt(0).toLowerCase()) {
        // If lowercase, capitalize first letter
        componentName = type.charAt(0).toUpperCase() + type.slice(1);
    }

    var componentUrl = "../../components/" + componentName + ".qml";
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

function deleteItem(item, parentList, root) {
    // Find the real parent list in the current model
    // parentList passed from CanvasItem might be stale due to model updates

    var found = findParentListAndIndex(root.formModel, item.id);
    if (!found) {
        console.error("Error: Could not find component to delete in model");
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

function moveItem(itemData, sourceParentList, targetParent, targetIndex, root) {
    // Find real source list and index
    var sourceInfo = findParentListAndIndex(root.formModel, itemData.id);
    if (!sourceInfo) {
        console.error("Error: Could not find component in source list");
        return;
    }

    var realSourceList = sourceInfo.list;
    var sourceIndex = sourceInfo.index;

    // Determine target children list
    var targetChildren;
    if (targetParent) {
        var realTargetParent = findItemInModel(root.formModel, targetParent.id);
        if (!realTargetParent) {
            console.error("Error: Could not find target container");
            return;
        }
        targetChildren = realTargetParent.children;
    } else {
        targetChildren = root.formModel;
    }

    var sameList = (realSourceList === targetChildren);

    if (sameList) {
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

function generateCode(root, codeDialog) {
    var code = "import QtQuick\nimport QtQuick.Controls\nimport QtQuick.Layouts\nimport Common 1.0\nimport \"../components\"\n\nItem {\n    width: 800\n    height: 600\n\n    ColumnLayout {\n        anchors.fill: parent\n        anchors.margins: 20\n        spacing: 10\n\n";
    code += generateChildrenCode(root.formModel, 2, root);
    code += "    }\n}";
    codeDialog.code = code;
    codeDialog.open();
}

function generateChildrenCode(children, indentLevel, root) {
    var code = "";
    for (var i = 0; i < children.length; i++) {
        var item = children[i];
        code += generateItemCode(item, indentLevel, root) + "\n";
    }
    return code;
}

function generateItemCode(item, indentLevel, root) {
    var indent = "    ".repeat(indentLevel);
    var code = "";

    // Map type to component name - handle both lowercase and capitalized
    var componentName = item.type;
    if (item.type.charAt(0) === item.type.charAt(0).toLowerCase()) {
        componentName = item.type.charAt(0).toUpperCase() + item.type.slice(1);
    }

    var componentUrl = "../../components/" + componentName + ".qml";
    var component = Qt.createComponent(componentUrl);

    if (component.status === Component.Ready) {
        var tempObject = component.createObject(root);
        if (tempObject) {
            if (typeof tempObject.generateCode === "function") {
                var childrenCode = "";
                // Only generate children code if it's a container (like StyledRow)
                if (item.children && item.children.length > 0) {
                    childrenCode = generateChildrenCode(item.children, indentLevel + 1, root);
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

function updateItemProperty(root, key, value) {
    if (root.selectedItem) {
        // Find the real object in formModel
        var realItem = findItemInModel(root.formModel, root.selectedItem.id);
        if (realItem) {
            realItem.props[key] = value;

            // Force UI update by deep copying the formModel
            root.formModel = deepCopyFormModel(root.formModel);

            // Update selectedItem reference to the new object
            root.selectedItem = findItemInModel(root.formModel, root.selectedItem.id);
        } else {
            console.error("Error: Could not find item in formModel", root.selectedItem.id);
        }
    }
}
