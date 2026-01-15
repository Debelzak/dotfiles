import qs.components.common
import qs.config
import qs.controllers
import QtQuick
import Quickshell

Row {
    id: root
    property var memUsed: System.formatKib(System.memUsed)
    property var cpuUsage: System.cpuPerc
    property var cpuTemp: System.cpuTemp
    property var gpuTemp: System.gpuTemp

    Button {
        id: btn
        height: root.parent.height
        contentItem: Row {
            spacing: 10

            // CPU USAGE
            Row {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 4
                Label {
                    font.family: "Font Awesome 7 Free"
                    font.pixelSize: 16
                    color: btn.active ? "#ffffff" : "#b1b1b5"
                    text: ""
                }

                Label {
                    font.pixelSize: btn.fontSize
                    color: btn.active ? "#ffffff" : "#b1b1b5"
                    text: `${Number(root.cpuUsage * 100).toFixed(0)}%`
                }
            }

            // CPU TEMP
            Row {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 4
                Label {
                    font.family: "Font Awesome 7 Free"
                    font.pixelSize: 16
                    color: btn.active ? "#ffffff" : "#b1b1b5"
                    text: ""
                }

                Label {
                    font.pixelSize: btn.fontSize
                    color: btn.active ? "#ffffff" : "#b1b1b5"
                    text: `${Number(root.cpuTemp).toFixed(0)}${Config.temperature_metric}`
                }
            }

            // RAM USAGE
            Row {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 4
                Label {
                    font.family: "Font Awesome 7 Free"
                    font.pixelSize: 16
                    color: btn.active ? "#ffffff" : "#b1b1b5"
                    text: ""
                }

                Label {
                    font.family: Config.main_font
                    font.pixelSize: btn.fontSize
                    color: btn.active ? "#ffffff" : "#b1b1b5"
                    text: `${root.memUsed.value.toFixed(1)} ${root.memUsed.unit}`
                }
            }

            // GPU TEMP
            Row {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 4
                Label {
                    font.family: "Font Awesome 7 Free"
                    font.pixelSize: 16
                    color: btn.active ? "#ffffff" : "#b1b1b5"
                    text: ""
                }

                Label {
                    font.pixelSize: btn.fontSize
                    color: btn.active ? "#ffffff" : "#b1b1b5"
                    text: `${Number(root.gpuTemp).toFixed(0)}${Config.temperature_metric}`
                }
            }
        }

        onClicked: () => {
            Quickshell.execDetached(["alacritty", "-e", "btop"])
        }
    }
}