#include "script_component.hpp"
// Fired EH callback. Attached to each monitored vehicle.
// Writes the fire timestamp to the group so the advance loop can read it
// regardless of which vehicle in the group fired.

params ["_veh"];

private _grp = group (gunner _veh);
if (isNull _grp) then { _grp = group (commander _veh) };
if (isNull _grp) exitWith {};

_grp setVariable ["STA_extdArty_lastFired", time];
