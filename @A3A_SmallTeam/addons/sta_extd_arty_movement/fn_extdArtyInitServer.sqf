#include "script_component.hpp"
// Server postInit. Starts the periodic scan loop if auto mode is enabled.

if (!isServer) exitWith {};

if (!STA_extdArty_enabled) exitWith {
    diag_log "STA extdArty: auto mode disabled — manual-only (use [vehicle this] call STA_fnc_extdArtyAddGroupMonitor).";
};

diag_log format ["STA extdArty: auto mode starting (scan every %1s).", STA_extdArty_scanInterval];

[] spawn {
    while {true} do {
        [] call STA_fnc_extdArtyPeriodicScan;
        sleep STA_extdArty_scanInterval;
    };
};
