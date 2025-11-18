# showMessage 使用统一说明

## 重要变更

为了简化使用，`showMessage` 函数在所有上下文中都可以**直接调用**，不需要 `formAPI.` 前缀。

## 统一的调用方式

### ✅ 推荐写法（统一）

```javascript
showMessage('消息内容', 'error');
```

### ⚠️ 旧写法（仍然支持，但不推荐）

```javascript
formAPI.showMessage('消息内容', 'error');
```

## 适用场景

### 1. 验证函数中

```javascript
// ✅ 推荐
if (!value || value.trim() === '') {
    showMessage('此字段不能为空', 'error');
    return false;
}
return true;

// ⚠️ 旧写法（仍然支持）
if (!value || value.trim() === '') {
    formAPI.showMessage('此字段不能为空', 'error');
    return false;
}
return true;
```

### 2. 事件函数中（onFocusLost、onTextChanged 等）

```javascript
// ✅ 推荐
if (self.text === '') {
    showMessage('请输入内容', 'warning');
}

// ⚠️ 旧写法（仍然支持）
if (self.text === '') {
    formAPI.showMessage('请输入内容', 'warning');
}
```

### 3. 按钮点击事件中

```javascript
// ✅ 推荐
try {
    MySqlHelper.insert('users', data);
    showMessage('提交成功！', 'success');
} catch(e) {
    showMessage('提交失败: ' + e, 'error');
}

// ⚠️ 旧写法（仍然支持）
try {
    MySqlHelper.insert('users', data);
    formAPI.showMessage('提交成功！', 'success');
} catch(e) {
    formAPI.showMessage('提交失败: ' + e, 'error');
}
```

## 为什么统一？

### 1. 更简洁

```javascript
// 简洁
showMessage('错误', 'error');

// 冗长
formAPI.showMessage('错误', 'error');
```

### 2. 更一致

在所有上下文中使用相同的调用方式，不需要记住什么时候用 `formAPI.`，什么时候不用。

### 3. 更符合习惯

类似于 JavaScript 的全局函数（如 `console.log()`），直接调用更自然。

## 其他全局函数

以下函数也可以直接调用，不需要 `formAPI.` 前缀：

### 控件操作
```javascript
getControlValue('name')           // 获取控件值
setControlValue('name', '张三')   // 设置控件值
enableControl('submitBtn')        // 启用控件
disableControl('submitBtn')       // 禁用控件
showControl('name')               // 显示控件
hideControl('name')               // 隐藏控件
focusControl('name')              // 让控件获得焦点
```

### 表单操作
```javascript
getAllValues()                    // 获取所有控件的值
validateAll()                     // 验证所有控件
resetForm()                       // 重置整个表单
resetControl('name')              // 重置指定控件
```

### 验证函数
```javascript
validateEmail(value)              // 验证邮箱
validatePhone(value)              // 验证手机号
validateIdCard(value)             // 验证身份证
validateChinese(value)            // 验证中文
validateNumber(value, min, max)   // 验证数字范围
validateRegex(value, pattern, msg) // 正则验证
```

### 数据库操作
```javascript
MySqlHelper.insert(table, data)
MySqlHelper.select(table, columns, where)
MySqlHelper.update(table, data, where)
MySqlHelper.remove(table, where)
```

## 完整示例

### 验证函数示例

```javascript
// 姓名验证
if (!value || value.trim() === '') {
    showMessage('姓名不能为空', 'error');
    return false;
}
if (value.length < 2) {
    showMessage('姓名至少2个字符', 'error');
    return false;
}
return true;
```

### 失去焦点事件示例

```javascript
// 检查三个字段是否都验证通过
if (formAPI.areControlsValid(['name', 'age', 'city'])) {
    // 执行查询
    var result = MySqlHelper.select('users', ['*'], 
        'name="' + getControlValue('name') + '"'
    );
    
    if (result.length > 0) {
        showMessage('找到 ' + result.length + ' 条记录', 'success');
    } else {
        showMessage('未找到记录', 'info');
    }
} else {
    showMessage('请先完成所有必填项', 'warning');
}
```

### 提交按钮示例

```javascript
// 验证所有字段
var validation = validateAll();
if (!validation.valid) {
    return; // 验证失败，已自动提示
}

// 提交数据
var submitData = {
    formId: formId,
    data: JSON.stringify(formData)
};

try {
    MySqlHelper.insert('dynamicData', submitData);
    showMessage('提交成功！', 'success');
    resetForm();
} catch(e) {
    showMessage('提交失败: ' + e, 'error');
}
```

## 注意事项

### 1. 两种写法都支持

为了兼容性，`formAPI.showMessage()` 仍然可以使用，但推荐使用 `showMessage()`。

### 2. 在验证函数中必须调用

验证函数返回 `false` 时，必须先调用 `showMessage()` 显示错误消息：

```javascript
// ✅ 正确
if (!value) {
    showMessage('不能为空', 'error');
    return false;
}

// ❌ 错误（没有显示消息）
if (!value) {
    return false;
}
```

### 3. 消息类型

`showMessage()` 的第二个参数是消息类型：
- `'info'` - 信息（蓝色）
- `'success'` - 成功（绿色）
- `'error'` - 错误（红色）
- `'warning'` - 警告（橙色）

## 迁移指南

如果你的代码中使用了 `formAPI.showMessage()`，可以：

### 选项1：保持不变

旧代码仍然可以正常工作，不需要修改。

### 选项2：批量替换

使用编辑器的查找替换功能：
- 查找：`formAPI.showMessage(`
- 替换为：`showMessage(`

## 总结

- ✅ 推荐使用：`showMessage('消息', 'error')`
- ⚠️ 仍然支持：`formAPI.showMessage('消息', 'error')`
- 📝 统一使用简洁的写法，让代码更清晰
- 🔄 旧代码不需要修改，仍然可以正常工作
