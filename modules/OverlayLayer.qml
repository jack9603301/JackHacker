import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland

Scope {
	Variants {
		model: Quickshell.screens

		PanelWindow {
			id: overlayLayer
			property var modelData
			screen: modelData
			anchors {
                        	right: true
                		bottom: true
			}
			margins {
                        	right: 50
                		bottom: 50
			}
			implicitWidth: content.width
			implicitHeight: content.height

			color: "transparent"
			mask: Region {}

			WlrLayershell.layer: WlrLayer.Overlay

			ColumnLayout {
				id: content
				Text {
					text: "Linux From Scratch 12.1"
					color: "#50ffffff"
					font.pointSize: 22
				}

				Text {
					text: "Ouyang Chunhui"
					color: "#50ffffff"
					font.pointSize: 14
				}
			}
		}
	}
}
