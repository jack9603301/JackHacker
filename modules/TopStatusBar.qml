import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Scope {
	Variants {
		model: Quickshell.screens
		PanelWindow {
			id: statusBar
			required property ShellScreen modelData
			screen: modelData

			WlrLayershell.layer: WlrLayer.Top

			anchors {
				top: true
				left: true
				right: true
			}
			WlrLayershell.exclusiveZone: workspacePopup.visible ? 0 : 30
			//WlrLayershell.exclusiveZone: 30
			//implicitHeight: 30
			implicitHeight: workspacePopup.visible ? (currentWorkspaceContext.y + currentWorkspaceContext.height + 5) + workspacesPopup.height : 30
			color: "transparent"
			Rectangle {
				id: currentWorkspaceContext
				readonly property HyprlandMonitor monitor: Hyprland.monitorFor(statusBar.screen)
				readonly property HyprlandWorkspace workspace: monitor.activeWorkspace
				readonly property int horizontalPadding: 10
				anchors {
					top: parent.top
					left: parent.left
				}

				implicitWidth: workspaceText.implicitWidth + (horizontalPadding * 2)
				implicitHeight: 30

				border {
					width: 1
					color: "white"
				}
				radius: 15
				color: Qt.rgba(255, 255, 255, 0.3)

				Text {
					id: workspaceText
					text: "当前工作区名称 => " + currentWorkspaceContext.workspace.name
					color: "white"
					font.pointSize: 10
					anchors.centerIn: parent
				}

				MouseArea {
					anchors.fill: parent
					cursorShape: Qt.PointingHandCursor
					onClicked: {
						workspacesPopup.visible = !workspacesPopup.visible;
					}

				}

			}

			Rectangle {
				id: workspacesPopup
				z: 10
				visible: true
				x: 100
				y: parent.height + 5
				property int totalWorkspaceCount: hyprland.workspaces ? hyprland.workspaces.length : 0
				width: parent.width
				height: totalWorkspaceCount * 30
				radius: 15
				border {
					width: 1
					color: "white"
				}
			}
		}
	}
}
