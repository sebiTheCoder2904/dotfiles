import QtQuick
import Quickshell



Image {
    id: archLogo
    source: "arch.png" // Ensure arch.png is in the correct directory
    anchors {
        right: parent.right
        bottom: parent.bottom
        margins: 8
    }
    width: 24
    height: 24
    fillMode: Image.PreserveAspectFit

    MouseArea {
        anchors.fill: parent
        onClicked: {
            console.log("Home button clicked");
        }
    } 
}