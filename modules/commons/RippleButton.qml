import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls

Button {
    id: root
    readonly property int radius: 15
    readonly property int borderLineWidth: 1
    readonly property color borderLineColor: "white"

    Rectangle {
        id: buttonContext
        radius: root.radius
        border {
            width: root.borderLineWidth
            color: root.borderLineColor
        }
    }
}
