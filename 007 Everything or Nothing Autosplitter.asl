// 007 James Bond Everything or Nothing Autosplitter
// For Dolphin & Retroarch - requires emu-helper-v3
// Created by NickRPGreen 

state("LiveSplit") {}

startup {
    //Creates a persistent instance of the GameCube class (for Dolphin and Retroarch)
	Assembly.Load(File.ReadAllBytes("Components/emu-help-v3")).CreateInstance("GCN");
    vars.GameState = vars.Helper.Make<uint>(0x80352644);
    vars.Level = vars.Helper.Make<ushort>(0x803765f0);
    vars.inLevel = false;

    settings.Add("midsplits", false, "Include in-level splits");
    settings.SetToolTip("midsplits", "Include splits for any in-level area changes, such as Boss Fights and Leap of Faith");
    settings.Add("splitTime", false, "Split on level end");
    settings.SetToolTip("splitTime", "Leave unchecked to split on selecting a new level");
}

start {
    return vars.GameState.Current == 5 && (vars.GameState.Old == 2 || vars.GameState.Old == 3); 
}

onStart {
    // Variable for tracking whether a level has started so midsplits work correctly
    vars.inLevel = false;
}

update {
    current.GameState = vars.GameState.Current;
    current.Level = vars.Level.Current;
}

split {
    // Final split on final cutscene starting
    if (vars.GameState.Current == 6 && vars.GameState.Old == 5 && vars.Level.Current == 33054) return true;

    if(vars.inLevel){
        // Check for end of shooter level
        if (vars.GameState.Current == 2 && (vars.GameState.Old == 5 || vars.GameState.Old == 6)) {
            vars.inLevel = false;
            if(settings["splitTime"]) return true;
        }
        // Check for end of a vehicle level
        else if(vars.GameState.Current == 0 && vars.GameState.Old == 2137250680) {
            vars.inLevel = false;
            if(settings["splitTime"]) return true;
        }
        // Midsplits
        else if(vars.Level.Current > 0 && vars.Level.Old == 0 && settings["midsplits"]) return true;
    }
    else {
        // Check for start of level
        if (vars.GameState.Current == 5 && vars.GameState.Old == 3 && !settings["splitTime"]) return true;
        // Check if midsplits logic has triggered at the start of the level
        else if(vars.Level.Current > 0 && vars.Level.Old == 0 && settings["midsplits"]) vars.inLevel = true;
    }
}

shutdown {
    vars.Helper.Dispose();
}

