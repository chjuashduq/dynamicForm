import QtQuick 6.5
import QtQuick.Controls 6.5
import Common 1.0

/**
 * 美化的标签
 */
StyledBase {
    id: root

    // Map text property to label property of StyledBase
    property alias text: root.label

    // Expose font property for customization
    property alias font: root.labelFont

    // Expose alignment properties from StyledBase (to avoid alias-to-alias issues)
    property alias horizontalAlignment: root.labelHorizontalAlignment
    property alias verticalAlignment: root.labelVerticalAlignment
    property alias elide: root.labelElide

    // StyledLabel IS the label, so we show it.
    showLabel: true

    // We need to expose color property for ControlFactory
    property alias color: root.labelColor

    property var defaultProps: mergeProps({
        "text": "Styled Label"
    })

    function generateCode(props, childrenCode, indent) {
        var layoutProps = generateLayoutCode(props, indent);
        return "StyledLabel {\n" + indent + "    text: \"" + props.text + "\"\n" + layoutProps + indent + "}";
    }
}
