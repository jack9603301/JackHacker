import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick 2.15
import QtQuick.Controls 2.15

Scope {
    Variants {
        model: Quickshell.screens
        PanelWindow {
            id: topLayer
            required property ShellScreen modelData
            screen: modelData

            WlrLayershell.layer: WlrLayer.Bottom
            anchors {
                top: true
                left: true
                right: true
                bottom: true
            }
            //focusable: false
            mask: Region {}
            color: "transparent"
            Rectangle {
                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                }
                border {
                    width: 1
                    color: Qt.rgba(1, 1, 1, 0.5)
                }
                radius: 15
                color: "transparent"
                MouseArea {
                    anchors.fill: parent
                    enabled: false
                }
            }
        }
    }
}
