#include "script_component.hpp"
// Server postInit. Starts the periodic scan loop if auto mode is enabled.
//
// IMPORTANT: postInit fires in the main-menu background scene too (it's an
// internal "mission"). Without gating, the scan runs and may attach a 2-second
// per-group monitor loop to any artillery-classed vehicle in the menu pedestal,
// causing a permanent menu stutter. We gate on findDisplay 46 (the in-game UI,
// null at menu) on player clients, and run immediately on dedicated servers.

if (!isServer) exitWith {};

[] spawn {
    if (hasInterface) then {
        // Wait until the actual in-game UI exists — skips the menu background.
        // Mission loads take 10s+; polling every 15s is plenty.
        waitUntil { sleep 15; !isNull (findDisplay 46) };
    };

    if (!STA_extdArty_enabled) exitWith {
        diag_log "STA extdArty: auto mode disabled — manual-only (use [vehicle this] call STA_fnc_extdArtyAddGroupMonitor).";
    };

    diag_log format ["STA extdArty: auto mode starting (scan every %1s).", STA_extdArty_scanInterval];

    while {true} do {
        [] call STA_fnc_extdArtyPeriodicScan;
        sleep STA_extdArty_scanInterval;
    };
};
