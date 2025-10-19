import QtQuick
import QtQuick.Layouts
import Quickshell

Scope {
    id: root
    property bool failed
    property string errorString

    Connections {
        target: Quickshell

        function onReloadCompleted() {
            Quickshell.inhibitReloadPopup();
            root.failed = false;
            popupLoader.visible = true;
        }

        function onReloadFailed(error: string) {
            Quickshell.inhibitReloadPopup();

            root.failed = true;
            root.errorString = error;
            popupLoader.visible = true;
        }
    }

    PanelWindow {
        id: popupLoader

        anchors {
            top: true
            left: true
        }

        margins {
            top: 25
            left: 25
        }

        implicitWidth: rect.implicitWidth
        implicitHeight: rect.implicitHeight

        color: "transparent"

        Rectangle {
            id: rect
            color: failed ? "#40802020" : "#40009020"

            implicitHeight: layout.implicitHeight + 50
            implicitWidth: layout.implicitWidth + 30

            MouseArea {
                id: mouseArea
                anchors.fill: parent
                onClicked: popupLoader.visible = false

                hoverEnabled: true
            }

            ColumnLayout {
                id: layout
                anchors {
                    top: parent.top
                    topMargin: 20
                    horizontalCenter: parent.horizontalCenter
                }

                Text {
                    text: root.failed ? "Reload failed." : "Reloaded completed!"
                    color: "white"
                }

                Text {
                    text: root.errorString
                    color: "white"
                    visible: root.errorString != ""
                }
            }

            Rectangle {
                id: bar
                color: "#20ffffff"
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                implicitHeight: 20

                PropertyAnimation {
                    id: anim
                    target: bar
                    property: "implicitWidth"
                    from: rect.implicitWidth
                    to: 0
                    duration: failed ? 10000 : 800
                    onFinished: popupLoader.visible = false

                    paused: mouseArea.containsMouse
                }
            }

            Component.onCompleted: anim.start()
        }
    }
}
