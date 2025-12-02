# QML 组件组合与父子访问详解 - PPT 版 🏗️

## 幻灯片 1: 组件组合概览

### 🎯 什么是组件组合？

组件组合就像搭积木，将多个小组件组合成复杂的界面。

```mermaid
graph TB
    A[完整页面] --> B[头部导航栏]
    A --> C[内容区域]
    A --> D[底部工具栏]
    
    B --> B1[Logo]
    B --> B2[菜单按钮]
    B --> B3[用户头像]
    
    C --> C1[侧边栏]
    C --> C2[主内容]
    
    C1 --> C11[菜单列表]
    C2 --> C21[标题]
    C2 --> C22[表单]
    C2 --> C23[按钮组]
    
    D --> D1[状态栏]
    D --> D2[操作按钮]
    
    style A fill:#409EFF,color:#fff
    style B fill:#67C23A,color:#fff
    style C fill:#E6A23C,color:#fff
    style D fill:#F56C6C,color:#fff
```

### 📸 参考图片
- [Material Design 组件](https://material.io/components)
- [Ant Design 组件库](https://ant.design/components/overview-cn/)
- [Element UI 组件](https://element.eleme.io/#/zh-CN/component/layout)

---

## 幻灯片 2: 父子访问关系核心规则

```mermaid
graph LR
    A[父组件<br/>Parent] --> B[子组件<br/>Child]
    B --> C[孙组件<br/>Grandchild]
    
    A -.->|✅ 可以访问| B
    A -.->|❌ 不能直接访问| C
    B -.->|✅ 可以访问| A
    B -.->|✅ 可以访问| C
    C -.->|✅ 可以访问| B
    C -.->|❌ 不能直接访问| A
    
    style A fill:#409EFF,color:#fff
    style B fill:#67C23A,color:#fff
    style C fill:#E6A23C,color:#fff
```

### 🔑 访问规则总结

| 访问方向 | 是否可以 | 访问方式 | 示例 |
|----------|----------|----------|------|
| 父 → 子 | ✅ 可以 | 通过 id | `childItem.property` |
| 父 → 孙 | ❌ 不能直接 | 需要通过子 | `childItem.grandchild.property` |
| 子 → 父 | ✅ 可以 | parent 关键字 | `parent.property` |
| 孙 → 父 | ❌ 不能直接 | parent.parent | `parent.parent.property` |
| 兄弟 → 兄弟 | ✅ 可以 | 通过 id | `siblingItem.property` |

---

## 幻灯片 3: 实战示例 - 登录页面组合

### 完整页面结构

```qml
// LoginPage.qml - 完整登录页面
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: loginPage  // 根组件
    width: 400
    height: 600
    color: "#f5f5f5"
    
    // 📦 组件1: 顶部Logo区域
    Rectangle {
        id: headerArea
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width
        height: 150
        color: "#409EFF"
        
        Column {
            anchors.centerIn: parent
            spacing: 10
            
            Image {
                id: logoImage
                source: "qrc:/images/logo.png"
                width: 80
                height: 80
                anchors.horizontalCenter: parent.horizontalCenter
            }
            
            Text {
                id: appTitle
                text: "欢迎登录"
                font.pixelSize: 24
                color: "white"
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }
    
    // 📦 组件2: 表单区域
    Rectangle {
        id: formArea
        anchors.top: headerArea.bottom
        anchors.topMargin: 30
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width - 60
        height: 250
        color: "white"
        radius: 10
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 15
            
            // 用户名输入框
            Column {
                spacing: 5
                Layout.fillWidth: true
                
                Text {
                    text: "用户名"
                    font.pixelSize: 14
                    color: "#666"
                }
                
                TextField {
                    id: usernameInput
                    width: parent.width
                    placeholderText: "请输入用户名"
                    
                    // ✅ 子组件可以访问父组件
                    onTextChanged: {
                        // 访问父组件的父组件
                        loginPage.validateForm()
                    }
                }
            }
            
            // 密码输入框
            Column {
                spacing: 5
                Layout.fillWidth: true
                
                Text {
                    text: "密码"
                    font.pixelSize: 14
                    color: "#666"
                }
                
                TextField {
                    id: passwordInput
                    width: parent.width
                    placeholderText: "请输入密码"
                    echoMode: TextInput.Password
                }
            }
            
            // 记住密码选项
            Row {
                spacing: 10
                
                CheckBox {
                    id: rememberCheckbox
                    text: "记住密码"
                }
            }
        }
    }
    
    // 📦 组件3: 按钮区域
    Column {
        id: buttonArea
        anchors.top: formArea.bottom
        anchors.topMargin: 20
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width - 60
        spacing: 15
        
        Button {
            id: loginButton
            width: parent.width
            height: 45
            text: "登录"
            
            background: Rectangle {
                color: loginButton.pressed ? "#3a8ee6" : "#409EFF"
                radius: 5
            }
            
            contentItem: Text {
                text: loginButton.text
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            
            onClicked: {
                // ✅ 访问兄弟组件的子组件
                console.log("用户名:", formArea.children[0].children[1].text)
                // ❌ 更好的方式：通过 id 访问
                console.log("用户名:", usernameInput.text)
                console.log("密码:", passwordInput.text)
                
                // ✅ 调用父组件的方法
                loginPage.performLogin()
            }
        }
        
        Button {
            id: registerButton
            width: parent.width
            height: 45
            text: "注册新账号"
            flat: true
        }
    }
    
    // 📦 根组件的方法
    function validateForm() {
        // ✅ 父组件可以访问子组件
        var isValid = usernameInput.text.length > 0 && 
                      passwordInput.text.length > 0
        loginButton.enabled = isValid
    }
    
    function performLogin() {
        // ✅ 父组件访问多个子组件
        console.log("执行登录...")
        console.log("用户名:", usernameInput.text)
        console.log("密码:", passwordInput.text)
        console.log("记住密码:", rememberCheckbox.checked)
    }
}
```

---

## 幻灯片 4: 父子访问详细图解

```mermaid
graph TB
    subgraph "根组件 loginPage"
        A[Rectangle id: loginPage]
        
        subgraph "子组件层级"
            B[Rectangle id: headerArea]
            C[Rectangle id: formArea]
            D[Column id: buttonArea]
        end
        
        subgraph "孙组件层级"
            B1[Image id: logoImage]
            B2[Text id: appTitle]
            C1[TextField id: usernameInput]
            C2[TextField id: passwordInput]
            C3[CheckBox id: rememberCheckbox]
            D1[Button id: loginButton]
            D2[Button id: registerButton]
        end
    end
    
    A --> B
    A --> C
    A --> D
    
    B --> B1
    B --> B2
    C --> C1
    C --> C2
    C --> C3
    D --> D1
    D --> D2
    
    style A fill:#409EFF,color:#fff
    style B fill:#67C23A,color:#fff
    style C fill:#67C23A,color:#fff
    style D fill:#67C23A,color:#fff
    style B1 fill:#E6A23C,color:#fff
    style B2 fill:#E6A23C,color:#fff
    style C1 fill:#E6A23C,color:#fff
    style C2 fill:#E6A23C,color:#fff
    style C3 fill:#E6A23C,color:#fff
    style D1 fill:#E6A23C,color:#fff
    style D2 fill:#E6A23C,color:#fff
```

### 访问示例代码

```qml
// 在 loginPage (根组件) 中：
function example1() {
    // ✅ 访问直接子组件
    headerArea.color = "red"
    formArea.visible = false
    
    // ✅ 访问孙组件（通过 id）
    usernameInput.text = "admin"
    loginButton.enabled = true
    
    // ❌ 错误方式：通过层级访问
    // formArea.children[0].children[1].text = "admin"  // 不推荐
}

// 在 usernameInput (孙组件) 中：
onTextChanged: {
    // ✅ 访问父组件
    parent.color = "yellow"
    
    // ✅ 访问祖父组件
    parent.parent.color = "blue"
    
    // ✅ 访问根组件（通过 id）
    loginPage.validateForm()
    
    // ✅ 访问兄弟组件（通过 id）
    passwordInput.focus = true
}

// 在 loginButton (孙组件) 中：
onClicked: {
    // ✅ 访问其他孙组件（通过 id）
    console.log(usernameInput.text)
    console.log(passwordInput.text)
    
    // ✅ 访问根组件方法
    loginPage.performLogin()
}
```

---

## 幻灯片 5: 访问方式对比

```mermaid
graph LR
    A[访问方式] --> B[通过 id]
    A --> C[通过 parent]
    A --> D[通过 children]
    A --> E[通过属性别名]
    
    B --> B1[✅ 推荐<br/>清晰明确]
    C --> C1[✅ 常用<br/>访问父组件]
    D --> D1[❌ 不推荐<br/>容易出错]
    E --> E1[✅ 最佳<br/>封装性好]
    
    style B1 fill:#67C23A,color:#fff
    style C1 fill:#67C23A,color:#fff
    style D1 fill:#F56C6C,color:#fff
    style E1 fill:#409EFF,color:#fff
```

### 代码对比

```qml
// ❌ 方式1: 通过 children 索引（不推荐）
formArea.children[0].children[1].text = "admin"
// 问题：索引可能变化，代码难以维护

// ✅ 方式2: 通过 id（推荐）
usernameInput.text = "admin"
// 优点：清晰明确，不会出错

// ✅ 方式3: 通过 parent（常用）
parent.width
parent.parent.color
// 优点：访问父组件很方便

// ✅ 方式4: 通过属性别名（最佳）
// 在组件定义中：
property alias username: usernameInput.text
property alias password: passwordInput.text

// 使用时：
loginPage.username = "admin"
console.log(loginPage.password)
// 优点：封装性好，接口清晰
```

---

## 幻灯片 6: 属性别名 - 最佳实践

### 🎯 为什么使用属性别名？

```mermaid
graph TB
    A[属性别名的优势] --> B[封装内部实现]
    A --> C[提供清晰接口]
    A --> D[便于维护]
    A --> E[提高复用性]
    
    style A fill:#409EFF,color:#fff
    style B fill:#67C23A,color:#fff
    style C fill:#67C23A,color:#fff
    style D fill:#67C23A,color:#fff
    style E fill:#67C23A,color:#fff
```

### 完整示例

```qml
// LoginForm.qml - 封装良好的登录表单组件
import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: root
    width: 340
    height: 250
    color: "white"
    radius: 10
    
    // ✅ 对外暴露的属性（属性别名）
    property alias username: usernameInput.text
    property alias password: passwordInput.text
    property alias rememberMe: rememberCheckbox.checked
    property alias loginEnabled: loginButton.enabled
    
    // ✅ 对外暴露的信号
    signal loginClicked()
    signal registerClicked()
    
    Column {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 15
        
        // 内部实现细节
        TextField {
            id: usernameInput
            width: parent.width
            placeholderText: "用户名"
        }
        
        TextField {
            id: passwordInput
            width: parent.width
            placeholderText: "密码"
            echoMode: TextInput.Password
        }
        
        CheckBox {
            id: rememberCheckbox
            text: "记住密码"
        }
        
        Button {
            id: loginButton
            width: parent.width
            text: "登录"
            onClicked: root.loginClicked()
        }
        
        Button {
            width: parent.width
            text: "注册"
            onClicked: root.registerClicked()
        }
    }
}
```

### 使用封装好的组件

```qml
// 在其他地方使用
LoginForm {
    id: loginForm
    anchors.centerIn: parent
    
    // ✅ 通过属性别名访问
    username: "admin"
    
    // ✅ 连接信号
    onLoginClicked: {
        console.log("用户名:", loginForm.username)
        console.log("密码:", loginForm.password)
        console.log("记住密码:", loginForm.rememberMe)
    }
}

// ✅ 外部访问也很方便
Button {
    text: "自动填充"
    onClicked: {
        loginForm.username = "test@example.com"
        loginForm.password = "123456"
    }
}
```

---

## 幻灯片 7: 复杂页面组合实战

### 📱 完整应用页面结构

```mermaid
graph TB
    A[应用主窗口<br/>ApplicationWindow] --> B[顶部导航栏<br/>Header]
    A --> C[侧边栏<br/>Sidebar]
    A --> D[主内容区<br/>ContentArea]
    A --> E[底部状态栏<br/>Footer]
    
    B --> B1[Logo]
    B --> B2[搜索框]
    B --> B3[用户菜单]
    
    C --> C1[菜单项1]
    C --> C2[菜单项2]
    C --> C3[菜单项3]
    
    D --> D1[面包屑导航]
    D --> D2[页面标题]
    D --> D3[工具栏]
    D --> D4[数据表格]
    D --> D5[分页器]
    
    E --> E1[版权信息]
    E --> E2[在线状态]
    
    style A fill:#409EFF,color:#fff
    style B fill:#67C23A,color:#fff
    style C fill:#E6A23C,color:#fff
    style D fill:#F56C6C,color:#fff
    style E fill:#909399,color:#fff
```

### 完整代码示例

```qml
// MainWindow.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

ApplicationWindow {
    id: mainWindow
    visible: true
    width: 1200
    height: 800
    title: "企业管理系统"
    
    // 对外属性
    property string currentUser: "管理员"
    property string currentPage: "dashboard"
    
    // 顶部导航栏
    header: Rectangle {
        id: headerBar
        height: 60
        color: "#409EFF"
        
        RowLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 20
            
            // Logo
            Image {
                source: "qrc:/images/logo.png"
                Layout.preferredWidth: 40
                Layout.preferredHeight: 40
            }
            
            Text {
                text: "企业管理系统"
                color: "white"
                font.pixelSize: 20
                font.bold: true
            }
            
            // 搜索框
            TextField {
                id: searchInput
                Layout.fillWidth: true
                Layout.preferredHeight: 35
                placeholderText: "搜索..."
            }
            
            // 用户菜单
            Button {
                text: mainWindow.currentUser
                onClicked: userMenu.open()
                
                Menu {
                    id: userMenu
                    y: parent.height
                    
                    MenuItem { text: "个人设置" }
                    MenuItem { text: "退出登录" }
                }
            }
        }
    }
    
    // 主内容区
    RowLayout {
        anchors.fill: parent
        spacing: 0
        
        // 侧边栏
        Rectangle {
            id: sidebar
            Layout.preferredWidth: 200
            Layout.fillHeight: true
            color: "#2c3e50"
            
            Column {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 5
                
                Repeater {
                    model: ["仪表盘", "用户管理", "数据分析", "系统设置"]
                    
                    delegate: Button {
                        width: parent.width
                        height: 40
                        text: modelData
                        flat: true
                        
                        background: Rectangle {
                            color: mainWindow.currentPage === modelData ? 
                                   "#34495e" : "transparent"
                            radius: 5
                        }
                        
                        contentItem: Text {
                            text: parent.text
                            color: "white"
                            horizontalAlignment: Text.AlignLeft
                            verticalAlignment: Text.AlignVCenter
                            leftPadding: 10
                        }
                        
                        onClicked: {
                            mainWindow.currentPage = modelData
                            contentLoader.source = modelData + ".qml"
                        }
                    }
                }
            }
        }
        
        // 主内容区域
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#ecf0f1"
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 15
                
                // 面包屑导航
                Row {
                    spacing: 10
                    
                    Text { text: "首页" }
                    Text { text: ">" }
                    Text { text: mainWindow.currentPage }
                }
                
                // 页面标题
                Text {
                    text: mainWindow.currentPage
                    font.pixelSize: 24
                    font.bold: true
                }
                
                // 动态加载的内容
                Loader {
                    id: contentLoader
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    source: "Dashboard.qml"
                }
            }
        }
    }
    
    // 底部状态栏
    footer: Rectangle {
        height: 30
        color: "#34495e"
        
        RowLayout {
            anchors.fill: parent
            anchors.margins: 5
            
            Text {
                text: "© 2024 企业管理系统"
                color: "white"
                font.pixelSize: 12
            }
            
            Item { Layout.fillWidth: true }
            
            Rectangle {
                width: 10
                height: 10
                radius: 5
                color: "#67C23A"
            }
            
            Text {
                text: "在线"
                color: "white"
                font.pixelSize: 12
            }
        }
    }
}
```

---

## 幻灯片 8: 组件通信模式

```mermaid
sequenceDiagram
    participant P as 父组件
    participant C1 as 子组件1
    participant C2 as 子组件2
    
    Note over P,C2: 模式1: 父组件协调
    C1->>P: 发送信号
    P->>C2: 更新属性
    
    Note over P,C2: 模式2: 直接通信
    C1->>C2: 通过 id 直接访问
    
    Note over P,C2: 模式3: 共享数据
    P->>C1: 绑定共享属性
    P->>C2: 绑定共享属性
    C1->>P: 修改共享属性
    P->>C2: 自动更新
```

### 三种通信模式代码

```qml
// 模式1: 父组件协调（推荐）
Rectangle {
    id: parent
    
    Button {
        id: button1
        text: "按钮1"
        onClicked: parent.handleButton1Click()
    }
    
    Text {
        id: text1
    }
    
    function handleButton1Click() {
        text1.text = "按钮1被点击"
    }
}

// 模式2: 直接通信（简单场景）
Rectangle {
    Button {
        id: button2
        onClicked: text2.text = "直接更新"
    }
    
    Text {
        id: text2
    }
}

// 模式3: 共享数据（复杂场景）
Rectangle {
    id: parent
    property string sharedData: ""
    
    TextField {
        text: parent.sharedData
        onTextChanged: parent.sharedData = text
    }
    
    Text {
        text: parent.sharedData  // 自动同步
    }
}
```

---

## 幻灯片 9: 最佳实践总结

### ✅ 推荐做法

```mermaid
graph LR
    A[最佳实践] --> B[使用 id 访问]
    A --> C[使用属性别名]
    A --> D[使用信号通信]
    A --> E[保持组件独立]
    
    style A fill:#409EFF,color:#fff
    style B fill:#67C23A,color:#fff
    style C fill:#67C23A,color:#fff
    style D fill:#67C23A,color:#fff
    style E fill:#67C23A,color:#fff
```

| 场景 | 推荐方式 | 原因 |
|------|----------|------|
| 访问子组件 | 通过 id | 清晰明确 |
| 访问父组件 | parent 关键字 | 简单直接 |
| 组件封装 | 属性别名 | 接口清晰 |
| 组件通信 | 信号机制 | 解耦合 |
| 跨层访问 | 避免或使用 id | 减少依赖 |

### ❌ 避免做法

| 错误做法 | 问题 | 正确做法 |
|----------|------|----------|
| `children[0].property` | 索引可能变化 | 使用 id |
| `parent.parent.parent` | 耦合度太高 | 使用信号或属性 |
| 直接修改内部组件 | 破坏封装 | 使用属性别名 |
| 循环引用 | 导致错误 | 重新设计结构 |

---

## 幻灯片 10: 参考资源

### 📚 在线图片资源

1. **UI 设计参考**
   - [Dribbble - UI Design](https://dribbble.com/tags/ui)
   - [Behance - Interface Design](https://www.behance.net/search/projects?search=interface)
   - [Pinterest - UI Components](https://www.pinterest.com/search/pins/?q=ui%20components)

2. **组件库参考**
   - [Material Design](https://material.io/design)
   - [Ant Design](https://ant.design/)
   - [Element UI](https://element.eleme.io/)
   - [Fluent UI](https://developer.microsoft.com/en-us/fluentui)

3. **图标资源**
   - [Font Awesome](https://fontawesome.com/)
   - [Material Icons](https://fonts.google.com/icons)
   - [Feather Icons](https://feathericons.com/)

4. **配色方案**
   - [Coolors](https://coolors.co/)
   - [Adobe Color](https://color.adobe.com/)
   - [Material Palette](https://www.materialpalette.com/)

### 🎨 设计工具
- Figma
- Sketch
- Adobe XD
- Qt Design Studio

---

<div align="center">

## 🎯 核心要点

**组件组合 = 搭积木**
**父子访问 = 有规则的沟通**
**属性别名 = 清晰的接口**

掌握这三点，你就能构建任何复杂的 QML 应用！ 🚀

</div>
