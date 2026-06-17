class CfgPatches {
    class STA_sta_gl_reslot {
        units[] = {};
        weapons[] = {};
        requiredVersion = 1.68;
        // CUP_Weapons_GrenadeLaunchers required so this loads after CUP defines
        // the launchers; otherwise CUP's later type override wipes our patch.
        requiredAddons[] = {"cba_main", "CUP_Weapons_GrenadeLaunchers"};
    };
};

// ── Re-slot CUP standalone grenade launchers ──────────────────────────────────
//
// Arma 3 weapon slot values (bitwise — type=3 made launchers vanish because
// 3 = 1|2 fits no single slot):
//   1 = Primary   2 = Handgun/Secondary   4 = Launcher/Tertiary
//
// All four go in the handgun slot (type = 2). For Arma the carry/aim animation
// state is hardcoded to the weapon's slot — there is no per-weapon override.
// The launcher slot (4) puts large GLs into the over-the-shoulder rocket pose
// with broken arm placement and unaimable hands (confirmed in-game; matches
// RHS GL Swap's documented limitation). Pistol slot uses the two-handed pistol
// pose which works reasonably for hand-held grenade pistols / revolvers.
//
// For M32/M79/6G30 (large GLs that look absurd stuffed into a hip holster),
// holsterScale = 0 hides the holstered model — same trick ACE uses for its
// mine detectors (ace_minedetector/config.cpp ACE_VMM3 / ACE_VMH3). Slot
// occupation and mass are inherited from the CUP definition unchanged; only
// the visual representation is hidden. Mk13 is genuinely pistol-sized so we
// leave its holstered model visible.

class CfgWeapons {
    class CUP_glaunch_Base {
        class WeaponSlotsInfo;
    };

    class CUP_glaunch_Mk13: CUP_glaunch_Base {
        type = 2;
    };

    class CUP_glaunch_M32: CUP_glaunch_Base {
        type = 2;
        class WeaponSlotsInfo: WeaponSlotsInfo {
            holsterScale = 0;
        };
    };

    class CUP_glaunch_M79: CUP_glaunch_Base {
        type = 2;
        class WeaponSlotsInfo: WeaponSlotsInfo {
            holsterScale = 0;
        };
    };

    class CUP_glaunch_6G30: CUP_glaunch_M32 {
        type = 2;
        class WeaponSlotsInfo: WeaponSlotsInfo {
            holsterScale = 0;
        };
    };
};
