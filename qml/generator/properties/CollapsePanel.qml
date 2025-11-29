import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../Common"

ColumnLayout {
    id: root

    default property alias content: contentContainer.data
    property string title: ""
    property bool isExpanded: true

    spacing: 0

    // Header
    Rectangle {
        Layout.fillWidth: true
        height: 40
        color: "transparent"

        MouseArea {
            anchors.fill: parent
            onClicked: root.isExpanded = !root.isExpanded
            cursorShape: Qt.PointingHandCursor
            hoverEnabled: true
            onEntered: parent.color = "#f5f7fa"
            onExited: parent.color = "transparent"
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 5
            anchors.rightMargin: 5
            spacing: 5

            Text {
                text: root.isExpanded ? "▼" : "▶"
                color: AppStyles.textSecondary
                font.pixelSize: 12
                Layout.preferredWidth: 15
                horizontalAlignment: Text.AlignHCenter
            }

            Text {
                text: root.title
                font.bold: true
                color: AppStyles.textPrimary
                Layout.fillWidth: true
                font.pixelSize: 14
            }
        }

        // Bottom border
        Rectangle {
            anchors.bottom: parent.bottom
            width: parent.width
            height: 1
            color: AppStyles.borderColor
            opacity: 0.5
        }
    }

    // Content
    ColumnLayout {
        id: contentContainer
        Layout.fillWidth: true
        visible: root.isExpanded
        Layout.margins: 10
        spacing: 10
    }
}
