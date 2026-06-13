class CfgPatches {
    class STA_sta_smoke_rounds {
        units[] = {};
        weapons[] = {};
        requiredVersion = 1.68;
        // CUP Weapons must be loaded, but we don't hard-require it so the
        // PBO loads cleanly on servers without CUP; the patch is simply a no-op.
        requiredAddons[] = {"cba_main"};
    };
};

// ── Ammo ──────────────────────────────────────────────────────────────────────
//
// Each color inherits from its matching 40mm parent. This means the
// "Slightly Bounce 40mm Smoke" mod's patches to those parents cascade here
// automatically (Arma resolves inheritance after all patches are merged).
// timeToLive = 24 is 80% of the vanilla ~30 s default.
// Visual cloud size (60% target) is in CfgCloudlets via effectsSmoke —
// left as inherited; needs in-game comparison and tuning.

class CfgAmmo {
    class G_40mm_Smoke;
    class G_40mm_SmokeRed;
    class G_40mm_SmokeGreen;
    class G_40mm_SmokeYellow;
    class G_40mm_SmokeBlue;

    class STA_26mm_Smoke: G_40mm_Smoke         { timeToLive = 24; };
    class STA_26mm_SmokeRed: G_40mm_SmokeRed   { timeToLive = 24; };
    class STA_26mm_SmokeGreen: G_40mm_SmokeGreen { timeToLive = 24; };
    class STA_26mm_SmokeYellow: G_40mm_SmokeYellow { timeToLive = 24; };
    class STA_26mm_SmokeBlue: G_40mm_SmokeBlue { timeToLive = 24; };
};

// ── Magazines ─────────────────────────────────────────────────────────────────

class CfgMagazines {
    class CA_Magazine;

    class STA_26mm_Smoke_Mag: CA_Magazine {
        scope = 2;
        displayName = "26.5mm Smoke Round (White)";
        displayNameShort = "26.5mm Smoke";
        ammo = "STA_26mm_Smoke";
        count = 1;
        mass = 6;
    };

    class STA_26mm_SmokeRed_Mag: CA_Magazine {
        scope = 2;
        displayName = "26.5mm Smoke Round (Red)";
        displayNameShort = "26.5mm Smoke (Red)";
        ammo = "STA_26mm_SmokeRed";
        count = 1;
        mass = 6;
    };

    class STA_26mm_SmokeGreen_Mag: CA_Magazine {
        scope = 2;
        displayName = "26.5mm Smoke Round (Green)";
        displayNameShort = "26.5mm Smoke (Green)";
        ammo = "STA_26mm_SmokeGreen";
        count = 1;
        mass = 6;
    };

    class STA_26mm_SmokeYellow_Mag: CA_Magazine {
        scope = 2;
        displayName = "26.5mm Smoke Round (Yellow)";
        displayNameShort = "26.5mm Smoke (Yellow)";
        ammo = "STA_26mm_SmokeYellow";
        count = 1;
        mass = 6;
    };

    class STA_26mm_SmokeBlue_Mag: CA_Magazine {
        scope = 2;
        displayName = "26.5mm Smoke Round (Blue)";
        displayNameShort = "26.5mm Smoke (Blue)";
        ammo = "STA_26mm_SmokeBlue";
        count = 1;
        mass = 6;
    };
};

// ── Add all magazines to CUP flare gun ────────────────────────────────────────

class CfgWeapons {
    class CUP_hgun_FlareGun {
        magazines[] += {
            "STA_26mm_Smoke_Mag",
            "STA_26mm_SmokeRed_Mag",
            "STA_26mm_SmokeGreen_Mag",
            "STA_26mm_SmokeYellow_Mag",
            "STA_26mm_SmokeBlue_Mag"
        };
    };
};
