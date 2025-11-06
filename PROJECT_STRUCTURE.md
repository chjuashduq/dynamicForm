# 动态表单QML项目结构文档

## 项目概述
这是一个基于Qt QML的动态表单生成器，支持通过JSON配置动态创建表单界面，包含表单预览和配置编辑两个主要功能模块。

## 项目架构
```
DynamicFormQML/
├── 核心C++文件
├── QML界面文件
├── 配置文件
└── 构建文件
```

## 详细文件结构

### 🔧 核心C++文件
```
├── main.cpp                    # 应用程序入口点
├── mainwindow.cpp             # 主窗口实现
├── mainwindow.h               # 主窗口头文件
└── mainwindow.ui              # 主窗口UI设计文件
```

#### main.cpp (行级说明)
```cpp
1-10:   头文件包含和命名空间声明
11-15:  Windows平台特定头文件
17:     主函数开始
18:     创建QApplication实例
19-22:  QML调试器设置（已禁用避免闪退）
24-33:  Windows控制台设置（仅调试模式）
35:     设置中文区域
37-38:  创建并显示主窗口
40:     进入事件循环
```

### 🎨 QML界面文件

#### 📁 根目录 (qml/)
```
qml/
├── main.qml                   # 主界面，Tab切换容器
├── config/                    # 配置编辑模块
├── render/                    # 表单渲染模块
└── core/                      # 核心功能模块
```

#### main.qml (行级说明)
```qml
1-3:    导入Qt模块
5-8:    文档注释
9-12:   根组件定义和尺寸设置
14-15:  表单配置和控件映射属性
17-19:  组件完成回调
21-32:  Tab栏定义（表单预览/配置编辑器）
34-67:  StackLayout容器，包含两个Tab页面
```

#### 📁 配置编辑模块 (qml/config/)
```
config/
├── ConfigEditor.qml           # 配置编辑器主界面
├── ControlTypeEditor.qml      # 控件类型特定属性编辑器
├── managers/                  # 管理器组件
│   ├── ConfigManager.qml      # 配置数据管理器
│   └── ControlTypeManager.qml # 控件类型管理器
├── panels/                    # 面板组件
│   ├── GridConfigPanel.qml    # 网格配置面板
│   ├── GridPreview.qml        # 网格预览组件
│   └── ControlToolbar.qml     # 控件工具栏
└── dialog/                    # 对话框组件
    ├── ControlEditDialog.qml  # 控件编辑对话框
    ├── BasicPropertiesPanel.qml # 基础属性面板
    ├── EventConfigPanel.qml   # 事件配置面板
    └── FunctionHelpDialog.qml # 函数帮助对话框
```

##### ConfigEditor.qml (行级说明)
```qml
1-4:    导入声明
6-16:   文档注释和版本信息
17-22:  组件定义和基础属性
24:     配置变化信号定义
26-38:  ConfigManager加载器和信号连接
40:     configManager属性别名
42-66:  组件初始化连接处理
68-88:  GridPreview信号连接函数
90-96:  延迟信号连接定时器
98-220: 主界面布局（标题、配置面板、工具栏、预览区域、按钮）
222-238: 编辑对话框加载器
240:    editDialog别名定义
```

##### GridPreview.qml (行级说明)
```qml
1-2:    导入声明
4-7:    文档注释
8-12:   组件定义和属性
14-17:  配置变化处理
19-22:  控件变化处理
24-26:  信号定义
28-32:  组件尺寸和位置设置
34:     高度属性
36-38:  高度变化处理
40-42:  高度属性变化处理
44-62:  高度计算函数
64-67:  外观样式设置
69-73:  类型管理器加载
75-200: Grid布局和Repeater（网格单元格）
202-248: 辅助函数（宽度、高度、位置计算等）
250-252: 组件完成回调
254-270: 定时器定义
272-282: 刷新函数
```

#### 📁 表单渲染模块 (qml/render/)
```
render/
├── FormPreview.qml            # 表单预览主组件
└── ControlFactory.qml         # 控件工厂
```

##### FormPreview.qml (行级说明)
```qml
1-4:    导入声明
6-9:    文档注释
10-14:  组件定义和属性
16-20:  配置变化监听
22-32:  核心组件实例（API、脚本引擎、控件工厂）
34-37:  延迟加载定时器
39-78:  消息提示组件
80-180: 主网格布局和表单加载逻辑
182-185: 公共重载方法
```

##### ControlFactory.qml (行级说明)
```qml
1-4:    导入声明
6-9:    文档注释
10-12:  组件定义和预编译组件
14-20:  外部依赖属性
22-30:  创建控件主函数
32-150: 私有辅助函数（标签、输入控件、样式、事件绑定）
```

#### 📁 核心功能模块 (qml/core/)
```
core/
├── FormAPI.qml                # 表单操作API库
└── ScriptEngine.qml           # JavaScript执行引擎
```

##### FormAPI.qml (行级说明)
```qml
1:      导入声明
3-6:    文档注释
7-12:   组件定义和属性
14-140: API函数定义（获取/设置值、样式控制、验证等）
```

##### ScriptEngine.qml (行级说明)
```qml
1:      导入声明
3-6:    文档注释
7-10:   组件定义和属性
12-70:  JavaScript函数执行引擎
```

### 📋 配置文件
```
├── form_config.json           # 示例表单配置文件
├── resources.qrc              # Qt资源文件
└── CMakeLists.txt             # CMake构建配置
```

### 🔨 构建文件
```
├── CMakeLists.txt             # 主CMake配置
├── CMakeLists.txt.user        # Qt Creator用户配置
└── build/                     # 构建输出目录
```

## 组件职责说明

### 🎯 主要组件职责

| 组件 | 职责 | 关键功能 |
|------|------|----------|
| **main.qml** | 应用主界面 | Tab切换、组件协调 |
| **ConfigEditor.qml** | 配置编辑器 | 组件加载、信号连接、界面布局 |
| **GridPreview.qml** | 网格预览 | 网格显示、高度计算、交互处理 |
| **FormPreview.qml** | 表单预览 | 表单渲染、控件创建、布局管理 |
| **ControlFactory.qml** | 控件工厂 | 动态创建各类表单控件 |
| **ConfigManager.qml** | 配置管理 | 配置数据CRUD、业务逻辑 |
| **FormAPI.qml** | 表单API | 控件操作、验证、消息显示 |
| **ScriptEngine.qml** | 脚本引擎 | JavaScript代码执行 |

### 🔄 数据流向

```
JSON配置 → ConfigManager → GridPreview (配置编辑)
                        ↓
JSON配置 → FormPreview → ControlFactory (表单渲染)
                      ↓
                   FormAPI ← ScriptEngine (交互处理)
```

### 🎨 界面层次结构

```
main.qml (根容器)
├── TabBar (标签栏)
└── StackLayout (页面容器)
    ├── FormPreview (表单预览页)
    │   └── GridLayout (表单网格)
    │       └── 动态控件
    └── ConfigEditor (配置编辑页)
        ├── GridConfigPanel (网格配置)
        ├── ControlToolbar (控件工具栏)
        ├── GridPreview (预览网格)
        └── ControlEditDialog (编辑对话框)
```

## 技术特点

### ✨ 核心特性
- **动态表单生成**: 基于JSON配置动态创建表单
- **可视化编辑**: 拖拽式配置界面
- **实时预览**: 配置变化实时反映
- **脚本支持**: 支持JavaScript事件处理
- **多控件类型**: 支持文本、数字、下拉、复选等控件

### 🏗️ 架构优势
- **模块化设计**: 组件职责单一，易于维护
- **松耦合**: 通过信号槽机制通信
- **可扩展**: 易于添加新的控件类型
- **响应式**: 自适应布局和高度计算

### 🔧 技术栈
- **Qt 6.5**: 跨平台应用框架
- **QML**: 声明式UI语言
- **JavaScript**: 脚本执行引擎
- **CMake**: 构建系统
- **JSON**: 配置数据格式

## 开发指南

### 📝 添加新控件类型
1. 在 `ControlTypeManager.qml` 中添加类型定义
2. 在 `ControlFactory.qml` 中实现创建逻辑
3. 在 `ControlTypeEditor.qml` 中添加属性编辑界面

### 🎨 修改界面样式
- 主要样式定义在各组件的 `color`、`border` 等属性中
- 统一的颜色方案可在组件顶部定义

### 🔍 调试技巧
- 使用 `console.log()` 输出调试信息（已清理）
- 通过边框颜色可视化组件边界（已移除）
- 利用Qt Creator的QML调试器

---

*文档生成时间: 2024年*
*项目版本: 2.0*