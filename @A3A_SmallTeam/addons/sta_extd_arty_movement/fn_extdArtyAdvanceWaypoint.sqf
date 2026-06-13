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
    if (STA_extdArty_debugLevel >= 2) then {
        [format ["STA arty [%1]: not at HOLD (type=%2, idx=%3) — skipping.", groupId _grp, _wpType, _curIdx]] remoteExec ["systemChat", 0];
    };
};

private _nextIdx = (_curIdx + 1) % (count _wps);
_grp setCurrentWaypoint (_wps select _nextIdx);

// Reset timer so we don't advance again until the next fire mission.
_grp setVariable ["STA_extdArty_lastFired", -1];

diag_log format ["STA extdArty: %1 advanced waypoint %2 → %3.", groupId _grp, _curIdx, _nextIdx];

if (STA_extdArty_debugLevel >= 2) then {
    [format ["STA arty [%1]: waypoint %2 → %3.", groupId _grp, _curIdx, _nextIdx]] remoteExec ["systemChat", 0];
};

if (STA_extdArty_debugLevel >= 1) then {
    private _ldr = leader _grp;
    private _vehType = typeOf (if (isNull objectParent _ldr) then { _ldr } else { objectParent _ldr });
    [format ["STA arty [%1]: %2 repositioning.", groupId _grp, _vehType]] remoteExec ["systemChat", 0];
    [_grp, _vehType] spawn {
        params ["_g", "_t"];
        waitUntil { sleep 5; isNull _g || {speed (vehicle (leader _g)) < 1} };
        if (!isNull _g) then {
            [format ["STA arty [%1]: %2 ready.", groupId _g, _t]] remoteExec ["systemChat", 0];
        };
    };
};
