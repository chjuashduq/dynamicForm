import QtQuick 6.5
import QtQuick.Controls 6.5
import QtQuick.Layouts 1.15
import "../Common" as Common

/**
 * 美化的日期时间选择器
 * 包含日历选择和时间微调功能
 */
StyledBase {
    id: root
    label: "日期时间"

    // 导出属性
    property alias text: control.text
    property alias placeholderText: control.placeholderText
    property alias readOnly: control.readOnly

    // 格式配置
    property string displayFormat: "yyyy-MM-dd HH:mm:ss"
    property string outputFormat: "yyyyMMddHHmmsszzz"

    // 内部状态：当前选中的时间对象
    property var currentDate: new Date()

    property var defaultProps: mergeProps({
        "label": "日期时间",
        "placeholder": "请选择时间",
        "text": "",
        "displayFormat": "yyyy-MM-dd HH:mm:ss",
        "outputFormat": "yyyyMMddHHmmsszzz"
    })

    // 将 Date 对象格式化为字符串
    function formatDate(date, format) {
        if (!date || isNaN(date.getTime()))
            return "";

        var y = date.getFullYear();
        var m = String(date.getMonth() + 1).padStart(2, '0');
        var d = String(date.getDate()).padStart(2, '0');
        var h = String(date.getHours()).padStart(2, '0');
        var min = String(date.getMinutes()).padStart(2, '0');
        var s = String(date.getSeconds()).padStart(2, '0');
        var z = String(date.getMilliseconds()).padStart(3, '0');

        var res = format;
        res = res.replace(/yyyy/g, y);
        res = res.replace(/MM/g, m);
        res = res.replace(/dd/g, d);
        res = res.replace(/HH/g, h);
        res = res.replace(/mm/g, min);
        res = res.replace(/ss/g, s);
        res = res.replace(/zzz/g, z);
        return res;
    }

    // 获取提交给后端的值
    function getValue() {
        if (!control.text)
            return "";
        if (!isNaN(currentDate.getTime())) {
            return formatDate(currentDate, root.outputFormat);
        }
        return control.text;
    }

    function generateCode(props, childrenCode, indent, events, functions) {
        var layoutProps = generateLayoutCode(props, indent);
        var code = "StyledDateTime {\n" + indent + "    text: \"" + props.text + "\"\n" + indent + "    displayFormat: \"" + (props.displayFormat || "yyyy-MM-dd HH:mm:ss") + "\"\n" + indent + "    outputFormat: \"" + (props.outputFormat || "yyyyMMddHHmmsszzz") + "\"\n" + indent + "    placeholderText: \"" + props.placeholder + "\"\n" + indent + "    enabled: " + props.enabled + "\n" + layoutProps;

        if (props.key && props.key.trim() !== "") {
            code += indent + "    key: \"" + props.key + "\"\n";
        }

        code += generateCommonEventsCode(props, events, indent, functions);
        code += indent + "}";
        return code;
    }

    // 输入框区域
    TextField {
        id: control
        Layout.fillWidth: true
        height: Common.AppStyles.inputHeight
        font.pixelSize: Common.AppStyles.fontSizeMedium
        font.family: Common.AppStyles.fontFamily
        color: Common.AppStyles.textPrimary
        placeholderTextColor: Common.AppStyles.textPlaceholder
        readOnly: true
        leftPadding: Common.AppStyles.inputPadding
        rightPadding: 40

        background: Rectangle {
            color: control.enabled ? Common.AppStyles.inputBackground : Common.AppStyles.backgroundColor
            border.color: {
                if (root.hasError)
                    return "red";
                if (pickerPopup.opened)
                    return Common.AppStyles.primaryColor;
                return Common.AppStyles.inputBorder;
            }
            border.width: (pickerPopup.opened || root.hasError) ? 2 : Common.AppStyles.inputBorderWidth
            radius: Common.AppStyles.inputRadius
        }

        MouseArea {
            anchors.fill: parent
            enabled: parent.enabled
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                if (control.text) {
                    var d = new Date(control.text);
                    if (!isNaN(d.getTime())) {
                        root.currentDate = d;
                    } else {
                        root.currentDate = new Date();
                    }
                } else {
                    root.currentDate = new Date();
                }

                if (!isNaN(root.currentDate.getTime())) {
                    calendar.month = root.currentDate.getMonth();
                    calendar.year = root.currentDate.getFullYear();
                    hourSpin.value = root.currentDate.getHours();
                    minSpin.value = root.currentDate.getMinutes();
                    secSpin.value = root.currentDate.getSeconds();
                }

                pickerPopup.open();
            }
        }

        Text {
            text: "📅"
            anchors.right: parent.right
            anchors.rightMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize: 16
            opacity: 0.6
        }
    }

    // 日期时间选择弹窗
    Popup {
        id: pickerPopup
        y: control.height + 5
        width: 300
        height: 450 // 稍微增加高度，防止拥挤
        padding: 0
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        background: Rectangle {
            color: "#ffffff"
            border.color: Common.AppStyles.borderColor
            border.width: 1
            radius: 8
            layer.enabled: true
        }

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            // 1. 顶部操作栏
            Rectangle {
                Layout.fillWidth: true
                height: 40
                color: Common.AppStyles.primaryColor
                radius: 8
                Rectangle {
                    anchors.bottom: parent.bottom
                    width: parent.width
                    height: 10
                    color: parent.color
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 5
                    anchors.rightMargin: 5

                    Button {
                        text: "<<"
                        flat: true
                        onClicked: calendar.year--
                        background: Item {}
                        contentItem: Text {
                            text: parent.text
                            color: "white"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.bold: true
                        }
                        Layout.preferredWidth: 30
                    }
                    Button {
                        text: "<"
                        flat: true
                        onClicked: {
                            if (calendar.month === 0) {
                                calendar.month = 11;
                                calendar.year--;
                            } else {
                                calendar.month--;
                            }
                        }
                        background: Item {}
                        contentItem: Text {
                            text: parent.text
                            color: "white"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.bold: true
                        }
                        Layout.preferredWidth: 30
                    }

                    Text {
                        text: calendar.year + "年 " + (calendar.month + 1) + "月"
                        color: "white"
                        font.bold: true
                        font.pixelSize: 16
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                    }

                    Button {
                        text: ">"
                        flat: true
                        onClicked: {
                            if (calendar.month === 11) {
                                calendar.month = 0;
                                calendar.year++;
                            } else {
                                calendar.month++;
                            }
                        }
                        background: Item {}
                        contentItem: Text {
                            text: parent.text
                            color: "white"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.bold: true
                        }
                        Layout.preferredWidth: 30
                    }
                    Button {
                        text: ">>"
                        flat: true
                        onClicked: calendar.year++
                        background: Item {}
                        contentItem: Text {
                            text: parent.text
                            color: "white"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.bold: true
                        }
                        Layout.preferredWidth: 30
                    }
                }
            }

            // 2. 星期表头
            DayOfWeekRow {
                locale: Qt.locale("zh_CN")
                Layout.fillWidth: true
                Layout.margins: 5
                delegate: Text {
                    text: model.shortName
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.bold: true
                    color: "#666"
                }
            }

            // 3. 日历网格
            MonthGrid {
                id: calendar
                Layout.fillWidth: true
                Layout.preferredHeight: 200
                Layout.margins: 5
                locale: Qt.locale("zh_CN")

                delegate: Rectangle {
                    height: width
                    radius: width / 2
                    color: {
                        var isSelected = (model.date.getDate() === root.currentDate.getDate() && model.date.getMonth() === root.currentDate.getMonth() && model.date.getFullYear() === root.currentDate.getFullYear());
                        var isToday = (model.date.toDateString() === new Date().toDateString());

                        if (isSelected)
                            return Common.AppStyles.primaryColor;
                        if (isToday)
                            return "#e6f7ff";
                        return "transparent";
                    }

                    Text {
                        anchors.centerIn: parent
                        text: model.day
                        color: {
                            var isSelected = (model.date.getDate() === root.currentDate.getDate() && model.date.getMonth() === root.currentDate.getMonth() && model.date.getFullYear() === root.currentDate.getFullYear());
                            if (isSelected)
                                return "white";
                            return model.month === calendar.month ? "#333" : "#ccc";
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            var newDate = new Date(root.currentDate);
                            newDate.setFullYear(model.date.getFullYear());
                            newDate.setMonth(model.date.getMonth());
                            newDate.setDate(model.date.getDate());
                            root.currentDate = newDate;

                            if (model.month !== calendar.month) {
                                calendar.month = model.month;
                                if (model.year !== undefined)
                                    calendar.year = model.year;
                            }
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#eee"
            }

            // 4. 时间选择器 (使用自定义样式的 SpinBox)
            RowLayout {
                Layout.fillWidth: true
                Layout.margins: 10
                spacing: 5

                Text {
                    text: "时间:"
                    color: "#666"
                    font.bold: true
                }

                TimeSpinBox {
                    id: hourSpin
                    from: 0
                    to: 23
                    // 补零函数
                    textFromValue: function (value, locale) {
                        return String(value).padStart(2, '0');
                    }
                    valueFromText: function (text, locale) {
                        return parseInt(text) || 0;
                    }
                }
                Text {
                    text: ":"
                    font.bold: true
                    color: "#666"
                }

                TimeSpinBox {
                    id: minSpin
                    from: 0
                    to: 59
                    textFromValue: function (value, locale) {
                        return String(value).padStart(2, '0');
                    }
                    valueFromText: function (text, locale) {
                        return parseInt(text) || 0;
                    }
                }
                Text {
                    text: ":"
                    font.bold: true
                    color: "#666"
                }

                TimeSpinBox {
                    id: secSpin
                    from: 0
                    to: 59
                    textFromValue: function (value, locale) {
                        return String(value).padStart(2, '0');
                    }
                    valueFromText: function (text, locale) {
                        return parseInt(text) || 0;
                    }
                }
            }

            // 5. 底部按钮
            RowLayout {
                Layout.fillWidth: true
                Layout.margins: 10
                spacing: 10

                Button {
                    text: "此刻"
                    Layout.fillWidth: true
                    onClicked: {
                        var now = new Date();
                        root.currentDate = now;
                        calendar.year = now.getFullYear();
                        calendar.month = now.getMonth();
                        hourSpin.value = now.getHours();
                        minSpin.value = now.getMinutes();
                        secSpin.value = now.getSeconds();
                    }
                }
                Button {
                    text: "确定"
                    highlighted: true
                    Layout.fillWidth: true
                    onClicked: {
                        var finalDate = new Date(root.currentDate);
                        finalDate.setHours(hourSpin.value);
                        finalDate.setMinutes(minSpin.value);
                        finalDate.setSeconds(secSpin.value);
                        root.currentDate = finalDate;

                        control.text = formatDate(finalDate, root.displayFormat);
                        pickerPopup.close();
                    }
                }
            }

            Item {
                Layout.preferredHeight: 10
            }
        }
    }

    // 定义统一的时间 SpinBox 样式
    component TimeSpinBox: SpinBox {
        editable: true
        Layout.fillWidth: true
        Layout.preferredHeight: 32 // 增加高度方便点击
        font.pixelSize: 12

        // 自定义 ContentItem 确保数字显示可见
        contentItem: TextInput {
            z: 2
            text: parent.textFromValue(parent.value, parent.locale)
            font: parent.font
            color: "#333333" // 显式黑色字体
            selectionColor: "#21be2b"
            selectedTextColor: "#ffffff"
            horizontalAlignment: Qt.AlignHCenter
            verticalAlignment: Qt.AlignVCenter
            readOnly: !parent.editable
            validator: parent.validator
            inputMethodHints: Qt.ImhDigitsOnly
        }

        // 自定义背景，确保有边框和底色
        background: Rectangle {
            implicitWidth: 50
            color: "#f5f5f5"
            border.color: parent.activeFocus ? Common.AppStyles.primaryColor : "#e0e0e0"
            border.width: 1
            radius: 4
        }
    }
}
