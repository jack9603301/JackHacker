//@ pragma UseQApplication
//@ pragma Env QT_QUICK_CONTROLS_STYLE=Universal
import QtQuick
import QtQuick.Window
import QtQuick.Controls
import Quickshell
import "modules"

ApplicationWindow {
	id: root
	ShellRoot {
		id: shell
		ReloadPopup {}
		OverlayLayer {}
		BottomLayer {}
		BottomStatusBar {}
	}
}
