# FormGenerator 改进计划

## 已完成
- ✅ 问题4：生成代码页面添加滚动支持

## 待实现功能

### 问题1：控件顺序调整
**需求**：能够调整控件的前后顺序，而不只是依次向下插入

**实现方案**：
1. 在 `CanvasItem` 上添加上移/下移按钮
2. 实现 `moveItem(index, direction)` 函数
3. 支持拖拽重排序（可选，复杂度更高）

**关键代码位置**：
- `CanvasItem.qml` - 添加控制按钮
- `FormGenerator.qml` - 添加移动函数

### 问题2：横向布局内嵌入控件
**需求**：StyledRow（横向布局）应该能够接受拖拽的子控件

**当前问题**：
- `CanvasItem.qml` 中的 `StyledRow` 有 `DropArea`，但可能没有正确触发
- `handleDrop` 需要支持容器作为 target

**实现方案**：
1. 确保 `StyledRow` 的 `DropArea` 能够正确接收 drop 事件
2. `handleDrop` 需要正确处理 `targetParent` 参数
3. 添加视觉反馈（高亮显示可放置区域）

**关键代码位置**：
- `CanvasItem.qml` 行 125-132 (StyledRow 的 DropArea)
- `FormGenerator.qml` `handleDrop` 函数

### 问题3：属性编辑冲突
**需求**：区分组件属性和布局属性，避免混淆

**实现方案**：
1. 在 `PropertyEditor` 中添加分组（Tabs 或 Sections）
   - "组件属性" tab：组件特有属性（text, placeholder, from, to 等）
   - "布局属性" tab：布局相关属性（layoutType, flex, widthPercent等）
   - "通用属性" tab：visible, enabled 等

2. 重构 `PropertyEditor.qml` 使用分组展示

**关键代码位置**：
- `PropertyEditor.qml` - 完全重构

## 实施优先级
1. **高优先级**：问题2（横向布局嵌入）- 这是核心功能
2. **中优先级**：问题1（顺序调整）- 提升用户体验
3. **低优先级**：问题3（属性分组）- UI优化

## 建议实施顺序
1. 先修复问题2，确保横向布局能够正常工作
2. 然后实现问题1，添加上下移动按钮
3. 最后优化问题3，改进属性编辑器UI
