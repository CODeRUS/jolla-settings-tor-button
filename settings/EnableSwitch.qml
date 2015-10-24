import QtQuick 2.1
import Sailfish.Silica 1.0
import org.nemomobile.dbus 2.0
import org.nemomobile.configuration 1.0
import Mer.Cutes 1.1

Switch {
    id: enableSwitch

    property string entryPath
    property bool activeState
    onActiveStateChanged: {
        enableSwitch.busy = false
    }

    CutesActor {
        id: tools
        source: "./tools.js"
    }

    ConfigurationGroup {
        id: proxyConf
        path: "/apps/tor-button"
        property bool browserProxy: true
        property bool browserRestart: true
    }

    Timer {
        id: checkState
        interval: 1000
        repeat: true
        onTriggered: {
            systemdServiceIface.updateProperties()
        }
    }

    DBusInterface {
        id: systemdServiceIface
        bus: DBus.SessionBus
        service: 'org.freedesktop.systemd1'
        path: '/org/freedesktop/systemd1/unit/tor_2eservice'
        iface: 'org.freedesktop.systemd1.Unit'

        signalsEnabled: true
        function updateProperties() {
            var activeProperty = systemdServiceIface.getProperty("ActiveState")
            console.log("ActiveState:", activeProperty)
            if (activeProperty === "active") {
                activeState = true
                checkState.stop()
            }
            else if (activeProperty === "inactive") {
                activeState = false
                checkState.stop()
            }
            else {
                checkState.start()
            }
        }

        onPropertiesChanged: updateProperties()
        Component.onCompleted: updateProperties()
    }

    DBusInterface {
        bus: DBus.SessionBus
        service: 'org.freedesktop.systemd1'
        path: '/org/freedesktop/systemd1/unit/tor_2eservice'
        iface: 'org.freedesktop.DBus.Properties'

        signalsEnabled: true
        onPropertiesChanged: systemdServiceIface.updateProperties()
        Component.onCompleted: systemdServiceIface.updateProperties()
    }

    DBusInterface {
        bus: DBus.SessionBus
        service: "org.freedesktop.systemd1"
        path: "/org/freedesktop/systemd1"
        iface: "org.freedesktop.systemd1.Manager"
        signalsEnabled: true

        signal unitNew(string name)
        onUnitNew: {
            if (name == "tor.service") {
                systemdServiceIface.updateProperties()
            }
        }
    }

    icon.source: "image://theme/icon-settings-tor"
    checked: activeState == "active"
    automaticCheck: false
    onClicked: {
        if (enableSwitch.busy) {
            return
        }
        systemdServiceIface.call(activeState ? "Stop" : "Start", ["replace"])
        if (proxyConf.browserProxy) {
            var proxy_reply = function() {
                var restart_reply = function() {
                    if (!activeState) {
                        var object = Qt.createQmlObject("import org.nemomobile.lipstick 0.1; LauncherItem { filePath: \"/usr/share/applications/sailfish-browser.desktop\" }", enableSwitch, "LauncherItem")
                        object.launchApplication()
                    }

                    systemdServiceIface.updateProperties()
                };
                var restart_error = function(err) {
                    console.log("error:", err);
                };
                if (proxyConf.browserRestart) {
                    tools.request("kill_browser", {}, {
                        on_reply: restart_reply, on_error: restart_error
                    });
                }
            };
            var proxy_error = function(err) {
                console.log("error:", err);
            };
            tools.request(activeState ? "disable_proxy" : "enable_proxy", {}, {
                on_reply: proxy_reply, on_error: proxy_error
            });
        }
        else {
            systemdServiceIface.updateProperties()
        }
        enableSwitch.busy = true
    }

    Behavior on opacity { FadeAnimation { } }
}
