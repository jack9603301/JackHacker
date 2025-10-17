import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Services.SystemTray
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.modules.commons

PopupWindow {
	id: root

	property var menu
	property color normalColor: Qt.rgba(14/255.0, 49/255.0, 90/255.0, 0.8)
	required property var window
	property int x
	property int y
	readonly property color dashLineSeparator: Qt.rgba(1, 1, 1, 0.5)
	readonly property int dashLength: 5
        readonly property int dashSpacing: 2

	anchor.window: window
	anchor.rect.x: x
	anchor.rect.y: y
	visible: false

	color: "transparent"

	implicitWidth: contextMenu.implicitWidth
	implicitHeight: contextMenu.implicitHeight + 10

	function open() {
		visible = true
		focusGrab.active = true
	}

	function close() {
		visible = false
		focusGrab.active = false
	}

	QsMenuOpener {
		id: menuOpener
		menu: root.menu
	}

	Rectangle {
		id: contextMenu
		implicitHeight: childrenRect.height + 10
		implicitWidth: childrenRect.width

		radius: 15
		color: root.normalColor

		border {
			width: 1
			color: "white"
		}

		ColumnLayout {
			spacing: 5
			Layout.fillWidth: true
			Repeater {
				model: menuOpener.children
				Rectangle {
					id: menuItemContext
					radius: modelData.isSeparator ? 0.5 : 5
					implicitHeight: modelData.isSeparator ? 1 : menuItem.height 
					implicitWidth: 100
					color: "transparent"

					Item {
						visible: modelData.isSeparator
						anchors.fill: parent

						Repeater {
							id: dashRepeater
							model: Math.ceil(menuItemContext.implicitWidth / (root.dashLength + root.dashSpacing))

							Rectangle {
								implicitWidth: root.dashLength
								implicitHeight: parent.parent.implicitHeight
								color: root.dashLineSeparator
								anchors.left: parent.left
								anchors.leftMargin: index * (root.dashLength + root.dashSpacing)
							}
						}
					}

					Text {
						id: menuItem
						text: modelData.text
						width: parent.implicitWidth
						horizontalAlignment: Text.AlignHCenter | Text.AlignVCenter
						anchors.top: parent.top
						color: "white"
						font.pointSize: 10
					}

					MouseArea {
						anchors.fill: parent
						hoverEnabled: true

						onEntered: function(mouse) {
							if (!modelData.isSeparator) {
								color = "#8FBCBB"
							}
						}

						onExited: function(mouse) {
							if (!modelData.isSeparator) {
								color =  "transparent"
							}
						}
					}
				}
			}
		}
	}

	HyprlandFocusGrab {
		id: focusGrab
		active: false
		windows: [root]
		onCleared: {
			root.close()
		}
	}

}
