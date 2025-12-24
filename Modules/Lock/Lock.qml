import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.Core

Item {
    id: root

    required property var context

    PamAuth {
        id: auth
        onSuccess: lock.locked = false
    }

    WlSessionLock {
        id: lock
        
        // When locked, create a surface for each screen
        LockScreen {
            lock: lock
            pam: auth
            colors: root.context.colors
        }
    }
    
    // IPC Handler to trigger lock
    IpcHandler {
        target: "lock"
        function lock() {
            lock.locked = true
        }
    }
}
