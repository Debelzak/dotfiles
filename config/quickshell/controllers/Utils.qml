pragma Singleton

import Quickshell
import QtQuick
import Qt.labs.folderlistmodel

Singleton {
    id: root

    FolderListModel {
        id: steamFiles
        showFiles: true
        showDirs: false
        nameFilters: ["*.jpg"]
        sortField: FolderListModel.Size
        sortReversed: true
    }

    function getAppIcon(name: string, fallback: string): string {
        const icon = DesktopEntries.heuristicLookup(name)?.icon;
        if (name.startsWith("steam_app_")) {
            return steamIconFromAppId(name)
        }
        else if (fallback !== "undefined") {
            return Quickshell.iconPath(icon, fallback);
        }
        return Quickshell.iconPath(icon);
    }

    function steamIconFromAppId(appId: string): string {
        if (!appId.startsWith("steam_app_"))
            return ""

        const id = appId.slice("steam_app_".length)
        const basePath = `file://${Quickshell.env("HOME")}/.steam/steam/appcache/librarycache/${id}`
        steamFiles.folder = basePath
        
        if (steamFiles.count > 0) {
            return `file://${steamFiles.get(0, "filePath")}`
        }

        return Quickshell.iconPath("application-x-executable");
    }
}