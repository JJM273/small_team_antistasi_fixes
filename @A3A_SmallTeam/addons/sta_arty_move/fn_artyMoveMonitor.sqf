#include "script_component.hpp"
/*
 * STA_fnc_artyMoveMonitor
 * Run from debug console with cursor pointing at the target artillery vehicle:
 *
 *   [] call STA_fnc_artyMoveMonitor;          // 15s default cooldown
 *   [30] call STA_fnc_artyMoveMonitor;         // custom 30s cooldown
 *
 * To stop monitoring a vehicle early:
 *   cursorObject setVariable ["STA_artyMove_active", false, true];
 *
 * The vehicle's HC group must already have its waypoint chain set in Zeus
 * (HOLD waypoints + a CYCLE at the end) before calling this.
 *
 * NOTE: For dedicated servers, run from the server debug console.
 * For hosted games, Zeus player IS the server — run from anywhere.
 */

params [["_cooldown", 15, [0]]];

private _veh = cursorObject;
if (isNull _veh) exitWith { hint "STA: No object under cursor."; };
if !(alive _veh) exitWith { hint "STA: Object is dead."; };

private _drv = driver _veh;
if (isNull _drv) exitWith { hint "STA: Vehicle has no driver — assign crew first."; };

private _grp = group _drv;
if (isNull _grp) exitWith { hint "STA: Driver is not in a group."; };

if (count waypoints _grp == 0) exitWith {
    hint "STA: Group has no waypoints. Set the waypoint chain in Zeus first.";
};

if (_veh getVariable ["STA_artyMove_active", false]) exitWith {
    hint format ["STA: %1 is already being monitored.", typeOf _veh];
};

_veh setVariable ["STA_artyMove_active", true, true];
_veh setVariable ["STA_artyMove_lastFired", -1, true];

// Fired EH fires on any machine it's added to regardless of vehicle locality.
// We broadcast the timestamp so the server-side loop can read it.
_veh addEventHandler ["Fired", {
    params ["_veh"];
    _veh setVariable ["STA_artyMove_lastFired", time, true];
}];

if (isServer) then {
    [_veh, _grp, _cooldown] spawn STA_fnc_artyMoveLoop;
} else {
    [_veh, _grp, _cooldown] remoteExec ["STA_fnc_artyMoveLoop", 2];
};

hint format [
    "STA: Monitoring %1.\nWaypoint advances %2s after last shot.\n(%3 waypoints set)",
    typeOf _veh, _cooldown, count waypoints _grp
];
