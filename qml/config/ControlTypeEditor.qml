import QtQuick 6.5
import QtQuick.Controls 6.5
import QtQuick.Layouts 1.4

/**
 * 控件类型特定属性编辑器
 */
Column {
    id: typeEditor

    property var controlConfig: ({})

    width: parent.width
    spacing: 15

    // 文本框属性
    GridLayout {
        visible: controlConfig.type === "text"
        columns: 2
        columnSpacing: 15
        rowSpacing: 10
        width: parent.width
        Label {
            text: "占位符文本:"
        }
        TextField {
            id: placeholderField
            text: controlConfig.placeholder || ""
            Layout.fillWidth: true
        }
        Label {
            text: "默认值:"
        }
        TextField {
            id: textValueField
            text: controlConfig.value || ""
            Layout.fillWidth: true
        }
    }

    // [新增] 日期时间属性
    GridLayout {
        visible: controlConfig.type === "datetime" || controlConfig.type === "StyledDateTime"
        columns: 2
        columnSpacing: 15
        rowSpacing: 10
        width: parent.width

        Label {
            text: "占位符文本:"
        }
        TextField {
            id: datePlaceholderField
            text: controlConfig.placeholder || "YYYY-MM-DD"
            Layout.fillWidth: true
        }

        Label {
            text: "显示格式:"
        }
        ComboBox {
            id: displayFormatCombo
            editable: true
            model: ["yyyy-MM-dd HH:mm:ss", "yyyy-MM-dd", "HH:mm:ss", "yyyy/MM/dd"]
            Layout.fillWidth: true
            Component.onCompleted: currentIndex = find(controlConfig.displayFormat || "yyyy-MM-dd HH:mm:ss")
        }

        Label {
            text: "返回格式 (API):"
        }
        ComboBox {
            id: outputFormatCombo
            editable: true
            model: ["yyyyMMddHHmmsszzz", "yyyy-MM-dd HH:mm:ss", "yyyyMMdd", "zzz"] // zzz是毫秒
            Layout.fillWidth: true
            Component.onCompleted: currentIndex = find(controlConfig.outputFormat || "yyyyMMddHHmmsszzz")
        }
    }

    // 数字框属性
    GridLayout {
        visible: controlConfig.type === "number"
        columns: 2
        columnSpacing: 15
        rowSpacing: 10
        width: parent.width
        Label {
            text: "默认数值:"
        }
        SpinBox {
            id: numberValueSpinBox
            from: -999999
            to: 999999
            value: parseInt(controlConfig.value) || 0
        }
    }

    // 密码框
    GridLayout {
        visible: controlConfig.type === "password"
        columns: 2
        columnSpacing: 15
        rowSpacing: 10
        width: parent.width
        Label {
            text: "占位符文本:"
        }
        TextField {
            id: passwordPlaceholderField
            text: controlConfig.placeholder || ""
            Layout.fillWidth: true
        }
    }

    // 下拉框
    Column {
        visible: controlConfig.type === "dropdown"
        spacing: 10
        width: parent.width
        Label {
            text: "选项列表 (格式: 显示文本|值，每行一个):"
        }
        ScrollView {
            width: parent.width
            height: 100
            TextArea {
                id: dropdownOptionsArea
                text: controlConfig.options ? formatOptionsForEdit(controlConfig.options) : ""
                wrapMode: TextArea.Wrap
                placeholderText: "例如:\n选项1|option1"
            }
        }
    }

    // 复选框
    Column {
        visible: controlConfig.type === "checkbox"
        spacing: 10
        width: parent.width
        Label {
            text: "选项列表:"
        }
        ScrollView {
            width: parent.width
            height: 100
            TextArea {
                id: checkboxOptionsArea
                text: controlConfig.options ? formatOptionsForEdit(controlConfig.options) : ""
                wrapMode: TextArea.Wrap
            }
        }
        RowLayout {
            width: parent.width
            Label {
                text: "排列方向:"
            }
            ComboBox {
                id: directionCombo
                model: ["horizontal", "vertical"]
                currentIndex: (controlConfig.direction === "vertical") ? 1 : 0
            }
        }
    }

    // 单选框
    Column {
        visible: controlConfig.type === "radio"
        spacing: 10
        width: parent.width
        Label {
            text: "选项列表:"
        }
        ScrollView {
            width: parent.width
            height: 100
            TextArea {
                id: radioOptionsArea
                text: controlConfig.options ? formatOptionsForEdit(controlConfig.options) : ""
                wrapMode: TextArea.Wrap
            }
        }
    }

    // 按钮
    GridLayout {
        visible: controlConfig.type === "button"
        columns: 2
        columnSpacing: 15
        rowSpacing: 10
        width: parent.width
        Label {
            text: "按钮文本:"
        }
        TextField {
            id: buttonTextField
            text: controlConfig.text || ""
            Layout.fillWidth: true
        }
    }

    function getTypeSpecificConfig() {
        var config = {};
        switch (controlConfig.type) {
        case "text":
            config.placeholder = placeholderField.text;
            config.value = textValueField.text;
            break;
        case "number":
            config.value = numberValueSpinBox.value;
            break;
        case "datetime": // [新增]
        case "StyledDateTime":
            config.placeholder = datePlaceholderField.text;
            config.displayFormat = displayFormatCombo.currentText;
            config.outputFormat = outputFormatCombo.currentText;
            break;
        case "password":
            config.placeholder = passwordPlaceholderField.text;
            break;
        case "dropdown":
            config.options = parseOptionsFromEdit(dropdownOptionsArea.text);
            break;
        case "checkbox":
            config.options = parseOptionsFromEdit(checkboxOptionsArea.text);
            config.direction = directionCombo.currentText;
            break;
        case "radio":
            config.options = parseOptionsFromEdit(radioOptionsArea.text);
            break;
        case "button":
            config.text = buttonTextField.text;
            break;
        }

        return config;
    }

    function formatOptionsForEdit(options) {
        if (!options || !Array.isArray(options))
            return "";
        return options.map(function (option) {
            if (typeof option === "string") {
                return option + "|" + option;
            } else if (option && option.label && option.value) {
                return option.label + "|" + option.value;
            }
            return "";
        }).join("\\n");
    }

    function parseOptionsFromEdit(text) {
        if (!text || text.trim() === "")
            return [];
        var lines = text.split("\\n").filter(function (line) {
            return line.trim() !== "";
        });
        return lines.map(function (line) {
            var parts = line.split("|");
            if (parts.length >= 2) {
                return {
                    "label": parts[0].trim(),
                    "value": parts[1].trim()
                };
            } else {
                var trimmed = parts[0].trim();
                return {
                    "label": trimmed,
                    "value": trimmed
                };
            }
        });
    }
}
