// fn_commitBattery.sqf
// params: [netId string]
// Adds vehicle to STA_batteryPool if valid and not already present
#include "script_component.hpp"

params ["_netId"];
private _vehicle = objectFromNetId _netId;
if (isNull _vehicle || !alive _vehicle) exitWith {};
if (getNumber (configFile >> "CfgVehicles" >> typeOf _vehicle >> "artilleryScanner") != 1) exitWith {};
if (_vehicle in STA_batteryPool) exitWith {};

STA_batteryPool pushBack _vehicle;
publicVariable "STA_batteryPool";
