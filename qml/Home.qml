import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "components"

Item {
    id: homeRoot

    signal navigate(string target)

    Rectangle {
        anchors.fill: parent
        color: "#f0f2f5"

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 40

            Text {
                text: "Dynamic Form System"
                font.pixelSize: 32
                font.bold: true
                color: "#333"
                Layout.alignment: Qt.AlignHCenter
            }

            GridLayout {
                columns: 3
                columnSpacing: 30
                rowSpacing: 30

                // Card 1: New Form (Form Generator)
                HomeCard {
                    title: "新建表单"
                    description: "可视化拖拽设计表单"
                    iconText: "✎"
                    accentColor: "#1890ff"
                    onClicked: homeRoot.navigate("generator")
                }

                // Card 2: Code Generator (Config Editor)
                HomeCard {
                    title: "代码生成"
                    description: "查看和编辑表单JSON配置"
                    iconText: "{}"
                    accentColor: "#52c41a"
                    onClicked: homeRoot.navigate("config")
                }

                // Card 3: Dynamic List
                HomeCard {
                    title: "表单列表"
                    description: "管理已生成的表单数据"
                    iconText: "☰"
                    accentColor: "#faad14"
                    onClicked: homeRoot.navigate("list")
                }

                // Card 4: Database Tables
                HomeCard {
                    title: "数据库表"
                    description: "代码生成与表结构管理"
                    iconText: "🗄️"
                    accentColor: "#722ed1"
                    onClicked: homeRoot.navigate("db_tables")
                }
            }
        }
    }

    component HomeCard: Rectangle {
        id: card
        width: 220
        height: 160
        radius: 8
        color: "white"

        property string title: ""
        property string description: ""
        property string iconText: ""
        property color accentColor: "#333"
        signal clicked

        // Shadow effect (simulated with border for now, or use DropShadow if available)
        border.color: mouseArea.containsMouse ? card.color : "#e8e8e8"
        border.width: mouseArea.containsMouse ? 2 : 1

        Behavior on border.color {
            ColorAnimation {
                duration: 200
            }
        }

        // Scale effect on hover
        scale: mouseArea.containsMouse ? 1.05 : 1.0
        Behavior on scale {
            NumberAnimation {
                duration: 200
            }
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: card.clicked()
        }

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 10

            Rectangle {
                width: 50
                height: 50
                radius: 25
                color: Qt.lighter(card.color, 1.8)
                Layout.alignment: Qt.AlignHCenter

                Text {
                    anchors.centerIn: parent
                    text: card.iconText
                    font.pixelSize: 24
                    color: card.color
                }
            }

            Text {
                text: card.title
                font.pixelSize: 18
                font.bold: true
                color: "#333"
                Layout.alignment: Qt.AlignHCenter
            }

            Text {
                text: card.description
                font.pixelSize: 12
                color: "#999"
                Layout.alignment: Qt.AlignHCenter
                Layout.maximumWidth: 180
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }
}
