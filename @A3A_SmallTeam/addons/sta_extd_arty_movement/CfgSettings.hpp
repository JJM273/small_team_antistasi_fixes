class CfgSettings {
    class CBA_Settings {

        class STA_extdArty_enabled {
            value = 1;
            typeName = "BOOL";
            isClient = 0;
            isServer = 1;
            force = 0;
            displayName = "Auto arty movement";
            description = "Automatically attach post-fire waypoint advancement to eligible artillery groups.";
            category = "A3A Small Team";
        };

        class STA_extdArty_scanInterval {
            value = 30;
            typeName = "SCALAR";
            isClient = 0;
            isServer = 1;
            force = 0;
            displayName = "Scan interval (s)";
            description = "How often (seconds) to check for new eligible artillery groups.";
            category = "A3A Small Team";
        };

        class STA_extdArty_includedClasses {
            value = "";
            typeName = "STRING";
            isClient = 0;
            isServer = 1;
            force = 0;
            displayName = "Included vehicle classes";
            description = "Comma-separated vehicle classnames (isKindOf) to force-include. Empty = use artilleryScanner config check.";
            category = "A3A Small Team";
        };

        class STA_extdArty_excludedClasses {
            value = "";
            typeName = "STRING";
            isClient = 0;
            isServer = 1;
            force = 0;
            displayName = "Excluded vehicle classes";
            description = "Comma-separated vehicle classnames (isKindOf) to exclude from auto-detection.";
            category = "A3A Small Team";
        };

        class STA_extdArty_cooldownMultiplier {
            value = 1.5;
            typeName = "SCALAR";
            isClient = 0;
            isServer = 1;
            force = 0;
            displayName = "Cooldown multiplier";
            description = "Detected weapon reload time is multiplied by this value to get the post-fire cooldown.";
            category = "A3A Small Team";
        };

        class STA_extdArty_minCooldown {
            value = 10;
            typeName = "SCALAR";
            isClient = 0;
            isServer = 1;
            force = 0;
            displayName = "Minimum cooldown (s)";
            description = "Minimum seconds after last shot before advancing waypoint, regardless of reload time.";
            category = "A3A Small Team";
        };

        class STA_extdArty_debugLevel {
            value = 0;
            typeName = "SCALAR";
            isClient = 0;
            isServer = 1;
            force = 0;
            displayName = "Debug level";
            description = "0 = None. 1 = Units (repositioning / ready). 2 = All (scan, cooldown reset, HOLD check).";
            category = "A3A Small Team";
        };

    };
};
