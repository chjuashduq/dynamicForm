/**
 * FormSerializer.js
 * 负责表单模型与JSON格式之间的转换
 */

// 生成唯一的ID
function generateId(prefix) {
    return prefix + "_" + Math.floor(Math.random() * 100000).toString();
}

/**
 * 将表单模型序列化为JSON字符串
 * @param {Array} formModel - 表单模型数组
 * @param {Object} metaData - 额外的元数据（可选）
 * @return {String} JSON字符串
 */
function serialize(formModel, metaData) {
    var exportData = {
        "version": "1.0",
        "timestamp": new Date().toISOString(),
        "meta": metaData || {},
        "items": []
    };

    if (formModel && Array.isArray(formModel)) {
        for (var i = 0; i < formModel.length; i++) {
            exportData.items.push(serializeItem(formModel[i]));
        }
    }

    return JSON.stringify(exportData, null, 4);
}

/**
 * 递归序列化单个组件项
 */
function serializeItem(item) {
    // 基础数据结构
    var itemData = {
        "type": item.type,
        "id": item.id || generateId(item.type),
        "props": cloneObject(item.props || {}),
        "events": cloneObject(item.events || {})
    };

    // 处理子组件（针对容器类型）
    if (item.children && Array.isArray(item.children) && item.children.length > 0) {
        itemData.children = [];
        for (var i = 0; i < item.children.length; i++) {
            itemData.children.push(serializeItem(item.children[i]));
        }
    }

    return itemData;
}

/**
 * 将JSON字符串反序列化为表单模型
 * @param {String} jsonString - JSON字符串
 * @return {Array} 表单模型数组
 */
function deserialize(jsonString) {
    try {
        var data = JSON.parse(jsonString);
        
        // 验证JSON格式
        if (!data || typeof data !== 'object') {
            console.error("FormSerializer: 无效的JSON数据");
            return [];
        }

        // 兼容处理：如果是直接的数组，或者包含items属性的对象
        var items = [];
        if (Array.isArray(data)) {
            items = data;
        } else if (data.items && Array.isArray(data.items)) {
            items = data.items;
        } else {
            console.error("FormSerializer: JSON中未找到items数组");
            return [];
        }

        // 递归处理每个项，确保数据结构完整
        var formModel = [];
        for (var i = 0; i < items.length; i++) {
            formModel.push(deserializeItem(items[i]));
        }

        return formModel;
    } catch (e) {
        console.error("FormSerializer: JSON解析错误", e);
        return [];
    }
}

/**
 * 递归反序列化单个组件项
 */
function deserializeItem(itemData) {
    var item = {
        "type": itemData.type || "Unknown",
        "id": itemData.id || generateId(itemData.type || "Item"),
        "props": cloneObject(itemData.props || {}),
        "events": cloneObject(itemData.events || {})
    };

    // 处理子组件
    if (itemData.children && Array.isArray(itemData.children)) {
        item.children = [];
        for (var i = 0; i < itemData.children.length; i++) {
            item.children.push(deserializeItem(itemData.children[i]));
        }
    }

    return item;
}

/**
 * 深拷贝对象
 */
function cloneObject(obj) {
    if (obj === null || typeof obj !== 'object') {
        return obj;
    }
    
    // 处理数组
    if (Array.isArray(obj)) {
        var arrCopy = [];
        for (var i = 0; i < obj.length; i++) {
            arrCopy[i] = cloneObject(obj[i]);
        }
        return arrCopy;
    }
    
    // 处理对象
    var copy = {};
    for (var key in obj) {
        if (obj.hasOwnProperty(key)) {
            copy[key] = cloneObject(obj[key]);
        }
    }
    return copy;
}
