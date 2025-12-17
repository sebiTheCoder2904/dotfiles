// Bar.qml
import Quickshell
import Quickshell.Io
import QtQuick
import Quickshell.Hyprland
import Quickshell.Services.Pipewire  // Add this import

Scope {
    id: root

    IpcHandler {
        target: "barWindow"

        function toggle() {
            barWindow.toggle();
        }
    }

    PanelWindow {
        id: barWindow

        function toggle() {
            if (barWindow.margins.left == 20) {
                barWindow.margins.left = 40 - 500;
            } else {
                barWindow.margins.left = 20;
            }
        }

        color: '#00000000' // Transparent background

        // x: -20 // Move sidebar 20px off the left edge

        anchors {
            top: true
            left: true
            bottom: true
        }
        margins {
            left: 40 - implicitWidth
            top: 20
            bottom: 20
        }

        implicitWidth: 500

        Rectangle {
            anchors.fill: parent
            color: '#b2222222' // Adjust color as needed
            radius: 20    // Set the corner radius
            z: -1         // Ensure background is behind content
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                barWindow.toggle();
            }
        }

        VerticalClock {}

        // ensure the volume slider is declared first so its id exists for anchoring
        BarVolumeSlider {
            id: volumeSliderContainer
        }
        
        BarAudioMixer { 
            id: audioMixerContainer
        }

        // AudioOutputMenu {
        //     anchors {
        //         left: parent.left
        //         leftMargin: 12
        //         right: volumeSliderContainer.left
        //         rightMargin: 10
        //         top: volumeSliderContainer.top
        //         bottom: volumeSliderContainer.bottom
        //     }
        //     // allow the menu to stretch between left edge and the slider
        //     z: 1
        // }

        HyprDesktops {}
        HomeButton {}
    }
}
