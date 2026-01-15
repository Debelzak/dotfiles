pragma Singleton
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Services.Notifications
import QtQuick

Singleton {
    id: root

    readonly property ListModel popup: ListModel {}
    readonly property ListModel unread: ListModel {}
    readonly property ListModel all: ListModel {}

    property bool doNotDisturb: false

    component NotificationModel: QtObject {
        id: notificationObject

        property int id;
        property string image;
        property string summary;
        property string body;
        property string appName;
        property string appIcon;
        property string desktopEntry;
        property int urgency;
        property bool hasActionIcons;
        property bool hasInlineReply;
        property string inlineReplyPlaceholder
        property bool lastGeneration;
        property list<var> actions;
        //property bool tracked;
        property bool resident;
        property var hints;
        property real expireTimeout;
        property bool justPopped

        readonly property Timer timer: Timer {
            running: true
            interval: notificationObject.expireTimeout > 0 ? notificationObject.expireTimeout : 4_000
            onTriggered: {
                notificationObject.removePopup()
            }
        }

        function removePopup() {
            for (let i = 0; i < root.popup.count; i++) {
                if (root.popup.get(i).modelData === this) {
                    root.popup.remove(i)
                    break
                }
            }
        }

        function removeUnread() {
            for (let i = 0; i < root.unread.count; i++) {
                if (root.unread.get(i).modelData === this) {
                    root.unread.remove(i)
                    break
                }
            }
        }
        
        function remove() {
            for (let i = 0; i < root.all.count; i++) {
                if (root.all.get(i).modelData === this) {
                    root.all.remove(i)
                    break
                }
            }
        }
    }

    NotificationServer {
        id: server

        keepOnReload: false
        actionsSupported: true
        bodyHyperlinksSupported: true
        bodyImagesSupported: true
        bodyMarkupSupported: true
        imageSupported: true
        persistenceSupported: true

        onNotification: (n) => {
            n.tracked = true
            const notification = notificationModel.createObject(root, {
                id: n.id,
                image: n.image,
                summary: n.summary,
                body: n.body,
                appName: n.appName,
                appIcon: n.appIcon,
                desktopEntry: n.desktopEntry,
                urgency: n.urgency,
                hasActionIcons: n.hasActionIcons,
                hasInlineReply: n.hasInlineReply,
                inlineReplyPlaceholder: n.inlineReplyPlaceholder,
                lastGeneration: n.lastGeneration,
                actions: n.actions,
                resident: n.resident,
                hints: n.hints,
                expireTimeout: n.expireTimeout,
                justPopped: true
            })
            
            root.popup.insert(0, { "modelData": notification })
            root.unread.insert(0, { "modelData": notification })
            root.all.insert(0, { "modelData": notification })
        }
    }

    Component {
        id: notificationModel
        NotificationModel{}
    }

    function init() {
        console.info("Notification daemon started")
    }
}