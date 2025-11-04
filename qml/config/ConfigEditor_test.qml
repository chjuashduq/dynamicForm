import QtQuick 6.5
import QtQuick.Controls 6.5
import QtQuick.Layouts 1.4

Item {
    id: configEditor
    
    property var currentConfig: ({
        "grid": {
            "rows": 8,
            "columns": 2,
            "rowSpacing": 5,
            "columnSpacing": 10,
            "rowHeights": [1, 1, 1, 1, 1, 1, 1, 2],
            "columnWidths": [1, 2]
        },
        "controls": []
    })
    
    Component.onCompleted: {
        console.log("Test ConfigEditor loaded successfully");
    }
    
    Rectangle {
        anchors.fill: parent
        color: "#f0f0f0"
        
        Text {
            anchors.centerIn: parent
            text: "ConfigEditor Test - 简化版本"
            font.pixelSize: 20
        }
    }
}