pragma Singleton

import Quickshell

Singleton {
    // General
    readonly property string temperature_metric: "°C"
    readonly property string main_font: "Cantarell Extra Bold"
    readonly property string gpu_type: "NVIDIA" // NVIDIA; GENERIC; NONE

    // Workspaces
    readonly property bool workspaces_showAll: false
    readonly property int workspaces_max: 9
    //readonly property var workspaces_labels: ({1: " 1 ", 2: " 2 ", 3: " 3 ", 4: " 4 ", 5: " 5 ", 6: " 6 ", 7: " 7 ", 8: " 8 ", 9: " 9 "}) // Default
    readonly property var workspaces_labels: ({1: "Ⅰ", 2: "Ⅱ", 3: "Ⅲ", 4: "Ⅳ", 5: "Ⅴ", 6: "Ⅵ", 7: "Ⅶ", 8: "Ⅷ", 9: "Ⅸ"}) // Roman
    //readonly property var workspaces_labels: ({1: "一", 2: "二", 3: "三", 4: "四", 6: "五", 6: "六", 7: "七", 8: "八", 9: "九"}) // Japanese

}