import QtQuick
import QtQuick.Controls

Item {
    id: root
    property string componentType: ""
    property string label: ""
    property string icon: ""

    width: parent.width
    height: 40

    property Item dragParent: null

    Rectangle {
        id: dragRect
        anchors.fill: parent
        color: "white"
        border.color: "#dcdfe6"
        radius: 4

        // 传递 componentType 属性，以便 drop.source 可以访问
        property string componentType: root.componentType

        Row {
            anchors.centerIn: parent
            spacing: 10
            Text {
                text: icon
                font.bold: true
            }
            Text {
                text: label
            }
        }

        Drag.active: mouseArea.drag.active
        Drag.supportedActions: Qt.CopyAction
        Drag.dragType: Drag.Automatic
        Drag.mimeData: {
            "componentType": componentType
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            drag.target: dragRect

            onReleased: {
                dragRect.Drag.drop();
                dragRect.parent = root;
                dragRect.anchors.fill = root;
            }
        }

        states: State {
            when: mouseArea.drag.active
            ParentChange {
                target: dragRect
                parent: root.dragParent ? root.dragParent : root.parent.parent.parent
            }
            PropertyChanges {
                target: dragRect
                z: 100
            }
            AnchorChanges {
                target: dragRect
                anchors.horizontalCenter: undefined
                anchors.verticalCenter: undefined
            }
        }
    }
}
