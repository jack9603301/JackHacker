//@ pragma UseQApplication
//@ pragma Env QT_QUICK_CONTROLS_STYLE=Universal
import QtQuick
import QtQuick.Window
import QtQuick.Controls
import Quickshell
import "modules"

ShellRoot {
	id: shell
	ReloadPopup {}
	OverlayLayer {}
	BottomLayer {}
	BottomStatusBar {}
}
