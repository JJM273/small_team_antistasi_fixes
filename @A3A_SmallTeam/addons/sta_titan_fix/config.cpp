class CfgPatches {
    class STA_sta_titan_fix {
        units[] = {};
        weapons[] = {};
        requiredVersion = 1.68;
        // ace_overpressure required so we load after ACE's base-class defaults.
        requiredAddons[] = {"cba_main", "ace_overpressure"};
    };
};

// ── Remove ACE overpressure damage from soft-launch Titan launchers ───────────
//
// Both Titan variants are Confined Spaces rated in vanilla, but ACE's
// overpressure system still applies damage — particularly dangerous on slopes
// where the backblast travels downhill into the firer.
//
// ACE picks the source (weapon / magazine / ammo) with the highest
// ace_overpressure_priority and reads ALL four values (angle/range/damage/
// offset) from that source — it's not a per-property merge. Patching just the
// weapon failed in-game even though ACE only sets priority = 1 on the launcher
// base. The reliable pattern (mirrored from CUP's CUP_SMAW_Spotting magazine)
// is to zero everything at the MAGAZINE with priority = 99 so nothing else can
// win the priority comparison.

class CfgMagazines {
    class CA_Magazine;

    class Titan_AA: CA_Magazine {
        ace_overpressure_angle = 0;
        ace_overpressure_range = 0;
        ace_overpressure_damage = 0;
        ace_overpressure_priority = 99;
    };

    class Titan_AT: CA_Magazine {
        ace_overpressure_angle = 0;
        ace_overpressure_range = 0;
        ace_overpressure_damage = 0;
        ace_overpressure_priority = 99;
    };
};
