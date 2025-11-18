import QtQuick 6.5
import QtQuick.Controls 6.5
import Common 1.0

/**
 * 美化的文本输入框
 */
TextField {
    id: control
    
    property bool hasError: false
    
    height: AppStyles.inputHeight
    font.pixelSize: AppStyles.fontSizeMedium
    font.family: AppStyles.fontFamily
    color: AppStyles.textPrimary
    placeholderTextColor: AppStyles.textPlaceholder
    selectByMouse: true
    
    leftPadding: AppStyles.inputPadding
    rightPadding: AppStyles.inputPadding
    
    background: Rectangle {
        color: control.enabled ? AppStyles.inputBackground : AppStyles.backgroundColor
        border.color: {
            if (hasError) return AppStyles.inputBorderError
            if (control.activeFocus) return AppStyles.inputBorderFocus
            return AppStyles.inputBorder
        }
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
