import QtQuick 6.5
import QtQuick.Controls 6.5
import QtQuick.Layouts 1.4
import Common 1.0
import "../components"
import mysqlhelper 1.0
Item {
    id: dynamicListRoot
    width: parent.width
    height: parent.height
    property var stackViewRef: ({})
    property var loaderInstanceRef: ({})

    // 模型
    ListModel {
        id: dynamicListModel
    }

    Component.onCompleted: {
        getData()
        
    }

    function getData(){
        var data = MySqlHelper.select("dynamicForm", [], "");
        dynamicListModel.clear();
        for (var i = 0; i < data.length; i++) {
            dynamicListModel.append({
                id: data[i].id,
                dynamicName: data[i].dynamicName,
                dynamicConfig: JSON.stringify(data[i].dynamicConfig)
            });
        }
    }

    // 整体布局
    Rectangle {
        anchors.fill: parent
        color: AppStyles.backgroundColor
    }
    
    RowLayout {
        id: topBar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.topMargin: AppStyles.spacingLarge
        anchors.leftMargin: AppStyles.spacingXLarge
        anchors.rightMargin: AppStyles.spacingXLarge
        height: 40
        z: 1  // 确保在最上层

        spacing: AppStyles.spacingSmall
        
        Text {
            text: "表单列表"
            font.pixelSize: AppStyles.fontSizeTitle
            color: AppStyles.textPrimary
            Layout.fillWidth: true
        }
        
        StyledButton {
            text: "新增表单"
            buttonType: "primary"
            onClicked: {
                if (stackViewRef && loaderInstanceRef) {
                    loaderInstanceRef.dynamicListLoadingLoader.visible = false;
                    loaderInstanceRef.configEditorLoader.visible = true;
                    loaderInstanceRef.configEditorLoader.item.initConfigEditor("");
                    stackViewRef.push(loaderInstanceRef.configEditorLoader);
                    
                }
            }
        }
    }
    
    ScrollView {
        id: scrollView
        anchors.top: topBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: AppStyles.spacingLarge
        clip: true

        ColumnLayout {
            id: tableColumn
            anchors.fill: parent
            spacing: AppStyles.spacingSmall
            
            // 表头
            RowLayout {
                id: headerRow
                Layout.fillWidth: true
                spacing: AppStyles.spacingMedium
                
                Rectangle {
                    color: AppStyles.primaryColor
                    radius: AppStyles.radiusMedium
                    Layout.fillWidth: true
                    Layout.preferredWidth: 0.1 * scrollView.width
                    height: AppStyles.controlHeightLarge
                    
                    StyledLabel {
                        anchors.centerIn: parent
                        text: "序号"
                        font.bold: true
                        color: "white"
                    }
                }
                Rectangle {
                    color: AppStyles.primaryColor
                    radius: AppStyles.radiusMedium
                    Layout.fillWidth: true
                    Layout.preferredWidth: 0.2 * scrollView.width
                    height: AppStyles.controlHeightLarge
                    
                    StyledLabel {
                        anchors.centerIn: parent
                        text: "表单名称"
                        font.bold: true
                        color: "white"
                    }
                }
                Rectangle {
                    color: AppStyles.primaryColor
                    radius: AppStyles.radiusMedium
                    Layout.fillWidth: true
                    Layout.preferredWidth: 0.4 * scrollView.width
                    height: AppStyles.controlHeightLarge
                    
                    StyledLabel {
                        anchors.centerIn: parent
                        text: "表单配置"
                        font.bold: true
                        color: "white"
                    }
                }
                Rectangle {
                    color: AppStyles.primaryColor
                    radius: AppStyles.radiusMedium
                    Layout.fillWidth: true
                    Layout.preferredWidth: 0.25 * scrollView.width
                    height: AppStyles.controlHeightLarge
                    
                    StyledLabel {
                        anchors.centerIn: parent
                        text: "操作"
                        font.bold: true
                        color: "white"
                    }
                }
            }

            // 数据行
            Repeater {
                model: dynamicListModel
                delegate: RowLayout {
                    Layout.fillWidth: true
                    spacing: AppStyles.spacingMedium
                    
                    Rectangle {
                        color: AppStyles.surfaceColor
                        radius: AppStyles.radiusMedium
                        border.color: AppStyles.borderColor
                        border.width: 1
                        Layout.fillWidth: true
                        Layout.preferredWidth: 0.1 * dynamicListRoot.width
                        height: AppStyles.controlHeightLarge
                        
                        StyledLabel {
                            anchors.centerIn: parent
                            text: index + 1
                        }
                    }
                    Rectangle {
                        color: AppStyles.surfaceColor
                        radius: AppStyles.radiusMedium
                        border.color: AppStyles.borderColor
                        border.width: 1
                        Layout.fillWidth: true
                        Layout.preferredWidth: 0.2 * dynamicListRoot.width
                        height: AppStyles.controlHeightLarge
                        
                        StyledLabel {
                            anchors.centerIn: parent
                            text: model.dynamicName
                        }
                    }
                    Rectangle {
                        color: AppStyles.surfaceColor
                        radius: AppStyles.radiusMedium
                        border.color: AppStyles.borderColor
                        border.width: 1
                        Layout.fillWidth: true
                        Layout.preferredWidth: 0.4 * dynamicListRoot.width
                        height: AppStyles.controlHeightLarge
                        
                        StyledLabel {
                            anchors.fill: parent

                            text: model.dynamicConfig

                            elide: Text.ElideRight         // 开启右侧省略号
                            horizontalAlignment: Text.AlignLeft
                            verticalAlignment: Text.AlignVCenter

                        }
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredWidth: 0.25 * dynamicListRoot.width
                        spacing: AppStyles.spacingSmall
                        
                        StyledButton {
                            text: "查询"
                            buttonType: "secondary"
                            Layout.fillWidth: true
                            onClicked: {
                                if (loaderInstanceRef && loaderInstanceRef.dataRecordListLoader) {
                                    var loader = loaderInstanceRef.dataRecordListLoader;
                                    
                                    if (!loader.item) {
                                        var connection = loader.onLoaded.connect(function() {
                                            if (loader.item) {
                                                loader.item.initPage(model.id, model.dynamicName, model.dynamicConfig);
                                            }
                                            loader.onLoaded.disconnect(connection);
                                        });
                                    } else {
                                        loader.item.initPage(model.id, model.dynamicName, model.dynamicConfig);
                                    }
                                    
                                    loaderInstanceRef.dynamicListLoadingLoader.visible = false;
                                    loader.visible = true;
                                    stackViewRef.push(loader);
                                }
                            }
                        }
                        StyledButton {
                            text: "新增"
                            buttonType: "primary"
                            Layout.fillWidth: true
                            onClicked: function(){
                                if (stackViewRef && loaderInstanceRef && loaderInstanceRef.formPreviewLoader) {
                                    var loader = loaderInstanceRef.formPreviewLoader;
                                    
                                    // 如果Loader还没有加载完成，等待加载
                                    if (!loader.item) {
                                        var connection = loader.onLoaded.connect(function() {
                                            if (loader.item) {
                                                loader.item.initForm(model.id, model.dynamicName, model.dynamicConfig);
                                            }
                                            loader.onLoaded.disconnect(connection);
                                        });
                                    } else {
                                        loader.item.initForm(model.id, model.dynamicName, model.dynamicConfig);
                                    }
                                    
                                    loaderInstanceRef.dynamicListLoadingLoader.visible = false;
                                    loader.visible = true;
                                    stackViewRef.push(loader);
                                }
                            }
                        }
                        StyledButton {
                            text: "编辑"
                            buttonType: "secondary"
                            Layout.fillWidth: true
                            onClicked: function(){
                                if (stackViewRef && loaderInstanceRef) {
                                    loaderInstanceRef.dynamicListLoadingLoader.visible = false;
                                    loaderInstanceRef.configEditorLoader.visible = true;
                                    loaderInstanceRef.configEditorLoader.item.initConfigEditor(model.dynamicName,model.dynamicConfig);
                                    stackViewRef.push(loaderInstanceRef.configEditorLoader);
                                    
                                }
                            }
                        }
                        StyledButton {
                            text: "删除"
                            buttonType: "danger"
                            Layout.fillWidth: true
                            onClicked: function(){
                                MessageManager.showDialog("确定要删除这个表单吗？", "warning", function() {
                                    var where = "id=" + model.id;
                                    try {
                                        MySqlHelper.remove("dynamicForm", where);
                                        MessageManager.showToast("删除成功", "success");
                                        getData();  // 立即刷新列表
                                    } catch(e) {
                                        MessageManager.showToast("删除失败: " + e, "error");
                                    }
                                });
                            }
                        }
                    }
                }
            }
        }
    }
}
