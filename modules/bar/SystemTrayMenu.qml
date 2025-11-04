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
    property color normalColor: Qt.rgba(14 / 255.0, 49 / 255.0, 90 / 255.0, 0.8)
    required property var window
    property int x
    property int y
    readonly property color dashLineSeparator: Qt.rgba(1, 1, 1, 0.5)
    readonly property int dashLength: 5
    readonly property int dashSpacing: 2
    property int iconSize: 30
    readonly property int buttonSize: 30
    property bool fcitx: false

    signal trigger()

    anchor.window: window
    anchor.rect.x: x
    anchor.rect.y: y
    visible: false

    color: "transparent"

    implicitWidth: contextMenu.implicitWidth
    implicitHeight: contextMenu.implicitHeight + 10

    function open() {
        visible = true;
        focusGrab.active = true;
    }

    function close() {
        visible = false;
        focusGrab.active = false;
    }

    QsMenuOpener {
        id: menuOpener
        menu: root.menu
    }

    Rectangle {
        id: contextMenu
        implicitHeight: childrenRect.height + 10
        implicitWidth: childrenRect.width + 10

        radius: 15
        color: root.normalColor

        border {
            width: 1
            color: "white"
        }

        ColumnLayout {
            id: menuItemContextLayout
            spacing: 5
            anchors.top: parent.top
            anchors.topMargin: 5
            Layout.fillWidth: true

            property bool closeDisplayItem: false

            Component.onCompleted: {
                var CloseDisplayItem = true;
                for (var i = 0; i < menuItemsRepeater.count; i++) {
                    var menuItem = menuItemsRepeater.itemAt(i);
                    if (!menuItem.separatorExtraOption) {
                        CloseDisplayItem = false;
                    }
                }
                closeDisplayItem = CloseDisplayItem;
            }

            Repeater {
                id: menuItemsRepeater
                model: menuOpener.children
                Rectangle {
                    id: menuItemContext
                    radius: modelData.isSeparator ? 0.5 : 5
                    anchors.left: parent.left
                    anchors.leftMargin: 5
                    implicitHeight: modelData.isSeparator ? 1 : menuItemLayout.height
                    implicitWidth: (menuItemLayout.width + 10) > parent.width ? menuItemLayout.width + 10 : parent.width
                    color: "transparent"
                    visible: modelData.enabled

                    property alias separatorExtraOption: separatorItemOption.visible

                    Item {
                        id: separatorItem
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

                    RowLayout {
                        id: menuItemLayout
                        spacing: 5
                        visible: !modelData.isSeparator

                        RadioButton {
                            id: radioButtomOption
                            visible: !menuItemContextLayout.closeDisplayItem && (!root.fcitx && (modelData.buttonType === QsMenuButtonType.RadioButton))
                            checked: modelData.checkState === Qt.Checked
                        }

                        CheckBox {
                            id: checkBoxOption
                            visible: !menuItemContextLayout.closeDisplayItem && (!root.fcitx && (modelData.buttonType === QsMenuButtonType.CheckBox))
                            checked: modelData.checkState === Qt.Checked
                        }

                        Item {
                            id: separatorItemOption
                            visible: !menuItemContextLayout.closeDisplayItem && (root.fcitx || (modelData.buttonType === QsMenuButtonType.None))
                            width: root.buttonSize
                        }


                        Image {
                            id: menuItemImage
                            visible: modelData.icon != ""
                            source: {
                                if (modelData.icon.includes("input-keyboard")) {
                                    return "../../assets/us-keyboard-input-white.svg";
                                } else if(modelData.icon.includes("view-refresh")) {
                                    return "../../assets/view-refresh-white.svg";
                                } else if(modelData.icon.includes("application-exit")) {
                                    return "../../assets/application-exit.svg";
                                } else {
                                    return modelData.icon;
                                }
                            }
                            Layout.preferredWidth: root.iconSize
                            Layout.preferredHeight: root.iconSize
                            fillMode: Image.PreserveAspectFit
                        }

                        Text {
                            id: menuItem
                            text: modelData.text
                            horizontalAlignment: Text.AlignHCenter | Text.AlignVCenter
                            color: "white"
                            font.pointSize: 10
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true

                        property bool init_input: false

                        onEntered: {
                            if (!init_input) {
                                init_input = true;
                                return;
                            }
                            if (!modelData.isSeparator) {
                                color = Qt.rgba(5/255, 219/255, 102/255, 0.6);
                            }
                        }

                        onExited: {
                            if (!modelData.isSeparator) {
                                color = "transparent";
                            }
                        }

                        onClicked: (mouse) => {
                            if (!modelData.isSeparator) {
                                modelData.triggered()
                                root.trigger()
                            }
                            mouse.accepted = true;
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
            root.close();
        }
    }
}
