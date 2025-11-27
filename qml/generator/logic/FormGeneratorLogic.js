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
    var id = type + "_" + Math.floor(Math.random() * 10000);
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
        // Fallback
        props = { visible: true };
    }

    if (!props.key) {
        props.key = type + "_" + new Date().getTime();
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

function generateCode(root, codeDialog) {
    var code = "import QtQuick\nimport QtQuick.Controls\nimport QtQuick.Layouts\nimport Common 1.0\nimport \"../components\"\n\nItem {\n    width: 800\n    height: 600\n\n    // 主容器 (默认 GridLayout)\n    GridLayout {\n        anchors.fill: parent\n        anchors.margins: 20\n        columns: 2 // 默认列数\n        rowSpacing: 10\n        columnSpacing: 15\n\n";
    var functions = [];
    code += generateChildrenCode(root.formModel, 2, root, functions);
    code += "    }\n\n";

    if (functions.length > 0) {
        code += "    // Event Handlers\n";
        code += functions.join("\n\n") + "\n";
    }

    code += "}";
    if (codeDialog) {
        codeDialog.code = code;
        codeDialog.open();
    }
    return code; // Return the code string
}

// 新增：仅生成子元素代码，不包裹 Item
function generateFormBody(formModel, root) {
    var functions = []; // 暂不处理内联函数，因为是用于生成的 C++ 模板
    return generateChildrenCode(formModel, 2, root, functions);
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

                // [关键修改] 手动注入 id，因为 generateCode 通常不包含 id
                // 如果 props 中有 id（我们在 GenEdit 中设置的），则使用它
                // 如果没有，但有 key，则使用 field_key 格式
                var originalId = item.props.id;
                if (!originalId && item.props.key) {
                    item.props.id = "field_" + item.props.key;
                }

                code = tempObject.generateCode(item.props, childrenCode, indent, item.events, functions);

                // 恢复 props，以免影响界面显示
                if (!originalId) delete item.props.id;
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