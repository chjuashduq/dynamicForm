import QtQuick 6.5
import QtQuick.Controls 6.5
import QtQuick.Layouts 1.4
import Common 1.0
import "../components"
import mysqlhelper 1.0

/**
 * 数据记录列表页面
 * 显示指定表单的所有数据记录
 */
Item {
    id: dataRecordListRoot
    width: parent.width
    height: parent.height
    
    property var stackViewRef: ({})
    property var loaderInstanceRef: ({})
    property int formId: -1
    property string formName: ""
    property var formConfig: ({})
    
    // 数据模型
    ListModel {
        id: dataRecordModel
    }
    
    Component.onCompleted: {
        if (formId > 0) {
            loadData()
        }
    }
    
    // 加载数据
    function loadData() {
        try {
            var where = "dynamicId=" + formId;
            var result = MySqlHelper.select("dynamicData", [], where);
            dataRecordModel.clear();
            
            for (var i = 0; i < result.length; i++) {
                var dataStr = result[i].data || "{}";
                // 如果 data 是对象，转换为 JSON 字符串
                if (typeof dataStr === "object") {
                    dataStr = JSON.stringify(dataStr);
                }
                
                dataRecordModel.append({
                    id: result[i].id,
                    dynamicId: result[i].dynamicId,
                    data: dataStr,
                    createTime: result[i].createTime || ""
                });
            }
        } catch(e) {
            MessageManager.showToast("加载数据失败: " + e, "error");
        }
    }
    
    // 初始化页面
    function initPage(id, name, config) {
        formId = id;
        formName = name;
        formConfig = JSON.parse(config);
        loadData();
    }
    
    // 格式化显示时间
    function formatDisplayTime(timeStr) {
        if (!timeStr) return "";
        
        // 如果是 Date 对象，直接格式化
        if (timeStr instanceof Date) {
            var date = timeStr;
            var year = date.getFullYear();
            var month = String(date.getMonth() + 1).padStart(2, '0');
            var day = String(date.getDate()).padStart(2, '0');
            var hours = String(date.getHours()).padStart(2, '0');
            var minutes = String(date.getMinutes()).padStart(2, '0');
            var seconds = String(date.getSeconds()).padStart(2, '0');
            return year + '-' + month + '-' + day + ' ' + hours + ':' + minutes + ':' + seconds;
        }
        
        // 转换为字符串
        var timeString = String(timeStr);
        
        // 如果是 ISO 格式，转换为可读格式
        if (timeString.indexOf('T') > 0) {
            var date = new Date(timeString);
            var year = date.getFullYear();
            var month = String(date.getMonth() + 1).padStart(2, '0');
            var day = String(date.getDate()).padStart(2, '0');
            var hours = String(date.getHours()).padStart(2, '0');
            var minutes = String(date.getMinutes()).padStart(2, '0');
            var seconds = String(date.getSeconds()).padStart(2, '0');
            return year + '-' + month + '-' + day + ' ' + hours + ':' + minutes + ':' + seconds;
        }
        
        // 如果已经是 MySQL 格式，直接返回
        return timeString;
    }
    
    // 背景
    Rectangle {
        anchors.fill: parent
        color: AppStyles.backgroundColor
    }
    
    // 顶部栏
    RowLayout {
        id: topBar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.topMargin: AppStyles.spacingLarge
        anchors.leftMargin: AppStyles.spacingXLarge
        anchors.rightMargin: AppStyles.spacingXLarge
        spacing: AppStyles.spacingMedium
        
        StyledButton {
            text: "返回"
            buttonType: "secondary"
            onClicked: {
                if (loaderInstanceRef && loaderInstanceRef.dataRecordListLoader) {
                    loaderInstanceRef.dataRecordListLoader.visible = false;
                    loaderInstanceRef.dynamicListLoadingLoader.visible = true;
                    stackViewRef.pop();
                }
            }
        }
        
        Text {
            text: formName + " - 数据记录"
            font.pixelSize: AppStyles.fontSizeTitle
            font.bold: true
            color: AppStyles.textPrimary
            Layout.fillWidth: true
        }
        
        StyledButton {
            text: "新增记录"
            buttonType: "primary"
            onClicked: {
                // 跳转到表单填写页面
                if (loaderInstanceRef && loaderInstanceRef.formPreviewLoader) {
                    var loader = loaderInstanceRef.formPreviewLoader;
                    
                    if (!loader.item) {
                        var connection = loader.onLoaded.connect(function() {
                            if (loader.item) {
                                loader.item.initForm(formId, formName, JSON.stringify(formConfig), true);
                            }
                            loader.onLoaded.disconnect(connection);
                        });
                    } else {
                        loader.item.initForm(formId, formName, JSON.stringify(formConfig), true);
                    }
                    
                    loaderInstanceRef.dataRecordListLoader.visible = false;
                    loader.visible = true;
                    stackViewRef.push(loader);
                }
            }
        }
    }
    
    // 数据列表
    ScrollView {
        id: scrollView
        anchors.top: topBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: AppStyles.spacingLarge
        clip: true
        
        ColumnLayout {
            anchors.fill: parent
            spacing: AppStyles.spacingSmall
            
            // 表头
            RowLayout {
                Layout.fillWidth: true
                spacing: AppStyles.spacingMedium
                
                Rectangle {
                    color: AppStyles.primaryColor
                    radius: AppStyles.radiusMedium
                    Layout.fillWidth: true
                    Layout.preferredWidth: 0.08 * scrollView.width
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
                    Layout.preferredWidth: 0.5 * scrollView.width
                    height: AppStyles.controlHeightLarge
                    
                    StyledLabel {
                        anchors.centerIn: parent
                        text: "数据内容"
                        font.bold: true
                        color: "white"
                    }
                }
                
                Rectangle {
                    color: AppStyles.primaryColor
                    radius: AppStyles.radiusMedium
                    Layout.fillWidth: true
                    Layout.preferredWidth: 0.15 * scrollView.width
                    height: AppStyles.controlHeightLarge
                    
                    StyledLabel {
                        anchors.centerIn: parent
                        text: "创建时间"
                        font.bold: true
                        color: "white"
                    }
                }
                
                Rectangle {
                    color: AppStyles.primaryColor
                    radius: AppStyles.radiusMedium
                    Layout.fillWidth: true
                    Layout.preferredWidth: 0.27 * scrollView.width
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
                model: dataRecordModel
                
                delegate: RowLayout {
                    Layout.fillWidth: true
                    spacing: AppStyles.spacingMedium
                    
                    // 序号
                    Rectangle {
                        color: AppStyles.surfaceColor
                        radius: AppStyles.radiusMedium
                        border.color: AppStyles.borderColor
                        border.width: 1
                        Layout.fillWidth: true
                        Layout.preferredWidth: 0.08 * scrollView.width
                        height: AppStyles.controlHeightLarge
                        
                        StyledLabel {
                            anchors.centerIn: parent
                            text: index + 1
                        }
                    }
                    
                    // 数据内容
                    Rectangle {
                        color: AppStyles.surfaceColor
                        radius: AppStyles.radiusMedium
                        border.color: AppStyles.borderColor
                        border.width: 1
                        Layout.fillWidth: true
                        Layout.preferredWidth: 0.5 * scrollView.width
                        height: AppStyles.controlHeightLarge
                        
                        StyledLabel {
                            anchors.fill: parent
                            anchors.margins: AppStyles.paddingSmall
                            text: model.data
                            elide: Text.ElideRight
                            horizontalAlignment: Text.AlignLeft
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                    
                    // 创建时间
                    Rectangle {
                        color: AppStyles.surfaceColor
                        radius: AppStyles.radiusMedium
                        border.color: AppStyles.borderColor
                        border.width: 1
                        Layout.fillWidth: true
                        Layout.preferredWidth: 0.15 * scrollView.width
                        height: AppStyles.controlHeightLarge
                        
                        StyledLabel {
                            anchors.centerIn: parent
                            text: formatDisplayTime(model.createTime)
                        }
                    }
                    
                    // 操作按钮
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredWidth: 0.27 * scrollView.width
                        spacing: AppStyles.spacingSmall
                        
                        StyledButton {
                            text: "编辑"
                            buttonType: "secondary"
                            Layout.fillWidth: true
                            onClicked: {
                                // 跳转到表单编辑页面
                                if (loaderInstanceRef && loaderInstanceRef.formPreviewLoader) {
                                    var loader = loaderInstanceRef.formPreviewLoader;
                                    
                                    if (!loader.item) {
                                        var connection = loader.onLoaded.connect(function() {
                                            if (loader.item) {
                                                loader.item.initFormForEdit(
                                                    formId, 
                                                    formName, 
                                                    JSON.stringify(formConfig),
                                                    model.id,
                                                    model.data
                                                );
                                            }
                                            loader.onLoaded.disconnect(connection);
                                        });
                                    } else {
                                        loader.item.initFormForEdit(
                                            formId, 
                                            formName, 
                                            JSON.stringify(formConfig),
                                            model.id,
                                            model.data
                                        );
                                    }
                                    
                                    loaderInstanceRef.dataRecordListLoader.visible = false;
                                    loader.visible = true;
                                    stackViewRef.push(loader);
                                }
                            }
                        }
                        
                        StyledButton {
                            text: "删除"
                            buttonType: "danger"
                            Layout.fillWidth: true
                            onClicked: {
                                MessageManager.showDialog("确定要删除这条记录吗？", "warning", function() {
                                    try {
                                        var where = "id=" + model.id;
                                        MySqlHelper.remove("dynamicData", where);
                                        MessageManager.showToast("删除成功", "success");
                                        loadData();  // 刷新列表
                                    } catch(e) {
                                        MessageManager.showToast("删除失败: " + e, "error");
                                    }
                                });
                            }
                        }
                    }
                }
            }
            
            // 空状态提示
            Rectangle {
                visible: dataRecordModel.count === 0
                Layout.fillWidth: true
                Layout.preferredHeight: 200
                color: "transparent"
                
                Column {
                    anchors.centerIn: parent
                    spacing: AppStyles.spacingMedium
                    
                    Text {
                        text: "暂无数据记录"
                        font.pixelSize: AppStyles.fontSizeLarge
                        color: AppStyles.textSecondary
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    
                    StyledButton {
                        text: "新增第一条记录"
                        buttonType: "primary"
                        anchors.horizontalCenter: parent.horizontalCenter
                        onClicked: {
                            if (loaderInstanceRef && loaderInstanceRef.formPreviewLoader) {
                                var loader = loaderInstanceRef.formPreviewLoader;
                                
                                if (!loader.item) {
                                    var connection = loader.onLoaded.connect(function() {
                                        if (loader.item) {
                                            loader.item.initForm(formId, formName, JSON.stringify(formConfig));
                                        }
                                        loader.onLoaded.disconnect(connection);
                                    });
                                } else {
                                    loader.item.initForm(formId, formName, JSON.stringify(formConfig));
                                }
                                
                                loaderInstanceRef.dataRecordListLoader.visible = false;
                                loader.visible = true;
                                stackViewRef.push(loader);
                            }
                        }
                    }
                }
            }
        }
    }
}
