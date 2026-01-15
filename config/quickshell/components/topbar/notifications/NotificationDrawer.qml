pragma ComponentBehavior: Bound

import qs.controllers
import QtQuick
import QtQuick.Shapes

Item {
    id: root
    
    required property Item attachedTo
    readonly property int notificationItemWidth: 450
    readonly property int notificationItemHeight: 70
    readonly property int padding: 5
    readonly property int itemTotalHeight: notificationItemHeight + padding

    // Âncoras do container invisível
    anchors.horizontalCenter: attachedTo.horizontalCenter
    anchors.top: attachedTo.bottom
    anchors.topMargin: -5
    
    width: notificationItemWidth + 20
    height: background.height

    Rectangle {
        id: background
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width
        color: "#11111b"
        bottomLeftRadius: 15
        bottomRightRadius: 15
        clip: true

        height: (listView.count * root.itemTotalHeight) + (listView.count > 0 ? root.padding : 0)

        Behavior on height {
            NumberAnimation {
                duration: 400
                easing.type: Easing.BezierSpline;
                easing.bezierCurve: [0.2, 0, 0, 1, 1, 1]
            }
        }

        ListView {
            id: listView
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            width: root.notificationItemWidth
            height: 1080 // FIXME
            
            model: Notifications.popup
            spacing: root.padding
            interactive: false
            clip: false

            delegate: NotificationItem { targetHeight: root.notificationItemHeight }

            // --- TRANSIÇÕES ---
            add: Transition {
                ParallelAnimation {
                    //NumberAnimation {property: "x"; from: root.notificationItemWidth; to: 0; duration: 600; easing.type: Easing.BezierSpline; easing.bezierCurve: [0.2, 0, 0, 1, 1, 1] }
                    NumberAnimation {properties: "opacity"; from: 0; to: 1; duration: 400; easing.type: Easing.InCubic}
                }
            }
            populate: add
            displaced: Transition {
                ParallelAnimation {
                    //NumberAnimation {property: "x"; to: 0; duration: 600; easing.type: Easing.BezierSpline; easing.bezierCurve: [0.2, 0, 0, 1, 1, 1] }
                    NumberAnimation {properties: "y"; duration: 400; easing.type: Easing.BezierSpline; easing.bezierCurve: [0.2, 0, 0, 1, 1, 1]}
                    NumberAnimation {properties: "opacity"; to: 1; duration: 400; easing.type: Easing.InCubic }
                }
            }
            move: displaced
            remove: Transition {
                ParallelAnimation {
                    //NumberAnimation { property: "y"; to: -root.notificationItemHeight; duration: 200 }
                    NumberAnimation { property: "scale"; to: 0; duration: 400; easing.type: Easing.BezierSpline; easing.bezierCurve: [0.2, 0, 0, 1, 1, 1] }
                    NumberAnimation { property: "opacity"; to: 0; duration: 400; easing.type: Easing.InCubic }
                }
            }
        }
        
    }

    // Top left corner
    Shape {
        id: shape_left

        // User defined
        property double rounding: 20
        property double roundingSize: (rounding > background.height / 2) ? background.height / 2 : rounding // Corner cannot be bigger than height / 2

        // Altura e largura da borda, para uma curvatura perfeita, definir a proporção 1:1
        property double lineSizeX: roundingSize // Largura da borda
        property double lineSizeY: roundingSize // Altura da borda

        ShapePath {
            strokeWidth: 0
            strokeColor: "transparent"
            fillColor: background.color

            // ponto inicial: canto superior esquerdo
            startX: 0
            startY: 0

            // linha para a esquerda de 20px
            PathLine {
                relativeX: -shape_left.lineSizeX
                relativeY: 0
            }

            // Linha para baixo-direita de 20px, aplicando arredondamento de 20px
            PathArc {
                relativeX: shape_left.lineSizeX
                relativeY: shape_left.lineSizeY
                radiusX: shape_left.roundingSize
                radiusY: shape_left.roundingSize
            }

            // linha para cima de 20px
            PathLine {
                relativeX: 0
                relativeY: -shape_left.lineSizeY
            }
        }
    }

    // Top right corner
    Shape {
        id: shape_right
        // User defined
        property double rounding: 20
        property double roundingSize: (rounding > background.height / 2) ? background.height / 2 : rounding

        // Altura e largura da borda, para uma curvatura perfeita, definir a proporção 1:1
        property double lineSizeX: roundingSize // Largura da borda
        property double lineSizeY: roundingSize // Altura da borda

        ShapePath {
            strokeWidth: 0
            strokeColor: "transparent"
            fillColor: background.color

            // ponto inicial: canto superior direito
            startX: background.width
            startY: 0

            // linha para a direita de 20px
            PathLine {
                relativeX: shape_right.lineSizeX
                relativeY: 0
            }

            // Linha para baixo-esquerda de 20px, aplicando arredondamento de 20px
            PathArc {
                relativeX: -shape_right.lineSizeX
                relativeY: shape_right.lineSizeY
                radiusX: shape_right.roundingSize
                radiusY: shape_right.roundingSize
                direction: PathArc.Counterclockwise
            }

            // linha para cima de 20px
            PathLine {
                relativeX: 0
                relativeY: -shape_right.lineSizeY
            }
        }
    }

    // Bloqueador de cliques
    MouseArea {
        anchors.fill: background
        acceptedButtons: Qt.AllButtons
    }
}