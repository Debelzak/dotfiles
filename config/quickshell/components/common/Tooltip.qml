import qs.config
import QtQuick
import QtQuick.Window

Window {
    id: root
    property alias text: label.text
    property Item target
    property int delay: 600

    flags: Qt.ToolTip | Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint
    color: "transparent"
    visible: false

    Timer {
        id: showTimer
        interval: root.delay
        repeat: false
        onTriggered: {
            if (!root.target) return;
            root.updatePosition();
            root.visible = true;
            root.opacity = 1;
        }
    }

    Rectangle {
        id: background
        color: '#cc000000'
        radius: 4
        border.color: "#22888888"
        implicitWidth: label.implicitWidth + 20
        implicitHeight: label.implicitHeight + 20

        Text {
            id: label
            anchors.centerIn: parent
            color: "white"
            font.family: Config.main_font
            font.weight: Font.Bold
            font.pixelSize: 13
        }
    }

    function showFor(item) {
        target = item;
        showTimer.restart(); // inicia o delay
    }

    function hide() {
        showTimer.stop();
        root.visible = false;
    }

    function updatePosition() {
        if (!target) return;

        // Calcula tamanho do tooltip
        root.width = background.implicitWidth;
        root.height = background.implicitHeight;

        // Posição global do target
        const targetPos = target.mapToGlobal(Qt.point(0, 4));
        const targetCenterX = targetPos.x + target.width / 2;

        // Centraliza o tooltip
        root.x = Math.round(targetCenterX - root.width / 2);
        root.y = Math.round(targetPos.y + target.height);
    }
}
