import qs.config
import QtQuick
import QtQuick.Controls
import Quickshell.Widgets

Button {
    id: root

    property int fontSize: 14
    property bool active: false
    property string tooltip

    // Left icon
    property string iconSource: ""
    property int iconSize: 18

    leftPadding: 10
    rightPadding: 10

    background: Rectangle {
        radius: 3
        color: (root.down || root.active) ? "#58585f" :
               root.hovered ? "#35353d" :
               "transparent"

        Behavior on color {
            ColorAnimation {
                duration: 150
                easing.type: Easing.InOutQuad
            }
        }
    }

    contentItem: Row {
        spacing: 10

        IconImage {
            anchors.verticalCenter: parent.verticalCenter
            visible: root.iconSource !== ""
            source: root.iconSource
            implicitSize: root.iconSize
            //smooth: true
        }
        
        // Default label shown when `text` property is used.
        Text {
            id: label
            anchors.verticalCenter: parent.verticalCenter
            text: root.text
            visible: root.text !== "" && root.text !== undefined
            font.family: Config.main_font
            font.pixelSize: root.fontSize
            font.weight: Font.Bold
            color: root.active ? "#ffffff" : "#b1b1b5"
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
        }
    }

    Tooltip {
        id: tooltip
        text: root.tooltip
    }

    onHoveredChanged: {
        if (!tooltip.text || tooltip.text === "")
            return;

        if (hovered) {
            tooltip.showFor(root);
        } else {
            tooltip.hide();
        }
    }
}