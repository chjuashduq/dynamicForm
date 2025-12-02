// FormGeneratorLogic.js

function handleDrop(drop, root, targetParent, targetIndex) {
    if (!drop.source) return;

    // Handle Move Existing Component
    if (drop.source.isExistingComponent) {
        moveItem(drop.source.itemData, drop.source.parentModel, targetParent, targetIndex, root);
        drop.accept(Qt.MoveAction);
        return;
    }

    if (!drop.source.componentType) return;

    var type = drop.source.componentType;
    var newItem = createItem(type, root);

    if (targetParent) {
        var realContainer = findItemInModel(root.formModel, targetParent.id);
        if (!realContainer) return;
        var newChildren = [].concat(realContainer.children || []);
        if (typeof targetIndex === "number" && targetIndex >= 0) {
            newChildren.splice(targetIndex, 0, newItem);
        } else {
            newChildren.push(newItem);
        }
        realContainer.children = newChildren;
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
        events: item.events ? JSON.parse(JSON.stringify(item.events)) : {},
        children: []
    };
    if (item.children && item.children.length > 0) {
        for (var i = 0; i < item.children.length; i++) {
            newItem.children.push(deepCopyItem(item.children[i]));
        }
    }
    return newItem;
}

function findItemInModel(model, itemId) {
    for (var i = 0; i < model.length; i++) {
        if (model[i].id === itemId) return model[i];
        if (model[i].children && model[i].children.length > 0) {
            var found = findItemInModel(model[i].children, itemId);
            if (found) return found;
        }
    }
    return null;
}

function createItem(type, root) {
    var id = type + "_" + Math.floor(Math.random() * 100000);
    var props = {};
    var children = [];

    var componentName = type;
    if (type.charAt(0) === type.charAt(0).toLowerCase()) {
        componentName = type.charAt(0).toUpperCase() + type.slice(1);
    }

    var componentUrl = "../../components/" + componentName + ".qml";
    var component = Qt.createComponent(componentUrl);

    if (component.status === Component.Ready) {
        var tempObject = component.createObject(root);
        if (tempObject) {
            if (tempObject.defaultProps) {
                props = JSON.parse(JSON.stringify(tempObject.defaultProps));
            }
            tempObject.destroy();
        }
    } else {
        props = { visible: true };
    }

    if (!props.key || props.key === "") {
        props.key = type.toLowerCase() + "_" + Math.floor(Math.random() * 10000).toString();
    }

    return { type: type, id: id, props: props, children: children };
}

function deleteItem(item, parentList, root) {
    var found = findParentListAndIndex(root.formModel, item.id);
    if (!found) return;

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

function findParentListAndIndex(currentList, itemId) {
    for (var i = 0; i < currentList.length; i++) {
        if (currentList[i].id === itemId) return { list: currentList, index: i };
        if (currentList[i].children && currentList[i].children.length > 0) {
            var result = findParentListAndIndex(currentList[i].children, itemId);
            if (result) return result;
        }
    }
    return null;
}

function moveItem(itemData, sourceParentList, targetParent, targetIndex, root) {
    var sourceInfo = findParentListAndIndex(root.formModel, itemData.id);
    if (!sourceInfo) return;

    var realSourceList = sourceInfo.list;
    var sourceIndex = sourceInfo.index;
    var targetChildren;

    if (targetParent) {
        var realTargetParent = findItemInModel(root.formModel, targetParent.id);
        if (!realTargetParent) return;
        targetChildren = realTargetParent.children;
    } else {
        targetChildren = root.formModel;
    }

    var sameList = (realSourceList === targetChildren);
    if (sameList) {
        if (targetIndex === -1) targetIndex = targetChildren.length;
        if (sourceIndex < targetIndex) targetIndex--;
        var movedItem = realSourceList.splice(sourceIndex, 1)[0];
        targetChildren.splice(targetIndex, 0, movedItem);
    } else {
        var movedItem = realSourceList.splice(sourceIndex, 1)[0];
        if (targetIndex === -1) targetChildren.push(movedItem);
        else targetChildren.splice(targetIndex, 0, movedItem);
    }

    root.formModel = deepCopyFormModel(root.formModel);
    root.selectedItem = findItemInModel(root.formModel, itemData.id);
}

// [修改] 去除对话框参数，只返回代码字符串
function generateCode(root) {
    var functions = [];
    var code = generateChildrenCode(root.formModel, 2, root, functions);

    if (functions.length > 0) {
        code += "\n            // Event Handlers\n";
        code += functions.join("\n\n") + "\n";
    }

    return code;
}

function generateChildrenCode(children, indentLevel, root, functions) {
    var code = "";
    for (var i = 0; i < children.length; i++) {
        var item = children[i];
        code += generateItemCode(item, indentLevel, root, functions) + "\n";
    }
    return code;
}

function generateItemCode(item, indentLevel, root, functions) {
    var indent = "    ".repeat(indentLevel);
    var code = "";
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
                if (item.children && item.children.length > 0) {
                    childrenCode = generateChildrenCode(item.children, indentLevel + 1, root, functions);
                }

                var propsWithId = JSON.parse(JSON.stringify(item.props));
                if (!propsWithId.id && propsWithId.key) {
                    if (propsWithId.key === "submit") propsWithId.id = "btn_submit";
                    else if (propsWithId.key === "cancel") propsWithId.id = "btn_cancel";
                    else propsWithId.id = "field_" + propsWithId.key;
                }

                code = tempObject.generateCode(propsWithId, childrenCode, indent, item.events, functions);
            }
            tempObject.destroy();
        }
    } else {
        code = indent + "// Error: " + component.errorString();
    }
    return code;
}

function updateItemProperty(root, key, value) {
    if (root.selectedItem) {
        var realItem = findItemInModel(root.formModel, root.selectedItem.id);
        if (realItem) {
            if (key === "events") {
                realItem.events = value;
            } else {
                realItem.props[key] = value;
            }
            root.formModel = deepCopyFormModel(root.formModel);
            root.selectedItem = findItemInModel(root.formModel, root.selectedItem.id);
        }
    }
}