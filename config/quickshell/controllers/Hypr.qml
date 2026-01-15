pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Hyprland

Singleton {
    id: root

    function init() {
        console.info("Hyprland daemon started")
    }

    function windowExists(address: string): bool {
        for (const win of Hyprland.toplevels.values) {
            if (win.address === address)
                return true
        }
        return false
    }

    function dispatchToWindow(address: string) {
        if(windowExists(address)) {
            Hyprland.dispatch(`focuswindow address:0x${address}`)
        }
    }

    Connections {
        target: Hyprland

        function onRawEvent(event: HyprlandEvent): void {
            if (event.name.endsWith("v2"))
                return;
            
            if (event.name === "urgent" ) {
                root.dispatchToWindow(event.data)
            } else if (event.name === "configreloaded") {
                //root.configReloaded();
                //root.reloadDynamicConfs();
            } else if (["workspace", "moveworkspace", "activespecial", "focusedmon"].includes(event.name)) {
                //Hyprland.refreshWorkspaces();
                //Hyprland.refreshMonitors();
            } else if (["openwindow", "closewindow", "movewindow"].includes(event.name)) {
                //Hyprland.refreshToplevels();
                //Hyprland.refreshWorkspaces();
            } else if (event.name.includes("mon")) {
                //Hyprland.refreshMonitors();
            } else if (event.name.includes("workspace")) {
                //Hyprland.refreshWorkspaces();
            } else if (event.name.includes("window") || event.name.includes("group") || ["pin", "fullscreen", "changefloatingmode", "minimize"].includes(event.name)) {
                //Hyprland.refreshToplevels();
            }
        }
    }
}
