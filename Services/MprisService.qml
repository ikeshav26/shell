pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Mpris

Singleton {
    id: root

    property alias activePlayer: instance.activePlayer
    property bool isPlaying: activePlayer ? activePlayer.playbackState === MprisPlaybackState.Playing : false
    
    // Track Info
    property string title: activePlayer ? activePlayer.trackTitle : "No Media"
    property string artist: activePlayer ? activePlayer.trackArtist : ""
    property string album: activePlayer ? activePlayer.trackAlbum : ""
    property string artUrl: activePlayer ? activePlayer.trackArtUrl : ""
    
    // Internal management to auto-select player
    QtObject {
        id: instance
        property var players: Mpris.players.values
        property var activePlayer: null
    }

    function updateActivePlayer() {
        const players = Mpris.players.values
        const playing = players.find(p => p.playbackState === MprisPlaybackState.Playing)
        
        if (playing) {
            instance.activePlayer = playing
        } else if (players.length > 0) {
            // Keep current if it's still valid, otherwise switch to first
            if (!instance.activePlayer || !players.includes(instance.activePlayer)) {
                instance.activePlayer = players[0]
            }
        } else {
            instance.activePlayer = null
        }
    }

    // Monitor for changes
    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: updateActivePlayer()
    }
    
    Connections {
        target: Mpris.players
        function onValuesChanged() { updateActivePlayer() }
    }
    
    Component.onCompleted: updateActivePlayer()

    
    function playPause() {
        if (activePlayer && activePlayer.canTogglePlaying) activePlayer.togglePlaying()
    }
    
    function next() {
        if (activePlayer && activePlayer.canGoNext) activePlayer.next()
    }
    
    function previous() {
        if (activePlayer && activePlayer.canGoPrevious) activePlayer.previous()
    }
}
