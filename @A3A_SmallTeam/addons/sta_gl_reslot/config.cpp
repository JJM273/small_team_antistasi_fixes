class CfgPatches {
    class STA_sta_gl_reslot {
        units[] = {};
        weapons[] = {};
        requiredVersion = 1.68;
        requiredAddons[] = {"cba_main"};
    };
};

// ── Re-slot CUP standalone grenade launchers ──────────────────────────────────
//
// Arma 3 weapon type values:
//   1 = Primary   2 = Handgun/Secondary   3 = Launcher/Tertiary
//
// CUP ships all of these as primaries (type = 0). This patch moves:
//   Mk13      → Secondary (pistol slot) — grenade pistol, pairs with a sidearm
//   M32/M79/6G30 → Launcher (tertiary slot) — treated as heavy GL, not primary

class CfgWeapons {
    class CUP_glaunch_Mk13 {
        type = 2;
    };

    class CUP_glaunch_M32 {
        type = 3;
    };

    class CUP_glaunch_M79 {
        type = 3;
    };

    class CUP_glaunch_6G30 {
        type = 3;
    };
};
