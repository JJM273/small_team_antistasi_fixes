#include "script_component.hpp"
// Scans all server-side groups for eligible artillery vehicles and starts monitoring.
// Runs on a loop at the configured interval. Called from fn_extdArtyInitServer.

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

{
    private _grp = _x;

    // Skip already-monitored groups.
    if (_grp getVariable ["STA_extdArty_monitored", false]) then { continue };

    // Only player-side groups.
    if (side _grp != teamPlayer) then { continue };

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
