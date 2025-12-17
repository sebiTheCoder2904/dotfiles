import Quickshell
import Quickshell.Io
import QtQuick
import Quickshell.Services.Pipewire

Rectangle {
    id: volumeSliderContainer

    implicitHeight: volumeIndicator.height + 30
    implicitWidth: volumeIndicator.width + 10

    anchors {
        right: parent.right
        bottom: parent.bottom

        margins: 10
        bottomMargin: 100
    }
    radius: implicitWidth / 2

    color: '#25afafaf'


    Rectangle {
        id: volumeIndicator

        PwObjectTracker {
            objects: [Pipewire.defaultAudioSink]
        }

        Connections {
            target: Pipewire.defaultAudioSink?.audio
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
                if (Pipewire.defaultAudioSink && Pipewire.defaultAudioSink.audio) {
                    if (Pipewire.defaultAudioSink.audio.volume <= 1.0) {
                        if (wheel.angleDelta.y > 0) {
                            Pipewire.defaultAudioSink.audio.volume = Pipewire.defaultAudioSink.audio.volume + 0.05;
                        } else {
                            Pipewire.defaultAudioSink.audio.volume = Pipewire.defaultAudioSink.audio.volume - 0.05;
                        }
                    }
                    if (Pipewire.defaultAudioSink.audio.volume > 1.0) {
                        Pipewire.defaultAudioSink.audio.volume = 1.0;
                    }
                }
            }
            onClicked: {
                // console.log(((100 - mouseY) / 100).toFixed(2));
                if (Pipewire.defaultAudioSink && Pipewire.defaultAudioSink.audio) {
                    Pipewire.defaultAudioSink.audio.volume = ((100 - mouseY) / 100).toFixed(2);
                }
            }

            // console.log("Margins left set to: " + margins.left);

        }

        Rectangle {
            id: fillRectangle
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }
            implicitHeight: parent.height * (Pipewire.defaultAudioSink?.audio.volume ?? 0)

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
