// fn_foRoleMenu.sqf
// Opens the FO role management dialog. Boss-only.
#include "script_component.hpp"

if (!(player isEqualTo theBoss)) exitWith {};

closeDialog 0;
createDialog "STA_foDialog";
disableSerialization;
private _display    = findDisplay 57002;
private _playerCtrl = _display displayCtrl 57201;
private _foCtrl     = _display displayCtrl 57206;

// Build player list (all human players except boss)
private _humanPlayers = playableUnits select { isPlayer _x && !(_x isEqualTo theBoss) };

lbClear _playerCtrl;
{ _playerCtrl lbAdd name _x } forEach _humanPlayers;

// Build current FO list — only online FOs; store UID as row data for safe revoke
lbClear _foCtrl;
{
    private _uid = _x;
    private _unit = (playableUnits select { isPlayer _x && getPlayerUID _x == _uid }) param [0, objNull];
    if (!isNull _unit) then {
        private _row = _foCtrl lbAdd name _unit;
        _foCtrl lbSetData [_row, _uid];
    };
} forEach STA_foPlayers;

// -- Grant FO ----------------------------------------------------------------
(_display displayCtrl 57202) ctrlAddEventHandler ["ButtonClick", {
    disableSerialization;
    private _selIdx = lbCurSel ((findDisplay 57002) displayCtrl 57201);
    if (_selIdx < 0) exitWith {
        ["FO Roles", "Select a player from the left list first."] call A3A_fnc_customHint;
    };
    private _humanPlayers = playableUnits select { isPlayer _x && !(_x isEqualTo theBoss) };
    private _target = _humanPlayers select _selIdx;
    private _uid = getPlayerUID _target;
    [_uid] remoteExec ["STA_fnc_grantFoRole", 2];
    [] spawn { sleep 0.6; closeDialog 0; [] call STA_fnc_foRoleMenu; };
}];

// -- Revoke FO ---------------------------------------------------------------
(_display displayCtrl 57203) ctrlAddEventHandler ["ButtonClick", {
    disableSerialization;
    private _foCtrl = (findDisplay 57002) displayCtrl 57206;
    private _selIdx = lbCurSel _foCtrl;
    if (_selIdx < 0) exitWith {
        ["FO Roles", "Select a player from the right list first."] call A3A_fnc_customHint;
    };
    private _uid = _foCtrl lbData _selIdx;
    [_uid] remoteExec ["STA_fnc_revokeFoRole", 2];
    [] spawn { sleep 0.6; closeDialog 0; [] call STA_fnc_foRoleMenu; };
}];

// -- Close -------------------------------------------------------------------
(_display displayCtrl 57204) ctrlAddEventHandler ["ButtonClick", { closeDialog 0; }];
