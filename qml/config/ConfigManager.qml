import QtQuick 6.5

/**
 * 配置管理器
 * 负责配置数据的管理和业务逻辑处理
 */
QtObject {
    id: configManager
    
    property var currentConfig: ({
        "grid": {
            "rows": 8,
            "columns": 2,
            "rowSpacing": 5,
            "columnSpacing": 10,
            "rowHeights": [1, 1, 1, 1, 1, 1, 1, 2],
            "columnWidths": [1, 2]
        },
        "controls": []
    })
    
    property bool initialized: false
    
    signal configChanged(var newConfig)
    signal internalConfigChanged(var newConfig)
    
    property var typeManagerLoader: Loader {
        source: "ControlTypeManager.qml"
    }
    property var typeManager: typeManagerLoader.item
    
    function updateGridConfig(gridConfig) {
        console.log("ConfigManager updateGridConfig called with:", JSON.stringify(gridConfig));
        currentConfig.grid = gridConfig;
        console.log("ConfigManager currentConfig.grid updated to:", JSON.stringify(currentConfig.grid));
        internalConfigChanged(currentConfig);
    }
    
    function addControl(type, position) {
        if (!typeManager) return null;
        var newControl = typeManager.createDefaultControl(type);
        
        if (position) {
            newControl.row = position.row;
            newControl.column = position.column;
        } else {
            var nextPos = getNextPosition();
            newControl.row = nextPos.row;
            newControl.column = nextPos.column;
        }
        
        if (!currentConfig.controls) {
            currentConfig.controls = [];
        }
        
        currentConfig.controls.push(newControl);
        console.log("ConfigManager addControl - current grid config:", JSON.stringify(currentConfig.grid));
        internalConfigChanged(currentConfig);
        
        return newControl;
    }
    
    function updateControl(index, controlConfig) {
        if (currentConfig.controls && index >= 0 && index < currentConfig.controls.length) {
            console.log("ConfigManager updateControl - updating control at index:", index);
            console.log("ConfigManager updateControl - new config:", JSON.stringify(controlConfig));
            currentConfig.controls[index] = controlConfig;
            // 强制触发数组变化
            var tempControls = currentConfig.controls.slice();
            currentConfig.controls = tempControls;
            console.log("ConfigManager updateControl - triggering internalConfigChanged");
            internalConfigChanged(currentConfig);
        }
    }
    
    function removeControl(index) {
        if (currentConfig.controls && index >= 0 && index < currentConfig.controls.length) {
            var removedControl = currentConfig.controls[index];
            console.log("ConfigManager removing control:", removedControl.label, "at index:", index);
            currentConfig.controls.splice(index, 1);
            console.log("ConfigManager controls count after removal:", currentConfig.controls.length);
            internalConfigChanged(currentConfig);
        }
    }
    
    function removeControlAtPosition(row, col) {
        if (!currentConfig.controls) return;
        
        console.log("ConfigManager removeControlAtPosition called for:", row, col);
        for (var i = 0; i < currentConfig.controls.length; i++) {
            var ctrl = currentConfig.controls[i];
            var ctrlRow = ctrl.row || 0;
            var ctrlCol = ctrl.column || 0;
            var ctrlRowSpan = ctrl.rowSpan || 1;
            var ctrlColSpan = ctrl.colSpan || 1;

            if (row >= ctrlRow && row < ctrlRow + ctrlRowSpan && 
                col >= ctrlCol && col < ctrlCol + ctrlColSpan) {
                console.log("Found control to remove:", ctrl.label, "at position", ctrlRow, ctrlCol);
                removeControl(i);
                return;
            }
        }
        console.log("No control found at position", row, col);
    }
    
    function getControlAtPosition(row, col) {
        if (!currentConfig.controls) return null;

        for (var i = 0; i < currentConfig.controls.length; i++) {
            var ctrl = currentConfig.controls[i];
            var ctrlRow = ctrl.row || 0;
            var ctrlCol = ctrl.column || 0;
            var ctrlRowSpan = ctrl.rowSpan || 1;
            var ctrlColSpan = ctrl.colSpan || 1;

            if (row >= ctrlRow && row < ctrlRow + ctrlRowSpan && 
                col >= ctrlCol && col < ctrlCol + ctrlColSpan) {
                return ctrl;
            }
        }
        return null;
    }
    
    function getControlIndex(control) {
        if (!currentConfig.controls) return -1;
        
        console.log("ConfigManager getControlIndex - looking for control:", JSON.stringify(control));
        
        for (var i = 0; i < currentConfig.controls.length; i++) {
            var currentControl = currentConfig.controls[i];
            // 使用多种方式比较控件
            if (currentControl === control || 
                (currentControl.key && control.key && currentControl.key === control.key) ||
                (currentControl.row === control.row && currentControl.column === control.column && currentControl.type === control.type)) {
                console.log("ConfigManager getControlIndex - found at index:", i);
                return i;
            }
        }
        console.log("ConfigManager getControlIndex - not found");
        return -1;
    }
    
    function getNextPosition() {
        if (!currentConfig.controls || currentConfig.controls.length === 0) {
            return { row: 0, column: 0 };
        }

        var gridRows = currentConfig.grid.rows || 8;
        var gridCols = currentConfig.grid.columns || 2;

        // 查找第一个空位置
        for (var row = 0; row < gridRows; row++) {
            for (var col = 0; col < gridCols; col++) {
                if (!getControlAtPosition(row, col)) {
                    return { row: row, column: col };
                }
            }
        }

        // 如果没有空位置，返回无效位置
        return { row: -1, column: -1 };
    }
    
    function resetConfig() {
        currentConfig = {
            "grid": {
                "rows": 8,
                "columns": 2,
                "rowSpacing": 5,
                "columnSpacing": 10,
                "rowHeights": [1, 1, 1, 1, 1, 1, 1, 2],
                "columnWidths": [1, 2]
            },
            "controls": []
        };
        internalConfigChanged(currentConfig);
    }
    
    function exportConfig() {
        return JSON.stringify(currentConfig, null, 2);
    }
    
    function importConfig(jsonString) {
        try {
            var config = JSON.parse(jsonString);
            currentConfig = config;
            initialized = true;
            configChanged(currentConfig);
            return true;
        } catch (e) {
            console.error("导入配置失败:", e);
            return false;
        }
    }
    
    // 初始化配置（从外部JSON加载）
    function initializeFromJson(jsonConfig) {
        if (!initialized && jsonConfig) {
            console.log("ConfigManager initializing from JSON config");
            currentConfig = jsonConfig;
            initialized = true;
            // 不触发configChanged，避免覆盖表单预览
        }
    }
}