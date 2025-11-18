import QtQuick 6.5
import QtQuick.Controls 6.5
import Common 1.0

/**
 * 美化的标签
 */
Label {
    id: control
    
    font.pixelSize: AppStyles.labelFontSize
    font.family: AppStyles.fontFamily
    color: AppStyles.labelColor
    verticalAlignment: Text.AlignVCenter
    elide: Text.ElideRight
}
