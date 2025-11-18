import QtQuick 6.5
import QtQuick.Controls 6.5
import Common 1.0

/**
 * 美化的按钮
 */
Button {
    id: control
    
    property string buttonType: "primary"  // primary, secondary, danger
    
    height: AppStyles.buttonHeight
    font.pixelSize: AppStyles.fontSizeMedium
    font.family: AppStyles.fontFamily
    font.bold: true
    
    leftPadding: AppStyles.buttonPadding
    rightPadding: AppStyles.buttonPadding
    
    contentItem: Text {
        text: control.text
        font: control.font
        color: buttonType === "secondary" ? AppStyles.textPrimary : "white"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
    
    background: Rectangle {
        color: {
            if (!control.enabled) return AppStyles.textDisabled
            if (control.pressed) {
                if (buttonType === "primary") return AppStyles.buttonPrimaryPressed
                if (buttonType === "danger") return AppStyles.buttonDangerHover
                return AppStyles.buttonSecondaryHover
            }
            if (control.hovered) {
                if (buttonType === "primary") return AppStyles.buttonPrimaryHover
                if (buttonType === "danger") return AppStyles.buttonDangerHover
                return AppStyles.buttonSecondaryHover
            }
            if (buttonType === "primary") return AppStyles.buttonPrimary
            if (buttonType === "danger") return AppStyles.buttonDanger
            return AppStyles.buttonSecondary
        }
        radius: AppStyles.buttonRadius
        
        Behavior on color {
            ColorAnimation { duration: AppStyles.animationDuration }
        }
    }
    
    // 鼠标悬停效果
    HoverHandler {
        cursorShape: Qt.PointingHandCursor
    }
}
