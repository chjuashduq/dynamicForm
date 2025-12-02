# QML 实战项目图解 - PPT 版 🚀

## 幻灯片 1: 项目架构总览

### 🏗️ 典型 QML 应用架构

```mermaid
graph TB
    A[QML 应用] --> B[表现层<br/>Presentation]
    A --> C[业务层<br/>Business Logic]
    A --> D[数据层<br/>Data]
    
    B --> B1[QML 界面]
    B --> B2[组件库]
    B --> B3[样式主题]
    
    C --> C1[JavaScript 逻辑]
    C --> C2[C++ 后端]
    C --> C3[状态管理]
    
    D --> D1[本地存储]
    D --> D2[网络请求]
    D --> D3[数据库]
    
    style A fill:#409EFF,color:#fff
    style B fill:#67C23A,color:#fff
    style C fill:#E6A23C,color:#fff
    style D fill:#F56C6C,color:#fff
```

### 📸 参考架构图
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [MVVM Pattern](https://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93viewmodel)

---

## 幻灯片 2: 项目目录结构

```
MyQMLApp/
├── qml/
│   ├── main.qml              # 应用入口
│   ├── components/           # 通用组件
│   │   ├── Button.qml
│   │   ├── Card.qml
│   │   └── Dialog.qml
│   ├── pages/                # 页面
│   │   ├── HomePage.qml
│   │   ├── LoginPage.qml
│   │   └── SettingsPage.qml
│   ├── layouts/              # 布局
│   │   ├── MainLayout.qml
│   │   └── SidebarLayout.qml
│   ├── styles/               # 样式
│   │   ├── Theme.qml
│   │   └── Colors.qml
│   └── utils/                # 工具
│       ├── API.qml
│       └── Storage.qml
├── src/                      # C++ 源码
│   ├── main.cpp
│   └── models/
├── resources/                # 资源文件
│   ├── images/
│   ├── fonts/
│   └── icons/
└── CMakeLists.txt
```

---

## 幻灯片 3: 项目1 - 待办事项应用

### 功能流程图

```mermaid
flowchart TD
    A[启动应用] --> B[显示任务列表]
    B --> C{用户操作}
    
    C -->|添加| D[输入任务]
    D --> E[保存到本地]
    E --> B
    
    C -->|完成| F[标记完成]
    F --> B
    
    C -->|删除| G[确认删除]
    G --> H[从列表移除]
    H --> B
    
    C -->|编辑| I[修改任务]
    I --> E
    
    style A fill:#67C23A,color:#fff
    style B fill:#409EFF,color:#fff
    style C fill:#E6A23C,color:#fff
```


### 核心代码实现

```qml
// TodoApp.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt.labs.settings 1.0

ApplicationWindow {
    id: window
    visible: true
    width: 400
    height: 600
    title: "待办事项"
    
    // 数据模型
    ListModel {
        id: todoModel
    }
    
    // 本地存储
    Settings {
        id: settings
        property string todos: ""
    }
    
    // 加载数据
    Component.onCompleted: {
        loadTodos()
    }
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 15
        
        // 标题
        Text {
            text: "我的待办"
            font.pixelSize: 28
            font.bold: true
            Layout.alignment: Qt.AlignHCenter
        }
        
        // 输入区域
        RowLayout {
            Layout.fillWidth: true
            spacing: 10
            
            TextField {
                id: inputField
                Layout.fillWidth: true
                placeholderText: "添加新任务..."
                onAccepted: addTodo()
            }
            
            Button {
                text: "添加"
                onClicked: addTodo()
            }
        }
        
        // 任务列表
        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: todoModel
            spacing: 10
            
            delegate: Rectangle {
                width: ListView.view.width
                height: 60
                color: "#f5f5f5"
                radius: 8
                
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 10
                    
                    CheckBox {
                        checked: model.completed
                        onClicked: {
                            todoModel.setProperty(index, "completed", checked)
                            saveTodos()
                        }
                    }
                    
                    Text {
                        Layout.fillWidth: true
                        text: model.text
                        font.strikeout: model.completed
                        color: model.completed ? "#999" : "#333"
                    }
                    
                    Button {
                        text: "删除"
                        flat: true
                        onClicked: {
                            todoModel.remove(index)
                            saveTodos()
                        }
                    }
                }
            }
        }
        
        // 统计信息
        Text {
            text: "共 " + todoModel.count + " 项任务"
            color: "#666"
            Layout.alignment: Qt.AlignHCenter
        }
    }
    
    // 添加任务
    function addTodo() {
        if (inputField.text.trim() !== "") {
            todoModel.append({
                text: inputField.text,
                completed: false
            })
            inputField.text = ""
            saveTodos()
        }
    }
    
    // 保存到本地
    function saveTodos() {
        var todos = []
        for (var i = 0; i < todoModel.count; i++) {
            todos.push({
                text: todoModel.get(i).text,
                completed: todoModel.get(i).completed
            })
        }
        settings.todos = JSON.stringify(todos)
    }
    
    // 从本地加载
    function loadTodos() {
        if (settings.todos) {
            var todos = JSON.parse(settings.todos)
            for (var i = 0; i < todos.length; i++) {
                todoModel.append(todos[i])
            }
        }
    }
}
```

---

## 幻灯片 4: 项目2 - 天气应用

### 数据流图

```mermaid
sequenceDiagram
    participant U as 用户界面
    participant A as API 管理器
    participant S as 服务器
    participant C as 缓存
    
    U->>A: 请求天气数据
    A->>C: 检查缓存
    
    alt 缓存有效
        C->>A: 返回缓存数据
        A->>U: 显示数据
    else 缓存过期
        A->>S: 发起网络请求
        S->>A: 返回天气数据
        A->>C: 更新缓存
        A->>U: 显示数据
    end
```

### 界面布局

```mermaid
graph TB
    A[天气应用] --> B[顶部<br/>城市选择]
    A --> C[中部<br/>当前天气]
    A --> D[底部<br/>未来预报]
    
    C --> C1[温度显示]
    C --> C2[天气图标]
    C --> C3[天气描述]
    C --> C4[湿度/风速]
    
    D --> D1[明天]
    D --> D2[后天]
    D --> D3[第三天]
    
    style A fill:#409EFF,color:#fff
    style C fill:#67C23A,color:#fff
```

---

## 幻灯片 5: 项目3 - 音乐播放器

### 状态机图

```mermaid
stateDiagram-v2
    [*] --> 停止
    停止 --> 播放: 点击播放
    播放 --> 暂停: 点击暂停
    暂停 --> 播放: 点击播放
    播放 --> 停止: 点击停止
    暂停 --> 停止: 点击停止
    
    播放 --> 下一首: 自动/手动
    下一首 --> 播放
    
    播放 --> 上一首: 手动
    上一首 --> 播放
```

### 组件结构

```mermaid
graph TB
    A[音乐播放器] --> B[播放列表]
    A --> C[播放控制]
    A --> D[进度条]
    A --> E[音量控制]
    
    B --> B1[歌曲列表]
    B --> B2[搜索框]
    
    C --> C1[上一首]
    C --> C2[播放/暂停]
    C --> C3[下一首]
    
    D --> D1[当前时间]
    D --> D2[滑块]
    D --> D3[总时长]
    
    style A fill:#409EFF,color:#fff
```

---

## 幻灯片 6: 项目4 - 聊天应用

### 实时通信流程

```mermaid
sequenceDiagram
    participant U1 as 用户1
    participant C1 as 客户端1
    participant S as 服务器
    participant C2 as 客户端2
    participant U2 as 用户2
    
    U1->>C1: 输入消息
    C1->>S: 发送消息
    S->>S: 存储消息
    S->>C2: 推送消息
    C2->>U2: 显示消息
    
    U2->>C2: 输入回复
    C2->>S: 发送回复
    S->>C1: 推送回复
    C1->>U1: 显示回复
```

### 界面布局

```mermaid
graph LR
    A[聊天应用] --> B[联系人列表]
    A --> C[聊天窗口]
    
    C --> C1[消息列表]
    C --> C2[输入框]
    C --> C3[发送按钮]
    
    style A fill:#409EFF,color:#fff
    style B fill:#67C23A,color:#fff
    style C fill:#E6A23C,color:#fff
```

---

## 幻灯片 7: 项目5 - 数据可视化仪表板

### 仪表板布局

```mermaid
graph TB
    A[仪表板] --> B[顶部导航]
    A --> C[左侧菜单]
    A --> D[主内容区]
    
    D --> D1[统计卡片区]
    D --> D2[图表区域]
    D --> D3[数据表格]
    
    D1 --> D11[卡片1: 总用户]
    D1 --> D12[卡片2: 总收入]
    D1 --> D13[卡片3: 订单数]
    D1 --> D14[卡片4: 增长率]
    
    D2 --> D21[折线图]
    D2 --> D22[柱状图]
    D2 --> D23[饼图]
    
    style A fill:#409EFF,color:#fff
    style D1 fill:#67C23A,color:#fff
    style D2 fill:#E6A23C,color:#fff
    style D3 fill:#F56C6C,color:#fff
```

### 数据流

```mermaid
flowchart LR
    A[数据源] --> B[数据处理]
    B --> C[数据模型]
    C --> D[图表组件]
    D --> E[用户界面]
    
    E --> F{用户交互}
    F -->|筛选| B
    F -->|刷新| A
    
    style A fill:#67C23A,color:#fff
    style E fill:#409EFF,color:#fff
```

---

## 幻灯片 8: 性能优化策略

### 优化技术对比

```mermaid
graph TB
    A[性能优化] --> B[加载优化]
    A --> C[渲染优化]
    A --> D[内存优化]
    
    B --> B1[懒加载]
    B --> B2[异步加载]
    B --> B3[预加载]
    
    C --> C1[使用 Animator]
    C --> C2[减少重绘]
    C --> C3[使用 Canvas]
    
    D --> D1[对象池]
    D --> D2[及时销毁]
    D --> D3[图片压缩]
    
    style A fill:#409EFF,color:#fff
    style B fill:#67C23A,color:#fff
    style C fill:#E6A23C,color:#fff
    style D fill:#F56C6C,color:#fff
```

### 性能指标

| 指标 | 目标值 | 优化方法 |
|------|--------|----------|
| 启动时间 | < 2秒 | 懒加载、预编译 |
| 帧率 | 60 FPS | 使用 Animator |
| 内存占用 | < 100MB | 对象池、压缩 |
| 响应时间 | < 100ms | 异步处理 |

---

## 幻灯片 9: 调试技巧

### 调试工具链

```mermaid
graph LR
    A[调试工具] --> B[Qt Creator]
    A --> C[QML Profiler]
    A --> D[Console 输出]
    A --> E[远程调试]
    
    B --> B1[断点调试]
    B --> B2[变量查看]
    
    C --> C1[性能分析]
    C --> C2[内存分析]
    
    D --> D1[console.log]
    D --> D2[console.warn]
    
    style A fill:#409EFF,color:#fff
```

### 常用调试代码

```qml
// 1. 输出调试信息
console.log("变量值:", myVariable)
console.warn("警告信息")
console.error("错误信息")

// 2. 性能计时
console.time("操作名称")
// ... 执行操作
console.timeEnd("操作名称")

// 3. 对象检查
console.log(JSON.stringify(myObject, null, 2))

// 4. 组件边界可视化
Rectangle {
    border.color: "red"  // 调试时显示边界
    border.width: 1
}

// 5. 属性变化监听
onWidthChanged: console.log("宽度变化:", width)
```

---

## 幻灯片 10: 部署流程

### 部署步骤

```mermaid
flowchart TD
    A[开发完成] --> B[代码审查]
    B --> C[单元测试]
    C --> D[集成测试]
    D --> E{测试通过?}
    
    E -->|否| F[修复问题]
    F --> C
    
    E -->|是| G[构建发布版]
    G --> H[打包应用]
    H --> I[签名]
    I --> J[发布]
    
    J --> K[Windows]
    J --> L[macOS]
    J --> M[Linux]
    J --> N[Android]
    
    style A fill:#67C23A,color:#fff
    style E fill:#E6A23C,color:#fff
    style J fill:#409EFF,color:#fff
```

### 平台特定配置

| 平台 | 打包工具 | 注意事项 |
|------|----------|----------|
| Windows | windeployqt | 包含 VC++ 运行库 |
| macOS | macdeployqt | 代码签名 |
| Linux | linuxdeployqt | 依赖库 |
| Android | androiddeployqt | 权限配置 |

---

## 幻灯片 11: 项目实战清单

### 🎯 学习路径

```mermaid
journey
    title 项目实战学习路径
    section 初级项目
      待办事项: 5: 学习者
      计算器: 4: 学习者
      记事本: 4: 学习者
    section 中级项目
      天气应用: 3: 学习者
      音乐播放器: 4: 学习者
      图片浏览器: 4: 学习者
    section 高级项目
      聊天应用: 3: 学习者
      数据仪表板: 4: 学习者
      企业管理系统: 5: 学习者
```

### 项目难度评估

| 项目 | 难度 | 时间 | 技能点 |
|------|------|------|--------|
| 待办事项 | ⭐ | 1天 | 基础组件、本地存储 |
| 计算器 | ⭐ | 1天 | 布局、事件处理 |
| 天气应用 | ⭐⭐ | 2-3天 | 网络请求、JSON |
| 音乐播放器 | ⭐⭐⭐ | 3-5天 | 多媒体、状态管理 |
| 聊天应用 | ⭐⭐⭐⭐ | 1-2周 | WebSocket、数据库 |
| 企业系统 | ⭐⭐⭐⭐⭐ | 1个月+ | 架构设计、性能优化 |

---

## 幻灯片 12: 参考资源

### 📚 开源项目参考

1. **GitHub 优秀项目**
   - [Cute-Sorrow/QML-Examples](https://github.com/topics/qml-examples)
   - [Qt Official Examples](https://doc.qt.io/qt-6/qtexamplesandtutorials.html)

2. **UI 设计灵感**
   - [Dribbble - Dashboard](https://dribbble.com/tags/dashboard)
   - [Behance - Mobile App](https://www.behance.net/search/projects?search=mobile%20app)
   - [UI8 - Design Systems](https://ui8.net/)

3. **图标和素材**
   - [Flaticon](https://www.flaticon.com/)
   - [Unsplash](https://unsplash.com/) - 免费图片
   - [Pexels](https://www.pexels.com/) - 免费视频和图片

4. **API 服务**
   - [OpenWeatherMap](https://openweathermap.org/api) - 天气 API
   - [JSONPlaceholder](https://jsonplaceholder.typicode.com/) - 测试 API
   - [Random User API](https://randomuser.me/) - 用户数据

---

<div align="center">

## 🎯 实战是最好的老师

**从简单项目开始**
**逐步挑战复杂应用**
**在实践中成长**

动手做起来，你就是下一个 QML 专家！ 🚀

</div>
