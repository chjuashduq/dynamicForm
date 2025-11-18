import QtQuick 6.5
import QtQuick.Controls 6.5
import Common 1.0

/**
 * 美化的下拉框
 */
ComboBox {
    id: control
    
    height: AppStyles.inputHeight
    font.pixelSize: AppStyles.fontSizeMedium
    font.family: AppStyles.fontFamily
    
    leftPadding: AppStyles.inputPadding
    rightPadding: AppStyles.inputPadding
    
    contentItem: Text {
        leftPadding: 0
        rightPadding: control.indicator.width + control.spacing
        text: control.displayText
        font: control.font
        color: control.enabled ? AppStyles.textPrimary : AppStyles.textDisabled
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
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
    
    indicator: Canvas {
        id: canvas
        x: control.width - width - control.rightPadding
        y: control.topPadding + (control.availableHeight - height) / 2
        width: 12
        height: 8
        contextType: "2d"
        
        Connections {
            target: control
            function onPressedChanged() { canvas.requestPaint(); }
        }
        
        onPaint: {
            context.reset();
            context.moveTo(0, 0);
            context.lineTo(width, 0);
            context.lineTo(width / 2, height);
            context.closePath();
            context.fillStyle = control.enabled ? AppStyles.textSecondary : AppStyles.textDisabled;
            context.fill();
        }
    }
    
    popup: Popup {
        y: control.height
        width: control.width
        implicitHeight: contentItem.implicitHeight
        padding: 1
        
        contentItem: ListView {
            clip: true
            implicitHeight: contentHeight
            model: control.popup.visible ? control.delegateModel : null
            currentIndex: control.highlightedIndex
            
            ScrollIndicator.vertical: ScrollIndicator { }
        }
        
        background: Rectangle {
            color: AppStyles.surfaceColor
            border.color: AppStyles.borderColor
            border.width: 1
            radius: AppStyles.radiusMedium
        }
    }
    
    delegate: ItemDelegate {
        width: control.width
        height: AppStyles.controlHeightMedium
        
        contentItem: Text {
            text: control.textRole ? (Array.isArray(control.model) ? modelData[control.textRole] : model[control.textRole]) : modelData
            color: AppStyles.textPrimary
            font: control.font
            elide: Text.ElideRight
            verticalAlignment: Text.AlignVCenter
        }
        
        background: Rectangle {
            color: parent.highlighted ? AppStyles.primaryLight : "transparent"
            opacity: parent.highlighted ? 0.2 : 1.0
        }
        
        highlighted: control.highlightedIndex === index
    }
}
