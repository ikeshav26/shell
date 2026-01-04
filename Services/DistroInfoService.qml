import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: root

    property string name: "Linux"
    property string url: "https://kernel.org"
    property string icon: "" // Default Tux icon
    property string bugUrl: ""
    property string supportUrl: ""
    property string distroId: ""

    property string _buffer: ""

    // Execute cat /etc/os-release to get system details
    property var _proc: Process {
        command: ["cat", "/etc/os-release"]
        running: true
        
        stdout: SplitParser {
            onRead: (data) => {
                root._buffer += data
            }
        }

        onExited: (code) => {
            if (code === 0) {
                root._parse(root._buffer)
            }
        }
    }

    function _parse(data) {
        const lines = data.split("\n");
        let info = {};
        
        for (let i = 0; i < lines.length; i++) {
            const line = lines[i].trim();
            if (!line || line.startsWith("#")) continue;
            
            const eqIdx = line.indexOf("=");
            if (eqIdx === -1) continue;
            
            const key = line.substring(0, eqIdx);
            let val = line.substring(eqIdx + 1);
            
            // Strip quotes
            if ((val.startsWith('"') && val.endsWith('"')) || (val.startsWith("'") && val.endsWith("'"))) {
                val = val.substring(1, val.length - 1);
            }
            
            info[key] = val;
        }

        // 1. Name
        if (info["PRETTY_NAME"]) root.name = info["PRETTY_NAME"];
        else if (info["NAME"]) root.name = info["NAME"];

        // 2. URLs
        if (info["HOME_URL"]) root.url = info["HOME_URL"];
        
        if (info["BUG_REPORT_URL"]) root.bugUrl = info["BUG_REPORT_URL"];
        else root.bugUrl = root.url;

        if (info["SUPPORT_URL"]) root.supportUrl = info["SUPPORT_URL"];
        else root.supportUrl = root.url;

        // 3. Icon Mapping
        if (info["ID"]) {
            root.distroId = info["ID"];
            root.icon = _getIcon(info["ID"]);
        }
    }

    function _getIcon(id) {
        const map = {
            "arch": "",
            "debian": "",
            "ubuntu": "",
            "fedora": "",
            "opensuse": "",
            "nixos": "",
            "gentoo": "",
            "linuxmint": "",
            "elementary": "",
            "manjaro": "",
            "endeavouros": "",
            "kali": "",
            "void": "",
            "alpine": "",
            "pop": "",
            "raspbian": "",
            "centos": "",
            "slackware": "",
            "rhel": ""
        };
        
        const lowerId = id.toLowerCase();
        // Exact match
        if (map[lowerId]) return map[lowerId];
        
        // Partial match
        for (let key in map) {
            if (lowerId.indexOf(key) !== -1) return map[key];
        }
        
        return ""; // Fallback Tux
    }
}