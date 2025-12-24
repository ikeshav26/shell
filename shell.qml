import Quickshell
import qs.Services
import qs.Modules.Background
import qs.Modules.Bar
import qs.Modules.Overlays
import qs.Modules.Lock

ShellRoot {
    id: root

    // Centralized Context (Services & State)
    Context {
        id: ctx
    }

    // Background
    Background {}

    // Lock Screen
    Lock {
        context: ctx
    }

    // Panels, Popups, and IPC
    Overlays {
        context: ctx
    }

    // The Bar
    BarWindow {
        context: ctx
    }
}
