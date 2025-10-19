import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import QtQuick.Layouts

Scope {
    id: root
    property string title: ""
    property string text: ""
    property bool active: true
    required property int x
    required property int y
    required property var window
    readonly property int fontSize: 10
    property color color: Qt.rgba(14 / 255.0, 49 / 255.0, 90 / 255.0, 0.8)

    Loader {
        id: tooltipLoader
        anchors.fill: parent
        active: root.active && (title != "" || text != "")
        sourceComponent: PopupWindow {
            visible: true
            anchor.window: root.window
            anchor.rect.x: root.x - (contentItem.implicitHeight + 5) / 2
            anchor.rect.y: root.y

            mask: Region {}

            color: "transparent"
            implicitWidth: contentItem.implicitWidth + 5
            implicitHeight: contentItem.implicitHeight + 5

            Rectangle {
                id: contentItem
                anchors.centerIn: parent
                anchors.fill: parent
                color: root.color
                radius: 8
                border.color: "#666666"
                border.width: 1

                implicitHeight: titleContext.implicitHeight + (text != "" ? textContext.implicitHeight : 0)
                implicitWidth: textContext.implicitWidth < titleContext.implicitWidth ? titleContext.implicitWidth : textContext.implicitWidth

                Rectangle {
                    id: titleContext
                    implicitWidth: titleLabel.implicitWidth + 10
                    implicitHeight: titleLabel.implicitHeight + 10
                    color: "transparent"

                    Text {
                        id: titleLabel
                        text: root.title
                        Layout.fillWidth: true
                        color: "white"
                        font.bold: true
                        font.pointSize: root.fontSize
                        wrapMode: Text.WordWrap
                        visible: text.length > 0
                        horizontalAlignment: Text.AlignHCenter | Text.AlignVCenter
                        anchors.centerIn: parent
                    }
                }

                Rectangle {
                    id: textContext
                    implicitWidth: textLabel.implicitWidth + 10
                    implicitHeight: textLabel.implicitHeight + 10
                    color: "transparent"
                    anchors.top: titleContext.bottom
                    Text {
                        id: textLabel
                        text: root.text
                        Layout.fillWidth: true
                        color: "white"
                        font.pointSize: root.fontSize
                        wrapMode: Text.WordWrap
                        visible: text.length > 0
                        horizontalAlignment: Text.AlignHCenter | Text.AlignVCenter
                        anchors.centerIn: parent
                    }
                }
            }
        }
    }
}
