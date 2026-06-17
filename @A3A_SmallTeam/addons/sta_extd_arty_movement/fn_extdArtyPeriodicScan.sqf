#include "script_component.hpp"
// Scans all server-side groups for eligible artillery vehicles and starts monitoring.
// Runs on a loop at the configured interval. Called from fn_extdArtyInitServer.

// Resolve the monitored side once per scan.
// 0=BLUFOR, 1=OPFOR, 2=Independent, 3=All sides (sentinel: skip side check).
// Read via missionNamespace getVariable so we don't crash if CBA hasn't
// finished registering the setting yet (postInit race).
private _sideIdx = missionNamespace getVariable ["STA_extdArty_monitorSide", 0];
private _monitorSide = switch (_sideIdx) do {
    case 0: { west };
    case 1: { east };
    case 2: { independent };
    case 3: { sideUnknown };
    default { west };
};

private _includedRaw = STA_extdArty_includedClasses;
private _excludedRaw = STA_extdArty_excludedClasses;

private _included = if (_includedRaw isEqualTo "") then {
    []
} else {
    _includedRaw splitString "," apply { _x - " " }
};

private _excluded = if (_excludedRaw isEqualTo "") then {
    []
} else {
    _excludedRaw splitString "," apply { _x - " " }
};

private _fn_isEligibleVehicle = {
    params ["_veh"];
    if (!alive _veh) exitWith { false };

    // Excluded classes take priority.
    if (_excluded findIf { _veh isKindOf _x } != -1) exitWith { false };

    // Included classes override artilleryScanner check.
    if (_included isNotEqualTo []) exitWith {
        _included findIf { _veh isKindOf _x } != -1
    };

    // Default: Arma's artilleryScanner config flag.
    getNumber (configOf _veh >> "artilleryScanner") == 1
};

if (STA_extdArty_debugLevel >= 2) then {
    ["STA arty: periodic scan running."] remoteExec ["systemChat", 0];
};

{
    private _grp = _x;

    // Skip already-monitored groups.
    if (_grp getVariable ["STA_extdArty_monitored", false]) then { continue };

    // Side filter (skipped when setting is "All sides").
    if (_monitorSide isNotEqualTo sideUnknown && {side _grp != _monitorSide}) then { continue };

    // Find the first eligible vehicle in the group.
    private _eligibleVeh = objNull;
    {
        private _v = if (isNull objectParent _x) then { _x } else { objectParent _x };
        if ([_v] call _fn_isEligibleVehicle) exitWith { _eligibleVeh = _v; };
    } forEach units _grp;

    if (!isNull _eligibleVeh) then {
        [_eligibleVeh, false] call STA_fnc_extdArtyAddGroupMonitor;
    };
} forEach allGroups;
