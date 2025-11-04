import Quickshell
import Quickshell.Io
import Quickshell.Widgets
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
            readonly property int barGlobalRadius: 5
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
            WlrLayershell.exclusiveZone: barHeight + 10
            implicitHeight: barHeight + 20
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
                    leftMargin: 20
                    topMargin: 10
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
                    onClicked: (mouse) => {
                        if (workspacesPopupLoader.is_open()) {
                            workspacesPopupLoader.close();
                        } else {
                            var centerXLocal = currentWorkspaceContext.implicitWidth / 2;
                            var centerYLocal = currentWorkspaceContext.implicitHeight / 2;
                            var centerGlobalPoint = mapToItem(null, centerXLocal, centerYLocal);
                            workspacesPopupLoader.open(centerGlobalPoint.x, centerGlobalPoint.y + 25);
                        }
                        mouse.accepted = true;
                    }
                    onWheel: function (wheel) {
                        if (wheel.angleDelta.y > 0) {
                            Hyprland.dispatch("workspace e+1");
                        } else if (wheel.angleDelta.y < 0) {
                            Hyprland.dispatch("workspace e-1");
                        }
                        wheel.accepted = true;
                    }
                }
            }
            Loader {
                id: workspacesPopupLoader
                active: false
                function open(x, y) {
                    active = true
                    item.anchor.rect.x = x;
                    item.anchor.rect.y = y;
                    item.open();
                }
                function close() {
                    item.close();
                    active = false;
                }
                function is_open() {
                    return active && item.is_open();
                }
                sourceComponent: PopupWindow {
                    id: workspacesPopup
                    visible: false
                    anchor.window: statusBar

                    readonly property int singleUnnamedWorkspacesGroup: 5
                    readonly property int gridSpacing: 5
                    readonly property int itemSize: statusBar.barHeight
                    readonly property int itemsPerRow: 10
                    readonly property color normalColor: Qt.rgba(14 / 255.0, 49 / 255.0, 90 / 255.0, 0.8)
                    readonly property int gap: 10
                    readonly property int contextWidth: 10 * statusBar.barWidth
                    readonly property color selectColor: Qt.rgba(5/255, 219/255, 102/255, 0.6)

                    implicitWidth: workspacesPopupContext.implicitWidth
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
                        implicitHeight: workspacesPopupTitle.implicitHeight + inputWorkspaceSelect.implicitHeight + unamePopupTitle.implicitHeight + unamedContextMenu.implicitHeight + workspacesPopupNamedTitle.implicitHeight + namedWorkspaceContext.implicitHeight + workspacesPopupSpecialTitle.implicitHeight + specialorkspaceContext.implicitHeight + workspacesPopup.gap * 9
                        implicitWidth: workspacesPopup.contextWidth + workspacesPopup.gap * 2
                        color: workspacesPopup.normalColor

                        border {
                            width: statusBar.lineWidth
                            color: statusBar.borderColor
                        }
                        radius: statusBar.barGlobalRadius

                        readonly property var unamedWorkspaces: Hyprland.workspaces.values.filter(function (ws) {
                            return ws.id > 0;
                        }).sort(function (a, b) {
                            return a.id - b.id;
                        })
                        readonly property var namedWorkspaces: Hyprland.workspaces.values.filter(function (ws) {
                            var isNamedId = ws.id < 0;
                            var isNotSpecial = !ws.name.startsWith("special:");
                            return isNamedId && isNotSpecial;
                        }).sort(function (a, b) {
                            return a.name.localeCompare(b.name);
                        })
                        readonly property var specialWorkspaces: Hyprland.workspaces.values.filter(function (ws) {
                            var isNamedId = ws.id < 0;
                            var isNotSpecial = !ws.name.startsWith("special:");
                            return isNamedId && !isNotSpecial;
                        }).sort(function (a, b) {
                            return a.id - b.id;
                        })

                        Rectangle {
                            id: workspacesPopupTitle
                            implicitHeight: statusBar.barHeight
                            implicitWidth: workspacesPopupContext.implicitWidth - workspacesPopup.gap * 2
                            radius: statusBar.barGlobalRadius
                            color: workspacesPopup.normalColor
                            anchors.top: parent.top
                            anchors.topMargin: workspacesPopup.gap
                            anchors.left: parent.left
                            anchors.leftMargin: workspacesPopup.gap

                            border {
                                width: statusBar.lineWidth
                                color: statusBar.borderColor
                            }
                            Text {
                                text: "工作区切换"
                                width:  workspacesPopup.contextWidth
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
                            implicitWidth:  workspacesPopup.contextWidth
                            anchors.top: workspacesPopupTitle.bottom
                            anchors.topMargin: workspacesPopup.gap
                            anchors.left: parent.left
                            anchors.leftMargin: workspacesPopup.gap

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
                                        text = "";
                                        focus = false;
                                    }
                                }

                                focus: false
                            }

                            MouseArea {
                                anchors.fill: parent
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
                            implicitWidth:  workspacesPopup.contextWidth
                            radius: statusBar.barGlobalRadius
                            anchors.top: inputWorkspaceSelect.bottom
                            anchors.topMargin: workspacesPopup.gap
                            anchors.left: parent.left
                            anchors.leftMargin: workspacesPopup.gap
                            color: Qt.rgba(83 / 255.0, 134 / 255.0, 103 / 255.0, 0.8)
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
                            anchors.topMargin: workspacesPopup.gap
                            anchors.left: parent.left
                            anchors.leftMargin: workspacesPopup.gap

                            readonly property int itemsPerLine: workspacesPopup.itemsPerRow
                            readonly property int itemCount: workspacesPopupContext.unamedWorkspaces.length
                            readonly property int itemsInLastRow: itemCount % workspacesPopup.itemsPerRow
                            readonly property int emptySlots: itemsInLastRow === 0 ? 0 : workspacesPopup.itemsPerRow - itemsInLastRow
                            readonly property int totalRows: Math.ceil(unamedContextMenu.itemCount * 1.0 / unamedContextMenu.itemsPerLine * 1.0)
                            implicitHeight: unamedContextMenu.totalRows * workspacesPopup.itemSize + (unamedContextMenu.totalRows > 0 ? (unamedContextMenu.totalRows - 1) * workspacesPopup.gridSpacing : 0)
                            implicitWidth:  workspacesPopup.contextWidth
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
                                        radius: workspacesPopup.itemSize / 2
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
                                            hoverEnabled: true
                                            onClicked: (mouse) => {
                                                if (!modelData.active) {
                                                    Hyprland.dispatch("workspace " + modelData.name);
                                                    workspacesPopupLoader.close();
                                                }
                                                mouse.accepted = true;
                                            }
                                            onEntered: {
                                                color = workspacesPopup.selectColor;
                                            }
                                            onExited: {
                                                color = modelData.active ? "#8FBCBB" : workspacesPopup.normalColor;
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
                            id: workspacesPopupNamedTitle
                            anchors.top: unamedContextMenu.bottom
                            anchors.topMargin: workspacesPopup.gap
                            anchors.left: parent.left
                            anchors.leftMargin: workspacesPopup.gap
                            implicitHeight: statusBar.barHeight
                            implicitWidth:  workspacesPopup.contextWidth
                            radius: statusBar.barGlobalRadius
                            visible: workspacesPopupContext.namedWorkspaces.length > 0 ? true : false
                            color: Qt.rgba(83 / 255.0, 134 / 255.0, 103 / 255.0, 0.8)
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
                            width:  workspacesPopup.contextWidth
                            implicitHeight: workspacesPopupContext.namedWorkspaces.length * statusBar.barHeight
                            spacing: workspacesPopup.gridSpacing
                            anchors.top: workspacesPopupNamedTitle.bottom
                            anchors.topMargin: workspacesPopup.gap
                            anchors.left: parent.left
                            anchors.leftMargin: workspacesPopup.gap
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
                                        hoverEnabled: true
                                        onClicked: (mouse) => {
                                            if (!modelData.active) {
                                                Hyprland.dispatch("workspace " + modelData.name);
                                                workspacesPopupLoader.close();
                                            }
                                            mouse.accepted = true;
                                        }
                                        onEntered: {
                                            color = workspacesPopup.selectColor;
                                        }
                                        onExited: {
                                            color = modelData.active ? "#8FBCBB" : workspacesPopup.normalColor;
                                        }
                                    }
                                }
                            }
                        }

                        Rectangle {
                            id: workspacesPopupSpecialTitle
                            anchors.top: namedWorkspaceContext.bottom
                            anchors.topMargin: workspacesPopup.gap
                            anchors.left: parent.left
                            anchors.leftMargin: workspacesPopup.gap
                            implicitHeight: statusBar.barHeight
                            implicitWidth:  workspacesPopup.contextWidth
                            radius: statusBar.barGlobalRadius
                            visible: workspacesPopupContext.specialWorkspaces.length > 0 ? true : false
                            color: Qt.rgba(83 / 255.0, 134 / 255.0, 103 / 255.0, 0.8)

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
                            implicitWidth:  workspacesPopup.contextWidth
                            implicitHeight: workspacesPopupContext.specialWorkspaces.length * statusBar.barHeight
                            spacing: workspacesPopup.gridSpacing
                            anchors.top: workspacesPopupSpecialTitle.bottom
                            anchors.topMargin: workspacesPopup.gap
                            anchors.left: parent.left
                            anchors.leftMargin: workspacesPopup.gap
                            visible: workspacesPopupContext.specialWorkspaces.length > 0 ? true : false

                            Repeater {
                                model: workspacesPopupContext.specialWorkspaces
                                Rectangle {
                                    implicitWidth: namedWorkspaceContext.implicitWidth
                                    implicitHeight: workspacesPopup.itemSize
                                    radius: statusBar.barGlobalRadius
                                    color: workspacesPopup.normalColor

                                    function getSpecialWorkspaceName(spacialWorkspaceName) {
                                        if (spacialWorkspaceName.startsWith("special:")) {
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
                                        hoverEnabled: true
                                        onClicked: (mouse) => {
                                            Hyprland.dispatch("togglespecialworkspace " + getSpecialWorkspaceName(modelData.name));
                                            workspacesPopupLoader.close();
                                            mouse.accepted = true;
                                        }
                                        onEntered: {
                                            color = workspacesPopup.selectColor;
                                        }
                                        onExited: {
                                            color = workspacesPopup.normalColor;
                                        }
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
                readonly property int iconSize: 20

                anchors {
                    top: parent.top
                    topMargin: 10
                    right: parent.right
                    rightMargin: 20
                    verticalCenter: parent.verticalCenter
                }

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

                                source: {
                                    if (modelData.icon.includes("input-keyboard-symbolic")) {
                                        return "../assets/us-keyboard-input-white.svg"
                                    } else {
                                        return modelData.icon;
                                    }
                                }

                                width: statusBar.iconSize - 10
                                height: statusBar.iconSize - 10

                                fillMode: Image.PreserveAspectFit

                                MouseArea {
                                    id: trayMouseArea
                                    anchors.fill: parent

                                    hoverEnabled: true
                                    acceptedButtons: Qt.LeftButton | Qt.RightButton

                                    onClicked: (mouse) => {
                                        if (mouse.button === Qt.LeftButton) {
                                            modelData.activate();
                                        }
                                        mouse.accepted = true;
                                    }

                                    onPressed: {
                                        if (mouse.button === Qt.RightButton) {
                                            if (modelData.hasMenu) {
                                                var centerXLocal = trayItemRect.implicitWidth / 2;
                                                var centerYLocal = trayItemRect.implicitHeight / 2;
                                                var centerGlobalPoint = trayMouseArea.mapToItem(null, centerXLocal, centerYLocal);
                                                menuLoader.active = true;
                                                menuLoader.set_fcitx_flag(modelData.title === "输入法");
                                                menuLoader.open(centerGlobalPoint.x, centerGlobalPoint.y + 15);
                                            }
                                        }

                                        mouse.accepted = true;
                                    }

                                    onExited: {
                                        toolTip.active = false;
                                        delayOpenTimer.stop();
                                    }

                                    onPositionChanged: {
                                        var centerXLocal = trayItemRect.implicitWidth / 2;
                                        var centerYLocal = trayItemRect.implicitHeight / 2;
                                        var centerGlobalPoint = trayMouseArea.mapToItem(null, centerXLocal, centerYLocal);
                                        toolTip.x = centerGlobalPoint.x;
                                        toolTip.y = centerGlobalPoint.y + 20;
                                        toolTip.title = modelData.tooltipTitle != "" ? modelData.tooltipTitle : modelData.title;
                                        toolTip.text = modelData.tooltipDescription;
                                        delayOpenTimer.start();
                                        mouse.accepted = true;
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
                                    active: false

                                    function open(x,y) {
                                        active = true;
                                        item.x = x;
                                        item.y = y;
                                        item.open();
                                    }

                                    function close() {
                                        item.close();
                                        active = false;
                                    }

                                    function set_fcitx_flag(is_fcitx) {
                                        item.fcitx = is_fcitx;
                                    }

                                    sourceComponent: SystemTrayMenu {
                                        id: menu
                                        window: statusBar
                                        menu: modelData.menu
                                        iconSize: trayContext.iconSize
                                        onTrigger: {
                                            menuLoader.close();
                                        }
                                    }
                                }

                                Timer {
                                    id: delayOpenTimer
                                    interval: 1000
                                    repeat: false
                                    onTriggered: {
                                        toolTip.active = true;
                                    }
                                }
                            }
                        }
                    }
                }
            }

            Rectangle {
                id: memAndCPU
                implicitHeight: statusBar.implicitHeight
                implicitWidth: contextMemAndCPU.implicitWidth + 10
                visible: true

                property string cpuUsage: "..."
                property string memUsage: "..."

                anchors {
                    top: parent.top
                    topMargin: 10
                    right: trayContext.left
                    rightMargin: 10
                    verticalCenter: parent.verticalCenter
                }

                color: statusBar.barNormalColor
                radius: statusBar.barGlobalRadius
                border {
                    width: statusBar.lineWidth
                    color: statusBar.borderColor
                }

                RowLayout {
                    id: contextMemAndCPU
                    anchors.fill: parent
                    spacing: 10
                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 10
                        text: "CPU: " + memAndCPU.cpuUsage
                        color: statusBar.textColor
                        font.pointSize: statusBar.fontSize
                    }
                    Text {
                        text: "RAM: " + memAndCPU.memUsage
                        color: statusBar.textColor
                        font.pointSize: statusBar.fontSize
                    }
                }

                Process {
                    id: memProcess

                    command: ["free", "-g"]
                    running: false

                    stdout: StdioCollector {
                        onStreamFinished: {
                            const lines = this.text.split('\n');
                            if (lines.length > 1) {
                                const memLine = lines[1].replace(/\s+/g, ' ').trim().split(' ');
                                if (memLine.length >= 4) {
                                    const total = parseInt(memLine[1]);
                                    const used = parseInt(memLine[2]);
                                    const available = parseInt(memLine[6]);

                                    memAndCPU.memUsage = `${used}GB / ${total}GB (${(used/total*100).toFixed(1)}%)`;
                                }
                            }
                        }
                    }
                }

                Process {
                    id: cpuProcess
                    command: ["iostat", "-c", "1", "2", "-o", "JSON"]
                    running: false
                    stdout: StdioCollector {
                        onStreamFinished: {
                            try {
                                const jsonObject = JSON.parse(this.text);
                                const statsArray = jsonObject.sysstat.hosts[0].statistics;
                                if (statsArray && statsArray.length > 0) {
                                    const latestStats = statsArray[statsArray.length - 1];
                                    const avgCpu = latestStats["avg-cpu"];

                                    if (avgCpu && avgCpu.idle !== undefined) {
                                        const idle = parseFloat(avgCpu.idle);
                                        const usage = 100.0 - idle;

                                        memAndCPU.cpuUsage = `${usage.toFixed(1)}%`;
                                    } else {
                                        memAndCPU.cpuUsage = "JSON Structure Error";
                                    }
                                } else {
                                    memAndCPU.cpuUsage = "N/A";
                                }
                            } catch (e) {
                                memAndCPU.cpuUsage = "JSON Parser Error";
                                console.error("Failed to parse iostat JSON:", e.message);
                            }
                        }
                    }
                }

                Timer {
                    interval: 2000
                    running: true
                    repeat: true
                    onTriggered: {
                        memProcess.running = true;
                        cpuProcess.running = true;
                    }
                }
            }

            Rectangle {
                id: datetime
                implicitHeight: statusBar.implicitHeight
                implicitWidth: contextDatetime.implicitWidth + 10
                visible: true

                property string date: "YYYY年MM月DD日"
                property string time: "HH:mm:ss "

                anchors {
                    top: parent.top
                    topMargin: 10
                    left: currentWorkspaceContext.right
                    leftMargin: 10
                    verticalCenter: parent.verticalCenter
                }

                color: statusBar.barNormalColor
                radius: statusBar.barGlobalRadius
                border {
                    width: statusBar.lineWidth
                    color: statusBar.borderColor
                }

                RowLayout {
                    id: contextDatetime
                    anchors.fill: parent
                    spacing: 10

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 10
                        text: datetime.date
                        color: statusBar.textColor
                        font.pointSize: statusBar.fontSize
                    }
                    Text {
                        text: datetime.time
                        color: statusBar.textColor
                        font.pointSize: statusBar.fontSize
                    }
                }

                function updateTime() {
                    const now = new Date();
                    time = Qt.formatTime(now, "HH:mm:ss ");
                    date = Qt.formatDate(now, "yyyy年MM月dd日");
                }

                Timer {
                    interval: 500
                    running: true
                    repeat: true
                    triggeredOnStart: true

                    onTriggered: {
                        datetime.updateTime();
                    }
                }
            }

            Rectangle {
                id: audioControl
                implicitHeight: statusBar.implicitHeight
                implicitWidth: contextAudioControl.implicitWidth + 10
                visible: true

                anchors {
                    top: parent.top
                    topMargin: 10
                    right: memAndCPU.left
                    rightMargin: 10
                    verticalCenter: parent.verticalCenter
                }

                property int currentVolume: -1
                property bool isMuted: false
                property string mixerControlName: "PCM"

                color: statusBar.barNormalColor
                radius: statusBar.barGlobalRadius
                border {
                    width: statusBar.lineWidth
                    color: statusBar.borderColor
                }

                RowLayout {
                    id: contextAudioControl
                    anchors.fill: parent
                    spacing: 10

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 10
                        text: audioControl.currentVolume < 0 ? "错误: 音量数据无效   " : "音量: " + audioControl.currentVolume + "%   "
                        color: audioControl.isMuted ? "red" : statusBar.textColor
                        font.pointSize: statusBar.fontSize
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredWidth: 80
                        Layout.preferredHeight: 6
                        radius: 3
                        color: "#444444"
                        anchors.verticalCenter: parent.verticalCenter

                        Rectangle {
                            width: parent.width * (audioControl.currentVolume / 100)
                            height: parent.height
                            radius: 3
                            color: audioControl.isMuted ? "red" : "#2ecc71"
                        }
                    }

                    Text {
                        text: "静音状态: " + (audioControl.isMuted ? "\uf6a9 已静音   " : "\uf028 未静音   ")
                        color: audioControl.isMuted ? "red" : statusBar.textColor
                        font.pointSize: statusBar.fontSize
                        visible: audioControl.currentVolume < 0 ? false : true
                    }
                }
            }

            Process {
                id: getAmixer
                command: ["amixer", "get", audioControl.mixerControlName]
                running: false

                stdout: StdioCollector {
                    onStreamFinished: {
                        var output = text;
                        var volumeMatch = output.match(/\[(\d+)%\]/);
                        var muteMatch = output.match(/\[(on|off)\]/);

                        if (volumeMatch && volumeMatch[1]) {
                            Qt.callLater(function() {
                                audioControl.currentVolume = parseInt(volumeMatch[1]);
                            });
                        }

                        if (muteMatch && muteMatch[1]) {
                            Qt.callLater(function() {
                                audioControl.isMuted = (muteMatch[1] === "off");
                            });
                        }
                    }
                }
            }

            Process {
                id: muteToggle
                command: ["amixer", "set", audioControl.mixerControlName, "toggle"]
                running: false

                stdout: StdioCollector {
                    onStreamFinished: {
                        audioTimer.restart();
                    }
                }
            }

            Process {
                id: pavuControl
                command: "pavucontrol"
                running: false
            }

            Process {
                id: volumeUp
                command: ["amixer", "set", audioControl.mixerControlName, "1%+"]
                running: false

                stdout: StdioCollector {
                    onStreamFinished: {
                        getAmixer.running = true;
                    }
                }
            }

            Process {
                id: volumeDown
                command: ["amixer", "set", audioControl.mixerControlName, "1%-"]
                running: false

                stdout: StdioCollector {
                    onStreamFinished: {
                        getAmixer.running = true;
                    }
                }
            }

            Timer {
                id: audioTimer
                interval: 3000
                repeat: true
                running: true
                triggeredOnStart: true

                onTriggered: {
                    getAmixer.running = true
                }
            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: {
                    if (mouse.button === Qt.LeftButton) {
                        muteToggleProcess.running = true;
                    } else if (mouse.button === Qt.RightButton) {
                        pavuControl.running = true;
                    }
                }

                onWheel: (wheel) => {
                    wheel.accepted = true;
                    if (wheel.angleDelta.y > 0) {
                        volumeUp.running = true;
                    } else if (wheel.angleDelta.y < 0) {
                        volumeDown.running = true;
                    }
                }
            }

            Rectangle {
                id: lockControl
                implicitHeight: statusBar.implicitHeight
                implicitWidth: contextLockControl.implicitWidth + 10
                visible: true

                anchors {
                    top: parent.top
                    topMargin: 10
                    left: datetime.right
                    leftMargin: 10
                    verticalCenter: parent.verticalCenter
                }

                property string status: "Disabled"

                color: statusBar.barNormalColor
                radius: statusBar.barGlobalRadius
                border {
                    width: statusBar.lineWidth
                    color: statusBar.borderColor
                }

                Process {
                    id: getLockStatus
                    command: ["/home/jack/.config/waybar/status_hyprlock.fish"]
                    running: false
                    stdout: StdioCollector {
                        onStreamFinished: {
                            var output = text;
                            lockControl.status = output.replace(/[\r\n]/g, "");
                        }
                    }
                }

                Text {
                    id: contextLockControl
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    anchors.top: parent.top
                    anchors.topMargin: 5
                    text: lockControl.status + "   "
                    color: statusBar.textColor
                    font.pointSize: statusBar.fontSize
                }

                Timer {
                    interval: 3000
                    repeat: true
                    running: true
                    triggeredOnStart: true
                    onTriggered: {
                        getLockStatus.running = true;
                    }
                }
            }
        }
    }
}
