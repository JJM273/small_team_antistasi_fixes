// fn_postFireMonitor.sqf
// Called server-side via remoteExec ["STA_fnc_postFireMonitor", 2]
// params: [netId string of the battery vehicle]
#include "../script_component.hpp"

params ["_netId"];
[_netId] spawn {
    params ["_netId"];
    private _vehicle = objectFromNetId _netId;
    if (isNull _vehicle) exitWith {};

    private _timeout = time + 600; // 10-minute safety timeout

    // Wait until the gun is done and not busy
    waitUntil {
        sleep 2;
        !alive _vehicle || { unitReady _vehicle } || { time > _timeout }
    };

    if (!alive _vehicle || time > _timeout) exitWith {};

    // Apply configured delay before moving
    sleep STA_setting_postFireMoveDelay;

    // Look up waypoint cycle for this battery
    private _waypointData = STA_batteryWaypoints getOrDefault [_vehicle, [[], 0]];
    _waypointData params ["_positions", "_idx"];
    if (_positions isEqualTo []) exitWith {}; // no waypoints set, stay put

    // Advance cycle index (wraps around)
    private _nextPos = _positions select _idx;
    private _nextIdx = (_idx + 1) mod count _positions;
    STA_batteryWaypoints set [_vehicle, [_positions, _nextIdx]];
    publicVariable "STA_batteryWaypoints";

    // Clear queued waypoints then issue move order
    private _grp = group (gunner _vehicle);
    while { count waypoints _grp > 0 } do { deleteWaypoint [_grp, 0] };
    _grp setCurrentWaypoint [_grp addWaypoint [_nextPos, 0]];
};
