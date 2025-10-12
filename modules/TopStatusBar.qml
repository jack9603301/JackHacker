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

			readonly property int barHeight: 30
        		readonly property int barWidth: 30
        		readonly property color barNormalColor: Qt.rgba(1, 1, 1, 0.3)
        		readonly property int barGlobalRadius: 15
        		readonly property int lineWidth: 1
			readonly property color borderColor: "white"
			readonly property color textColor: "white"
			readonly property int fontSize: 10

			WlrLayershell.layer: WlrLayer.Bottom

			anchors {
				top: true
				left: true
				right: true
			}
			WlrLayershell.exclusiveZone: barHeight
			implicitHeight: barHeight
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
				implicitHeight: statusBar.barWidth

				border {
					width: statusBar.lineWidth
					color: statusBar.borderColor
				}
				radius: statusBar.barGlobalRadius
				color: statusBar.barNormalColor

				Text {
					id: workspaceText
					text: "当前工作区 => " + currentWorkspaceContext.workspace.name
					color: "white"
					font.pointSize: fontSize
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

			PopupWindow {
				id: workspacesPopup
				visible: false
				anchor.window: statusBar
				anchor.rect.x: 20
				anchor.rect.y: 40

				readonly property int singleUnnamedWorkspacesGroup: 5
				readonly property int gridSpacing: 5
				readonly property int itemSize: statusBar.barHeight
				readonly property int itemsPerRow: 10
				readonly property color normalColor: Qt.rgba(14/255.0, 49/255.0, 90/255.0, 0.8)

				implicitWidth: 10 * statusBar.barWidth
				implicitHeight: workspacesPopupContext.height + 100
				color: "transparent"

				Rectangle {
					id: workspacesPopupContext
					readonly property int horizontalPadding: 10
					property int totalWorkspaceCount: Hyprland.workspaces.values.length
					implicitHeight: workspacesPopupTitle.implicitHeight + workspacesPopupContextMenu.height
					implicitWidth: workspacesPopup.implicitWidth
					color: workspacesPopup.normalColor

					border {
						width: statusBar.lineWidth
						color: statusBar.borderColor
					}
					radius: statusBar.barGlobalRadius

					Rectangle {
						id: workspacesPopupTitle
						implicitHeight: statusBar.barHeight
						implicitWidth: workspacesPopup.implicitWidth
						radius: statusBar.barGlobalRadius
						color: "#538667"
						border {
							width: statusBar.lineWidth
							color: statusBar.borderColor
						}
						Text {
							text: "工作区切换"
							width: workspacesPopupContext.implicitWidth
							height: statusBar.barHeight
							color: statusBar.textColor
							horizontalAlignment: Text.AlignHCenter | Text.AlignVCenter
							font.pointSize: statusBar.fontSize
							anchors.top: parent.top
							anchors.topMargin: 5
						}
					}
					ColumnLayout {
						id: workspacesPopupContextMenu
						anchors.fill: parent
						spacing: 5

						anchors.top: workspacesPopupTitle.bottom

						readonly property var unamedWorkspaces: Hyprland.workspaces.values.filter(function(ws) {
							return ws.id > 0;
						}).sort(function(a, b) {
							return a.id - b.id;
						})
						readonly property var namedWorkspaces: Hyprland.workspaces.values.filter(function(ws) {
							var isNamedId = ws.id < 0;
							var isNotSpecial = !ws.name.startsWith("special:");
							return isNamedId && isNotSpecial;
                                                }).sort(function(a, b) {
                                                        return a.name.localeCompare(b.name);
						})
						readonly property var specialWorkspaces: Hyprland.workspaces.values.filter(function(ws) {
							var isNamedId = ws.id < 0;
							var isNotSpecial = !ws.name.startsWith("special:");
							return isNamedId && !isNotSpecial;
                                                }).sort(function(a, b) {
                                                        return a.id - b.id;
						})

						Flow {
							id: workspacesGrid
							width: workspacesPopup.implicitWidth - (workspacesPopupContextMenu.padding * 2)
							spacing: workspacesPopup.gridSpacing
							Layout.fillWidth: true

							readonly property int itemCount: workspacesPopupContextMenu.unamedWorkspaces.length
                            				readonly property int itemsInLastRow: itemCount % workspacesPopup.itemsPerRow
							readonly property int emptySlots: itemsInLastRow === 0 ? 0 : workspacesPopup.itemsPerRow - itemsInLastRow
							readonly property int totalRows: Math.ceil(workspacesGrid.itemCount / workspacesGrid.itemsPerLine)
							Layout.preferredHeight: workspacesGrid.totalRows * workspacesPopup.itemSize + (workspacesGrid.totalRows > 0 ? (workspacesGrid.totalRows - 1) * workspacesPopup.gridSpacing : 0)

							Repeater {
								model: workspacesPopupContextMenu.unamedWorkspaces
								Rectangle {
                                    					width: workspacesPopup.itemSize
                                    					height: workspacesPopup.itemSize
                                    					radius: statusBar.barGlobalRadius
                                    					color: modelData.active ? "#8FBCBB" : workspacesPopup.normalColor
                                    					border.width: statusBar.lineWidth
									border.color: statusBar.borderColor

									Text {
										text: modelData.name
										anchors.centerIn: parent
										color: statusBar.textColor
										font.pointSize: statusBar.fontSize
									}
			    					}
							}

							Repeater {
								model: workspacesGrid.emptySlots

								Rectangle {
                                    					width: workspacesPopup.itemSize
                                    					height: workspacesPopup.itemSize
                                    					color: "transparent"
                                    					border.width: 0
                                				}
							}
						}
					}
				}
			}
		}
	}
}
