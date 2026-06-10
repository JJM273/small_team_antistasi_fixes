// fn_setBatteryWaypoints.sqf
// params: [netId string, [[x,y,z],...] positions array]
// Stores or replaces the waypoint cycle for a battery; resets index to 0
#include "script_component.hpp"

params ["_netId", "_positions"];
private _vehicle = objectFromNetId _netId;
if (isNull _vehicle) exitWith {};

STA_batteryWaypoints set [_vehicle, [_positions, 0]];
publicVariable "STA_batteryWaypoints";
