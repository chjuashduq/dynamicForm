# AppStyles 移至 Common 目录说明

## ✅ 已完成的修改

### 1. 移动 AppStyles
- ✅ 创建 `qml/Common/AppStyles.qml`
- ✅ 删除 `qml/styles/AppStyles.qml`
- ✅ 删除 `qml/styles/qmldir`

### 2. 更新 qmldir
- ✅ 在 `qml/Common/qmldir` 中注册 AppStyles 单例

### 3. 更新 resources.qrc
- ✅ 移除 `qml/styles/AppStyles.qml`
- ✅ 移除 `qml/styles/qmldir`
- ✅ 添加 `qml/Common/AppStyles.qml`（已在 qmldir 中）

### 4. 更新所有导入语句
- ✅ `qml/components/StyledTextField.qml` - `import Common 1.0`
- ✅ `qml/components/StyledButton.qml` - `import Common 1.0`
- ✅ `qml/components/StyledLabel.qml` - `import Common 1.0`
- ✅ `qml/components/StyledComboBox.qml` - `import Common 1.0`
- ✅ `qml/components/StyledSpinBox.qml` - `import Common 1.0`
- ✅ `qml/render/ControlFactory.qml` - `import Common 1.0`
- ✅ `qml/render/FormPreview.qml` - `import Common 1.0`
- ✅ `qml/dynamic/dynamicList.qml` - `import Common 1.0`

## 📝 新的目录结构

```
qml/
├── Common/
│   ├── qmldir                    # 模块定义文件
│   ├── MessageManager.qml        # 消息管理器（单例）
│   └── AppStyles.qml             # 全局样式（单例）✨ 新位置
├── components/
│   ├── StyledTextField.qml
│   ├── StyledButton.qml
│   ├── StyledLabel.qml
│   ├── StyledComboBox.qml
│   └── StyledSpinBox.qml
├── render/
│   ├── ControlFactory.qml
│   └── FormPreview.qml
└── dynamic/
    └── dynamicList.qml
```

## 🎯 使用方式

### 统一的导入语句

现在所有文件都使用统一的导入：

```qml
import Common 1.0

// 使用 AppStyles
Rectangle {
    color: AppStyles.primaryColor
    radius: AppStyles.radiusMedium
}

// 使用 MessageManager
Button {
    onClicked: {
        MessageManager.showToast("消息", "info")
    }
}
```

### Common 模块包含

- **MessageManager** - 消息管理器
- **AppStyles** - 全局样式配置

## ✨ 优势

1. **统一管理**：所有全局单例都在 Common 目录中
2. **简化导入**：只需要 `import Common 1.0`
3. **符合规范**：Common 目录用于存放公共组件和工具
4. **易于维护**：相关功能集中在一起

## 🚀 下一步

**重新编译项目**，AppStyles 现在已经正确集成到 Common 模块中。

```bash
# 清理构建
rm -rf build

# 重新构建
mkdir build
cd build
cmake ..
cmake --build .
```

## 🔍 验证

编译后运行应用，应该看到：
- ✅ 美化的输入框
- ✅ 美化的按钮
- ✅ 美化的标签
- ✅ 美化的下拉框
- ✅ 美化的数字输入框
- ✅ 统一的颜色和样式

如果出现 "module 'Common' is not installed" 错误，请确保：
1. `qml/Common/qmldir` 文件存在
2. `qml/Common/AppStyles.qml` 文件存在
3. resources.qrc 包含这两个文件
4. 已重新编译项目

## 📋 总结

AppStyles 已成功移至 Common 目录，现在：
- ✅ 与 MessageManager 在同一模块中
- ✅ 使用统一的 `import Common 1.0` 导入
- ✅ 所有文件已更新
- ✅ 旧的 styles 目录已删除

重新编译后即可使用！🎉
