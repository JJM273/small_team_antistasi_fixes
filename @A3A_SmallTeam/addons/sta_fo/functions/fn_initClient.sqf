// fn_initClient.sqf
// Runs postInit on every client (and server if it hosts)
#include "script_component.hpp"

// Register CBA addon settings
[
    "STA_setting_foRequireRadio",
    "CHECKBOX",
    ["Require radio for FO", "FO must carry a radio to open the artillery interface (mirrors boss radio check)"],
    "A3A Small Team",
    true,
    true
] call CBA_fnc_addSetting;

[
    "STA_setting_foCanSetWaypoints",
    "CHECKBOX",
    ["FOs can set waypoints", "Allows FO-role players to configure battery firing positions (boss can always do this)"],
    "A3A Small Team",
    false,
    true
] call CBA_fnc_addSetting;

[
    "STA_setting_postFireMoveDelay",
    "SLIDER",
    ["Post-fire move delay (s)", "Seconds after last round before battery moves to next position"],
    "A3A Small Team",
    [0, 120, 5, 30],
    true
] call CBA_fnc_addSetting;

// Remaining client init (keybind, global fallbacks) added in Task 11
