import QtQuick 6.5
import QtQuick.Controls 6.5
import Common 1.0

/**
 * 美化的数字输入框
 */
SpinBox {
    id: control
    
    height: AppStyles.inputHeight
    font.pixelSize: AppStyles.fontSizeMedium
    font.family: AppStyles.fontFamily
    
    leftPadding: AppStyles.inputPadding
    rightPadding: AppStyles.inputPadding + 40  // 为按钮留空间
    
    contentItem: TextInput {
        z: 2
        text: control.textFromValue(control.value, control.locale)
        font: control.font
        color: control.enabled ? AppStyles.textPrimary : AppStyles.textDisabled
        selectionColor: AppStyles.primaryLight
        selectedTextColor: "white"
        horizontalAlignment: Qt.AlignLeft
        verticalAlignment: Qt.AlignVCenter
        readOnly: !control.editable
        validator: control.validator
        inputMethodHints: Qt.ImhFormattedNumbersOnly
    }
    
    up.indicator: Rectangle {
        x: control.width - width - 1
        y: 1
        implicitWidth: 38
        implicitHeight: (control.height - 2) / 2
        color: control.up.pressed ? AppStyles.primaryDark : (control.up.hovered ? AppStyles.primaryLight : AppStyles.primaryColor)
        radius: AppStyles.radiusSmall
        
        Text {
            text: "+"
            font.pixelSize: control.font.pixelSize
            color: "white"
            anchors.centerIn: parent
        }
        
        Behavior on color {
            ColorAnimation { duration: AppStyles.animationDuration }
        }
    }
    
    down.indicator: Rectangle {
        x: control.width - width - 1
        y: control.height - height - 1
        implicitWidth: 38
        implicitHeight: (control.height - 2) / 2
        color: control.down.pressed ? AppStyles.primaryDark : (control.down.hovered ? AppStyles.primaryLight : AppStyles.primaryColor)
        radius: AppStyles.radiusSmall
        
        Text {
            text: "-"
            font.pixelSize: control.font.pixelSize
            color: "white"
            anchors.centerIn: parent
        }
        
        Behavior on color {
            ColorAnimation { duration: AppStyles.animationDuration }
        }
    }
    
    background: Rectangle {
        color: control.enabled ? AppStyles.inputBackground : AppStyles.backgroundColor
        border.color: control.activeFocus ? AppStyles.inputBorderFocus : AppStyles.inputBorder
        border.width: control.activeFocus ? 2 : AppStyles.inputBorderWidth
        radius: AppStyles.inputRadius
        
        Behavior on border.color {
            ColorAnimation { duration: AppStyles.animationDuration }
        }
        
        Behavior on border.width {
            NumberAnimation { duration: AppStyles.animationDuration }
        }
    }
}
