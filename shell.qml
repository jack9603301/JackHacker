//@ pragma UseQApplication
import QtQuick
import QtQuick.Window
import QtQuick.Controls
import Quickshell
import "modules"

ShellRoot {
    id: shell
    ReloadPopup {}
    OverlayLayer {}
    //BottomLayer {}
    BottomStatusBar {}
}
