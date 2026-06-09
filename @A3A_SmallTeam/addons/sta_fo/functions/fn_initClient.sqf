// fn_initClient.sqf
// Runs postInit on every client (and server if it hosts)
#include "../script_component.hpp"

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

// Global fallbacks for clients that join after server init
if (isNil "STA_foPlayers")        then { STA_foPlayers        = [] };
if (isNil "STA_batteryPool")      then { STA_batteryPool      = [] };
if (isNil "STA_batteryWaypoints") then { STA_batteryWaypoints = createHashMap };

// CBA keybind registration
[
    "sta_fo",
    "STA_FO_Artillery",
    ["FO Artillery", "Open the artillery fire mission interface (FO or commander)"],
    {
        if (player getVariable ["incapacitated", false]) exitWith {};
        if (player getVariable ["owner", player] != player) exitWith {};
        if (isNil "theBoss") exitWith {};
        private _isBoss = player isEqualTo theBoss;
        private _isFO   = (getPlayerUID player) in STA_foPlayers;
        if (!_isBoss && !_isFO) exitWith {};
        [] spawn A3A_fnc_artySupport;
    },
    {},
    [30, [true, true, false]],  // Ctrl+Shift+A (DIK_A = 30)
    false,
    false
] call CBA_fnc_addKeybind;
