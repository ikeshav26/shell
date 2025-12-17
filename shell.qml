import Quickshell
import qs.Services
import qs.Modules.Background
import qs.Modules.Bar
import qs.Modules.Overlays

ShellRoot {
    id: root

    // Centralized Context (Services & State)
    Context {
        id: ctx
    }

    // Background
    Background {}

    // Panels, Popups, and IPC
    Overlays {
        context: ctx
    }

    // The Bar
    BarWindow {
        context: ctx
    }
}
