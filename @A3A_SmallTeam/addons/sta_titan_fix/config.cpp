class CfgPatches {
    class STA_sta_titan_fix {
        units[] = {};
        weapons[] = {};
        requiredVersion = 1.68;
        // ace_overpressure required so our overrides apply after ACE sets the
        // base-class defaults — otherwise ACE's later value wins the merge.
        requiredAddons[] = {"cba_main", "ace_overpressure"};
    };
};

// ── Remove ACE overpressure damage from soft-launch Titan launchers ───────────
//
// Both Titan variants are Confined Spaces rated in vanilla, but ACE's overpressure
// system still applies damage — particularly dangerous on slopes where the
// backblast travels downhill into the firer. ACE sets damage = 0.5 on the
// launch_Titan_base/short_base classes (see ace_overpressure/CfgWeapons).
// Setting ace_overpressure_damage = 0 on the user-facing launchers overrides
// the inherited value to zero.

class CfgWeapons {
    class launch_Titan_base;
    class launch_Titan_short_base;

    class launch_Titan_F: launch_Titan_base {
        ace_overpressure_damage = 0;
    };

    class launch_Titan_short_F: launch_Titan_short_base {
        ace_overpressure_damage = 0;
    };
};
