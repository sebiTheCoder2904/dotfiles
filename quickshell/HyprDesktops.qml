import Quickshell
import Quickshell.Io
import QtQuick
import Quickshell.Hyprland

Rectangle {
    id: desktopIndicator
    implicitHeight: columnContent.height + 10
    implicitWidth: columnContent.width + 10

    color: '#25afafaf'
    radius: 15

    anchors {
        right: parent.right
        verticalCenter: parent.verticalCenter
        margins: 5
    }

    MouseArea {
        anchors.fill: parent
        onWheel: {
            if (wheel.angleDelta.y < 0) {
                Hyprland.dispatch("workspace " + (Hyprland.focusedWorkspace.id + 1));
            } 
            else {
                Hyprland.dispatch("workspace " + (Hyprland.focusedWorkspace.id - 1)); 
            }
            console.log(wheel.angleDelta.y);
        }
    }

    Column {
        id: columnContent
        spacing: 10
        anchors.centerIn: parent

        Repeater {
            model: Hyprland.workspaces
            delegate: Rectangle {
                visible: modelData.id >= 0 // Only show workspaces with non-negative IDs
                width: 20
                height: 20
                radius: 15
                color: modelData.id === Hyprland.focusedWorkspace.id ? "#ff8800" : '#42cccccc'

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        Hyprland.dispatch("workspace " + modelData.id);
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: modelData.id
                    font.pixelSize: 12
                    font.bold: true
                    color: "white"
                }
            }
        }
    }
}

