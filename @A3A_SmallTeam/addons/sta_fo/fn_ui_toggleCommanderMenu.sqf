// fn_toggleCommanderMenu.sqf
// Override of SCRT_fnc_ui_toggleCommanderMenu
// ONLY CHANGE from original: calls STA_fnc_injectCommanderButton after the commander menu opens.
// All other logic is identical to the Antistasi original.
#include "../script_component.hpp"

if (isMenuOpen) then {
    closeDialog 0;
    closeDialog 0;
    isMenuOpen = false;
} else {
    if (player isEqualTo theBoss) then {
        closeDialog 0;
        closeDialog 0;
        createDialog "commanderMenu";
        [] call SCRT_fnc_ui_populateCommanderMenu;
        isMenuOpen = true;
        if (vehicle player isEqualTo player) then {
            [] spawn SCRT_fnc_misc_orbitingCamera;
        } else {
            [] spawn SCRT_fnc_misc_followCamera;
        };

        // STA addition: inject our buttons into the open commander menu
        [] call STA_fnc_injectCommanderButton;

    } else {
        closeDialog 0;
        closeDialog 0;
        createDialog "rebelMenu";
        [] call SCRT_fnc_ui_populateRebelMenu;
        isMenuOpen = true;
        if (vehicle player isEqualTo player) then {
            [] spawn SCRT_fnc_misc_orbitingCamera;
        } else {
            [] spawn SCRT_fnc_misc_followCamera;
        };
    };
};
