#include "script_component.hpp"

class CfgPatches {
    class sta_fo {
        units[] = {};
        weapons[] = {};
        requiredVersion = 1.0;
        requiredAddons[] = {"cba_main"}; // TODO: add correct Antistasi addon class names once identified (A3A_main and SCRT_main were wrong)
    };
};

#include "CfgFunctions.hpp"
#include "CfgSettings.hpp"
#include "dialogs.hpp"
