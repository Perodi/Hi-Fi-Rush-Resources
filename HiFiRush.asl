/* 
----------------------------
Hi-Fi Rush Autosplitter v0.1
----------------------------
Autosplitter by Perodi
Thanks to Meta, Candle, Vorime, AFSilver, and BoltClock for finding addresses and
working on previous versions and the load remover!
----------------------------
*/

state("Hi-Fi-RUSH", "Unknown") {}
state("Hi-Fi-RUSH", "Release (Xbox)") {
    bool isLoading : 0x6FB800C;
}
state("Hi-Fi-RUSH", "Release (Steam)") {
    bool isLoading : 0x6E1EBC4;
}
state("Hi-Fi-RUSH", "Update 1 (Xbox)") {
    bool isLoading : 0x6FB707C;
}
state("Hi-Fi-RUSH", "Update 1 (Steam)") {
    bool isLoading : 0x6CF1BE4;
}
state("Hi-Fi-RUSH", "Update 2 (Xbox)") {
    bool isLoading : 0x7032BCC;
}
state("Hi-Fi-RUSH", "Update 2 (Steam)") {
    bool isLoading : 0x6D6A1F4;
}
state("Hi-Fi-RUSH", "Update 3 (Xbox)") {
    bool isLoading : 0x703E13C;
}
state("Hi-Fi-RUSH", "Update 3 (Steam)") {
    bool isLoading : 0x71004CC;
}
state("Hi-Fi-RUSH", "Update 4 (Xbox)") {
    bool isLoading : 0x70471CC;
}
state("Hi-Fi-RUSH", "Update 4 (Steam)") {
    bool isLoading : 0x70B650C;
}
state("Hi-Fi-RUSH", "Update 6 (Xbox)") {
    bool isLoading : 0x7091B44;
}
state("Hi-Fi-RUSH", "Update 6 (Steam)") {
    bool isLoading : 0x72644A0;
}
state("Hi-Fi-RUSH", "Update 7 (Steam)") {
    bool isLoading : 0x728C9B8;
}
state("Hi-Fi-RUSH", "Update 8 (Steam)") {
    bool isLoading : 0x72919F8;
    int track : 0x728D6C8, 0x8, 0x240, 0x238;
    int checkpoint : 0x728D6C8, 0x8, 0x240, 0x220;
    string18 chorus : 0x728D6C8, 0x8, 0x240, 0x250, 0x0;
}

startup {
    // ----- Settings ----- //

    settings.Add("removeLoads", true, "Enable Load Remover");

    settings.Add("autosplit", true, "Enable Autosplitter");
    settings.CurrentDefaultParent = "autosplit";
    settings.Add("autosplit_track", true, "Autosplit Tracks");
    settings.SetToolTip("autosplit_track", "Splits when you load into the next track");
    settings.Add("autosplit_chorus", false, "Autosplit Choruses");

    settings.CurrentDefaultParent = null;
    settings.Add("debug", false, "Debug Mode");
    settings.SetToolTip("debug", "Enables print output in DebugView");

    // ----- Variables ----- //

    vars.leftChorus = false;
    vars.trackSplits = Enumerable.Range(2, 11).ToList();
}

init {
    vars.hasLoadRemover = false;
    vars.hasAutospliter = false;

    // Use memory size to determine what version of the game is running.
    switch (modules.First().ModuleMemorySize) {
        case 0x171D7000:
            version = "Release (Xbox)";
            vars.hasLoadRemover = true;
            break;
        case 0x17ED7000:
            version = "Release (Steam)";
            vars.hasLoadRemover = true;
            break;
        case 0x17D47000:
            version = "Update 1 (Xbox)";
            vars.hasLoadRemover = true;
            break;
        case 0x18517000:
            version = "Update 1 (Steam)";
            vars.hasLoadRemover = true;
            break;
        case 0x18050000:
            version = "Update 2 (Xbox)";
            vars.hasLoadRemover = true;
            break;
        case 0x18786000:
            version = "Update 2 (Steam)";
            vars.hasLoadRemover = true;
            break;
        case 0x17816000:
            version = "Update 3 (Xbox)";
            vars.hasLoadRemover = true;
            break;
        case 0x18841000:
            version = "Update 3 (Steam)";
            vars.hasLoadRemover = true;
            break;
        case 0x17902000:
            version = "Update 4 (Xbox)";
            vars.hasLoadRemover = true;
            break;
        case 0x18D50000:
            version = "Update 4 (Steam)";
            vars.hasLoadRemover = true;
            break;
        case 0x18177000:
            version = "Update 6 (Xbox)";
            vars.hasLoadRemover = true;
            break;
        case 0x18C38000:
            version = "Update 6 (Steam)";
            vars.hasLoadRemover = true;
            break;
        case 0x187AA000:
            version = "Update 7 (Steam)";
            vars.hasLoadRemover = true;
            break;
        case 0x188C8000:
            version = "Update 8 (Steam)";
            vars.hasLoadRemover = true;
            vars.hasAutospliter = true;
            break;
        default:
            version = "Unknown";
            break;
    }

    if (settings["debug"]) {
        print(string.Format(
            "Detected Version: \"{0}\"\nMemory Size: 0x{1:X}\nLoad Remover: {2}\nAutosplitter: {3}",
            version,
            modules.First().ModuleMemorySize,
            vars.hasLoadRemover,
            vars.hasAutospliter
        ));
    }
}

start {
    if (vars.hasAutospliter && settings["autosplit"]) {
        // Starts timer upon gaining control of Chai in Track 1
        return (old.checkpoint != current.checkpoint) && (current.checkpoint == 100);
    }
}

onStart {
    // Reset variables when timer is started
    vars.trackSplits = Enumerable.Range(2, 11).ToList();
    vars.leftChorus = false;
}

update {
    // Return base case if version isn't supported due to missing variables.
    if (!vars.hasLoadRemover && !vars.hasAutospliter) {
        return;
    }

    if (vars.hasLoadRemover) {
        // Load remover debug output
        if (settings["debug"] && (old.isLoading != current.isLoading)) {
            string loadingMessage = current.isLoading ? "Game is loading..." : "Game finished loading!";
            print(loadingMessage);
        }
    }

    if (vars.hasAutospliter) {
        // Autosplitter debug output
        if (settings["debug"] && (old.track != current.track)) {
            print(string.Format("track changed to {0}", current.track));
        }
        if (settings["debug"] && (old.checkpoint != current.checkpoint)) {
            print(string.Format("checkpoint changed to {0}", current.checkpoint));
        }
        if (settings["debug"] && (old.chorus != current.chorus) && (current.chorus != null)) {
            print(string.Format("chorus changed to \"{0}\"", current.chorus));
        }
    }
}

split {
    // Base return case if autosplitter isn't available or setting is disabled
    if (!vars.hasAutospliter || !settings["autosplit"]) {
        return false;
    }

    // Track autosplitter (After Hideout) - split if you entered the next track in the list.
    if (settings["autosplit_track"] && (current.track == vars.trackSplits[0])) {
        vars.trackSplits.RemoveAt(0);
        return true;
    }

    // Track autosplitter (Enter Hideout) - split when you exit a track into the hideout.

    // Chorus autosplitter - split if you leave a chorus and remain in the level
    if (settings["autosplit_chorus"] && (current.chorus != old.chorus) && (current.chorus == null)) {
        // Effectively waits one update, otherwise it will split on reload and death in a chorus
        vars.leftChorus = true;
    }
    if (vars.leftChorus) {
        vars.leftChorus = false;
        // Return true if chorus was completed, returns false if level was reloaded
        return current.checkpoint != -1;
    }
}

isLoading {
    if (settings["removeLoads"] && vars.hasLoadRemover) {
        return current.isLoading;
    }
}
