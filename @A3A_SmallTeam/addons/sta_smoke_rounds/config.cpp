class CfgPatches {
    class STA_sta_smoke_rounds {
        units[] = {};
        weapons[] = {};
        requiredVersion = 1.68;
        // CUP_Weapons_Flaregun required so we load AFTER CUP defines the
        // flare gun and its magazines — otherwise CUP's later magazines[] = {...}
        // definition overwrites our magazines[] += {...} addition.
        requiredAddons[] = {"cba_main", "CUP_Weapons_Flaregun"};
    };
};

// ── Ammo ──────────────────────────────────────────────────────────────────────
//
// Inherits G_40mm_Smoke (vanilla 40mm UGL smoke). The "Slightly Bounce 40mm
// Smoke" mod patches G_40mm_Smoke directly, so when loaded its bounce behavior
// cascades to our children via inheritance resolution.
// timeToLive = 24 is 80% of the ~30 s vanilla default.

class CfgAmmo {
    class G_40mm_Smoke;
    class G_40mm_SmokeRed;
    class G_40mm_SmokeGreen;
    class G_40mm_SmokeYellow;
    class G_40mm_SmokeBlue;

    class STA_26mm_Smoke: G_40mm_Smoke              { timeToLive = 24; };
    class STA_26mm_SmokeRed: G_40mm_SmokeRed        { timeToLive = 24; };
    class STA_26mm_SmokeGreen: G_40mm_SmokeGreen    { timeToLive = 24; };
    class STA_26mm_SmokeYellow: G_40mm_SmokeYellow  { timeToLive = 24; };
    class STA_26mm_SmokeBlue: G_40mm_SmokeBlue      { timeToLive = 24; };
};

// ── Magazines ─────────────────────────────────────────────────────────────────
//
// Inherit from CUP_FlareWhite_265_M so we automatically get the right pistol
// magazine setup (type=16, initSpeed=160, mass=4, nameSound="grenadelauncher",
// count=1). We only override displayName, descriptionShort, and ammo.

class CfgMagazines {
    class CUP_FlareWhite_265_M;

    class STA_26mm_Smoke_Mag: CUP_FlareWhite_265_M {
        displayName = "26.5mm Smoke (White)";
        displayNameShort = "Smoke White";
        descriptionShort = "Type: Smoke<br/>Rounds: 1<br/>Used in: Flare Pistol";
        ammo = "STA_26mm_Smoke";
    };

    class STA_26mm_SmokeRed_Mag: CUP_FlareWhite_265_M {
        displayName = "26.5mm Smoke (Red)";
        displayNameShort = "Smoke Red";
        descriptionShort = "Type: Smoke<br/>Rounds: 1<br/>Used in: Flare Pistol";
        ammo = "STA_26mm_SmokeRed";
    };

    class STA_26mm_SmokeGreen_Mag: CUP_FlareWhite_265_M {
        displayName = "26.5mm Smoke (Green)";
        displayNameShort = "Smoke Green";
        descriptionShort = "Type: Smoke<br/>Rounds: 1<br/>Used in: Flare Pistol";
        ammo = "STA_26mm_SmokeGreen";
    };

    class STA_26mm_SmokeYellow_Mag: CUP_FlareWhite_265_M {
        displayName = "26.5mm Smoke (Yellow)";
        displayNameShort = "Smoke Yellow";
        descriptionShort = "Type: Smoke<br/>Rounds: 1<br/>Used in: Flare Pistol";
        ammo = "STA_26mm_SmokeYellow";
    };

    class STA_26mm_SmokeBlue_Mag: CUP_FlareWhite_265_M {
        displayName = "26.5mm Smoke (Blue)";
        displayNameShort = "Smoke Blue";
        descriptionShort = "Type: Smoke<br/>Rounds: 1<br/>Used in: Flare Pistol";
        ammo = "STA_26mm_SmokeBlue";
    };
};

// ── Bind magazines to the CUP flare gun ───────────────────────────────────────
//
// Explicit Pistol_Base_F parent declaration is required for magazines[] +=
// to extend the parent class's array. Without it, the patch silently no-ops.

class CfgWeapons {
    class Pistol_Base_F;

    class CUP_hgun_FlareGun: Pistol_Base_F {
        magazines[] += {
            "STA_26mm_Smoke_Mag",
            "STA_26mm_SmokeRed_Mag",
            "STA_26mm_SmokeGreen_Mag",
            "STA_26mm_SmokeYellow_Mag",
            "STA_26mm_SmokeBlue_Mag"
        };
    };
};
