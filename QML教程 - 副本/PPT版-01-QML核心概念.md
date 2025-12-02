# QML 核心概念 - PPT 版 🎯

## 幻灯片 1: QML 是什么？

```mermaid
graph LR
    A[QML] --> B[声明式语言]
    A --> C[用于UI设计]
    A --> D[基于JavaScript]
    A --> E[Qt Quick的一部分]
    
    style A fill:#409EFF,color:#fff
    style B fill:#67C23A,color:#fff
    style C fill:#E6A23C,color:#fff
    style D fill:#F56C6C,color:#fff
    style E fill:#909399,color:#fff
```

### 核心特点
- 🎨 **声明式** - 描述"是什么"而非"怎么做"
- ⚡ **高性能** - GPU 加速渲染
- 🔄 **动态绑定** - 属性自动更新
- 🧩 **组件化** - 易于复用

---

## 幻灯片 2: QML vs 其他技术

```mermaid
graph TB
    subgraph QML
        A1[声明式语法]
        A2[高性能]
        A3[跨平台]
        A4[动画丰富]
    end
    
    subgraph HTML/CSS
        B1[声明式语法]
        B2[中等性能]
        B3[Web平台]
        B4[动画良好]
    end
    
    subgraph Qt Widgets
        C1[命令式语法]
        C2[高性能]
        C3[跨平台]
        C4[动画一般]
    end
    
    style A1 fill:#67C23A
    style A2 fill:#67C23A
    style A3 fill:#67C23A
    style A4 fill:#67C23A
```

---

## 幻灯片 3: QML 文件结构

```mermaid
graph TD
    A[QML 文件] --> B[导入语句]
    A --> C[根元素]
    C --> D[属性]
    C --> E[子元素]
    C --> F[函数]
    C --> G[信号处理器]
    
    style A fill:#409EFF,color:#fff
    style B fill:#E6A23C,color:#fff
    style C fill:#67C23A,color:#fff
    style D fill:#F56C6C,color:#fff
    style E fill:#F56C6C,color:#fff
    style F fill:#F56C6C,color:#fff
    style G fill:#F56C6C,color:#fff
```

### 代码示例
```qml
import QtQuick 6.5          // 导入

Rectangle {                 // 根元素
    width: 400             // 属性
    height: 300
    color: "lightblue"
    
    Text {                 // 子元素
        text: "Hello"
        anchors.centerIn: parent
    }
    
    function sayHi() {     // 函数
        console.log("Hi!")
    }
    
    onClicked: sayHi()     // 信号处理器
}
```

---

## 幻灯片 4: 基本元素对比

```mermaid
graph LR
    A[基本元素] --> B[Item<br/>不可见基类]
    A --> C[Rectangle<br/>矩形/圆角]
    A --> D[Text<br/>文本显示]
    A --> E[Image<br/>图片显示]
    A --> F[MouseArea<br/>鼠标交互]
    
    style A fill:#409EFF,color:#fff
    style B fill:#909399,color:#fff
    style C fill:#67C23A,color:#fff
    style D fill:#E6A23C,color:#fff
    style E fill:#F56C6C,color:#fff
    style F fill:#409EFF,color:#fff
```

### 使用场景
| 元素 | 用途 | 可见性 |
|------|------|--------|
| Item | 容器、布局 | ❌ |
| Rectangle | 背景、边框 | ✅ |
| Text | 文字显示 | ✅ |
| Image | 图片显示 | ✅ |
| MouseArea | 点击、拖拽 | ❌ |

---

## 幻灯片 5: 属性系统

```mermaid
graph TD
    A[属性] --> B[基本类型]
    A --> C[对象类型]
    A --> D[属性绑定]
    
    B --> B1[int/real]
    B --> B2[string]
    B --> B3[bool]
    B --> B4[color]
    
    C --> C1[var]
    C --> C2[list]
    
    D --> D1[单向绑定]
    D --> D2[自动更新]
    
    style A fill:#409EFF,color:#fff
    style B fill:#67C23A,color:#fff
    style C fill:#E6A23C,color:#fff
    style D fill:#F56C6C,color:#fff
```

### 示例对比

**❌ 静态赋值**
```qml
Rectangle {
    width: 200
    height: 100
}
```

**✅ 动态绑定**
```qml
Rectangle {
    width: parent.width * 0.5  // 自动跟随父元素
    height: width / 2          // 自动跟随宽度
}
```

---

## 幻灯片 6: 属性绑定原理

```mermaid
sequenceDiagram
    participant P as Parent
    participant C as Child
    
    Note over P: width = 400
    P->>C: 通知宽度变化
    Note over C: width = parent.width * 0.5
    Note over C: 自动计算: 400 * 0.5 = 200
    
    Note over P: width = 600
    P->>C: 通知宽度变化
    Note over C: 自动计算: 600 * 0.5 = 300
    Note over C: 无需手动更新！
```

### 关键点
- 🔄 **自动更新** - 依赖变化时自动重新计算
- ⚡ **高效** - 只在需要时更新
- 🎯 **简洁** - 无需手动监听

---

## 幻灯片 7: 记忆口诀

### QML 五大核心

```mermaid
mindmap
  root((QML))
    元素
      Item
      Rectangle
      Text
    属性
      声明
      绑定
      别名
    布局
      Anchors
      Positioners
      Layouts
    信号
      内置信号
      自定义信号
      Connections
    动画
      Behavior
      Animation
      Transition
```

### 记忆技巧
1. **元素** = 积木块 🧱
2. **属性** = 积木的颜色和大小 🎨
3. **布局** = 积木的摆放方式 📐
4. **信号** = 积木之间的通信 📡
5. **动画** = 积木的移动方式 🎬

---

## 幻灯片 8: 快速参考卡

### 常用元素速查

| 图标 | 元素 | 一句话描述 |
|------|------|-----------|
| 📦 | Item | 万物之源，不可见容器 |
| 🟦 | Rectangle | 有颜色的矩形 |
| 📝 | Text | 显示文字 |
| 🖼️ | Image | 显示图片 |
| 👆 | MouseArea | 捕获鼠标事件 |
| ⬆️ | Column | 垂直排列 |
| ➡️ | Row | 水平排列 |
| 🔲 | Grid | 网格排列 |

---

## 幻灯片 9: 学习路线图

```mermaid
journey
    title QML 学习之旅
    section 第1周
      基础语法: 3: 学习者
      基本元素: 4: 学习者
      简单布局: 5: 学习者
    section 第2周
      属性绑定: 4: 学习者
      信号与槽: 5: 学习者
      JavaScript: 4: 学习者
    section 第3周
      动画效果: 5: 学习者
      状态管理: 4: 学习者
    section 第4周
      实战项目: 5: 学习者
      性能优化: 4: 学习者
```

### 学习建议
- 📅 **每天 1-2 小时**
- 💻 **边学边练**
- 🎯 **做小项目**
- 👥 **加入社区**

---

## 幻灯片 10: 第一个程序

### Hello World 对比

**传统方式 (C++)**
```cpp
// 10+ 行代码
#include <QApplication>
#include <QLabel>
int main() {
    QApplication app;
    QLabel label("Hello");
    label.show();
    return app.exec();
}
```

**QML 方式**
```qml
// 3 行代码！
Text {
    text: "Hello World"
}
```

### 优势
- ✅ 代码更少
- ✅ 更易理解
- ✅ 更易维护

---

## 总结卡片

### 记住这 5 点

```mermaid
graph LR
    A[QML] --> B[1️⃣ 声明式]
    A --> C[2️⃣ 组件化]
    A --> D[3️⃣ 属性绑定]
    A --> E[4️⃣ 信号驱动]
    A --> F[5️⃣ 动画丰富]
    
    style A fill:#409EFF,color:#fff,stroke:#409EFF,stroke-width:4px
    style B fill:#67C23A,color:#fff
    style C fill:#E6A23C,color:#fff
    style D fill:#F56C6C,color:#fff
    style E fill:#909399,color:#fff
    style F fill:#409EFF,color:#fff
```

### 下一步
👉 学习布局系统
