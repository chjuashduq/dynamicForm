import QtQuick 6.5
import QtQuick.Controls 6.5
import QtQuick.Layouts 1.15
import "../Common" as Common

/**
 * 美化的下拉框组件
 */
StyledBase {
    id: root
    label: "下拉框"

    // 导出属性
    property alias model: control.model
    property alias currentIndex: control.currentIndex
    property alias currentText: control.currentText
    property alias editable: control.editable
    property alias textRole: control.textRole
    property alias valueRole: control.valueRole
    property alias currentValue: control.currentValue

    property string dictType: ""

    property var defaultProps: mergeProps({
        "label": "下拉框",
        "model": [
            {
                "label": "选项1",
                "value": "opt1"
            },
            {
                "label": "选项2",
                "value": "opt2"
            }
        ],
        "dictType": "",
        "enabled": true,
        "visible": true
    })

    // [关键修复] 暴露 find 函数，解决 TypeError: Property 'find' ... is not a function
    function find(value) {
        return control.find(value);
    }

    function generateCode(props, childrenCode, indent, events, functions) {
        var layoutProps = generateLayoutCode(props, indent);

        var modelStr;
        if (props.dictType && props.dictType.trim() !== "") {
            // 生成动态加载代码
            modelStr = "loadDictData(\"" + props.dictType + "\")";
        } else {
            // 生成静态数组
            modelStr = JSON.stringify(props.model || [], null, 4).replace(/\n/g, "\n" + indent + "    ");
        }

        var code = "StyledComboBox {\n" + indent + "    label: \"" + (props.label || "") + "\"\n" + indent + "    labelWidth: " + (props.labelWidth || 80) + "\n" + indent + "    showLabel: " + (props.showLabel !== false) + "\n" + indent + "    textRole: \"label\"\n" + indent + "    valueRole: \"value\"\n" + indent + "    model: " + modelStr + "\n" + indent + "    enabled: " + (props.enabled !== false) + "\n" + layoutProps;

        if (props.key && props.key.trim() !== "") {
            code += indent + "    key: \"" + props.key + "\"\n";
        }

        if (props.dictType && props.dictType.trim() !== "") {
            code += indent + "    dictType: \"" + props.dictType + "\"\n";
        }

        code += generateCommonEventsCode(props, events, indent, functions);
        code += indent + "}";
        return code;
    }

    ComboBox {
        id: control
        Layout.fillWidth: true
        textRole: "label"
        valueRole: "value"

        onActivated: index => root.activated(index)

        background: Rectangle {
            implicitWidth: 120
            implicitHeight: 40
            border.color: {
                if (root.hasError)
                    return "red";
                return control.activeFocus ? Common.AppStyles.primaryColor : Common.AppStyles.borderColor;
            }
            border.width: (control.activeFocus || root.hasError) ? 2 : 1
            radius: Common.AppStyles.radiusMedium
        }
    }

    signal activated(int index)
}
