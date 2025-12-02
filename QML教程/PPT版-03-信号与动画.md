# QML 信号与动画 - PPT 版 🎬

## 幻灯片 1: 信号与槽机制

```mermaid
sequenceDiagram
    participant U as 用户
    participant B as Button
    participant H as Handler
    participant UI as 界面
    
    U->>B: 点击
    B->>H: onClicked 信号
    H->>UI: 更新界面
    UI-->>U: 显示结果
```

### 核心概念
- 📡 **信号** = 事件通知
- 🎯 **槽** = 事件处理
- 🔄 **自动连接** = 无需手动绑定

---

## 幻灯片 2: 常见信号类型

```mermaid
mindmap
  root((信号类型))
    鼠标信号
      onClicked
      onPressed
      onReleased
      onEntered
      onExited
    属性信号
      onWidthChanged
      onColorChanged
      onTextChanged
    自定义信号
      signal mySignal
      emit mySignal
```

---

## 幻灯片 3: 信号处理方式对比

```mermaid
graph TB
    A[信号处理] --> B[内联处理<br/>最简单]
    A --> C[函数调用<br/>可复用]
    A --> D[Connections<br/>最灵活]
    
    B --> B1["onClicked: { }"]
    C --> C1["onClicked: func()"]
    D --> D1["Connections { }"]
    
    style A fill:#409EFF,color:#fff
    style B fill:#67C23A,color:#fff
    style C fill:#E6A23C,color:#fff
    style D fill:#F56C6C,color:#fff
```

### 代码对比

**方式 1: 内联**
```qml
Button {
    onClicked: { count++ }
}
```

**方式 2: 函数**
```qml
Button {
    onClicked: handleClick()
    function handleClick() { count++ }
}
```

**方式 3: Connections**
```qml
Connections {
    target: button
    onClicked: { count++ }
}
```

---

## 幻灯片 4: 自定义信号流程

```mermaid
graph LR
    A[1️⃣ 定义信号<br/>signal clicked] --> B[2️⃣ 发出信号<br/>clicked.emit]
    B --> C[3️⃣ 处理信号<br/>onClicked: {}]
    
    style A fill:#67C23A,color:#fff
    style B fill:#E6A23C,color:#fff
    style C fill:#F56C6C,color:#fff
```

### 完整示例
```qml
Rectangle {
    // 1. 定义
    signal customClicked(int x, int y)
    
    MouseArea {
        anchors.fill: parent
        onClicked: function(mouse) {
            // 2. 发出
            parent.customClicked(mouse.x, mouse.y)
        }
    }
    
    // 3. 处理
    onCustomClicked: function(x, y) {
        console.log("点击位置:", x, y)
    }
}
```

---

## 幻灯片 5: 动画类型全景

```mermaid
graph TB
    A[QML 动画] --> B[Behavior<br/>属性变化自动动画]
    A --> C[Animation<br/>手动控制动画]
    A --> D[Transition<br/>状态切换动画]
    
    B --> B1[最简单<br/>自动触发]
    C --> C1[最灵活<br/>手动控制]
    D --> D1[最优雅<br/>状态驱动]
    
    style A fill:#409EFF,color:#fff
    style B fill:#67C23A,color:#fff
    style C fill:#E6A23C,color:#fff
    style D fill:#F56C6C,color:#fff
```

---

## 幻灯片 6: Behavior 自动动画

```mermaid
graph LR
    A[属性改变] --> B[Behavior 拦截]
    B --> C[播放动画]
    C --> D[到达目标值]
    
    style A fill:#67C23A,color:#fff
    style B fill:#E6A23C,color:#fff
    style C fill:#F56C6C,color:#fff
    style D fill:#409EFF,color:#fff
```

### 对比

**❌ 没有动画**
```qml
Rectangle {
    x: 0
    MouseArea {
        onClicked: parent.x = 300  // 瞬间移动
    }
}
```

**✅ 有动画**
```qml
Rectangle {
    x: 0
    Behavior on x {
        NumberAnimation { duration: 500 }  // 平滑移动
    }
    MouseArea {
        onClicked: parent.x = 300
    }
}
```

---

## 幻灯片 7: 缓动函数效果

```mermaid
graph TB
    A[缓动函数] --> B[Linear<br/>匀速<br/>━━━━━]
    A --> C[InQuad<br/>加速<br/>╱━━━━]
    A --> D[OutQuad<br/>减速<br/>━━━━╲]
    A --> E[InOutQuad<br/>先加后减<br/>╱━━╲]
    A --> F[OutBounce<br/>弹跳<br/>━━╲╱╲]
    
    style A fill:#409EFF,color:#fff
    style B fill:#67C23A,color:#fff
    style C fill:#E6A23C,color:#fff
    style D fill:#F56C6C,color:#fff
    style E fill:#909399,color:#fff
    style F fill:#409EFF,color:#fff
```

### 视觉对比

```
Linear:     ━━━━━━━━━━━━━━━━
InQuad:     ╱━━━━━━━━━━━━━━
OutQuad:    ━━━━━━━━━━━━━━╲
InOutQuad:  ╱━━━━━━━━━━━━╲
OutBounce:  ━━━━━━━━╲╱╲╱╲
```

---

## 幻灯片 8: 动画组合

```mermaid
graph TB
    A[动画组合] --> B[SequentialAnimation<br/>顺序执行<br/>1→2→3]
    A --> C[ParallelAnimation<br/>同时执行<br/>1+2+3]
    
    B --> B1[移动→旋转→缩放]
    C --> C1[移动+旋转+缩放]
    
    style A fill:#409EFF,color:#fff
    style B fill:#67C23A,color:#fff
    style C fill:#E6A23C,color:#fff
```

### 可视化

**Sequential (顺序)**
```
时间轴: ━━━━━━━━━━━━━━━━━━━━
动画1:  ████
动画2:      ████
动画3:          ████
```

**Parallel (并行)**
```
时间轴: ━━━━━━━━━━━━━━━━━━━━
动画1:  ████████████
动画2:  ████████████
动画3:  ████████████
```

---

## 幻灯片 9: 状态与过渡

```mermaid
stateDiagram-v2
    [*] --> 默认
    默认 --> 展开: 点击
    展开 --> 收起: 再次点击
    收起 --> 默认: 动画结束
    
    note right of 默认
        width: 100
        height: 100
    end note
    
    note right of 展开
        width: 200
        height: 200
    end note
```

### 代码结构
```qml
Rectangle {
    states: [
        State { name: "expanded" }
    ]
    
    transitions: [
        Transition {
            from: ""; to: "expanded"
            NumberAnimation { duration: 500 }
        }
    ]
}
```

---

## 幻灯片 10: 动画性能优化

```mermaid
graph LR
    A[性能优化] --> B[使用 Animator<br/>⚡ 渲染线程]
    A --> C[启用 layer<br/>🎨 缓存图层]
    A --> D[避免复杂绑定<br/>🚀 减少计算]
    
    style A fill:#409EFF,color:#fff
    style B fill:#67C23A,color:#fff
    style C fill:#E6A23C,color:#fff
    style D fill:#F56C6C,color:#fff
```

### 对比

| 方式 | 性能 | 使用 |
|------|------|------|
| NumberAnimation | ⭐⭐⭐ | 主线程 |
| OpacityAnimator | ⭐⭐⭐⭐⭐ | 渲染线程 |
| XAnimator | ⭐⭐⭐⭐⭐ | 渲染线程 |

---

## 幻灯片 11: 常用动画速查

```mermaid
mindmap
  root((动画类型))
    位置
      NumberAnimation x/y
      XAnimator
      YAnimator
    大小
      NumberAnimation width/height
      ScaleAnimator
    颜色
      ColorAnimation
    透明度
      OpacityAnimator
    旋转
      RotationAnimator
    路径
      PathAnimation
```

---

## 幻灯片 12: 实战案例 - 加载动画

```mermaid
graph TB
    A[加载动画] --> B[旋转动画<br/>RotationAnimation]
    A --> C[透明度动画<br/>OpacityAnimator]
    A --> D[缩放动画<br/>ScaleAnimator]
    
    B --> B1[0° → 360°<br/>循环播放]
    C --> C1[1.0 → 0.3<br/>渐变效果]
    D --> D1[1.0 → 1.2<br/>脉冲效果]
    
    style A fill:#409EFF,color:#fff
    style B fill:#67C23A,color:#fff
    style C fill:#E6A23C,color:#fff
    style D fill:#F56C6C,color:#fff
```

---

## 幻灯片 13: 记忆口诀

### 动画三字经

```mermaid
graph LR
    A[属性变] --> B[用 Behavior]
    C[手动控] --> D[用 Animation]
    E[状态切] --> F[用 Transition]
    
    style A fill:#67C23A,color:#fff
    style B fill:#67C23A,color:#fff
    style C fill:#E6A23C,color:#fff
    style D fill:#E6A23C,color:#fff
    style E fill:#F56C6C,color:#fff
    style F fill:#F56C6C,color:#fff
```

### 快速记忆

| 场景 | 使用 | 特点 |
|------|------|------|
| 🔄 属性自动变化 | Behavior | 最简单 |
| 🎮 手动控制播放 | Animation | 最灵活 |
| 🎯 状态切换 | Transition | 最优雅 |

---

## 总结卡片

### 信号与动画速查

```mermaid
graph TB
    A[QML 交互] --> B[信号<br/>事件通知]
    A --> C[动画<br/>视觉反馈]
    
    B --> B1[onClicked]
    B --> B2[onChanged]
    B --> B3[自定义]
    
    C --> C1[Behavior]
    C --> C2[Animation]
    C --> C3[Transition]
    
    style A fill:#409EFF,color:#fff
    style B fill:#67C23A,color:#fff
    style C fill:#E6A23C,color:#fff
```

### 关键点
- 📡 信号 = 通知机制
- 🎬 动画 = 平滑过渡
- ⚡ Animator = 高性能

### 下一步
👉 实战项目开发
