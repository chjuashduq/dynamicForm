import QtQuick 6.5
import QtQuick.Controls 6.5
import QtQuick.Layouts 1.4
import mysqlhelper 1.0
import Common 1.0
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

    RowLayout {
        id: topBar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.topMargin: 20       // 距离顶部 20px
        anchors.leftMargin: 35      // 距离左侧 15px
        Layout.fillWidth: true

        spacing: 5
        Button {
            text: "新增表单"
            Layout.fillWidth: true
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

    // 整体布局
    ScrollView {
        id: scrollView
        anchors.top: topBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        clip: true

        ColumnLayout {
            id: tableColumn
            anchors.fill: parent
            spacing: 5
            anchors.margins: 25
            // 表头
            RowLayout {
                id: headerRow
                Layout.fillWidth: true

                spacing: 10
                Rectangle {
                    color: "#f0f0f0"
                    radius: 5
                    Layout.fillWidth: true
                    Layout.preferredWidth: 0.1 * scrollView.width
                    height: 40
                    Label {
                        anchors.centerIn: parent
                        text: "序号"
                        font.bold: true
                    }
                }
                Rectangle {
                    color: "#f0f0f0"
                    radius: 5
                    Layout.fillWidth: true
                    Layout.preferredWidth: 0.2 * scrollView.width
                    height: 40
                    Label {
                        anchors.centerIn: parent
                        text: "表单名称"
                        font.bold: true
                    }
                }
                Rectangle {
                    color: "#f0f0f0"
                    radius: 5
                    Layout.fillWidth: true
                    Layout.preferredWidth: 0.4 * scrollView.width
                    height: 40
                    Label {
                        anchors.centerIn: parent
                        text: "表单配置"
                        font.bold: true
                    }
                }
                Rectangle {
                    color: "#f0f0f0"
                    radius: 5
                    Layout.fillWidth: true
                    Layout.preferredWidth: 0.25 * scrollView.width
                    height: 40
                    Label {
                        anchors.centerIn: parent
                        text: "操作"
                        font.bold: true
                    }
                }
            }

            // 数据行
            Repeater {
                model: dynamicListModel
                delegate: RowLayout {
                    Layout.fillWidth: true
                    spacing: 10
                    Rectangle {
                        color: "#ffffff"
                        radius: 5
                        border.color: "#cccccc"
                        Layout.fillWidth: true
                        Layout.preferredWidth: 0.1 * dynamicListRoot.width
                        height: 40
                        Label {
                            anchors.centerIn: parent
                            text: index+1
                        }
                    }
                    Rectangle {
                        color: "#ffffff"
                        radius: 5
                        border.color: "#cccccc"
                        Layout.fillWidth: true
                        Layout.preferredWidth: 0.2 * dynamicListRoot.width
                        height: 40
                        Label {
                            anchors.centerIn: parent
                            text: model.dynamicName
                        }
                    }
                    Rectangle {
                        color: "#ffffff"
                        radius: 5
                        border.color: "#cccccc"
                        Layout.fillWidth: true
                        Layout.preferredWidth: 0.4 * dynamicListRoot.width
                        height: 40
                        Label {
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
                        spacing: 5
                        Button {
                            text: "查询记录"
                            Layout.fillWidth: true
                            onClicked: console.log("查询记录 id:", model.id)
                        }
                        Button {
                            text: "新增记录"
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
                        Button {
                            text: "编辑表单"
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
                        Button {
                            text: "删除表单"
                            Layout.fillWidth: true
                            onClicked: function(){
                                var where = "id="+model.id;
                                try{
                                    MySqlHelper.remove("dynamicForm",where)
                                    MessageManager.showDialog("删除成功","info",getData())

                                    
                                }catch(e){
                                    console.log("删除失败，error",e)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
