import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Io
import QtQuick
import QtQuick.Controls

Rectangle {
    id: audioOutputMenu
    // width: 180
    implicitWidth: 180
    height: parent ? parent.height : 220
    color: "#333"
    radius: 10

    property var sinksModel: []
    property int selectedSinkId: -1
    property string wpctlLastCmd: ""    // <-- new helper

    Item {
        anchors.fill: parent

        ListView {
            id: sinksListView
            model: sinksModel
            anchors.fill: parent
            anchors.margins: 8
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            interactive: true
            highlightFollowsCurrentItem: false

            delegate: Rectangle {
                width: sinksListView.width
                height: 32
                radius: 6
                color: (modelData.id === selectedSinkId) ? "#2a8f8f" : "#444"
                border.color: (modelData.id === selectedSinkId) ? "#fff" : "#666"
                border.width: 1

                property int sinkIndex: index

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (modelData && modelData.id) {
                            if (Pipewire && Pipewire.defaultAudioSink && Pipewire.defaultAudioSink.id !== undefined) {
                                console.log("PW-DBG: Pipewire binding present; attempting to set via binding is optional.");
                            }
                            console.log("PW-DBG: setting default sink via wpctl id:", modelData.id);
                            wpctlLastCmd = "set-default";
                            wpctlProc.command = ["wpctl", "set-default", modelData.rawId || modelData.id.toString()];
                            wpctlProc.running = true;
                        }
                    }
                }

                Row {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 8
                    padding: 6

                    Image {
                        source: "audio-speaker-symbolic"
                        width: 16
                        height: 16
                    }
                    Text {
                        text: modelData.name || modelData.description || modelData.id
                        color: "white"
                        font.pixelSize: 13
                        elide: Text.ElideRight
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }
        }

        visible: sinksModel && sinksModel.length > 0
    }

    Text {
        anchors.centerIn: parent
        text: (!sinksModel || sinksModel.length === 0) ? "No audio outputs found" : ""
        color: "white"
        font.pixelSize: 14
        visible: (!sinksModel || sinksModel.length === 0)
    }

    // Process used to run wpctl commands — use 'command' + StdioCollector per other files
    Process {
        id: wpctlProc
        // command set dynamically by code; set running = true to start
        stdout: StdioCollector {
            onStreamFinished: {
                var out = text || "";
                console.log("PW-DBG: wpctl stdout length:", out.length, "for cmd:", audioOutputMenu.wpctlLastCmd);
                if (audioOutputMenu.wpctlLastCmd === "status") {
                    var parsed = audioOutputMenu.parseWpctlStatus(out);
                    if (parsed && parsed.length > 0) {
                        sinksModel = parsed;
                        try {
                            if (Pipewire && Pipewire.defaultAudioSink && Pipewire.defaultAudioSink.id !== undefined) {
                                selectedSinkId = parseInt(Pipewire.defaultAudioSink.id);
                            }
                        } catch (e) { console.log("PW-DBG: selecting default failed:", e); }
                    } else {
                        console.log("PW-DBG: parsed zero sinks from wpctl output");
                    }
                } else if (audioOutputMenu.wpctlLastCmd === "set-default") {
                    // after set-default, refresh list
                    audioOutputMenu.fetchSinksFromWpctl();
                } else {
                    // generic refresh
                    audioOutputMenu.fetchSinksFromWpctl();
                }
            }
        }
    }

    Timer {
        id: pollTimer
        interval: 800
        repeat: true
        running: false
        onTriggered: {
            if (!(sinksModel && sinksModel.length > 0)) fetchSinksFromWpctl();
            else pollTimer.stop();
        }
    }

    function parseWpctlStatus(text) {
        var lines = text.split(/\r?\n/);
        var sinks = [];
        var inSinks = false;
        for (var i = 0; i < lines.length; ++i) {
            var l = lines[i];
            // detect beginning of sinks section (robust, ignore box-drawing)
            if (!inSinks && /Sinks:/i.test(l)) { inSinks = true; continue; }
            if (!inSinks) continue;
            // stop when we hit another top-level section header (e.g. Sources:, Video:, Settings:)
            if (/^\S/.test(l) && /(?:Sources|Video|Settings|Filters|Streams|Devices):/i.test(l)) break;
            if (/^\s*$/.test(l)) continue;
            // detect default marker (*) and id/name
            // examples:
            // " *   44. Easy Effects Sink                   [vol: 0.00]"
            // "    73. USB Audio Speakers                   [vol: 1.00]"
            var def = /^\s*\*\s*/.test(l);
            var m = l.match(/^\s*(?:\*?\s*)?(\d+)\.\s+(.+?)(?:\s+\[|$)/);
            if (m) {
                var id = parseInt(m[1]);
                var name = m[2].trim();
                sinks.push({ id: id, rawId: id.toString(), name: name, default: def });
                continue;
            }
            // fallback: try to capture "<number>.<space><name>" anywhere
            var m2 = l.match(/(\d+)\.\s+([^\[]+)/);
            if (m2) {
                var id2 = parseInt(m2[1]);
                var name2 = m2[2].trim();
                sinks.push({ id: id2, rawId: id2.toString(), name: name2, default: false });
            }
        }
        // try to set selectedSinkId from parsed default marker if available
        for (var j = 0; j < sinks.length; ++j) {
            if (sinks[j].default) {
                selectedSinkId = parseInt(sinks[j].id);
                break;
            }
        }
        return sinks;
    }

    function fetchSinksFromWpctl() {
        try {
            wpctlLastCmd = "status";
            wpctlProc.command = ["wpctl", "status"];
            wpctlProc.running = true;
        } catch (e) {
            console.log("PW-DBG: fetchSinksFromWpctl error:", e);
        }
    }

    Component.onCompleted: {
        // prefer native Pipewire binding if it exposes a list
        if (Pipewire && Pipewire.audioSinks && Pipewire.audioSinks.length !== undefined) {
            var arr = [];
            for (var i = 0; i < Pipewire.audioSinks.length; ++i) arr.push(Pipewire.audioSinks[i]);
            sinksModel = arr;
            if (Pipewire.defaultAudioSink && Pipewire.defaultAudioSink.id !== undefined)
                selectedSinkId = parseInt(Pipewire.defaultAudioSink.id);
            return;
        }
        // fallback to wpctl
        console.log("PW-DBG: falling back to wpctl parsing");
        fetchSinksFromWpctl();
        pollTimer.start();
    }
}