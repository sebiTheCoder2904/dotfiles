import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick

Rectangle {
    id: appLauncherContainer
    width: 400
    height: 400
    color: "#222"
    radius: 16

    property var appList: []

    function loadApps() {
        var xhr = new XMLHttpRequest();
        xhr.open("GET", "/home/sebi/.config/quickshell/apps.json");
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                try {
                    appLauncherContainer.appList = JSON.parse(xhr.responseText);
                    console.log("Loaded apps.json:", xhr.responseText);
                    console.log("Parsed appList:", JSON.stringify(appLauncherContainer.appList));
                } catch (e) {
                    console.log("Failed to parse apps.json:", e);
                }
            }
        }
        xhr.send();
    }

    Component.onCompleted: {
        loadApps();
    }

    GridView {
        anchors.fill: parent
        cellWidth: 80
        cellHeight: 100
        model: appList
        delegate: Rectangle {
            width: 80
            height: 100
            color: "transparent"
            visible: model.icon !== undefined && model.icon !== ""

            Column {
                anchors.centerIn: parent
                spacing: 6

                Image {
                    source: model.icon ? model.icon : ""
                    width: 48
                    height: 48
                    fillMode: Image.PreserveAspectFit
                    onStatusChanged: {
                        console.log("Image status for", model.icon, ":", status);
                    }
                }

                Text {
                    text: model.name ? model.name : ""
                    color: "white"
                    font.pixelSize: 14
                    horizontalAlignment: Text.AlignHCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    Component.onCompleted: {
                        console.log("Displaying app:", text);
                    }
                }
            }
        }
    }
}