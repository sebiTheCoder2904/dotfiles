import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts 1.15
import Quickshell.Services.Pipewire


Rectangle {
    id: audioMixerContainer

    property int volumeSliderHeight: 230

    implicitHeight: volumeSliderHeight + 30
    // implicitWidth: volumeSliderHeight + 100

    anchors {
        right: parent.right
        left: parent.left
        bottom: parent.bottom

        margins: 10
        rightMargin: 50
        bottomMargin: 100 - ((audioMixerContainer.implicitHeight - volumeSliderHeight) / 2)      
    }

    color: '#13afafaf'
    radius: 15


    function findSinkById(id) {
        var lists = [Pipewire && Pipewire.sinks, Pipewire && Pipewire.audioSinks, Pipewire && Pipewire.outputs, Pipewire && Pipewire.audioOutputs];
        for (var li = 0; li < lists.length; ++li) {
            var list = lists[li];
            if (!list) continue;
            for (var i = 0; i < list.length; ++i) {
                var s = list[i];
                if (!s) continue;
                // some bindings expose node object directly, sometimes under .audio
                var candidate = (s.audio !== undefined) ? s.audio : s;
                if ((s.id !== undefined && s.id === id) || (candidate.id !== undefined && candidate.id === id)) {
                    return candidate;
                }
            }
        }
        return null;
    }

    function findSinkByNamePart(part) {
        if (!part) return null;
        var needle = part.toLowerCase();
        var lists = [Pipewire && Pipewire.sinks, Pipewire && Pipewire.audioSinks, Pipewire && Pipewire.outputs, Pipewire && Pipewire.audioOutputs];
        for (var li = 0; li < lists.length; ++li) {
            var list = lists[li];
            if (!list) continue;
            for (var i = 0; i < list.length; ++i) {
                var s = list[i];
                if (!s) continue;
                var candidate = (s.audio !== undefined) ? s.audio : s;
                var name = (s.name || s.description || candidate.name || candidate.description || "").toString().toLowerCase();
                if (name.indexOf(needle) !== -1) return candidate;
            }
        }
        return null;
    }

    // use RowLayout so children can share available width equally
    RowLayout {
        id: slidersRow
        anchors.fill: parent
        anchors.margins: 6     // smaller outer margin
        spacing: 12

        // small fixed gap to the left wall
        Item { Layout.preferredWidth: 8 }

        VolumeSlider {
            id: audioMixerVolumeSlider1
            implicitHeight: volumeSliderHeight
            Layout.preferredWidth: 20
            Layout.alignment: Qt.AlignVCenter
        }

        // flexible spacer between sliders
        Item { Layout.fillWidth: true }

        VolumeSlider {
            id: audioMixerVolumeSlider2
            implicitHeight: volumeSliderHeight
            Layout.preferredWidth: 20
            Layout.alignment: Qt.AlignVCenter
        }

        Item { Layout.fillWidth: true }

        VolumeSlider {
            id: audioMixerVolumeSlider3
            // prefer name-based lookup, fallback to numeric id, fallback to default sink
            whichSink: findSinkByNamePart("Front Headphones") || findSinkById(104) || (Pipewire.defaultAudioSink && Pipewire.defaultAudioSink.audio) || null

            implicitHeight: volumeSliderHeight
            Layout.preferredWidth: 20
            Layout.alignment: Qt.AlignVCenter
        }

        // small fixed gap to the right wall
        Item { Layout.preferredWidth: 8 }
    }

    
}
