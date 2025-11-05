# 重构后组件加载问题解决方案

## 问题描述
重构后的组件无法正常加载，出现以下错误：
- `Type ConfigManager unavailable`
- `Cannot assign to non-existent default property`

## 解决方案

### 1. 使用Loader动态加载组件
由于QML的组件查找机制，自定义组件需要通过Loader动态加载：

```qml
Loader {
    id: configManagerLoader
    source: "ConfigManager.qml"
    onLoaded: {
        // 初始化逻辑
    }
}
property var configManager: configManagerLoader.item
```

### 2. 添加空值检查
所有对动态加载组件的访问都需要添加空值检查：

```qml
// 错误的方式
model: typeManager.controlTypes

// 正确的方式  
model: typeManager ? typeManager.controlTypes : []
```

### 3. 正确的初始化顺序
使用Connections确保组件按正确顺序初始化：

```qml
Connections {
    target: configManagerLoader
    function onLoaded() {
        // 在这里初始化依赖组件
    }
}
```

## 测试步骤

1. 启动应用程序
2. 切换到"配置编辑器"标签页
3. 检查是否显示网格配置面板
4. 检查是否显示控件工具栏
5. 检查是否显示网格预览
6. 尝试添加控件
7. 尝试编辑控件

## 常见问题

### Q: 组件显示空白
A: 检查Loader的source路径是否正确，确保所有QML文件都在resources.qrc中注册

### Q: 点击按钮无响应  
A: 检查信号连接是否正确，确保在onLoaded中建立连接

### Q: 属性访问错误
A: 添加空值检查，使用三元运算符或条件判断