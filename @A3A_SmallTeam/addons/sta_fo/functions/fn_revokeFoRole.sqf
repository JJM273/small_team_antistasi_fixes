// fn_revokeFoRole.sqf
// params: [UID string]
// Removes UID from STA_foPlayers
#include "../script_component.hpp"

params ["_uid"];
STA_foPlayers = STA_foPlayers - [_uid];
publicVariable "STA_foPlayers";
