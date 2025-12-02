# QML 完全学习教程 - 第1章：基础入门

## 📚 目录
1. [什么是 QML](#什么是-qml)
2. [QML 基本语法](#qml-基本语法)
3. [第一个 QML 程序](#第一个-qml-程序)
4. [基本元素类型](#基本元素类型)
5. [属性系统](#属性系统)

---

## 什么是 QML

### QML 简介
**QML (Qt Modeling Language)** 是一种声明式语言,用于设计用户界面。它是 Qt Quick 的一部分。

**核心特点:**
- 📝 **声明式语法** - 描述界面"是什么",而不是"怎么做"
- 🎨 **CSS-like 样式** - 类似 CSS 的属性设置方式
- ⚡ **高性能** - 基于 OpenGL 的硬件加速渲染
- 🔄 **动态绑定** - 属性之间可以自动关联更新
- 🧩 **组件化** - 易于创建和复用组件

### QML vs 传统 UI 框架

| 特性 | QML | HTML/CSS | Qt Widgets |
|------|-----|----------|------------|
| 语法风格 | 声明式 | 声明式 | 命令式 |
| 学习曲线 | 中等 | 简单 | 较难 |
| 性能 | 高 | 中 | 高 |
| 跨平台 | ✅ | ✅ | ✅ |
| 动画支持 | 优秀 | 良好 | 一般 |

---

## QML 基本语法

### 1. 文件结构

```qml
// 导入语句
import QtQuick 6.5
import QtQuick.Controls 6.5

// 根元素
Rectangle {
    // 属性
    width: 400
    height: 300
    color: "lightblue"
    
    // 子元素
    Text {
        text: "Hello QML"
        anchors.centerIn: parent
    }
}
```

### 2. 注释

```qml
// 单行注释

/*
   多行注释
   可以跨越多行
*/
```

### 3. 导入模块

```qml
import QtQuick 6.5              // Qt Quick 核心模块
import QtQuick.Controls 6.5     // 控件模块
import QtQuick.Layouts 1.4      // 布局模块
import QtQuick.Window 2.15      // 窗口模块
```

**自定义模块导入:**
```qml
import "."                      // 导入当前目录
import "../components"          // 导入相对路径
import Common 1.0               // 导入命名模块
```

---

## 第一个 QML 程序

### 示例 1: Hello World

创建文件 `HelloWorld.qml`:

```qml
import QtQuick 6.5
import QtQuick.Controls 6.5

// 应用程序窗口
ApplicationWindow {
    // 窗口属性
    width: 400
    height: 300
    visible: true
    title: "我的第一个 QML 程序"
    
    // 窗口内容
    Rectangle {
        anchors.fill: parent
        color: "#f0f0f0"
        
        Text {
            text: "Hello, QML!"
            font.pixelSize: 32
            font.bold: true
            color: "#333333"
            anchors.centerIn: parent
        }
    }
}
```

**代码解析:**
- `ApplicationWindow` - 应用程序主窗口
- `width/height` - 设置窗口大小
- `visible: true` - 显示窗口
- `anchors.fill: parent` - 填充父元素
- `anchors.centerIn: parent` - 在父元素中居中

### 示例 2: 带按钮的界面

```qml
import QtQuick 6.5
import QtQuick.Controls 6.5

ApplicationWindow {
    width: 400
    height: 300
    visible: true
    title: "按钮示例"
    
    Column {
        anchors.centerIn: parent
        spacing: 20
        
        Text {
            text: "点击次数: " + clickCount
            font.pixelSize: 24
        }
        
        Button {
            text: "点击我"
            onClicked: {
                clickCount++
            }
        }
    }
    
    // 属性定义
    property int clickCount: 0
}
```

**新概念:**
- `Column` - 垂直布局容器
- `spacing` - 子元素间距
- `property` - 自定义属性
- `onClicked` - 点击事件处理

---

## 基本元素类型

### 1. Item - 基础元素

`Item` 是所有可视元素的基类,本身不可见。

```qml
Item {
    width: 100
    height: 100
    
    // Item 本身不可见,但可以包含子元素
    Rectangle {
        anchors.fill: parent
        color: "red"
    }
}
```

**常用属性:**
- `x, y` - 位置坐标
- `width, height` - 尺寸
- `visible` - 是否可见
- `enabled` - 是否启用
- `opacity` - 透明度 (0-1)

### 2. Rectangle - 矩形

最常用的可视元素,可以绘制矩形和圆角矩形。

```qml
Rectangle {
    width: 200
    height: 100
    color: "#409EFF"        // 填充颜色
    border.color: "#333"    // 边框颜色
    border.width: 2         // 边框宽度
    radius: 8               // 圆角半径
}
```

**渐变效果:**
```qml
Rectangle {
    width: 200
    height: 100
    
    gradient: Gradient {
        GradientStop { position: 0.0; color: "#409EFF" }
        GradientStop { position: 1.0; color: "#67C23A" }
    }
}
```

### 3. Text - 文本

显示文本内容。

```qml
Text {
    text: "这是一段文本"
    font.pixelSize: 16      // 字体大小
    font.bold: true         // 粗体
    font.italic: false      // 斜体
    font.family: "Arial"    // 字体族
    color: "#333333"        // 文字颜色
    
    // 文本对齐
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
    
    // 文本换行
    wrapMode: Text.WordWrap
    elide: Text.ElideRight  // 省略号
}
```

### 4. Image - 图片

显示图片。

```qml
Image {
    source: "images/logo.png"   // 图片路径
    width: 100
    height: 100
    fillMode: Image.PreserveAspectFit  // 填充模式
    
    // 平滑缩放
    smooth: true
    antialiasing: true
}
```

**填充模式:**
- `Image.Stretch` - 拉伸填充
- `Image.PreserveAspectFit` - 保持比例,适应大小
- `Image.PreserveAspectCrop` - 保持比例,裁剪填充
- `Image.Tile` - 平铺
- `Image.Pad` - 不缩放

### 5. MouseArea - 鼠标区域

处理鼠标事件的不可见元素。

```qml
Rectangle {
    width: 100
    height: 100
    color: "lightblue"
    
    MouseArea {
        anchors.fill: parent
        
        onClicked: {
            console.log("点击了矩形")
        }
        
        onPressed: {
            parent.color = "blue"
        }
        
        onReleased: {
            parent.color = "lightblue"
        }
        
        onEntered: {
            console.log("鼠标进入")
        }
        
        onExited: {
            console.log("鼠标离开")
        }
    }
}
```

---

## 属性系统

### 1. 属性定义

```qml
Item {
    // 基本类型属性
    property int count: 0
    property string name: "张三"
    property bool isActive: true
    property real price: 99.99
    property color bgColor: "#409EFF"
    
    // 对象类型属性
    property var data: ({name: "test", value: 123})
    property list<int> numbers: [1, 2, 3, 4, 5]
}
```

**属性类型:**
- `int` - 整数
- `real` - 浮点数
- `string` - 字符串
- `bool` - 布尔值
- `color` - 颜色
- `date` - 日期
- `var` - 任意类型
- `list<Type>` - 列表

### 2. 属性绑定

属性可以绑定到表达式,当表达式中的值变化时,属性自动更新。

```qml
Rectangle {
    width: 200
    height: 100
    
    Text {
        // 绑定到父元素的宽度
        text: "宽度: " + parent.width
        
        // 绑定到计算表达式
        x: parent.width / 2 - width / 2
        y: parent.height / 2 - height / 2
    }
}
```

**动态绑定示例:**
```qml
Rectangle {
    id: box
    width: 100
    height: 100
    color: "red"
    
    // 颜色绑定到宽度
    color: width > 150 ? "green" : "red"
    
    MouseArea {
        anchors.fill: parent
        onClicked: {
            // 改变宽度会自动更新颜色
            box.width = box.width + 20
        }
    }
}
```

### 3. 属性别名

使用 `alias` 创建属性别名,指向其他属性。

```qml
Rectangle {
    id: container
    
    // 创建别名,暴露内部元素的属性
    property alias labelText: label.text
    property alias labelColor: label.color
    
    Text {
        id: label
        text: "默认文本"
        color: "black"
    }
}

// 使用别名
container.labelText = "新文本"
container.labelColor = "red"
```

### 4. 只读属性

```qml
Item {
    // 只读属性
    readonly property int maxValue: 100
    
    // 尝试修改会报错
    // maxValue = 200  // 错误!
}
```

---

## 💡 实战练习

### 练习 1: 创建一个计数器

```qml
import QtQuick 6.5
import QtQuick.Controls 6.5

ApplicationWindow {
    width: 300
    height: 200
    visible: true
    title: "计数器"
    
    property int counter: 0
    
    Column {
        anchors.centerIn: parent
        spacing: 20
        
        Text {
            text: "计数: " + counter
            font.pixelSize: 32
            anchors.horizontalCenter: parent.horizontalCenter
        }
        
        Row {
            spacing: 10
            anchors.horizontalCenter: parent.horizontalCenter
            
            Button {
                text: "-"
                onClicked: counter--
            }
            
            Button {
                text: "+"
                onClicked: counter++
            }
            
            Button {
                text: "重置"
                onClicked: counter = 0
            }
        }
    }
}
```

### 练习 2: 颜色选择器

```qml
import QtQuick 6.5
import QtQuick.Controls 6.5

ApplicationWindow {
    width: 400
    height: 300
    visible: true
    title: "颜色选择器"
    
    Column {
        anchors.centerIn: parent
        spacing: 20
        
        Rectangle {
            width: 200
            height: 200
            color: Qt.rgba(redSlider.value, greenSlider.value, blueSlider.value, 1)
            border.color: "#333"
            border.width: 2
            radius: 8
        }
        
        Column {
            spacing: 10
            
            Row {
                spacing: 10
                Text { text: "红:"; width: 30 }
                Slider {
                    id: redSlider
                    from: 0
                    to: 1
                    value: 0.5
                }
            }
            
            Row {
                spacing: 10
                Text { text: "绿:"; width: 30 }
                Slider {
                    id: greenSlider
                    from: 0
                    to: 1
                    value: 0.5
                }
            }
            
            Row {
                spacing: 10
                Text { text: "蓝:"; width: 30 }
                Slider {
                    id: blueSlider
                    from: 0
                    to: 1
                    value: 0.5
                }
            }
        }
    }
}
```

---

## 📝 小结

本章学习了:
- ✅ QML 的基本概念和特点
- ✅ QML 文件的基本结构
- ✅ 常用的基本元素类型
- ✅ 属性系统和属性绑定
- ✅ 简单的交互示例

**下一章预告:** 布局系统 - 学习如何使用各种布局管理器组织界面元素

---

## 🔗 相关资源

- [Qt 官方文档](https://doc.qt.io/qt-6/qmlapplications.html)
- [QML 类型参考](https://doc.qt.io/qt-6/qmltypes.html)
- [Qt Quick 示例](https://doc.qt.io/qt-6/qtquick-codesamples.html)
