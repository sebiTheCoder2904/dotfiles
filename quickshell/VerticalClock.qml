import Quickshell
import Quickshell.Io
import QtQuick

Rectangle {
    id: clockContainer
    implicitWidth: clockText.width + 10
    implicitHeight: clockText.height + 10
    color: '#25afafaf'
    radius: 15

    anchors {
        right: parent.right
        top: parent.top
        margins: 10
    }
    // anchors.centerIn: parent

    Text {
        id: clockText
        text: VerticalClockText.time
        font.pixelSize: 12
        font.bold: true
        color: "white"
        anchors.centerIn: parent
        // Enable text wrapping to handle newlines
    }
}

