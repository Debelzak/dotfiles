pragma ComponentBehavior: Bound

import qs.config
import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Layouts

Item {
    required property int targetHeight

    id: root
    width: parent?.width
    height: targetHeight

    // Notification attrs
    required property var modelData;

    Rectangle {
        property real warpX: root.modelData.justPopped ? 1 : 0
        property int slide: warpX * parent.width
        
        id: container
        width: root.width - Math.abs(slide)
        height: parent.height
        color: "#45475a"
        radius: 10
        clip: true
        x: slide > 0 ? Math.abs(slide) : 0

        Behavior on warpX {
            NumberAnimation { duration: 500; easing.type: Easing.OutCubic }
        }

        Component.onCompleted: {
            if (root.modelData.justPopped) {
                warpX = 0
                root.modelData.justPopped = false
            }
        }

        Rectangle {
            id: innerContent
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width + Math.abs(container.slide)
            height: parent.height
            color: "transparent"
            x: (container.slide > 0) ? 0 : container.slide

            RowLayout {
                id: row
                width: parent.width - 20
                anchors.centerIn: parent
                spacing: 5

                Rectangle { 
                    id: avatar
                    color: "#11111b"
                    width: height
                    height: 56
                    radius: height
                    Layout.alignment: Qt.AlignTop

                    Image {
                        id: img
                        source: root.modelData.image
                        width: avatar.width
                        height: avatar.height
                        fillMode: Image.PreserveAspectCrop
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
                    id: content;
                    height: 50;
                    radius: 5;
                    color: "transparent";
                    Layout.fillWidth: true;
                    
                    TextMetrics {
                        id: titleText
                        text: root.modelData.summary
                    }

                    Text {
                        id: title
                        font.family: Config.main_font
                        text: titleText.text
                        font.pointSize: 11

                        color: "#b1b1b5"
                        topPadding: 4
                        leftPadding: 4
                        maximumLineCount: 1
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
                    }

                    Text {
                        id: expandBtn
                        anchors.right: parent.right
                        anchors.verticalCenter: title.verticalCenter
                        font.family: Config.main_font
                        text: ""
                        font.pointSize: 10
                        color: "#b1b1b5"
                        rightPadding: 5
                        bottomPadding: 5
                        maximumLineCount: 1
                    }

                    Text {
                        id: time
                        anchors.left: timeSeparator.right
                        anchors.verticalCenter: title.verticalCenter
                        font.family: Config.main_font
                        text: "agora"
                        font.pointSize: 10

                        color: "#b1b1b5"
                        topPadding: 3
                        leftPadding: 5
                        maximumLineCount: 1
                    }
                
                    TextMetrics {
                        id: bodyText
                        text: root.modelData.body
                        elide: Text.ElideRight
                        elideWidth: content.width - 50
                    }

                    Text {
                        id: body
                        anchors.top: title.bottom
                        font.family: Config.main_font
                        width: parent.width
                        text: bodyText.elidedText
                        font.pointSize: 10
                        color: "#b1b1b5"
                        leftPadding: 4
                        maximumLineCount: 1
                    }
                    
                }
            }
        }
    }
}
