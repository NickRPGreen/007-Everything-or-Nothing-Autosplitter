// 007 James Bond Everything or Nothing Autosplitter
// For Dolphin & Retroarch - requires emu-helper-v3
// Created by NickRPGreen 

state("LiveSplit") {}

startup {
    // Creates a persistent instance of the GameCube class (for Dolphin and Retroarch)
	Assembly.Load(File.ReadAllBytes("Components/emu-help-v3")).CreateInstance("GCN");
    vars.GameState = vars.Helper.Make<uint>(0x80352644);
    vars.Level = vars.Helper.Make<ushort>(0x803765f0);
    
    vars.inLevel = false; // Variable for tracking whether a level has started so midsplits work correctly
    vars.storeLevel = 0; // Variable for tracking which level is active to avoid splitting on death

    settings.Add("midsplits", false, "Include in-level splits");
    settings.SetToolTip("midsplits", "Include splits for any in-level area changes, such as Boss Fights and Leap of Faith");
    settings.Add("splitTime", false, "Split on level end");
    settings.SetToolTip("splitTime", "Leave unchecked to split on selecting a new level");
}

start {
    if(vars.GameState.Current == 5 && (vars.GameState.Old == 2 || vars.GameState.Old == 3)){
        vars.inLevel = false;
        vars.storeLevel = 33126;
        return true;
    }
}

split {
    // Midsplit
    if(vars.Level.Old == 0 && vars.Level.Current != 0 && vars.Level.Current != vars.storeLevel) {
        vars.storeLevel = vars.Level.Current;
        if(vars.inLevel && settings["midsplits"]) return true;
        else vars.inLevel = true;
    }
    
    // Final split on final cutscene starting
    else if (vars.GameState.Current == 6 && vars.GameState.Old == 5 && vars.Level.Current == 33054) return true;
  
    // Split on Level End
    else if(vars.inLevel){
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
    }

    // Split on Level Start
    else if (vars.GameState.Current == 5 && vars.GameState.Old == 3 && !settings["splitTime"]) return true;
}

shutdown {
    vars.Helper.Dispose();
}
