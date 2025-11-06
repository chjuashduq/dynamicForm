import QtQuick 6.5                                    // 导入Qt Quick 6.5模块

/**
 * 配置管理器
 * 负责配置数据的管理和业务逻辑处理
 * 
 * 主要功能：
 * - 管理表单配置数据（网格布局、控件列表）
 * - 提供控件的增删改查操作
 * - 处理配置的导入导出
 * - 管理控件在网格中的位置分配
 */
QtObject {                                          // 定义配置管理器对象
    id: configManager                               // 组件唯一标识符
    
    // 当前表单配置数据，包含网格配置和控件列表
    property var currentConfig: ({                  // 主配置对象，存储所有表单配置信息
        "grid": {                                   // 网格布局配置
            "rows": 8,                              // 网格行数，默认8行
            "columns": 2,                           // 网格列数，默认2列
            "rowSpacing": 5,                        // 行间距，单位像素
            "columnSpacing": 10,                    // 列间距，单位像素
            "rowHeights": [1, 1, 1, 1, 1, 1, 1, 2], // 各行高度比例，最后一行高度为其他行的2倍
            "columnWidths": [1, 2]                  // 各列宽度比例，第二列宽度为第一列的2倍
        },
        "controls": []                              // 控件列表，存储所有表单控件的配置信息
    })
    
    // 初始化状态标志，用于防止重复初始化
    property bool initialized: false                // 标记配置管理器是否已完成初始化
    
    // 配置变化信号，用于通知外部组件配置已更新
    signal configChanged(var newConfig)            // 外部配置变化信号，用于应用配置到表单预览
    signal internalConfigChanged(var newConfig)    // 内部配置变化信号，用于更新配置编辑器界面
    
    // 控件类型管理器加载器，用于创建和管理不同类型的控件
    property var typeManagerLoader: Loader {       // 动态加载控件类型管理器
        source: "ControlTypeManager.qml"           // 控件类型管理器文件路径
    }
    property var typeManager: typeManagerLoader.item // 控件类型管理器实例的引用
    
    /**
     * 更新网格配置
     * @param gridConfig 新的网格配置对象，包含行数、列数、间距等信息
     */
    function updateGridConfig(gridConfig) {         // 更新网格布局配置的函数
        currentConfig.grid = gridConfig;            // 将新的网格配置赋值给当前配置
        internalConfigChanged(currentConfig);       // 触发内部配置变化信号，通知界面更新
    }
    
    /**
     * 添加新控件到表单配置中
     * @param type 控件类型（如"text", "number", "button"等）
     * @param position 可选的位置对象，包含row和column属性
     * @return 返回创建的控件配置对象，失败时返回null
     */
    function addControl(type, position) {           // 添加新控件的函数
        if (!typeManager) return null;              // 如果类型管理器未加载，返回null
        var newControl = typeManager.createDefaultControl(type); // 使用类型管理器创建默认控件配置
        
        if (position) {                             // 如果指定了位置参数
            newControl.row = position.row;          // 设置控件所在行
            newControl.column = position.column;    // 设置控件所在列
        } else {                                    // 如果未指定位置
            var nextPos = getNextPosition();        // 自动查找下一个可用位置
            newControl.row = nextPos.row;           // 设置控件行位置
            newControl.column = nextPos.column;     // 设置控件列位置
        }
        
        if (!currentConfig.controls) {              // 如果控件列表不存在
            currentConfig.controls = [];            // 初始化控件列表为空数组
        }
        
        currentConfig.controls.push(newControl);   // 将新控件添加到控件列表末尾
        internalConfigChanged(currentConfig);      // 触发内部配置变化信号
        
        return newControl;                          // 返回创建的控件配置对象
    }
    
    /**
     * 更新指定索引位置的控件配置
     * @param index 控件在列表中的索引位置
     * @param controlConfig 新的控件配置对象
     */
    function updateControl(index, controlConfig) {  // 更新控件配置的函数
        // 验证控件列表存在且索引有效
        if (currentConfig.controls && index >= 0 && index < currentConfig.controls.length) {
            currentConfig.controls[index] = controlConfig; // 更新指定索引位置的控件配置
            // 强制触发数组变化，确保QML能检测到数组内容的改变
            var tempControls = currentConfig.controls.slice(); // 创建数组的浅拷贝
            currentConfig.controls = tempControls;     // 重新赋值以触发属性变化信号
            internalConfigChanged(currentConfig);      // 触发内部配置变化信号
        }
    }
    
    /**
     * 根据索引删除控件
     * @param index 要删除的控件在列表中的索引位置
     */
    function removeControl(index) {                 // 删除控件的函数
        // 验证控件列表存在且索引有效
        if (currentConfig.controls && index >= 0 && index < currentConfig.controls.length) {
            currentConfig.controls.splice(index, 1); // 从数组中删除指定索引的控件
            internalConfigChanged(currentConfig);    // 触发内部配置变化信号
        }
    }
    
    /**
     * 根据网格位置删除控件
     * @param row 网格行位置
     * @param col 网格列位置
     */
    function removeControlAtPosition(row, col) {    // 根据位置删除控件的函数
        if (!currentConfig.controls) return;       // 如果控件列表不存在，直接返回
        
        // 遍历所有控件，查找占用指定位置的控件
        for (var i = 0; i < currentConfig.controls.length; i++) {
            var ctrl = currentConfig.controls[i];  // 获取当前遍历的控件
            var ctrlRow = ctrl.row || 0;            // 控件起始行位置，默认为0
            var ctrlCol = ctrl.column || 0;         // 控件起始列位置，默认为0
            var ctrlRowSpan = ctrl.rowSpan || 1;    // 控件跨越的行数，默认为1
            var ctrlColSpan = ctrl.colSpan || 1;    // 控件跨越的列数，默认为1

            // 检查指定位置是否在当前控件的占用范围内
            if (row >= ctrlRow && row < ctrlRow + ctrlRowSpan && 
                col >= ctrlCol && col < ctrlCol + ctrlColSpan) {
                removeControl(i);                   // 删除找到的控件
                return;                             // 删除后立即返回，避免继续遍历
            }
        }
    }
    
    /**
     * 获取指定网格位置的控件
     * @param row 网格行位置
     * @param col 网格列位置
     * @return 返回占用该位置的控件配置对象，如果没有控件则返回null
     */
    function getControlAtPosition(row, col) {       // 根据位置获取控件的函数
        if (!currentConfig.controls) return null;  // 如果控件列表不存在，返回null

        // 遍历所有控件，查找占用指定位置的控件
        for (var i = 0; i < currentConfig.controls.length; i++) {
            var ctrl = currentConfig.controls[i];  // 获取当前遍历的控件
            var ctrlRow = ctrl.row || 0;            // 控件起始行位置，默认为0
            var ctrlCol = ctrl.column || 0;         // 控件起始列位置，默认为0
            var ctrlRowSpan = ctrl.rowSpan || 1;    // 控件跨越的行数，默认为1
            var ctrlColSpan = ctrl.colSpan || 1;    // 控件跨越的列数，默认为1

            // 检查指定位置是否在当前控件的占用范围内
            if (row >= ctrlRow && row < ctrlRow + ctrlRowSpan && 
                col >= ctrlCol && col < ctrlCol + ctrlColSpan) {
                return ctrl;                        // 返回找到的控件配置对象
            }
        }
        return null;                                // 如果没有找到控件，返回null
    }
    
    /**
     * 获取控件在列表中的索引位置
     * @param control 要查找的控件配置对象
     * @return 返回控件的索引位置，如果未找到则返回-1
     */
    function getControlIndex(control) {             // 获取控件索引的函数
        if (!currentConfig.controls) return -1;    // 如果控件列表不存在，返回-1
        
        // 遍历控件列表，查找匹配的控件
        for (var i = 0; i < currentConfig.controls.length; i++) {
            var currentControl = currentConfig.controls[i]; // 获取当前遍历的控件
            // 使用多种方式比较控件，提高匹配的准确性
            if (currentControl === control ||       // 直接对象引用比较
                (currentControl.key && control.key && currentControl.key === control.key) || // 通过唯一key比较
                (currentControl.row === control.row && currentControl.column === control.column && currentControl.type === control.type)) { // 通过位置和类型比较
                return i;                           // 返回找到的控件索引
            }
        }
        return -1;                                  // 如果没有找到匹配的控件，返回-1
    }
    
    /**
     * 获取网格中下一个可用的空位置
     * @return 返回包含row和column属性的位置对象，如果没有空位置则返回{row: -1, column: -1}
     */
    function getNextPosition() {                    // 获取下一个可用位置的函数
        // 如果没有控件或控件列表为空，返回起始位置(0,0)
        if (!currentConfig.controls || currentConfig.controls.length === 0) {
            return { row: 0, column: 0 };           // 返回网格左上角位置
        }

        var gridRows = currentConfig.grid.rows || 8;    // 获取网格总行数，默认8行
        var gridCols = currentConfig.grid.columns || 2; // 获取网格总列数，默认2列

        // 按行优先顺序查找第一个空位置
        for (var row = 0; row < gridRows; row++) {      // 遍历所有行
            for (var col = 0; col < gridCols; col++) {  // 遍历当前行的所有列
                if (!getControlAtPosition(row, col)) {  // 检查当前位置是否为空
                    return { row: row, column: col };   // 返回找到的空位置
                }
            }
        }

        // 如果网格已满，没有空位置，返回无效位置标识
        return { row: -1, column: -1 };             // 返回无效位置，表示网格已满
    }
    
    /**
     * 重置配置为默认值
     * 清除所有控件并恢复默认的网格设置
     */
    function resetConfig() {                        // 重置配置的函数
        currentConfig = {                           // 重新设置为默认配置
            "grid": {                               // 默认网格配置
                "rows": 8,                          // 8行网格
                "columns": 2,                       // 2列网格
                "rowSpacing": 5,                    // 行间距5像素
                "columnSpacing": 10,                // 列间距10像素
                "rowHeights": [1, 1, 1, 1, 1, 1, 1, 2], // 行高比例，最后一行为其他行的2倍
                "columnWidths": [1, 2]              // 列宽比例，第二列为第一列的2倍
            },
            "controls": []                          // 清空控件列表
        };
        internalConfigChanged(currentConfig);      // 触发内部配置变化信号
    }
    
    /**
     * 导出当前配置为JSON字符串
     * @return 返回格式化的JSON字符串，包含完整的表单配置
     */
    function exportConfig() {                      // 导出配置的函数
        return JSON.stringify(currentConfig, null, 2); // 将配置对象转换为格式化的JSON字符串
    }
    
    /**
     * 从JSON字符串导入配置
     * @param jsonString 包含表单配置的JSON字符串
     * @return 返回true表示导入成功，false表示导入失败
     */
    function importConfig(jsonString) {            // 导入配置的函数
        try {                                      // 尝试解析JSON字符串
            var config = JSON.parse(jsonString);   // 将JSON字符串解析为配置对象
            currentConfig = config;                 // 更新当前配置
            initialized = true;                     // 标记为已初始化
            configChanged(currentConfig);          // 触发外部配置变化信号
            return true;                            // 返回成功标识
        } catch (e) {                              // 捕获JSON解析错误
            return false;                           // 返回失败标识
        }
    }
    
    /**
     * 从外部JSON配置对象初始化配置管理器
     * 仅在未初始化状态下执行，避免重复初始化
     * @param jsonConfig 外部传入的配置对象
     */
    function initializeFromJson(jsonConfig) {      // 从JSON对象初始化配置的函数
        if (!initialized && jsonConfig) {          // 仅在未初始化且有配置数据时执行
            currentConfig = jsonConfig;             // 设置当前配置为传入的配置
            initialized = true;                     // 标记为已初始化
            // 注意：这里不触发configChanged信号，避免覆盖表单预览的现有内容
        }
    }
}