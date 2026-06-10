// fn_injectCommanderButton.sqf
// Programmatically adds "Manage Artillery" and "Manage FO Roles" buttons to the
// already-open commanderMenu display.
// Called immediately after createDialog "commanderMenu" in fn_toggleCommanderMenu.sqf.
//
// NOTE: button positions are best-guess values and may need visual tuning
// against Antistasi's commanderMenu layout. Adjust x/y/w/h if buttons overlap.
#include "../script_component.hpp"

disableSerialization;
private _display = findDisplay 60000;
if (isNull _display) exitWith {};

// "Manage Artillery" button
private _btnArty = _display ctrlCreate ["RscButtonMenu", -1];
_btnArty ctrlSetPosition [0.01, 0.9, 0.16, 0.04];
_btnArty ctrlSetText "Manage Artillery";
_btnArty ctrlCommit 0;
_btnArty ctrlAddEventHandler ["ButtonClick", {
    closeDialog 0;
    isMenuOpen = false;
    [] call STA_fnc_batteryManageMenu;
}];

// "Manage FO Roles" button
private _btnFO = _display ctrlCreate ["RscButtonMenu", -1];
_btnFO ctrlSetPosition [0.01, 0.95, 0.16, 0.04];
_btnFO ctrlSetText "Manage FO Roles";
_btnFO ctrlCommit 0;
_btnFO ctrlAddEventHandler ["ButtonClick", {
    closeDialog 0;
    isMenuOpen = false;
    [] call STA_fnc_foRoleMenu;
}];
