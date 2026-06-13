#include "script_component.hpp"
// Checks whether the group is at a HOLD waypoint and advances to the next one.
// Called by the per-group advance loop after cooldown expires.
// Safe to call with no waypoints — exits silently.

params ["_grp"];

private _wps = waypoints _grp;
if (_wps isEqualTo []) exitWith {};

private _curIdx = currentWaypoint _grp;
private _wpType = waypointType [_grp, _curIdx];

if (_wpType != "HOLD") exitWith {
    diag_log format ["STA extdArty: %1 fired but not at HOLD (type=%2, idx=%3) — skipping advance.", groupId _grp, _wpType, _curIdx];
};

private _nextIdx = (_curIdx + 1) % (count _wps);
_grp setCurrentWaypoint (_wps select _nextIdx);

// Reset timer so we don't advance again until the next fire mission.
_grp setVariable ["STA_extdArty_lastFired", -1];

diag_log format ["STA extdArty: %1 advanced waypoint %2 → %3.", groupId _grp, _curIdx, _nextIdx];
