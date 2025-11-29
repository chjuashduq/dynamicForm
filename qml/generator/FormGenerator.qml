import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt.labs.folderlistmodel
import QtQuick.Dialogs

import "../utils"
import "../Common"
import "../components"
import "properties"
import "library"
import "logic/FormGeneratorLogic.js" as Logic
import "json/FormSerializer.js" as Serializer
import "../core"

Item {
    id: root
    objectName: "FormGeneratorRoot"
    anchors.fill: parent

    // Core Components for Preview
    FormAPI {
        id: formAPI
        scriptEngine: scriptEngine
    }

    ScriptEngine {
        id: scriptEngine
        formAPI: formAPI
    }

    property alias formAPI: formAPI
    property alias scriptEngine: scriptEngine

    // Model to store the form structure
    property var formModel: []
    property var selectedItem: null
    property bool previewMode: false

    // Component Library Model
    property var componentGroups: undefined
    Component.onCompleted: {
        if (typeof componentJson !== "undefined") {
            componentGroups = JSON.parse(componentJson);
        } else {
            console.warn("componentJson is undefined, using default list");
            var defaultJson = '[{"group":"布局组件","items":[{"type":"StyledRow","label":"横向布局","icon":"▤"}]},{"group":"基础组件","items":[{"type":"StyledTextField","label":"文本输入","icon":"✎","supportFormConfig":true},{"type":"StyledSpinBox","label":"数字输入","icon":"123","supportFormConfig":true},{"type":"StyledComboBox","label":"下拉选择","icon":"▼","supportFormConfig":true},{"type":"StyledButton","label":"按钮","icon":"ok"},{"type":"StyledLabel","label":"文本标签","icon":"T"}]}]';
            componentGroups = JSON.parse(defaultJson);
        }
    }
    RowLayout {
        anchors.fill: parent
        spacing: 0

        // Left Panel: Component Library
        Rectangle {
            Layout.preferredWidth: 250
            Layout.fillHeight: true
            visible: !root.previewMode // Hide library in preview mode

            gradient: Gradient {
                GradientStop {
                    position: 0.0
                    color: "#f8f9fa"
                }
                GradientStop {
                    position: 1.0
                    color: "#e9ecef"
                }
            }

            border.color: "#dee2e6"
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 15

                // Title
                Rectangle {
                    Layout.fillWidth: true
                    height: 40
                    color: "#1890ff"
                    radius: 8

                    Text {
                        anchors.centerIn: parent
                        text: "📦 组件库"
                        font.bold: true
                        font.pixelSize: 18
                        color: "white"
                    }
                }

                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true

                    Column {
                        width: parent.width
                        spacing: 12

                        Repeater {
                            model: componentGroups
                            delegate: Column {
                                width: parent.width
                                spacing: 10

                                Text {
                                    text: modelData.group
                                    font.bold: true
                                }

                                Flow {
                                    width: parent.width
                                    spacing: 10

                                    Repeater {
                                        model: modelData.items
                                        delegate: DraggableComponent {
                                            componentType: modelData.type
                                            label: modelData.label
                                            icon: modelData.icon
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        // Center Panel: Canvas
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredWidth: 100 // Allow it to shrink/grow
            Layout.minimumWidth: 300   // Minimum usable width
            color: "white"

            // Toolbar
            RowLayout {
                id: toolbar
                height: 40
                width: parent.width
                anchors.top: parent.top
                spacing: 10

                Button {
                    text: root.previewMode ? "退出预览" : "预览模式"
                    onClicked: {
                        root.previewMode = !root.previewMode;
                        if (root.previewMode) {
                            root.selectedItem = null; // Clear selection when entering preview
                        }
                    }
                }

                Button {
                    text: "清空"
                    visible: !root.previewMode
                    onClicked: {
                        root.formModel = [];
                        root.selectedItem = null;
                    }
                }

                Button {
                    text: "生成代码"
                    visible: !root.previewMode
                    onClicked: generateCode()
                }

                Button {
                    text: "导出JSON"
                    visible: !root.previewMode
                    onClicked: {
                        exportDialog.open();
                    }
                }

                Button {
                    text: "导入JSON"
                    visible: !root.previewMode
                    onClicked: {
                        importDialog.open();
                    }
                }

                Item {
                    Layout.fillWidth: true
                }
            }

            ScrollView {
                anchors.top: toolbar.bottom
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right

                Flickable {
                    id: canvasFlickable
                    anchors.fill: parent
                    contentHeight: canvasColumn.height + 100
                    contentWidth: width

                    Column {
                        id: canvasColumn
                        width: parent.width - 40
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 10

                        // Drop Area for Root (Append)
                        DropArea {
                            id: rootDropArea
                            width: parent.width
                            height: Math.max(canvasFlickable.height - 20, 500)

                            onDropped: drop => {
                                console.log("根节点 DropArea 触发");
                                var targetIndex = -1;
                                var yPos = canvasContent.mapFromItem(rootDropArea, drop.x, drop.y).y;
                                // Calculate index based on Y position
                                var visualChildren = [];
                                for (var i = 0; i < canvasContent.children.length; i++) {
                                    var child = canvasContent.children[i];
                                    if (child.item && child.item.hasOwnProperty("itemData")) {
                                        visualChildren.push(child);
                                    }
                                }

                                for (var i = 0; i < visualChildren.length; i++) {
                                    var child = visualChildren[i];
                                    if (yPos < child.y + child.height / 2) {
                                        targetIndex = i;
                                        break;
                                    }
                                }

                                handleDrop(drop, null, targetIndex);
                            }

                            Rectangle {
                                anchors.fill: parent
                                color: "#f5f7fa"
                                border.color: "#e4e7ed"

                                Flow {
                                    id: canvasContent
                                    width: parent.width - 40
                                    anchors.top: parent.top
                                    anchors.topMargin: 20
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    spacing: 0
                                    flow: Flow.LeftToRight

                                    Repeater {
                                        model: root.formModel
                                        delegate: Loader {
                                            width: {
                                                if (!modelData.props)
                                                    return canvasContent.width;
                                                var type = modelData.props.layoutType;

                                                if (type === "fixed")
                                                    return modelData.props.width || 100;
                                                if (type === "percent")
                                                    return (canvasContent.width - 10) * ((modelData.props.widthPercent || 100) / 100);
                                                // Default or fill
                                                return canvasContent.width;
                                            }

                                            source: "canvas/CanvasItem.qml"
                                            onLoaded: {
                                                item.itemData = modelData;
                                                item.index = index;
                                                item.parentModel = root.formModel;
                                                item.parentItemData = null;
                                            }
                                            Binding {
                                                target: item
                                                property: "itemData"
                                                value: modelData
                                                when: item !== null
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        // Right Panel: Properties
        Rectangle {
            // [修改] 增加属性面板宽度到 350
            Layout.preferredWidth: 350
            Layout.fillHeight: true
            color: "#f0f2f5"
            border.color: "#dcdfe6"

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 10

                Text {
                    text: "属性设置"
                    font.bold: true
                    font.pixelSize: 16
                }

                PropertyEditor {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    targetItem: root.selectedItem
                    visible: !root.previewMode
                    onPropertyChanged: (key, value) => {
                        Logic.updateItemProperty(root, key, value);
                    }
                }
            }
        }
    }

    function handleDrop(drop, targetParent, targetIndex) {
        Logic.handleDrop(drop, root, targetParent, targetIndex);
    }

    function deleteItem(item, parentList) {
        Logic.deleteItem(item, parentList, root);
    }

    function generateCode() {
        Logic.generateCode(root, codeDialog);
    }

    // Use QtQuick.Controls Dialog (default)
    Dialog {
        id: codeDialog
        title: "生成的QML代码"
        width: 600
        height: 500
        anchors.centerIn: parent
        property string code: ""
        standardButtons: Dialog.Ok

        ScrollView {
            anchors.fill: parent

            TextArea {
                anchors.fill: parent
                text: codeDialog.code
                readOnly: true
                selectByMouse: true
                wrapMode: TextArea.NoWrap
            }
        }
    }

    FileDialog {
        id: exportDialog
        title: "导出表单JSON"
        fileMode: FileDialog.SaveFile
        nameFilters: ["JSON files (*.json)", "All files (*)"]
        defaultSuffix: "json"
        onAccepted: {
            var path = FileHelper.getLocalPath(selectedFile.toString());
            var json = Serializer.serialize(root.formModel, {
                "name": "DynamicForm"
            });
            if (FileHelper.write(path, json)) {
                formAPI.showMessage("导出成功: " + path, "success");
            } else {
                formAPI.showMessage("导出失败", "error");
            }
        }
    }

    FileDialog {
        id: importDialog
        title: "导入表单JSON"
        fileMode: FileDialog.OpenFile
        nameFilters: ["JSON files (*.json)", "All files (*)"]
        onAccepted: {
            var path = FileHelper.getLocalPath(selectedFile.toString());
            var content = FileHelper.read(path);
            if (content) {
                var model = Serializer.deserialize(content);
                if (model && model.length > 0) {
                    root.formModel = model;
                    root.selectedItem = null;
                    formAPI.showMessage("导入成功", "success");
                } else {
                    formAPI.showMessage("导入失败: JSON格式错误或为空", "error");
                }
            } else {
                formAPI.showMessage("读取文件失败", "error");
            }
        }
    }
}
