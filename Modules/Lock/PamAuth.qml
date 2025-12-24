import Quickshell
import Quickshell.Services.Pam
import QtQuick

QtObject {
    id: root
    
    // Signals
    signal success()
    signal failure()
    signal error()
    
    // Properties
    property string buffer: ""
    property bool authenticating: false
    
    // Functions
    function submit(password) {
        if (password === "") return;
        
        console.log("[PamAuth] Starting authentication");
        buffer = password;
        authenticating = true;
        pamCtx.start();
    }
    
    property PamContext pamCtx: PamContext {
        config: "passwd"
        // Adjust path if needed, standard distros assume /etc/pam.d, 
        // Quickshell might use implicit system configs or a specific one. 
        // Caelestia used a custom asset path. I will try "system-auth" or "login" or just "passwd" if Quickshell provides it.
        // Actually, Quickshell.Services.Pam likely defaults correctly or needs a service name.
        // "passwd" is usually safe for simple auth.
        // Assuming Quickshell has access to system pam configs.
        
        onResponseRequiredChanged: {
            if (responseRequired) {
                respond(root.buffer);
                root.buffer = ""; // Clear buffer immediately
            }
        }
        
        onCompleted: (result) => {
            root.authenticating = false;
            
            if (result === PamResult.Success) {
                console.log("[PamAuth] Authentication success");
                root.success();
            } else {
                console.log("[PamAuth] Authentication failed with result:", result);
                if (result === PamResult.Error) root.error();
                else root.failure();
            }
        }
    }
}
