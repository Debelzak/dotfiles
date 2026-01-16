pragma ComponentBehavior: Bound

import qs.config
import qs.controllers
import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Layouts

Item {
    required property int targetWidth
    required property int targetHeight

    signal removalFinished()

    id: root
    width: container.width
    height: container.height

    // Notification attrs
    required property var modelData;

    property bool expand: false

    MouseArea {
        anchors.fill: root
        acceptedButtons: Qt.AllButtons
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onEntered: {
            Notifications.preventPopupRemoval = true
            root.modelData.timer.stop()
            container.color = '#3c3d4c'
        }
        onExited: {
            Notifications.preventPopupRemoval = false
            root.modelData.timer.restart()
            container.color = "#45475a"
        }
        onClicked: (mouseEvent) => {
            root.expand = !root.expand
        }
    }

    ListView.onRemove: outAnimation.start()

    SequentialAnimation {
        id: outAnimation

        PropertyAction { target: root; property: "ListView.delayRemove"; value: true }
        ParallelAnimation {
            //NumberAnimation { target: root; property: "scale"; to: 0; duration: 400; easing.type: Easing.BezierSpline; easing.bezierCurve: [0.2, 0, 0, 1, 1, 1] }
            NumberAnimation { target: root; property: "opacity"; to: 0; duration: 400; easing.type: Easing.InCubic }
            NumberAnimation { target: root; property: "height"; to: 0; duration: 400; easing.type: Easing.InCubic }
            //NumberAnimation { target: root; property: "y"; duration: 400; easing.type: Easing.BezierSpline; easing.bezierCurve: [0.2, 0, 0, 1, 1, 1]}
        }
        PropertyAction { target: root; property: "ListView.delayRemove"; value: false }
    }
    
    Rectangle {
        property real warpX: root.modelData.justPopped ? 1 : 0
        property int slide: warpX * root.targetWidth
        
        id: container
        width: root.targetWidth - Math.abs(slide)
        height: root.targetHeight
        color: "#45475a"
        radius: 10
        clip: true
        x: slide > 0 ? Math.abs(slide) : 0

        Behavior on warpX {
            NumberAnimation { duration: 400; easing.type: Easing.OutCubic }
        }

        Component.onCompleted: {
            if (root.modelData.justPopped) {
                warpX = 0
                root.modelData.justPopped = false
            }
        }

        states: [
            State{
                name: "expanded"
                when: root.expand === true
                PropertyChanges {
                    container.height: content.height + 20
                }
            }
        ]
        
        Rectangle {
            id: innerContent
            anchors.centerIn: parent
            width: parent.width + Math.abs(container.slide) - 10
            height: parent.height - 10
            color: "transparent"
            x: (container.slide > 0) ? 0 : container.slide

            Rectangle {
                id: avatar
                color: "#11111b"
                width: height
                height: 56
                radius: height
                anchors.top: parent.top
                anchors.left: parent.left
                //anchors.verticalCenter: parent.verticalCenter

                Image {
                    id: img
                    source: root.modelData.image
                    width: avatar.width
                    height: avatar.height
                    //fillMode: Image.PreserveAspectCrop
                    z: 1

                    layer.enabled: true
                    layer.effect: OpacityMask {
                        maskSource: Rectangle {
                            width: avatar.width
                            height: avatar.height
                            radius: avatar.radius
                            color: "white"   // alpha = 1
                        }
                    }
                }

                Text {
                    font.family: "Font Awesome 7 Free"
                    font.pixelSize: 24
                    anchors.centerIn: parent
                    text: ""
                    color: "#b1b1b5"
                }
            }

            Rectangle {
                id: content
                radius: 5
                color: "transparent"
                anchors.leftMargin: 5
                anchors.left: avatar.right

                width: parent.width - avatar.width - 10
                implicitHeight: body.y + body.implicitHeight + 10
                
                TextMetrics {
                    id: titleText
                    text: root.modelData.summary
                }

                Text {
                    id: appName
                    anchors.top: content.top
                    opacity: root.expand ? 1 : 0

                    font.family: Config.main_font
                    text: root.modelData.appName
                    font.pointSize: 11
                    color: "#b1b1b5"
                    topPadding: 4
                    leftPadding: 4
                    maximumLineCount: 1

                    states: [
                        State{
                            name: "expanded"
                            when: root.expand === true
                            PropertyChanges {
                                appName.opacity: 1
                            }
                        }
                    ]

                    Behavior on opacity {
                        NumberAnimation { duration: 400; easing.type: Easing.BezierSpline; easing.bezierCurve: [0.2, 0, 0, 1, 1, 1]}
                    }
                }

                Text {
                    id: title
                    anchors.top: content.top

                    font.family: Config.main_font
                    text: titleText.text
                    font.pointSize: 11

                    color: "#b1b1b5"
                    topPadding: 5
                    leftPadding: 5
                    maximumLineCount: 1

                    states: [
                        State{
                            name: "expanded"
                            when: root.expand === true
                            AnchorChanges {
                                target: title
                                anchors.top: appName.bottom
                            }
                        }
                    ]
                    
                    transitions: [
                        Transition{
                            AnchorAnimation { duration: 400; easing.type: Easing.BezierSpline; easing.bezierCurve: [0.2, 0, 0, 1, 1, 1] }
                        }
                    ]
                }

                Text {
                    id: timeSeparator
                    anchors.left: title.right
                    anchors.verticalCenter: title.verticalCenter
                    font.family: Config.main_font
                    text: "•"
                    font.pointSize: 10

                    color: "#b1b1b5"
                    topPadding: 4
                    leftPadding: 5
                    maximumLineCount: 1

                    states: [
                        State {
                            name: "collapsed"
                            when: root.expand === false && container.x == 0
                            AnchorChanges {
                                target: timeSeparator
                                anchors.left: title.right
                            }
                        },
                        State {
                            name: "expanded"
                            when: root.expand === true
                            AnchorChanges {
                                target: timeSeparator
                                anchors.left: appName.right
                                anchors.verticalCenter: appName.verticalCenter
                            }
                        }
                    ]

                    transitions: [
                        Transition {
                            from: "*"
                            to: "*"
                            AnchorAnimation {
                                duration: 400
                                easing.type: Easing.BezierSpline
                                easing.bezierCurve: [0.2, 0, 0, 1, 1, 1]
                            }
                        }
                    ]
                }

                Text {
                    id: time
                    anchors.left: timeSeparator.right
                    anchors.verticalCenter: timeSeparator.verticalCenter
                    font.family: Config.main_font
                    text: "agora"
                    font.pointSize: 10

                    color: "#b1b1b5"
                    topPadding: 3
                    leftPadding: 5
                    maximumLineCount: 1
                }

                Text {
                    id: expandBtn
                    anchors.right: parent.right
                    anchors.verticalCenter: appName.verticalCenter
                    font.family: Config.main_font
                    text: ""
                    font.pointSize: 10
                    color: "#b1b1b5"
                    rightPadding: 0
                    bottomPadding: 5
                    maximumLineCount: 1
                }
            
                TextMetrics {
                    id: bodyText
                    text: root.modelData.body
                    //text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
                    elide: Text.ElideRight
                    elideWidth: content.width - 50
                }

                Text {
                    id: body
                    anchors.top: title.bottom
                    font.family: Config.main_font
                    width: parent.width
                    text: bodyText.text
                    wrapMode: Text.WordWrap
                    font.pointSize: 10
                    color: "#b1b1b5"
                    leftPadding: 4
                    maximumLineCount: root.expand ? 999 : 1

                    states: [
                        State{
                            name: "expanded"
                            when: root.expand === true
                            PropertyChanges {
                                body.maximumLineCount: undefined
                                body.text: bodyText.text
                            }
                        }
                    ]

                    transitions: [
                        Transition {
                            PropertyAction {
                                target: body
                                property: "maximumLineCount"
                            }
                            AnchorAnimation {
                                duration: 400
                                easing.type: Easing.BezierSpline
                                easing.bezierCurve: [0.2, 0, 0, 1, 1, 1]
                            }
                        }
                    ]

                    Behavior on height {
                        NumberAnimation {
                            duration: 400
                            easing.type: Easing.BezierSpline;
                            easing.bezierCurve: [0.2, 0, 0, 1, 1, 1]
                        }
                    }
                }

                Behavior on opacity {
                    NumberAnimation { duration: 400; easing.type: Easing.BezierSpline; easing.bezierCurve: [0.2, 0, 0, 1, 1, 1]}
                }
                
            }
            
        }
    }
}
