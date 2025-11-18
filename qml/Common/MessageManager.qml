pragma Singleton
import QtQuick 6.5
import QtQuick.Controls 6.5

Item {
    id: messageManager
    // 单例初始不可见，实际显示位置外部赋值
    visible: false
    z: 99999

    /* ========== 外部注册父容器 ========== */
    // 由 root QML 注册：MessageManager.registerRootItem(this)
    property Item hostRoot: null

    function registerRootItem(item) {
        hostRoot = item;
        parent = item;
        anchors.fill = item;
        visible = true;
    }

    /* =====================
       对外方法
       ===================== */
    function showDialog(message, type, callback) {
        _dialog.messageText = message;
        _dialog.messageType = type || "info";
        _dialog.onOkAction = callback || null;
        _dialog.open();
    }

    function showToast(message, type) {
        _toast.showMessage(message, type);
    }

    Dialog {
        id: _dialog
        parent: messageManager
        modal: true
        anchors.centerIn: parent
        width: 360
        height: 180

        property string messageText: ""
        property string messageType: "info"
        property var onOkAction: null

        // 自定义按钮代替 standardButtons
        footer: DialogButtonBox {
            Button {
                text: "OK"
                onClicked: {
                    if (_dialog.onOkAction)
                        _dialog.onOkAction();
                    _dialog.close();
                }
            }
        }

        Rectangle {
            anchors.fill: parent
            anchors.margins: 10
            color: _dialog.messageType === "error" ? "#f8d7da" : _dialog.messageType === "success" ? "#d4edda" : _dialog.messageType === "warning" ? "#fff3cd" : "#d1ecf1"
            radius: 8
            border.color: "#888"

            Text {
                anchors.centerIn: parent
                text: _dialog.messageText
                font.pixelSize: 14
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }

    /* ===== Toast ===== */
    Rectangle {
        id: _toast
        parent: messageManager
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 10

        width: Math.min(parent.width - 20, 400)
        height: toastText.height + 20
        radius: 8
        visible: false
        z: 100000

        Text {
            id: toastText
            anchors.centerIn: parent
            text: ""
            wrapMode: Text.WordWrap
            font.pixelSize: 14
        }

        Timer {
            id: toastTimer
            interval: 2500
            onTriggered: _toast.visible = false
        }

        function showMessage(message, type) {
            toastText.text = message;

            if (type === "error") {
                _toast.color = "#ffebee";
                toastText.color = "#c62828";
            } else if (type === "warning") {
                _toast.color = "#fff3e0";
                toastText.color = "#ef6c00";
            } else {
                _toast.color = "#e8f5e9";
                toastText.color = "#2e7d32";
            }

            _toast.visible = true;
            toastTimer.restart();
        }
    }
}
