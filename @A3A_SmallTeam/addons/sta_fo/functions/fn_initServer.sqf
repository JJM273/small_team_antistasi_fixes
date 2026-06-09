// fn_initServer.sqf
// Runs postInit on server only (serverInit = 1 in CfgFunctions)
#include "../script_component.hpp"

if (!isServer) exitWith {};

// Authoritative session state
STA_foPlayers        = [];             // array of player UIDs with FO role
STA_batteryPool      = [];             // array of committed artillery vehicles
STA_batteryWaypoints = createHashMap;  // vehicle -> [[pos,...], currentIndex]

publicVariable "STA_foPlayers";
publicVariable "STA_batteryPool";
publicVariable "STA_batteryWaypoints";
