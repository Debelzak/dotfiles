pragma Singleton

import qs.config
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property string glyph: ""
    property bool hasData: false
    property double tempCurrent: 0
    property double tempMin: 0
    property double tempMax: 0
    property double tempFeelsLike: 0
    property string description: ""
    property string region: ""
    property string state: ""
    property string country: ""

    QtObject {
        id: internal

        function refreshWeather() {
            if (weatherProcess.running) {
                return
            }

            weatherProcess.exec(weatherProcess.command)
        }

        readonly property var process: Process {
            id: weatherProcess
            command: [ "sh", "/home/maru/.config/quickshell/scripts/weather/getweather.sh" ]

            stdout: StdioCollector {
                onStreamFinished: function() {
                    try {
                        const data = JSON.parse(this.text)
                        if (data.current) {
                            root.glyph = data.current.glyph ?? "?"
                            root.tempCurrent = Math.round(data.current.main?.temp ?? data.current.main?.temp ?? 9999)
                            root.tempMin = Math.round(data.forecast[0]?.min ?? data.forecast[0]?.min ?? 0)
                            root.tempMax = Math.round(data.forecast[0]?.max ?? data.forecast[0]?.max ?? 0)
                            root.tempFeelsLike = Math.round(data.current.main.feels_like ?? data.current.main.feels_like ?? 0)
                            root.description = data.current.weather?.[0]?.description ?? ""
                            root.region = data.location.name ?? ""
                            root.state = data.location.state ?? ""
                            root.country = data.location.country ?? ""

                            root.hasData = true;
                            console.info(`Weather data refreshed`)
                        }
                    } catch (e) {
                        console.warn("Failed to parse weather JSON:", e)
                    }
                }
            }
        }

        readonly property var timer: Timer {
            interval: 10 * 60 * 1000
            running: true
            repeat: true
            onTriggered: internal.refreshWeather()
        }
    }

    /** roda ao iniciar */
    Component.onCompleted: internal.refreshWeather()
}