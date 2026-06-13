#include "script_component.hpp"
// Returns the post-fire cooldown for a vehicle in seconds.
// Reads reloadTime from the gunner's current weapon config, applies multiplier and minimum.
// Falls back to minimum cooldown if no gunner or no config value found.

params ["_veh"];

private _minCooldown   = STA_extdArty_minCooldown;
private _multiplier    = STA_extdArty_cooldownMultiplier;

private _gunner = gunner _veh;
if (isNull _gunner) then { _gunner = commander _veh };
if (isNull _gunner) exitWith { _minCooldown };

private _turretPath = _veh unitTurret _gunner;
private _state = weaponState [_veh, _turretPath, ""];
if (_state isEqualTo []) exitWith { _minCooldown };

_state params ["_weapon", "_muzzle", "_fireMode"];
if (_weapon isEqualTo "") exitWith { _minCooldown };

private _cfg = configFile >> "CfgWeapons" >> _weapon;
if (_muzzle != _weapon)    then { _cfg = _cfg >> _muzzle; };
if (_fireMode != _muzzle)  then { _cfg = _cfg >> _fireMode; };

private _reloadTime = getNumber (_cfg >> "reloadTime");
if (_reloadTime <= 0) exitWith { _minCooldown };

(_reloadTime * _multiplier) max _minCooldown
