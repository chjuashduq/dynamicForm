import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../Common"
import "."

Rectangle {
    id: root
    color: AppStyles.backgroundColor
    border.color: AppStyles.borderColor
    border.width: 1

    property var targetItem
    property var onPropertyChanged

    Text {
        text: targetItem ? "组件属性: " + targetItem.type : "未选中组件"
        font.pixelSize: AppStyles.fontSizeLarge
        font.bold: true
        color: AppStyles.textPrimary
        Layout.alignment: Qt.AlignHCenter
        Layout.bottomMargin: 12
    }
    ColumnLayout {
        anchors.fill: parent
        anchors.topMargin: 30
        spacing: 10

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: AppStyles.borderColor
            visible: !!targetItem
        }

        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            contentWidth: -1 // Disable horizontal scrolling
            visible: !!targetItem

            ColumnLayout {
                width: parent.width
                spacing: 15

                LayoutSection {
                    targetItem: root.targetItem
                    onPropertyChanged: (name, value) => {
                        if (root.onPropertyChanged)
                            root.onPropertyChanged(name, value);
                    }
                }

                ContainerSection {
                    targetItem: root.targetItem
                    onPropertyChanged: (name, value) => {
                        if (root.onPropertyChanged)
                            root.onPropertyChanged(name, value);
                    }
                }

                ComponentSection {
                    targetItem: root.targetItem
                    onPropertyChanged: (name, value) => {
                        if (root.onPropertyChanged)
                            root.onPropertyChanged(name, value);
                    }
                }

                DataSection {
                    targetItem: root.targetItem
                    onPropertyChanged: (name, value) => {
                        if (root.onPropertyChanged)
                            root.onPropertyChanged(name, value);
                    }
                }

                EventSection {
                    targetItem: root.targetItem
                    onPropertyChanged: (name, value) => {
                        // Here we assume 'value' is the events object and 'name' is "events"
                        // We need to ensure the backend handles this correctly.
                        // If we treat "events" as a property in 'props', it will be saved in JSON.
                        if (root.onPropertyChanged)
                            root.onPropertyChanged(name, value);
                    }
                }
            }
        }
    }
}
