import Quickshell
import Quickshell.Io
import QtQuick
import Quickshell.Services.Pipewire

Rectangle {
    implicitHeight: audioMixerIndicator.height + 30
    implicitWidth: audioMixerIndicator.width + 10

    // store a reference to the sink object to operate on
    property var whichSink: (Pipewire && Pipewire.defaultAudioSink && Pipewire.defaultAudioSink.audio) ? Pipewire.defaultAudioSink.audio : null

    radius: implicitWidth / 2
    color: '#25afafaf'


    Rectangle {
        id: audioMixerIndicator

        // track the selected sink object so UI updates when it becomes available/changes
        PwObjectTracker {
            objects: [ whichSink ]
        }

        // connect to signals of the selected sink
        Connections {
            target: whichSink
        }

        implicitHeight: 200
        implicitWidth: 10
        color: '#42ffffff'
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 5
        radius: implicitWidth / 2

        MouseArea {
            anchors.fill: parent
            onWheel: {
                if (whichSink && whichSink.volume !== undefined) {
                    var v = whichSink.volume;
                    if (wheel.angleDelta.y > 0) v += 0.05; else v -= 0.05;
                    // clamp between 0 and 1
                    if (v < 0) v = 0;
                    if (v > 1) v = 1;
                    whichSink.volume = parseFloat(v.toFixed(2));
                }
            }
            onClicked: {
                if (whichSink && whichSink.volume !== undefined) {
                    var v = ((100 - mouseY) / 100);
                    if (v < 0) v = 0;
                    if (v > 1) v = 1;
                    whichSink.volume = parseFloat(v.toFixed(2));
                }
            }
        }

        Rectangle {
            id: fillRectangle
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }
            // defensive access to whichSink.volume
            implicitHeight: parent.height * ((whichSink && whichSink.volume !== undefined) ? whichSink.volume : 0)
            radius: parent.implicitWidth / 2
            color: "white"
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: -20
            text: "\uf028" // FontAwesome speaker icon
            font.family: "FontAwesome"
            font.pixelSize: 12
            color: "white"
        }
    }
}