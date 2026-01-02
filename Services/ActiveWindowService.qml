import QtQuick
import Quickshell.Hyprland
import Quickshell.Io

Item {
    // Native binding using Quickshell's Hyprland module
    // This is more efficient than polling 'hyprctl'
    property string title: {
        const active = Hyprland.activeWindow;
        const focusedWs = Hyprland.focusedWorkspace;

        if (!active || !focusedWs) return "";
        
        // Only show title if the active window is on the currently focused workspace
        if (active.workspace.id === focusedWs.id) {
            return active.title;
        }
        
        return "";
    }
}
