/* 
----------------------------
Hi-Fi Rush Autosplitter v0.2
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

    settings.Add("autosplit", true, "Enable Autosplitter - Please select ONLY 1 Preset");
    settings.CurrentDefaultParent = "autosplit";
    settings.Add("autosplit_after_track", true, "After Tracks");
    settings.SetToolTip("autosplit_after_track", "Splits when you load out of a track into either the next level or the hideout.");
    settings.Add("autosplit_before_track", false, "Before Tracks");
    settings.SetToolTip("autosplit_before_track", "Splits when you load into a new track from either the previous level or the hideout.");
    settings.Add("autosplit_chorus", false, "Choruses and After Tracks");
    settings.SetToolTip("autosplit_chorus", "Splits whenever you finish a chorus or finish a track.");

    settings.CurrentDefaultParent = null;
    settings.Add("debug", false, "Debug Mode");
    settings.SetToolTip("debug", "Enables print output in DebugView");

    // ----- Variables ----- //

    vars.LAST_CHECKPOINTS = new List<int> {125, 231, 320, 418, 521, 605, 738, 827, 905, 1021, 1115, 1203};
    vars.EXCLUDE_CHORUSES = new List<string> {"TR01_CR08", "TR02_CR10", "TR03_CR06", "TR03_CR07", "TR04_CR07", "TR05_CR06", "TR06_CR03", "TR07_CR10", "TR08_CR09", "TR09_CR01", "TR10_CR10", "TR12_CR01"};

    // Used in chorus splits
    vars.leftChorus = false;
    // Used in after track splits
    vars.lastTrack = 0;
    // Used in before track splits
    vars.lastSplitTrack = 1;
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
    vars.leftChorus = false;
    vars.lastTrack = 0;
    vars.lastSplitTrack = 1;
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

    // Track autosplitter (Before Track) - split if you entered any track that wasn't the track you were last in.
    if (settings["autosplit_before_track"] && (current.track != 30) && (current.track != -1) && (current.track != vars.lastSplitTrack)) {
        vars.lastSplitTrack = current.track;
        return true;
    }

    // Track autosplitter (After Track) - split when you exit a track while in the last checkpoint and enter into any other track or the hideout.
    if ((settings["autosplit_after_track"] || settings["autosplit_chorus"]) && (vars.LAST_CHECKPOINTS.Contains(old.checkpoint)) && (current.track == -1)) {
        // Saves the last track you were in when you leave a level from the last checkpoint
        vars.lastTrack = old.track;
    } else if ((vars.lastTrack != 0) && (current.track != -1)) {
        // If you don't reload and instead go to another track, split.
        bool split = current.track != vars.lastTrack;
        vars.lastTrack = 0;
        return split;
    }


    // Chorus autosplitter - split if you leave a chorus and remain in the level
    if (settings["autosplit_chorus"] && (current.chorus != old.chorus) && (current.chorus == null) && (!vars.EXCLUDE_CHORUSES.Contains(old.chorus))) {
        // Effectively waits one update, otherwise it will split on reload and death in a chorus
        vars.leftChorus = true;
    }
    if (vars.leftChorus) {
        vars.leftChorus = false;
        // Return true if chorus was completed, returns false if level was reloaded or you died.
        return current.checkpoint != -1;
    }
}

isLoading {
    if (settings["removeLoads"] && vars.hasLoadRemover) {
        return current.isLoading;
    }
}
