class CfgPatches {
    class STA_sta_titan_fix {
        units[] = {};
        weapons[] = {};
        requiredVersion = 1.68;
        requiredAddons[] = {"cba_main"};
    };
};

// ── Remove ACE backblast from soft-launch Titan launchers ─────────────────────
//
// Both Titan variants are Confined Spaces rated in vanilla, but ACE's overpressure
// system still applies damage — particularly dangerous on slopes where backblast
// travels downward into the firer. ACE_Overpressure = 0 disables that system
// for these two launchers. Harmless if ACE is not loaded.

class CfgWeapons {
    class Launcher_Base_F;

    class launch_Titan_F: Launcher_Base_F {
        ACE_Overpressure = 0;
    };

    class launch_Titan_short_F: Launcher_Base_F {
        ACE_Overpressure = 0;
    };
};
