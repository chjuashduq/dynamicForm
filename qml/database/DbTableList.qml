import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import mysqlhelper 1.0

Item {
    id: root
    anchors.fill: parent

    property var tableModel: []
    property var originalTableModel: []

    signal editTable(string tableName)

    Component.onCompleted: {
        console.log("DbTableList loaded. Size:", width, "x", height);
        refreshTables();
    }

    function refreshTables() {
        console.log("DbTableList: Refreshing tables...");
        try {
            if (typeof MySqlHelper !== "undefined") {
                var tables = MySqlHelper.getDbTables();
                console.log("DbTableList: Got tables count:", tables.length);
                originalTableModel = tables;
            } else {
                console.error("DbTableList: MySqlHelper is undefined!");
                // Mock data
                originalTableModel = [
                    {
                        tableName: "error_table",
                        tableComment: "MySqlHelper Missing",
                        entityName: "Error",
                        createTime: "",
                        updateTime: ""
                    }
                ];
            }
        } catch (e) {
            console.error("DbTableList: Error calling MySqlHelper.getDbTables:", e);
            originalTableModel = [
                {
                    tableName: "exception_table",
                    tableComment: "Exception Occurred",
                    entityName: "Exception",
                    createTime: "",
                    updateTime: ""
                }
            ];
        }
        filterTables();
    }

    function filterTables() {
        var nameFilter = tableNameInput.text.trim().toLowerCase();
        var commentFilter = tableCommentInput.text.trim().toLowerCase();

        if (nameFilter === "" && commentFilter === "") {
            tableModel = originalTableModel;
            return;
        }

        var filtered = [];
        for (var i = 0; i < originalTableModel.length; i++) {
            var item = originalTableModel[i];
            var nameMatch = (item.tableName || "").toLowerCase().indexOf(nameFilter) !== -1;
            var commentMatch = (item.tableComment || "").toLowerCase().indexOf(commentFilter) !== -1;

            if (nameMatch && commentMatch) {
                filtered.push(item);
            }
        }
        tableModel = filtered;
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 20

        // Search Bar
        RowLayout {
            Layout.fillWidth: true
            spacing: 15

            Text {
                text: "表名称"
                font.pixelSize: 14
            }
            TextField {
                id: tableNameInput
                placeholderText: "请输入表名称"
                Layout.preferredWidth: 200
            }

            Text {
                text: "表描述"
                font.pixelSize: 14
            }
            TextField {
                id: tableCommentInput
                placeholderText: "请输入表描述"
                Layout.preferredWidth: 200
            }

            Button {
                text: "搜索"
                highlighted: true
                onClicked: filterTables()
            }
            Button {
                text: "重置"
                onClicked: {
                    tableNameInput.text = "";
                    tableCommentInput.text = "";
                    filterTables();
                }
            }
        }

        // Table Header
        Rectangle {
            Layout.fillWidth: true
            height: 40
            color: "#f8f8f9"

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                spacing: 0

                Item {
                    Layout.preferredWidth: 50
                    Text {
                        text: "序号"
                        anchors.centerIn: parent
                        font.bold: true
                    }
                }
                Item {
                    Layout.preferredWidth: 150
                    Text {
                        text: "表名称"
                        anchors.centerIn: parent
                        font.bold: true
                    }
                }
                Item {
                    Layout.preferredWidth: 150
                    Text {
                        text: "表描述"
                        anchors.centerIn: parent
                        font.bold: true
                    }
                }
                Item {
                    Layout.preferredWidth: 150
                    Text {
                        text: "实体"
                        anchors.centerIn: parent
                        font.bold: true
                    }
                }
                Item {
                    Layout.preferredWidth: 180
                    Text {
                        text: "创建时间"
                        anchors.centerIn: parent
                        font.bold: true
                    }
                }
                Item {
                    Layout.preferredWidth: 180
                    Text {
                        text: "更新时间"
                        anchors.centerIn: parent
                        font.bold: true
                    }
                }
                Item {
                    Layout.fillWidth: true
                    Text {
                        text: "操作"
                        anchors.centerIn: parent
                        font.bold: true
                    }
                }
            }
        }

        // Table List
        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            model: root.tableModel
            delegate: Rectangle {
                width: ListView.view.width
                height: 50
                color: index % 2 === 0 ? "white" : "#f9f9f9"

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    spacing: 0

                    Item {
                        Layout.preferredWidth: 50
                        Text {
                            text: index + 1
                            anchors.centerIn: parent
                        }
                    }
                    Item {
                        Layout.preferredWidth: 150
                        Text {
                            text: modelData.tableName
                            anchors.centerIn: parent
                        }
                    }
                    Item {
                        Layout.preferredWidth: 150
                        Text {
                            text: modelData.tableComment
                            anchors.centerIn: parent
                        }
                    }
                    Item {
                        Layout.preferredWidth: 150
                        Text {
                            text: modelData.entityName
                            anchors.centerIn: parent
                        }
                    }
                    Item {
                        Layout.preferredWidth: 180
                        Text {
                            text: modelData.createTime
                            anchors.centerIn: parent
                        }
                    }
                    Item {
                        Layout.preferredWidth: 180
                        Text {
                            text: modelData.updateTime
                            anchors.centerIn: parent
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                        RowLayout {
                            anchors.centerIn: parent
                            spacing: 10
                            Text {
                                text: "预览"
                                color: "#1890ff"
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                }
                            }
                            Text {
                                text: "编辑"
                                color: "#1890ff"
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: root.editTable(modelData.tableName)
                                }
                            }
                            Text {
                                text: "删除"
                                color: "red"
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                }
                            }
                            Text {
                                text: "同步"
                                color: "#1890ff"
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                }
                            }
                            Text {
                                text: "生成代码"
                                color: "#1890ff"
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    width: parent.width
                    height: 1
                    color: "#e8e8e8"
                    anchors.bottom: parent.bottom
                }
            }
        }
    }
}
