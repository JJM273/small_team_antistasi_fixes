#include "script_component.hpp"
/*
 * STA_fnc_extdArtyAddGroupMonitor
 *
 * Attaches post-fire waypoint advancement to an artillery group.
 * Called automatically by the periodic scan (auto mode) or manually from Zeus:
 *
 *   [vehicle this] call STA_fnc_extdArtyAddGroupMonitor;
 *
 * Manual calls bypass the auto-eligibility check, so you can force-add any vehicle.
 * The advance logic (HOLD check, cooldown) is identical in both cases.
 *
 * Parameters:
 *   _veh      - The artillery vehicle. Group is derived from its gunner/commander.
 *   _manual   - (optional, default false) True when called manually; skips eligibility guard.
 */

params ["_veh", ["_manual", false]];

if (isNull _veh || !alive _veh) exitWith {
    if (_manual) then { hint "STA: Vehicle is null or dead."; };
};

private _gunner = gunner _veh;
if (isNull _gunner) then { _gunner = commander _veh };
if (isNull _gunner) exitWith {
    if (_manual) then { hint "STA: Vehicle has no crew."; };
};

private _grp = group _gunner;
if (isNull _grp) exitWith {
    if (_manual) then { hint "STA: Crew not in a group."; };
};

if (_grp getVariable ["STA_extdArty_monitored", false]) exitWith {
    if (_manual) then { hint format ["STA: %1 is already monitored.", typeOf _veh]; };
};

// --- Attach Fired EH to all current vehicles in the group ---
private _fn_attachEH = {
    params ["_v"];
    if (_v getVariable ["STA_extdArty_hasEH", false]) exitWith {};
    if !(alive _v) exitWith {};
    _v addEventHandler ["Fired", { [_this select 0] call STA_fnc_extdArtyGroupFiredEH; }];
    _v setVariable ["STA_extdArty_hasEH", true];
};

{
    if (!(isNull objectParent _x)) then { [objectParent _x] call _fn_attachEH };
} forEach units _grp;
[_veh] call _fn_attachEH;

// Calculate initial cooldown from the vehicle's current weapon.
private _cooldown = [_veh] call STA_fnc_extdArtyGetWeaponCooldown;
_grp setVariable ["STA_extdArty_lastFired",  -1];
_grp setVariable ["STA_extdArty_cooldown",   _cooldown];
_grp setVariable ["STA_extdArty_monitored",  true];

diag_log format ["STA extdArty: monitoring %1 (group %2, cooldown %3s).", typeOf _veh, groupId _grp, _cooldown];
if (_manual) then {
    hint format ["STA: Monitoring %1.\n%2s cooldown after last shot.", typeOf _veh, _cooldown];
};

// --- Per-group advance loop ---
[_grp, _fn_attachEH] spawn {
    params ["_grp", "_fn_attachEH"];

    while {!isNull _grp && {({alive _x} count units _grp) > 0}} do {
        sleep 2;

        // Re-attach EH to any new vehicles (handles mortyAI respawn).
        {
            if (!(isNull objectParent _x)) then { [objectParent _x] call _fn_attachEH };
        } forEach units _grp;

        private _lastFired  = _grp getVariable ["STA_extdArty_lastFired",  -1];
        private _cooldown   = _grp getVariable ["STA_extdArty_cooldown",    STA_extdArty_minCooldown];

        if (_lastFired > 0 && {time - _lastFired >= _cooldown}) then {
            [_grp] call STA_fnc_extdArtyAdvanceWaypoint;
        };
    };

    _grp setVariable ["STA_extdArty_monitored", false];
    diag_log format ["STA extdArty: stopped monitoring group %1 (no survivors).", groupId _grp];
};
