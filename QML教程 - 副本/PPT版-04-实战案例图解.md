# QML 实战案例图解 - PPT 版 🚀

## 幻灯片 1: 项目架构全景

```mermaid
graph TB
    subgraph 视图层
        A[ConfigEditor<br/>配置编辑器]
        B[FormPreview<br/>表单预览]
        C[DynamicList<br/>表单列表]
    end
    
    subgraph 控制层
        D[ControlFactory<br/>控件工厂]
        E[ScriptEngine<br/>脚本引擎]
        F[ConfigManager<br/>配置管理]
    end
    
    subgraph 数据层
        G[FormAPI<br/>表单API]
        H[MySqlHelper<br/>数据库]
        I[(MySQL)]
    end
    
    A --> F
    B --> D
    B --> E
    D --> G
    E --> G
    G --> H
    H --> I
    
    style A fill:#409EFF,color:#fff
    style B fill:#67C23A,color:#fff
    style C fill:#E6A23C,color:#fff
    style D fill:#F56C6C,color:#fff
    style E fill:#909399,color:#fff
```

---

## 幻灯片 2: 工厂模式应用

```mermaid
graph LR
    A[配置<br/>JSON] --> B[ControlFactory<br/>工厂]
    B --> C[Text<br/>文本框]
    B --> D[Number<br/>数字框]
    B --> E[Dropdown<br/>下拉框]
    B --> F[Button<br/>按钮]
    
    style A fill:#409EFF,color:#fff
    style B fill:#67C23A,color:#fff
    style C fill:#E6A23C,color:#fff
    style D fill:#E6A23C,color:#fff
    style E fill:#E6A23C,color:#fff
    style F fill:#E6A23C,color:#fff
```

### 核心代码
```qml
function createControl(config) {
    switch(config.type) {
        case "text": return createTextField()
        case "number": return createSpinBox()
        case "dropdown": return createComboBox()
    }
}
```

---

## 幻灯片 3: 组件生命周期

```mermaid
sequenceDiagram
    participant U as 用户
    participant L as Loader
    participant C as Component
    participant D as 数据库
    
    U->>L: 点击"新增表单"
    L->>C: 创建组件
    C->>C: Component.onCompleted
    C->>D: 加载配置
    D-->>C: 返回数据
    C-->>U: 显示界面
    
    U->>C: 编辑表单
    C->>D: 保存数据
    
    U->>L: 返回列表
    L->>C: 销毁组件
    C->>C: Component.onDestruction
```

---

## 幻灯片 4: 数据流转图

```mermaid
graph TB
    A[用户输入] --> B[FormPreview<br/>表单预览]
    B --> C[ControlFactory<br/>创建控件]
    C --> D[ScriptEngine<br/>执行验证]
    D --> E{验证通过?}
    E -->|是| F[FormAPI<br/>收集数据]
    E -->|否| G[显示错误]
    F --> H[MySqlHelper<br/>保存数据]
    H --> I[(数据库)]
    
    style A fill:#409EFF,color:#fff
    style E fill:#F56C6C,color:#fff
    style I fill:#67C23A,color:#fff
```

---

## 幻灯片 5: 动态表单系统核心流程

```mermaid
journey
    title 表单创建流程
    section 设计阶段
      打开设计器: 5: 用户
      配置网格: 4: 用户
      添加控件: 5: 用户
      配置属性: 4: 用户
    section 保存阶段
      验证配置: 3: 系统
      生成JSON: 5: 系统
      保存数据库: 5: 系统
    section 使用阶段
      加载表单: 5: 系统
      填写数据: 4: 用户
      提交保存: 5: 系统
```

---

## 幻灯片 6: 控件创建流程

```mermaid
stateDiagram-v2
    [*] --> 解析配置
    解析配置 --> 创建容器
    创建容器 --> 创建标签
    创建标签 --> 创建输入控件
    创建输入控件 --> 应用样式
    应用样式 --> 绑定事件
    绑定事件 --> 注册到Map
    注册到Map --> [*]
    
    note right of 创建输入控件
        根据type创建
        text/number/dropdown
    end note
```

---

## 幻灯片 7: 事件处理机制

```mermaid
graph TB
    A[用户操作] --> B{事件类型}
    
    B -->|焦点丢失| C[onFocusLost]
    B -->|值变化| D[onValueChanged]
    B -->|点击| E[onClicked]
    
    C --> F[执行验证]
    F --> G{通过?}
    G -->|是| H[执行事件代码]
    G -->|否| I[标签变红]
    
    D --> H
    E --> H
    
    H --> J[ScriptEngine]
    J --> K[更新UI/保存数据]
    
    style A fill:#409EFF,color:#fff
    style B fill:#67C23A,color:#fff
    style G fill:#F56C6C,color:#fff
    style K fill:#E6A23C,color:#fff
```

---

## 幻灯片 8: 组件通信模式

```mermaid
graph LR
    subgraph 父组件
        A[ConfigEditor]
    end
    
    subgraph 子组件1
        B[ConfigManager]
    end
    
    subgraph 子组件2
        C[GridPreview]
    end
    
    A -->|初始化| B
    B -->|信号: configChanged| A
    A -->|更新| C
    C -->|信号: controlClicked| A
    
    style A fill:#409EFF,color:#fff
    style B fill:#67C23A,color:#fff
    style C fill:#E6A23C,color:#fff
```

---

## 幻灯片 9: 性能优化策略

```mermaid
mindmap
  root((性能优化))
    异步加载
      Loader
      asynchronous
      按需加载
    组件复用
      对象池
      Component
      预编译
    减少绑定
      简化表达式
      避免循环依赖
    使用Animator
      渲染线程
      GPU加速
    缓存策略
      layer.enabled
      图层缓存
```

---

## 幻灯片 10: 常见问题解决

```mermaid
graph TB
    A[常见问题] --> B[性能问题]
    A --> C[内存泄漏]
    A --> D[布局错乱]
    A --> E[事件不触发]
    
    B --> B1[使用Profiler分析]
    C --> C1[检查对象销毁]
    D --> D1[检查anchors冲突]
    E --> E1[检查信号连接]
    
    style A fill:#F56C6C,color:#fff
    style B fill:#E6A23C,color:#fff
    style C fill:#E6A23C,color:#fff
    style D fill:#E6A23C,color:#fff
    style E fill:#E6A23C,color:#fff
```

---

## 幻灯片 11: 项目文件结构

```mermaid
graph TB
    A[项目根目录] --> B[qml/]
    A --> C[mysql/]
    A --> D[resources.qrc]
    
    B --> B1[config/<br/>配置编辑]
    B --> B2[render/<br/>表单渲染]
    B --> B3[core/<br/>核心功能]
    B --> B4[components/<br/>通用组件]
    
    C --> C1[MySqlHelper]
    C --> C2[ConnectionManager]
    
    style A fill:#409EFF,color:#fff
    style B fill:#67C23A,color:#fff
    style C fill:#E6A23C,color:#fff
```

---

## 幻灯片 12: 设计模式应用

```mermaid
graph LR
    A[设计模式] --> B[工厂模式<br/>ControlFactory]
    A --> C[单例模式<br/>MySqlHelper]
    A --> D[观察者模式<br/>信号与槽]
    A --> E[策略模式<br/>验证函数]
    
    style A fill:#409EFF,color:#fff
    style B fill:#67C23A,color:#fff
    style C fill:#E6A23C,color:#fff
    style D fill:#F56C6C,color:#fff
    style E fill:#909399,color:#fff
```

### 应用场景

| 模式 | 应用 | 优势 |
|------|------|------|
| 🏭 工厂 | 动态创建控件 | 解耦、易扩展 |
| 🔒 单例 | 数据库连接 | 资源共享 |
| 👀 观察者 | 配置变化通知 | 自动更新 |
| 🎯 策略 | 可插拔验证 | 灵活配置 |

---

## 幻灯片 13: 关键技术点

```mermaid
mindmap
  root((核心技术))
    动态创建
      createObject
      Component
      工厂模式
    属性绑定
      自动更新
      单向绑定
      性能优化
    信号通信
      自定义信号
      Connections
      事件总线
    脚本执行
      JavaScript
      Function构造
      上下文注入
    数据持久化
      MySQL
      JSON序列化
      C++交互
```

---

## 幻灯片 14: 开发流程

```mermaid
graph LR
    A[需求分析] --> B[架构设计]
    B --> C[组件开发]
    C --> D[集成测试]
    D --> E[性能优化]
    E --> F[部署上线]
    
    style A fill:#409EFF,color:#fff
    style B fill:#67C23A,color:#fff
    style C fill:#E6A23C,color:#fff
    style D fill:#F56C6C,color:#fff
    style E fill:#909399,color:#fff
    style F fill:#409EFF,color:#fff
```

### 时间分配

| 阶段 | 占比 | 重点 |
|------|------|------|
| 需求分析 | 10% | 明确目标 |
| 架构设计 | 20% | 模块划分 |
| 组件开发 | 40% | 功能实现 |
| 集成测试 | 15% | 问题修复 |
| 性能优化 | 10% | 体验提升 |
| 部署上线 | 5% | 发布维护 |

---

## 幻灯片 15: 最佳实践总结

```mermaid
graph TB
    A[最佳实践] --> B[组件化<br/>单一职责]
    A --> C[数据驱动<br/>属性绑定]
    A --> D[异步加载<br/>按需创建]
    A --> E[错误处理<br/>友好提示]
    A --> F[性能优化<br/>Profiler分析]
    
    style A fill:#409EFF,color:#fff
    style B fill:#67C23A,color:#fff
    style C fill:#67C23A,color:#fff
    style D fill:#67C23A,color:#fff
    style E fill:#67C23A,color:#fff
    style F fill:#67C23A,color:#fff
```

---

## 总结卡片

### 项目开发要点

```mermaid
graph LR
    A[QML项目] --> B[1️⃣ 架构设计]
    A --> C[2️⃣ 组件复用]
    A --> D[3️⃣ 性能优化]
    A --> E[4️⃣ 错误处理]
    A --> F[5️⃣ 代码规范]
    
    style A fill:#409EFF,color:#fff,stroke:#409EFF,stroke-width:4px
    style B fill:#67C23A,color:#fff
    style C fill:#E6A23C,color:#fff
    style D fill:#F56C6C,color:#fff
    style E fill:#909399,color:#fff
    style F fill:#409EFF,color:#fff
```

### 记住这些
- 🏗️ **架构** = 清晰分层
- 🧩 **组件** = 高内聚低耦合
- ⚡ **性能** = Profiler + Animator
- 🛡️ **错误** = try-catch + 提示
- 📝 **规范** = 注释 + 命名

### 下一步
👉 实战练习项目
