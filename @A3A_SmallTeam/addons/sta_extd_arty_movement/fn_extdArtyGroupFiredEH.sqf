#include "script_component.hpp"
// Fired EH callback. Attached to each monitored vehicle.
// Writes the fire timestamp to the group so the advance loop can read it
// regardless of which vehicle in the group fired.

params ["_veh"];

private _grp = group (gunner _veh);
if (isNull _grp) then { _grp = group (commander _veh) };
if (isNull _grp) exitWith {};

private _prevFired = _grp getVariable ["STA_extdArty_lastFired", -1];
_grp setVariable ["STA_extdArty_lastFired", time];

if (STA_extdArty_debugLevel >= 2 && {_prevFired > 0}) then {
    private _cd = _grp getVariable ["STA_extdArty_cooldown", STA_extdArty_minCooldown];
    [format ["STA arty [%1]: cooldown (%2s) reset", groupId _grp, _cd]] remoteExec ["systemChat", 0];
};
