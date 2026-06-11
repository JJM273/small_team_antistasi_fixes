#include "script_component.hpp"

// Register our tab. SCRT_fnc_ui_changeTab will slide idc 8000 on/off screen.
menuSliderArray pushBack ["ARTILLERY", 8000];

disableSerialization;
private _display = findDisplay 60000;
if (isNull _display) exitWith {};

// Build the tab ControlsGroup starting off-screen (matches Antistasi tab convention).
private _tabX = -0.4 * safeZoneW + safeZoneX;
private _tabY = safeZoneY + (12 * pixelGridNoUIScale * pixelH);
private _tabW = 0.35 * safeZoneW;
private _tabH = safeZoneH - (24 * pixelGridNoUIScale * pixelH);

private _grp = _display ctrlCreate ["RscControlsGroup", 8000];
_grp ctrlSetPosition [_tabX, _tabY, _tabW, _tabH];
_grp ctrlCommit 0;

private _btnH  = 0.04;
private _btnW  = _tabW - 0.02;
private _btnX  = 0.01;

private _btnArty = _display ctrlCreate ["RscButtonMenu", 8011, _grp];
_btnArty ctrlSetPosition [_btnX, 0.02, _btnW, _btnH];
_btnArty ctrlSetText "Manage Artillery";
_btnArty ctrlCommit 0;
_btnArty ctrlAddEventHandler ["ButtonClick", {
    closeDialog 0; closeDialog 0;
    isMenuOpen = false;
    [] call STA_fnc_batteryManageMenu;
}];

private _btnFO = _display ctrlCreate ["RscButtonMenu", 8012, _grp];
_btnFO ctrlSetPosition [_btnX, 0.08, _btnW, _btnH];
_btnFO ctrlSetText "Manage FO Roles";
_btnFO ctrlCommit 0;
_btnFO ctrlAddEventHandler ["ButtonClick", {
    closeDialog 0; closeDialog 0;
    isMenuOpen = false;
    [] call STA_fnc_foRoleMenu;
}];
