// fn_removeBattery.sqf
// params: [netId string]
// Removes vehicle from pool and clears its waypoint cycle
#include "script_component.hpp"

params ["_netId"];
private _vehicle = objectFromNetId _netId;
STA_batteryPool = STA_batteryPool - [_vehicle];
STA_batteryWaypoints deleteAt _vehicle;
publicVariable "STA_batteryPool";
publicVariable "STA_batteryWaypoints";
