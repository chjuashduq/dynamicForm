# QML 布局系统对比 - PPT 版 📐

## 幻灯片 1: 三大布局方式

```mermaid
graph TB
    A[QML 布局] --> B[Anchors<br/>锚点布局]
    A --> C[Positioners<br/>定位器]
    A --> D[Layouts<br/>布局管理器]
    
    B --> B1[相对定位<br/>最灵活]
    C --> C1[简单排列<br/>最简单]
    D --> D1[自适应<br/>最智能]
    
    style A fill:#409EFF,color:#fff
    style B fill:#67C23A,color:#fff
    style C fill:#E6A23C,color:#fff
    style D fill:#F56C6C,color:#fff
```

---

## 幻灯片 2: Anchors 锚点系统

```mermaid
graph TD
    A[Parent 父元素] --> B[Child 子元素]
    
    B --> C[top 顶部]
    B --> D[bottom 底部]
    B --> E[left 左侧]
    B --> F[right 右侧]
    B --> G[centerIn 居中]
    B --> H[fill 填充]
    
    style A fill:#409EFF,color:#fff
    style B fill:#67C23A,color:#fff
    style C fill:#E6A23C,color:#fff
    style D fill:#E6A23C,color:#fff
    style E fill:#E6A23C,color:#fff
    style F fill:#E6A23C,color:#fff
    style G fill:#F56C6C,color:#fff
    style H fill:#F56C6C,color:#fff
```

### 可视化示例

```
┌─────────────────────────────┐
│  Parent                     │
│  ┌─────────────────────┐   │ ← anchors.top
│  │  anchors.top        │   │
│  └─────────────────────┘   │
│                             │
│      ┌──────────┐           │
│      │ centerIn │           │ ← anchors.centerIn
│      └──────────┘           │
│                             │
│  ┌─────────────────────┐   │
│  │  anchors.bottom     │   │ ← anchors.bottom
│  └─────────────────────┘   │
└─────────────────────────────┘
```

---

## 幻灯片 3: Anchors 常用组合

```mermaid
graph LR
    A[常用锚点] --> B[居中<br/>centerIn]
    A --> C[填充<br/>fill]
    A --> D[顶部对齐<br/>top + left + right]
    A --> E[底部对齐<br/>bottom + left + right]
    
    style A fill:#409EFF,color:#fff
    style B fill:#67C23A,color:#fff
    style C fill:#E6A23C,color:#fff
    style D fill:#F56C6C,color:#fff
    style E fill:#909399,color:#fff
```

### 代码速查

| 效果 | 代码 |
|------|------|
| 🎯 居中 | `anchors.centerIn: parent` |
| 📦 填充 | `anchors.fill: parent` |
| ⬆️ 顶部 | `anchors.top: parent.top` |
| ⬇️ 底部 | `anchors.bottom: parent.bottom` |
| ⬅️ 左侧 | `anchors.left: parent.left` |
| ➡️ 右侧 | `anchors.right: parent.right` |

---

## 幻灯片 4: Positioners 定位器家族

```mermaid
graph TB
    A[Positioners<br/>定位器] --> B[Row<br/>水平排列<br/>→→→]
    A --> C[Column<br/>垂直排列<br/>↓↓↓]
    A --> D[Grid<br/>网格排列<br/>⊞⊞⊞]
    A --> E[Flow<br/>流式排列<br/>自动换行]
    
    style A fill:#409EFF,color:#fff
    style B fill:#67C23A,color:#fff
    style C fill:#E6A23C,color:#fff
    style D fill:#F56C6C,color:#fff
    style E fill:#909399,color:#fff
```

### 可视化对比

**Row (水平)**
```
┌───┐ ┌───┐ ┌───┐
│ 1 │ │ 2 │ │ 3 │
└───┘ └───┘ └───┘
```

**Column (垂直)**
```
┌───┐
│ 1 │
└───┘
┌───┐
│ 2 │
└───┘
┌───┐
│ 3 │
└───┘
```

**Grid (网格)**
```
┌───┐ ┌───┐ ┌───┐
│ 1 │ │ 2 │ │ 3 │
└───┘ └───┘ └───┘
┌───┐ ┌───┐ ┌───┐
│ 4 │ │ 5 │ │ 6 │
└───┘ └───┘ └───┘
```

---

## 幻灯片 5: Layouts 布局管理器

```mermaid
graph TB
    A[Layouts<br/>智能布局] --> B[RowLayout<br/>水平自适应]
    A --> C[ColumnLayout<br/>垂直自适应]
    A --> D[GridLayout<br/>网格自适应]
    
    B --> B1[fillWidth<br/>填充宽度]
    C --> C1[fillHeight<br/>填充高度]
    D --> D1[跨行跨列<br/>rowSpan/colSpan]
    
    style A fill:#409EFF,color:#fff
    style B fill:#67C23A,color:#fff
    style C fill:#E6A23C,color:#fff
    style D fill:#F56C6C,color:#fff
```

### 关键属性

| 属性 | 作用 | 示例 |
|------|------|------|
| `Layout.fillWidth` | 填充剩余宽度 | ✅ |
| `Layout.fillHeight` | 填充剩余高度 | ✅ |
| `Layout.preferredWidth` | 首选宽度 | 200 |
| `Layout.minimumWidth` | 最小宽度 | 100 |
| `Layout.maximumWidth` | 最大宽度 | 400 |

---

## 幻灯片 6: 三种布局方式对比

```mermaid
graph TB
    subgraph Anchors
        A1[灵活性: ⭐⭐⭐⭐⭐]
        A2[简单性: ⭐⭐⭐]
        A3[自适应: ⭐⭐⭐⭐]
    end
    
    subgraph Positioners
        B1[灵活性: ⭐⭐⭐]
        B2[简单性: ⭐⭐⭐⭐⭐]
        B3[自适应: ⭐⭐]
    end
    
    subgraph Layouts
        C1[灵活性: ⭐⭐⭐⭐]
        C2[简单性: ⭐⭐⭐⭐]
        C3[自适应: ⭐⭐⭐⭐⭐]
    end
```

### 选择建议

| 场景 | 推荐 | 原因 |
|------|------|------|
| 简单排列 | Positioners | 代码最少 |
| 相对定位 | Anchors | 最灵活 |
| 响应式布局 | Layouts | 自动计算 |
| 复杂表单 | Layouts | 对齐整齐 |

---

## 幻灯片 7: 实战案例 - 三栏布局

```mermaid
graph LR
    A[三栏布局] --> B[左侧栏<br/>固定 200px]
    A --> C[中间栏<br/>自适应]
    A --> D[右侧栏<br/>固定 200px]
    
    style A fill:#409EFF,color:#fff
    style B fill:#67C23A,color:#fff
    style C fill:#E6A23C,color:#fff
    style D fill:#F56C6C,color:#fff
```

### 可视化

```
┌────────────────────────────────────┐
│ ┌────┐ ┌──────────────┐ ┌────┐   │
│ │左侧│ │   中间内容   │ │右侧│   │
│ │200 │ │   自适应     │ │200 │   │
│ │px  │ │              │ │px  │   │
│ └────┘ └──────────────┘ └────┘   │
└────────────────────────────────────┘
```

### 代码对比

**❌ 复杂方式 (Anchors)**
```qml
// 需要 15+ 行代码
```

**✅ 简单方式 (RowLayout)**
```qml
RowLayout {
    Rectangle { Layout.preferredWidth: 200 }  // 左
    Rectangle { Layout.fillWidth: true }      // 中
    Rectangle { Layout.preferredWidth: 200 }  // 右
}
```

---

## 幻灯片 8: 布局决策树

```mermaid
graph TD
    A{需要什么布局?} --> B{简单排列?}
    B -->|是| C[Row/Column]
    B -->|否| D{相对定位?}
    D -->|是| E[Anchors]
    D -->|否| F{自适应?}
    F -->|是| G[RowLayout/ColumnLayout]
    F -->|否| H{网格?}
    H -->|是| I[GridLayout]
    H -->|否| J[组合使用]
    
    style A fill:#409EFF,color:#fff
    style C fill:#67C23A,color:#fff
    style E fill:#E6A23C,color:#fff
    style G fill:#F56C6C,color:#fff
    style I fill:#909399,color:#fff
```

---

## 幻灯片 9: 常见布局模式

```mermaid
mindmap
  root((常见布局))
    顶部导航
      固定高度
      填充宽度
    侧边栏
      固定宽度
      填充高度
    卡片网格
      Grid
      Flow
    表单
      GridLayout
      两列对齐
    底部栏
      固定高度
      填充宽度
```

---

## 幻灯片 10: 记忆口诀

### 布局三字经

```mermaid
graph LR
    A[简单排] --> B[用 Row/Column]
    C[要对齐] --> D[用 Anchors]
    E[要自适应] --> F[用 Layouts]
    
    style A fill:#67C23A,color:#fff
    style B fill:#67C23A,color:#fff
    style C fill:#E6A23C,color:#fff
    style D fill:#E6A23C,color:#fff
    style E fill:#F56C6C,color:#fff
    style F fill:#F56C6C,color:#fff
```

### 快速记忆

| 口诀 | 含义 | 使用 |
|------|------|------|
| 📏 **排排站** | 简单排列 | Row/Column |
| 🎯 **锚定位** | 相对定位 | Anchors |
| 📐 **智能算** | 自适应 | Layouts |

---

## 总结卡片

### 布局选择速查表

```mermaid
graph TB
    A{我的需求} --> B[水平/垂直排列]
    A --> C[相对父元素定位]
    A --> D[响应式/自适应]
    A --> E[网格对齐]
    
    B --> F[Row/Column]
    C --> G[Anchors]
    D --> H[RowLayout/ColumnLayout]
    E --> I[GridLayout]
    
    style A fill:#409EFF,color:#fff
    style F fill:#67C23A,color:#fff
    style G fill:#E6A23C,color:#fff
    style H fill:#F56C6C,color:#fff
    style I fill:#909399,color:#fff
```

### 下一步
👉 学习信号与槽
