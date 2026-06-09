// fn_batteryManageMenu.sqf
// Opens the battery management dialog and wires all buttons.
// Must run on the commander's client only.
#include "../script_component.hpp"

if (!(player isEqualTo theBoss)) exitWith {};

closeDialog 0;
createDialog "STA_batteryDialog";
disableSerialization;
private _display  = findDisplay 57001;
private _listCtrl = _display displayCtrl 57101;

// Populate listbox with current pool
lbClear _listCtrl;
{
    _listCtrl lbAdd format ["%1  @  %2", (getText (configFile >> "CfgVehicles" >> typeOf _x >> "displayName")), mapGridPosition _x];
} forEach STA_batteryPool;

// -- Commit New --------------------------------------------------------------
(_display displayCtrl 57102) ctrlAddEventHandler ["ButtonClick", {
    closeDialog 0;
    [] spawn {
        if (!visibleMap) then { openMap true };
        ["Battery Commit", "Click the map position of the artillery vehicle to commit."] call A3A_fnc_customHint;

        STA_commitClickPos = nil;
        onMapSingleClick "STA_commitClickPos = _pos; onMapSingleClick '';";
        waitUntil { sleep 0.1; !isNil "STA_commitClickPos" || !visibleMap };

        if (isNil "STA_commitClickPos") exitWith { [] call STA_fnc_batteryManageMenu };
        private _pos = STA_commitClickPos;
        STA_commitClickPos = nil;
        openMap false;

        // Find nearest uncommitted artilleryScanner vehicle within 50m of click
        private _candidates = _pos nearObjects 50 select {
            alive _x &&
            { getNumber (configFile >> "CfgVehicles" >> typeOf _x >> "artilleryScanner") == 1 } &&
            { !(_x in STA_batteryPool) }
        };
        if (_candidates isEqualTo []) exitWith {
            ["Battery Commit", "No uncommitted artillery vehicle within 50m of that position."] call A3A_fnc_customHint;
            [] call STA_fnc_batteryManageMenu;
        };

        [netId (_candidates select 0)] remoteExec ["STA_fnc_commitBattery", 2];
        sleep 0.6;
        [] call STA_fnc_batteryManageMenu;
    };
}];

// -- Set Waypoints -----------------------------------------------------------
(_display displayCtrl 57103) ctrlAddEventHandler ["ButtonClick", {
    disableSerialization;
    private _listCtrl = (findDisplay 57001) displayCtrl 57101;
    private _selIdx = _listCtrl lbCurSel;
    if (_selIdx < 0) exitWith {
        ["Battery Waypoints", "Select a battery from the list first."] call A3A_fnc_customHint;
    };
    private _battery = STA_batteryPool select _selIdx;
    closeDialog 0;

    [netId _battery] spawn {
        params ["_netId"];
        private _positions = [];

        if (!visibleMap) then { openMap true };
        ["Battery Waypoints", "Click up to 5 firing positions. Close the map when done."] call A3A_fnc_customHint;

        STA_wpClickPos = nil;
        onMapSingleClick "STA_wpClickPos = _pos;";

        while { count _positions < 5 && visibleMap } do {
            waitUntil { sleep 0.1; !isNil "STA_wpClickPos" || !visibleMap };
            if (!isNil "STA_wpClickPos") then {
                _positions pushBack STA_wpClickPos;
                STA_wpClickPos = nil;
                ["Battery Waypoints", format ["Position %1 set. Click next or close map to finish.", count _positions]] call A3A_fnc_customHint;
            };
        };
        onMapSingleClick "";
        openMap false;

        if (_positions isEqualTo []) exitWith { [] call STA_fnc_batteryManageMenu };

        [_netId, _positions] remoteExec ["STA_fnc_setBatteryWaypoints", 2];
        ["Battery Waypoints", format ["%1 firing positions saved.", count _positions]] call A3A_fnc_customHint;
        sleep 0.6;
        [] call STA_fnc_batteryManageMenu;
    };
}];

// -- Remove Battery ----------------------------------------------------------
(_display displayCtrl 57104) ctrlAddEventHandler ["ButtonClick", {
    disableSerialization;
    private _listCtrl = (findDisplay 57001) displayCtrl 57101;
    private _selIdx = _listCtrl lbCurSel;
    if (_selIdx < 0) exitWith {
        ["Battery Remove", "Select a battery from the list first."] call A3A_fnc_customHint;
    };
    private _battery = STA_batteryPool select _selIdx;
    [netId _battery] remoteExec ["STA_fnc_removeBattery", 2];
    [] spawn { sleep 0.6; closeDialog 0; [] call STA_fnc_batteryManageMenu; };
}];

// -- Close -------------------------------------------------------------------
(_display displayCtrl 57105) ctrlAddEventHandler ["ButtonClick", { closeDialog 0; }];
