import QtQuick 6.5
import QtQuick.Controls 6.5

/**
 * 控件工具栏
 * 负责控件添加按钮的显示和管理
 */
Rectangle {
    id: controlToolbar
    
    signal controlRequested(string type)
    
    width: parent ? parent.width - 40 : 400
    height: 120
    anchors.horizontalCenter: parent ? parent.horizontalCenter : undefined
    color: "#ffffff"
    border.color: "#dee2e6"
    border.width: 1
    radius: 8

    property var typeManagerLoader: Loader {
        source: "../managers/ControlTypeManager.qml"
    }
    property var typeManager: typeManagerLoader.item

    Column {
        anchors.fill: parent
        anchors.margins: 15
        spacing: 10

        Text {
            text: "添加控件"
            font.pixelSize: 16
            font.bold: true
        }

        // 第一行控件
        Row {
            spacing: 15

            Repeater {
                model: typeManager ? typeManager.controlTypes.slice(0, 8) : []
                
                Button {
                    text: modelData.icon + " " + modelData.label
                    onClicked: controlRequested(modelData.type)
                }
            }
        }

        // 第二行控件
        Row {
            spacing: 15

            Repeater {
                model: typeManager ? typeManager.controlTypes.slice(8) : []
                
                Button {
                    text: modelData.icon + " " + modelData.label
                    onClicked: controlRequested(modelData.type)
                }
            }
        }
    }
}
