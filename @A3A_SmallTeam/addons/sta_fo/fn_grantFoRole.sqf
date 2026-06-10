// fn_grantFoRole.sqf
// params: [UID string]
// Adds UID to STA_foPlayers if not already present
#include "script_component.hpp"

params ["_uid"];
if (_uid in STA_foPlayers) exitWith {};
STA_foPlayers pushBack _uid;
publicVariable "STA_foPlayers";
