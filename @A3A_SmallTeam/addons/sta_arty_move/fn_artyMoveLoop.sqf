#include "script_component.hpp"
// Server-side monitoring loop. Spawned by STA_fnc_artyMoveMonitor.
// Polls the broadcasted lastFired timestamp; when cooldown expires, advances
// the group to its next waypoint.

params ["_veh", "_grp", ["_cooldown", 15]];

private _lastProcessed = -1;
diag_log format ["STA artyMove: started monitoring %1 (cooldown %2s, %3 waypoints)", typeOf _veh, _cooldown, count waypoints _grp];

while {alive _veh && {_veh getVariable ["STA_artyMove_active", false]}} do {
    private _lastFired = _veh getVariable ["STA_artyMove_lastFired", -1];

    if (_lastFired > _lastProcessed && {time - _lastFired >= _cooldown}) then {
        _lastProcessed = _lastFired;

        private _wps = waypoints _grp;
        private _wpCount = count _wps;

        if (_wpCount > 0) then {
            private _nextIdx = ((currentWaypoint _grp) + 1) % _wpCount;
            _grp setCurrentWaypoint (_wps select _nextIdx);
            diag_log format ["STA artyMove: %1 → waypoint %2/%3", typeOf _veh, _nextIdx + 1, _wpCount];
        };
    };

    sleep 2;
};

diag_log format ["STA artyMove: stopped monitoring %1", typeOf _veh];
