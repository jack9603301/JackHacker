import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Services.SystemTray
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.modules.commons
import qs.modules.bar
Scope {
	Variants {
		model: Quickshell.screens
		PanelWindow {
			id: statusBar
			required property ShellScreen modelData
			screen: modelData

			readonly property double barHeight: 30
        		readonly property double barWidth: 30
        		readonly property color barNormalColor: Qt.rgba(1, 1, 1, 0.3)
        		readonly property int barGlobalRadius: 15
        		readonly property int lineWidth: 1
			readonly property color borderColor: "white"
			readonly property color textColor: "white"
			readonly property int fontSize: 10
			readonly property int iconSize: 30

			WlrLayershell.layer: WlrLayer.Bottom
			WlrLayershell.keyboardFocus: WlrLayershell.OnDemand

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
				readonly property string currentWorkspace: currentWorkspaceContext.workspace == null ? "[null]" : currentWorkspaceContext.workspace.name
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
					text: "当前工作区 => " + currentWorkspaceContext.currentWorkspace
					color: "white"
					font.pointSize: fontSize
					anchors.centerIn: parent
				}

				MouseArea {
					anchors.fill: parent

					acceptedButtons: Qt.RightButton
					onClicked: {
						if(workspacesPopup.is_open()) {
							workspacesPopup.close()
						} else {
							workspacesPopup.open()
						}
					}
					onWheel: function(wheel) {
						if (wheel.angleDelta.y > 0) {
							Hyprland.dispatch("workspace e+1")
						} else if (wheel.angleDelta.y < 0) {
							Hyprland.dispatch("workspace e-1")
						}
						wheel.accepted = true;
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
				implicitHeight: workspacesPopupContext.implicitHeight
				color: "transparent"

				function open() {
					visible = true;
					focusGrab.active = true;
				}

				function close() {
					visible = false;
					focusGrab.active = false;
				}

				function is_open() {
					return visible;
				}

				HyprlandFocusGrab {
					id: focusGrab
					active: false
					windows: [workspacesPopup]
					onCleared: {
						workspacesPopup.visible = false;
					}
				}

				Rectangle {
					id: workspacesPopupContext
					readonly property int horizontalPadding: 10
					property int totalWorkspaceCount: Hyprland.workspaces.values.length
					implicitHeight: workspacesPopupTitle.implicitHeight + inputWorkspaceSelect.implicitHeight + unamePopupTitle.implicitHeight + unamedContextMenu.implicitHeight + workspacesPopupNamedTitle.implicitHeight + namedWorkspaceContext.implicitHeight + workspacesPopupSpecialTitle.implicitHeight + specialorkspaceContext.implicitHeight + 5
					implicitWidth: workspacesPopup.implicitWidth
					color: workspacesPopup.normalColor

					border {
						width: statusBar.lineWidth
						color: statusBar.borderColor
					}
					radius: statusBar.barGlobalRadius

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

					Rectangle {
                                                id: workspacesPopupTitle
                                                implicitHeight: statusBar.barHeight
                                                implicitWidth: workspacesPopup.implicitWidth
                                                radius: statusBar.barGlobalRadius
                                                color: workspacesPopup.normalColor

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

					Rectangle {
						id: inputWorkspaceSelect
						implicitHeight: statusBar.barHeight
						implicitWidth: workspacesPopup.implicitWidth
						anchors.top: workspacesPopupTitle.bottom

						radius: statusBar.barGlobalRadius
						color: Qt.rgba(0, 0, 0, 0.4)

						border {
                        				width: statusBar.lineWidth
                        				color: statusBar.borderColor
						}

						TextField {
							id: workspaceInput
							anchors.fill: parent
							placeholderText: "输入工作区名字..."
							placeholderTextColor: statusBar.textColor
							color: statusBar.textColor
							font.pointSize: statusBar.fontSize
							background: null
							activeFocusOnPress: true
							horizontalAlignment: Text.AlignHCenter
							verticalAlignment: Text.AlignVCenter

							onAccepted: {
								var WorkspaceName = text;
								if (WorkspaceName.length > 0) {
									Hyprland.dispatch("workspace name:" + WorkspaceName);
									text = ""
									focus = false;
								}
							}

							focus: false
						}

						MouseArea {
                                        		anchors.fill: parent
                                        		//cursorShape: Qt.PointingHandCursor
							hoverEnabled: true

							onEntered: {
								workspaceInput.focus = true;
							}

							onExited: {
								workspaceInput.focus = false;
                                        		}
						}
					}

					Rectangle {
                                                id: unamePopupTitle
                                                implicitHeight: statusBar.barHeight
                                                implicitWidth: workspacesPopup.implicitWidth
						radius: statusBar.barGlobalRadius
						anchors.top: inputWorkspaceSelect.bottom
                                                color: Qt.rgba(83/255.0, 134/255.0, 103/255.0, 0.8)
                                                border {
                                                        width: statusBar.lineWidth
                                                        color: statusBar.borderColor
                                                }
                                                Text {
                                                        text: "无名工作区"
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
						id: unamedContextMenu
						spacing: 5

						anchors.top: unamePopupTitle.bottom

						readonly property int itemsPerLine: workspacesPopup.itemsPerRow
                                                readonly property int itemCount: workspacesPopupContext.unamedWorkspaces.length
                                                readonly property int itemsInLastRow: itemCount % workspacesPopup.itemsPerRow
                                                readonly property int emptySlots: itemsInLastRow === 0 ? 0 : workspacesPopup.itemsPerRow - itemsInLastRow
						readonly property int totalRows: Math.ceil(unamedContextMenu.itemCount * 1.0 / unamedContextMenu.itemsPerLine * 1.0)
						implicitHeight: unamedContextMenu.totalRows * workspacesPopup.itemSize + (unamedContextMenu.totalRows > 0 ? (unamedContextMenu.totalRows - 1) * workspacesPopup.gridSpacing : 0)
						implicitWidth: workspacesPopup.implicitWidth
						Flow {
							id: workspacesGrid
							spacing: workspacesPopup.gridSpacing
							Layout.fillWidth: true
							Layout.preferredHeight: unamedContextMenu.totalRows * workspacesPopup.itemSize + (unamedContextMenu.totalRows > 0 ? (unamedContextMenu.totalRows - 1) * workspacesPopup.gridSpacing : 0)
							Layout.preferredWidth: workspacesPopup.implicitWidth
								
							Repeater {
								model: workspacesPopupContext.unamedWorkspaces
								Rectangle {
                                    					implicitWidth: workspacesPopup.itemSize
                                    					implicitHeight: workspacesPopup.itemSize
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

									MouseArea {
                                        					anchors.fill: parent
                                        					cursorShape: Qt.PointingHandCursor
										onClicked: {
											if (!modelData.active) {
												Hyprland.dispatch("workspace " + modelData.name)
											}
										}
									}
			    					}
							}

							Repeater {
								model: workspacesGrid.emptySlots

								Rectangle {
                                    					implicitWidth: workspacesPopup.itemSize
                                    					implicitHeight: workspacesPopup.itemSize
                                    					color: "transparent"
                                    					border.width: 0
                                				}
							}
						}
					}

					Rectangle {
						anchors.top: unamedContextMenu.bottom
                                                id: workspacesPopupNamedTitle
                                                implicitHeight: statusBar.barHeight
                                                implicitWidth: workspacesPopup.implicitWidth
						radius: statusBar.barGlobalRadius
						visible: workspacesPopupContext.namedWorkspaces.length > 0 ? true : false
                                                color: Qt.rgba(83/255.0, 134/255.0, 103/255.0, 0.8)
                                                border {
                                                        width: statusBar.lineWidth
                                                        color: statusBar.borderColor
                                                }
                                                Text {
                                                        text: "命名工作区"
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
						id: namedWorkspaceContext
						width: workspacesPopup.implicitWidth
						implicitHeight: workspacesPopupContext.namedWorkspaces.length * statusBar.barHeight
						spacing: workspacesPopup.gridSpacing
						anchors.top: workspacesPopupNamedTitle.bottom
						visible: workspacesPopupContext.namedWorkspaces.length > 0 ? true : false
						Layout.fillWidth: true

						Repeater {
							model: workspacesPopupContext.namedWorkspaces
							Rectangle {
								implicitWidth: namedWorkspaceContext.width
								implicitHeight: workspacesPopup.itemSize
								radius: statusBar.barGlobalRadius
								border.width: modelData.active ? statusBar.lineWidth : 0
								border.color: modelData.active ? statusBar.borderColor : 0
								color: modelData.active ? "#8FBCBB" : workspacesPopup.normalColor
								Text {
									text: modelData.name
									anchors.centerIn: parent
									color: statusBar.textColor
									font.pointSize: statusBar.fontSize
								}

								MouseArea {
                                                                        anchors.fill: parent
                                                                       	cursorShape: Qt.PointingHandCursor
									onClicked: {
										if (!modelData.active) {
                                                                        		Hyprland.dispatch("workspace " + modelData.name)
										}
									}
                                                                }
							}
						}
					}

					Rectangle {
                                                anchors.top: namedWorkspaceContext.bottom
                                                id: workspacesPopupSpecialTitle
                                                implicitHeight: statusBar.barHeight
                                                implicitWidth: workspacesPopup.implicitWidth
						radius: statusBar.barGlobalRadius
						visible: workspacesPopupContext.specialWorkspaces.length > 0 ? true : false
                                                color: Qt.rgba(83/255.0, 134/255.0, 103/255.0, 0.8)
                                                border {
                                                        width: statusBar.lineWidth
                                                        color: statusBar.borderColor
                                                }
                                                Text {
                                                        text: "特殊工作区"
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
                                                id: specialorkspaceContext
                                                implicitWidth: workspacesPopup.implicitWidth
                                                implicitHeight: workspacesPopupContext.specialWorkspaces.length * statusBar.barHeight
                                                spacing: workspacesPopup.gridSpacing
						anchors.top: workspacesPopupSpecialTitle.bottom
						visible: workspacesPopupContext.specialWorkspaces.length > 0 ? true : false

                                                Repeater {
                                                        model: workspacesPopupContext.specialWorkspaces
							Rectangle {
                                                                implicitWidth: namedWorkspaceContext.implicitWidth
                                                                implicitHeight: workspacesPopup.itemSize
								radius: statusBar.barGlobalRadius
								color: workspacesPopup.normalColor

								function getSpecialWorkspaceName(spacialWorkspaceName) {
									if(spacialWorkspaceName.startsWith("special:")) {
										return spacialWorkspaceName.substring("special:".length);
									}
									return spacialWorkspaceName;
								}
								
								Text {
                                                                        text: getSpecialWorkspaceName(modelData.name)
                                                                        anchors.centerIn: parent
                                                                        color: statusBar.textColor
                                                                        font.pointSize: statusBar.fontSize
								}

								MouseArea {
                                                                        anchors.fill: parent
                                                                        cursorShape: Qt.PointingHandCursor
                                                                        onClicked: {
                                                                                Hyprland.dispatch("togglespecialworkspace " + getSpecialWorkspaceName(modelData.name))
                                                                        }
                                                                }
                                                        }
                                                }
                                        }
				}
			}

			Rectangle {
				id: trayContext
                                implicitHeight: statusBar.implicitHeight
				implicitWidth: trayIconsFlow.implicitWidth < statusBar.iconSize ? 30 : trayIconsFlow.implicitWidth + 10
				visible: trayIconsFlow.implicitWidth < statusBar.iconSize ? false : true

				anchors.right: parent.right
				anchors.verticalCenter: parent.verticalCenter

                                color: statusBar.barNormalColor
                                radius: statusBar.barGlobalRadius
                                border {
                                        width: statusBar.lineWidth
                                        color: statusBar.borderColor
                                }

                                Flow {
                                        id: trayIconsFlow
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.right: parent.right
                                        anchors.rightMargin: 5
					spacing: 5

                                        Repeater {
                                                model: SystemTray.items

						delegate: Rectangle {
							id: trayItemRect
							required property SystemTrayItem modelData

							implicitWidth: statusBar.iconSize
							implicitHeight: statusBar.iconSize

							color: "transparent"

							Image {
								id: trayIcon
								anchors.centerIn: trayItemRect

								source: modelData.icon

								width: statusBar.iconSize - 10
								height: statusBar.iconSize - 10

								fillMode: Image.PreserveAspectFit

								MouseArea {
									id: trayMouseArea
									anchors.fill: parent

									hoverEnabled: true
									acceptedButtons: Qt.LeftButton | Qt.RightButton

									onClicked: {
										if (mouse.button === Qt.LeftButton) {
											modelData.activate()
										}
										mouse.accepted = true;
									}

									onPressed: {
										if (mouse.button === Qt.RightButton) {
											if (modelData.hasMenu) {
												//modelData.display(statusBar, 100, 100)
												menuLoader.active = true
												menuLoader.open()
												//menu.QsWindow.color = "red"
												//test.open()
											}
										}

										mouse.accepted = true;
									}

									onExited: {
										toolTip.active = false
										delayOpenTimer.stop()
									}

									onPositionChanged: {
										var centerXLocal = trayItemRect.implicitWidth / 2
										var centerYLocal = trayItemRect.implicitHeight / 2
										var centerGlobalPoint = trayMouseArea.mapToItem(null, centerXLocal, centerYLocal);
										toolTip.x = centerGlobalPoint.x
                                                                               	toolTip.y = centerGlobalPoint.y + 20
                                                                                toolTip.title = modelData.tooltipTitle != "" ? modelData.tooltipTitle : modelData.title
										toolTip.text = modelData.tooltipDescription
										delayOpenTimer.start()
										mouse.accepted = true
									}


								}

								PopupTooltip {
									id: toolTip
									window: statusBar
									x: 0
									y: 0
								}

								Loader {
									id: menuLoader

									function open() {
										item.open()
									}
									function close() {
										item.close()
									}

									sourceComponent: SystemTrayMenu {
										id: menu
										x: 100
										y: 100
										window: statusBar
										menu: modelData.menu
									}
								}

								Timer {
                                        				id: delayOpenTimer
                                        				interval: 1000	
                                        				repeat: false
									onTriggered: {
										toolTip.active = true
                                        				}
                                				}
							}
                                                }
                                        }
                                }
			}
		}
	}
}

