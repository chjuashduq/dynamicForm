# QML 完全学习教程 - 第4章：JavaScript 集成

## 📚 目录
1. [JavaScript 基础](#javascript-基础)
2. [在 QML 中使用 JavaScript](#在-qml-中使用-javascript)
3. [JavaScript 文件](#javascript-文件)
4. [常用 JavaScript 技巧](#常用-javascript-技巧)
5. [实战案例](#实战案例)

---

## JavaScript 基础

QML 使用 JavaScript 作为脚本语言,支持 ES6+ 语法。

### 1. 变量和数据类型

```qml
Item {
    Component.onCompleted: {
        // 变量声明
        var name = "张三"           // 字符串
        var age = 25                // 数字
        var isActive = true         // 布尔值
        var data = null             // null
        var nothing                 // undefined
        
        // ES6 变量声明
        let count = 0               // 块级作用域
        const PI = 3.14159          // 常量
        
        // 数组
        var numbers = [1, 2, 3, 4, 5]
        var mixed = [1, "hello", true, {name: "test"}]
        
        // 对象
        var person = {
            name: "李四",
            age: 30,
            address: {
                city: "北京",
                street: "长安街"
            }
        }
        
        console.log("姓名:", person.name)
        console.log("城市:", person.address.city)
    }
}
```

### 2. 函数

```qml
Item {
    // 函数定义
    function add(a, b) {
        return a + b
    }
    
    // 箭头函数
    property var multiply: (a, b) => a * b
    
    // 默认参数
    function greet(name = "访客") {
        return "你好, " + name
    }
    
    // 可变参数
    function sum(...numbers) {
        return numbers.reduce((total, num) => total + num, 0)
    }
    
    Component.onCompleted: {
        console.log(add(5, 3))              // 8
        console.log(multiply(4, 6))         // 24
        console.log(greet())                // 你好, 访客
        console.log(greet("张三"))          // 你好, 张三
        console.log(sum(1, 2, 3, 4, 5))    // 15
    }
}
```

### 3. 控制流

```qml
Item {
    function checkAge(age) {
        // if-else
        if (age < 18) {
            return "未成年"
        } else if (age < 60) {
            return "成年人"
        } else {
            return "老年人"
        }
    }
    
    function getDayName(day) {
        // switch
        switch(day) {
            case 0: return "星期日"
            case 1: return "星期一"
            case 2: return "星期二"
            case 3: return "星期三"
            case 4: return "星期四"
            case 5: return "星期五"
            case 6: return "星期六"
            default: return "无效"
        }
    }
    
    function printNumbers() {
        // for 循环
        for (var i = 0; i < 5; i++) {
            console.log(i)
        }
        
        // for...of 循环
        var fruits = ["苹果", "香蕉", "橙子"]
        for (var fruit of fruits) {
            console.log(fruit)
        }
        
        // while 循环
        var count = 0
        while (count < 3) {
            console.log("Count:", count)
            count++
        }
    }
}
```

---

## 在 QML 中使用 JavaScript

### 1. 内联 JavaScript

直接在 QML 属性中使用 JavaScript 表达式。

```qml
Rectangle {
    // 简单表达式
    width: 100 * 2
    height: width / 2
    color: width > 150 ? "green" : "red"
    
    // 三元运算符
    visible: count > 0 ? true : false
    
    // 逻辑运算
    enabled: isLoggedIn && hasPermission
    
    property int count: 0
    property bool isLoggedIn: true
    property bool hasPermission: false
}
```

### 2. 函数定义

```qml
Rectangle {
    id: root
    
    // 简单函数
    function sayHello() {
        console.log("Hello!")
    }
    
    // 带参数的函数
    function calculateArea(width, height) {
        return width * height
    }
    
    // 访问 QML 属性
    function doubleWidth() {
        root.width = root.width * 2
    }
    
    // 复杂逻辑
    function processData(data) {
        if (!data) {
            console.log("数据为空")
            return null
        }
        
        var result = {
            processed: true,
            timestamp: Date.now(),
            data: data
        }
        
        return result
    }
    
    MouseArea {
        anchors.fill: parent
        onClicked: {
            root.sayHello()
            var area = root.calculateArea(100, 50)
            console.log("面积:", area)
        }
    }
}
```

### 3. 数组操作

```qml
Item {
    property var items: ["苹果", "香蕉", "橙子"]
    
    function arrayOperations() {
        // 添加元素
        items.push("葡萄")
        
        // 删除最后一个元素
        items.pop()
        
        // 在开头添加
        items.unshift("草莓")
        
        // 删除第一个元素
        items.shift()
        
        // 查找元素
        var index = items.indexOf("香蕉")
        console.log("香蕉的索引:", index)
        
        // 切片
        var slice = items.slice(0, 2)
        console.log("前两个:", slice)
        
        // 拼接
        var newItems = items.concat(["西瓜", "芒果"])
        console.log("拼接后:", newItems)
        
        // 遍历
        items.forEach(function(item, index) {
            console.log(index + ":", item)
        })
        
        // 映射
        var upperItems = items.map(function(item) {
            return item.toUpperCase()
        })
        
        // 过滤
        var filtered = items.filter(function(item) {
            return item.length > 2
        })
        
        // 查找
        var found = items.find(function(item) {
            return item.startsWith("苹")
        })
        
        // 归约
        var lengths = items.reduce(function(total, item) {
            return total + item.length
        }, 0)
    }
}
```

### 4. 对象操作

```qml
Item {
    property var person: ({
        name: "张三",
        age: 25,
        city: "北京"
    })
    
    function objectOperations() {
        // 访问属性
        console.log(person.name)
        console.log(person["age"])
        
        // 修改属性
        person.age = 26
        person["city"] = "上海"
        
        // 添加属性
        person.email = "zhangsan@example.com"
        
        // 删除属性
        delete person.email
        
        // 检查属性是否存在
        if ("name" in person) {
            console.log("有 name 属性")
        }
        
        // 获取所有键
        var keys = Object.keys(person)
        console.log("键:", keys)
        
        // 获取所有值
        var values = Object.values(person)
        console.log("值:", values)
        
        // 遍历对象
        for (var key in person) {
            console.log(key + ":", person[key])
        }
        
        // 合并对象
        var extra = {phone: "13800138000"}
        var merged = Object.assign({}, person, extra)
        
        // 深拷贝
        var copy = JSON.parse(JSON.stringify(person))
    }
}
```

---

## JavaScript 文件

将 JavaScript 代码放在单独的 `.js` 文件中,便于复用和维护。

### 1. 创建 JS 文件

创建 `utils.js`:

```javascript
// utils.js

// 格式化日期
function formatDate(date) {
    var year = date.getFullYear()
    var month = String(date.getMonth() + 1).padStart(2, '0')
    var day = String(date.getDate()).padStart(2, '0')
    return year + '-' + month + '-' + day
}

// 格式化时间
function formatTime(date) {
    var hours = String(date.getHours()).padStart(2, '0')
    var minutes = String(date.getMinutes()).padStart(2, '0')
    var seconds = String(date.getSeconds()).padStart(2, '0')
    return hours + ':' + minutes + ':' + seconds
}

// 格式化日期时间
function formatDateTime(date) {
    return formatDate(date) + ' ' + formatTime(date)
}

// 验证邮箱
function validateEmail(email) {
    var pattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
    return pattern.test(email)
}

// 验证手机号
function validatePhone(phone) {
    var pattern = /^1[3-9]\d{9}$/
    return pattern.test(phone)
}

// 生成随机字符串
function randomString(length) {
    var chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'
    var result = ''
    for (var i = 0; i < length; i++) {
        result += chars.charAt(Math.floor(Math.random() * chars.length))
    }
    return result
}

// 深拷贝
function deepCopy(obj) {
    return JSON.parse(JSON.stringify(obj))
}

// 防抖函数
function debounce(func, wait) {
    var timeout
    return function() {
        var context = this
        var args = arguments
        clearTimeout(timeout)
        timeout = setTimeout(function() {
            func.apply(context, args)
        }, wait)
    }
}
```

### 2. 导入和使用 JS 文件

```qml
import QtQuick 6.5
import QtQuick.Controls 6.5
import "utils.js" as Utils

ApplicationWindow {
    width: 400
    height: 300
    visible: true
    title: "JavaScript 文件示例"
    
    Column {
        anchors.centerIn: parent
        spacing: 20
        
        Button {
            text: "显示当前时间"
            onClicked: {
                var now = new Date()
                var formatted = Utils.formatDateTime(now)
                timeText.text = formatted
            }
        }
        
        Text {
            id: timeText
            text: "点击按钮显示时间"
            font.pixelSize: 16
        }
        
        TextField {
            id: emailField
            placeholderText: "输入邮箱"
            width: 250
        }
        
        Button {
            text: "验证邮箱"
            onClicked: {
                var isValid = Utils.validateEmail(emailField.text)
                resultText.text = isValid ? "✅ 邮箱格式正确" : "❌ 邮箱格式错误"
                resultText.color = isValid ? "green" : "red"
            }
        }
        
        Text {
            id: resultText
            font.pixelSize: 14
        }
    }
}
```

### 3. 共享状态的 JS 文件

创建 `state.js`:

```javascript
// state.js
.pragma library  // 声明为库,所有导入共享同一实例

var currentUser = null
var isLoggedIn = false
var settings = {}

function login(username) {
    currentUser = username
    isLoggedIn = true
    console.log("用户登录:", username)
}

function logout() {
    currentUser = null
    isLoggedIn = false
    console.log("用户登出")
}

function getSetting(key, defaultValue) {
    return settings[key] !== undefined ? settings[key] : defaultValue
}

function setSetting(key, value) {
    settings[key] = value
}
```

使用共享状态:

```qml
import QtQuick 6.5
import "state.js" as State

Item {
    Component.onCompleted: {
        // 所有导入 state.js 的地方共享同一个状态
        State.login("张三")
        console.log("当前用户:", State.currentUser)
        console.log("是否登录:", State.isLoggedIn)
    }
}
```

---

## 常用 JavaScript 技巧

### 1. 字符串操作

```qml
Item {
    function stringOperations() {
        var str = "Hello World"
        
        // 长度
        console.log(str.length)  // 11
        
        // 大小写转换
        console.log(str.toUpperCase())  // HELLO WORLD
        console.log(str.toLowerCase())  // hello world
        
        // 查找
        console.log(str.indexOf("World"))  // 6
        console.log(str.includes("Hello")) // true
        
        // 替换
        console.log(str.replace("World", "QML"))  // Hello QML
        
        // 分割
        var words = str.split(" ")  // ["Hello", "World"]
        
        // 截取
        console.log(str.substring(0, 5))  // Hello
        console.log(str.slice(6))         // World
        
        // 去除空格
        var padded = "  test  "
        console.log(padded.trim())  // "test"
        
        // 重复
        console.log("*".repeat(5))  // *****
        
        // 模板字符串
        var name = "张三"
        var age = 25
        console.log(`姓名: ${name}, 年龄: ${age}`)
    }
}
```

### 2. 数学运算

```qml
Item {
    function mathOperations() {
        // 基本运算
        console.log(Math.abs(-5))      // 5
        console.log(Math.ceil(4.3))    // 5
        console.log(Math.floor(4.7))   // 4
        console.log(Math.round(4.5))   // 5
        
        // 最大最小值
        console.log(Math.max(1, 5, 3)) // 5
        console.log(Math.min(1, 5, 3)) // 1
        
        // 幂运算
        console.log(Math.pow(2, 3))    // 8
        console.log(Math.sqrt(16))     // 4
        
        // 随机数
        console.log(Math.random())     // 0-1 之间的随机数
        
        // 随机整数 (min 到 max 之间)
        function randomInt(min, max) {
            return Math.floor(Math.random() * (max - min + 1)) + min
        }
        console.log(randomInt(1, 10))
        
        // 三角函数
        console.log(Math.sin(Math.PI / 2))  // 1
        console.log(Math.cos(0))            // 1
    }
}
```

### 3. 日期时间

```qml
Item {
    function dateOperations() {
        // 创建日期
        var now = new Date()
        var specific = new Date(2024, 0, 1)  // 2024年1月1日
        var fromString = new Date("2024-01-01")
        
        // 获取日期部分
        console.log(now.getFullYear())   // 年
        console.log(now.getMonth())      // 月 (0-11)
        console.log(now.getDate())       // 日
        console.log(now.getDay())        // 星期 (0-6)
        
        // 获取时间部分
        console.log(now.getHours())      // 小时
        console.log(now.getMinutes())    // 分钟
        console.log(now.getSeconds())    // 秒
        console.log(now.getMilliseconds()) // 毫秒
        
        // 时间戳
        console.log(now.getTime())       // 毫秒时间戳
        console.log(Date.now())          // 当前时间戳
        
        // 日期计算
        var tomorrow = new Date()
        tomorrow.setDate(tomorrow.getDate() + 1)
        
        var nextMonth = new Date()
        nextMonth.setMonth(nextMonth.getMonth() + 1)
    }
}
```

### 4. JSON 操作

```qml
Item {
    function jsonOperations() {
        // 对象转 JSON 字符串
        var obj = {
            name: "张三",
            age: 25,
            hobbies: ["阅读", "运动"]
        }
        var jsonString = JSON.stringify(obj)
        console.log(jsonString)
        
        // 格式化输出
        var formatted = JSON.stringify(obj, null, 2)
        console.log(formatted)
        
        // JSON 字符串转对象
        var parsed = JSON.parse(jsonString)
        console.log(parsed.name)
        
        // 深拷贝
        var copy = JSON.parse(JSON.stringify(obj))
    }
}
```

---

## 实战案例

### 案例 1: 表单验证器

创建 `validator.js`:

```javascript
// validator.js

function validateRequired(value, message) {
    if (!value || value.trim() === "") {
        return {
            valid: false,
            message: message || "此字段不能为空"
        }
    }
    return { valid: true }
}

function validateEmail(value) {
    var pattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
    if (!pattern.test(value)) {
        return {
            valid: false,
            message: "请输入有效的邮箱地址"
        }
    }
    return { valid: true }
}

function validatePhone(value) {
    var pattern = /^1[3-9]\d{9}$/
    if (!pattern.test(value)) {
        return {
            valid: false,
            message: "请输入有效的手机号码"
        }
    }
    return { valid: true }
}

function validateLength(value, min, max) {
    var len = value.length
    if (len < min) {
        return {
            valid: false,
            message: `长度不能少于 ${min} 个字符`
        }
    }
    if (max && len > max) {
        return {
            valid: false,
            message: `长度不能超过 ${max} 个字符`
        }
    }
    return { valid: true }
}

function validateNumber(value, min, max) {
    var num = parseFloat(value)
    if (isNaN(num)) {
        return {
            valid: false,
            message: "请输入有效的数字"
        }
    }
    if (min !== undefined && num < min) {
        return {
            valid: false,
            message: `数值不能小于 ${min}`
        }
    }
    if (max !== undefined && num > max) {
        return {
            valid: false,
            message: `数值不能大于 ${max}`
        }
    }
    return { valid: true }
}
```

使用验证器:

```qml
import QtQuick 6.5
import QtQuick.Controls 6.5
import QtQuick.Layouts 1.4
import "validator.js" as Validator

ApplicationWindow {
    width: 500
    height: 400
    visible: true
    title: "表单验证示例"
    
    ScrollView {
        anchors.fill: parent
        anchors.margins: 20
        
        ColumnLayout {
            width: parent.width - 40
            spacing: 15
            
            // 用户名
            TextField {
                id: usernameField
                placeholderText: "用户名"
                Layout.fillWidth: true
                
                property string errorMessage: ""
                
                onTextChanged: errorMessage = ""
            }
            
            Text {
                text: usernameField.errorMessage
                color: "red"
                font.pixelSize: 12
                visible: usernameField.errorMessage !== ""
            }
            
            // 邮箱
            TextField {
                id: emailField
                placeholderText: "邮箱"
                Layout.fillWidth: true
                
                property string errorMessage: ""
                
                onTextChanged: errorMessage = ""
            }
            
            Text {
                text: emailField.errorMessage
                color: "red"
                font.pixelSize: 12
                visible: emailField.errorMessage !== ""
            }
            
            // 手机号
            TextField {
                id: phoneField
                placeholderText: "手机号"
                Layout.fillWidth: true
                
                property string errorMessage: ""
                
                onTextChanged: errorMessage = ""
            }
            
            Text {
                text: phoneField.errorMessage
                color: "red"
                font.pixelSize: 12
                visible: phoneField.errorMessage !== ""
            }
            
            // 提交按钮
            Button {
                text: "提交"
                Layout.alignment: Qt.AlignHCenter
                
                onClicked: {
                    var isValid = true
                    
                    // 验证用户名
                    var usernameResult = Validator.validateRequired(usernameField.text, "用户名不能为空")
                    if (!usernameResult.valid) {
                        usernameField.errorMessage = usernameResult.message
                        isValid = false
                    } else {
                        var lengthResult = Validator.validateLength(usernameField.text, 3, 20)
                        if (!lengthResult.valid) {
                            usernameField.errorMessage = lengthResult.message
                            isValid = false
                        }
                    }
                    
                    // 验证邮箱
                    var emailResult = Validator.validateEmail(emailField.text)
                    if (!emailResult.valid) {
                        emailField.errorMessage = emailResult.message
                        isValid = false
                    }
                    
                    // 验证手机号
                    var phoneResult = Validator.validatePhone(phoneField.text)
                    if (!phoneResult.valid) {
                        phoneField.errorMessage = phoneResult.message
                        isValid = false
                    }
                    
                    if (isValid) {
                        console.log("表单验证通过!")
                        // 提交数据...
                    }
                }
            }
        }
    }
}
```

---

## 📝 小结

本章学习了:
- ✅ JavaScript 在 QML 中的基本用法
- ✅ 如何创建和使用 JavaScript 文件
- ✅ 常用的 JavaScript 操作技巧
- ✅ 实际项目中的 JavaScript 应用

**下一章预告:** 动画系统 - 学习如何创建流畅的动画效果
