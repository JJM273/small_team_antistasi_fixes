class CfgFunctions {
    class STA {
        class extd_arty {
            file = "\sta_extd_arty_movement";
            class extdArtyInitServer      { postInit = 1; serverInit = 1; };
            class extdArtyPeriodicScan    {};
            class extdArtyAddGroupMonitor {};
            class extdArtyGroupFiredEH    {};
            class extdArtyAdvanceWaypoint {};
            class extdArtyGetWeaponCooldown {};
        };
    };
};
