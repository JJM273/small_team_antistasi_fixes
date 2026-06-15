class CfgPatches {
    class STA_sta_gl_reslot {
        units[] = {};
        weapons[] = {};
        requiredVersion = 1.68;
        // CUP_Weapons_GrenadeLaunchers required so this loads after CUP defines
        // the launchers; otherwise CUP's later type = 1 override wipes our patch.
        requiredAddons[] = {"cba_main", "CUP_Weapons_GrenadeLaunchers"};
    };
};

// ── Re-slot CUP standalone grenade launchers ──────────────────────────────────
//
// Arma 3 weapon slot values:
//   1 = Primary   2 = Handgun/Secondary   3 = Launcher/Tertiary
//
// Mk13         → Secondary (pistol slot) — grenade pistol, pairs with a sidearm
// M32/M79/6G30 → Launcher (tertiary slot) — treated as heavy GL, not primary

class CfgWeapons {
    class CUP_glaunch_Base;

    class CUP_glaunch_Mk13: CUP_glaunch_Base {
        type = 2;
    };

    class CUP_glaunch_M32: CUP_glaunch_Base {
        type = 3;
    };

    class CUP_glaunch_M79: CUP_glaunch_Base {
        type = 3;
    };

    class CUP_glaunch_6G30: CUP_glaunch_M32 {
        type = 3;
    };
};
