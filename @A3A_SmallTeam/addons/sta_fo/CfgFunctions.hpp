class CfgFunctions {
    // Our own functions
    class STA {
        class default {
            file = QPATHTOFOLDER(functions);
            class initServer            { postInit = 1; serverInit = 1; };
            class initClient            { postInit = 1; };
            class postFireMonitor       {};
            class commitBattery         {};
            class removeBattery         {};
            class setBatteryWaypoints   {};
            class grantFoRole           {};
            class revokeFoRole          {};
            class batteryManageMenu     {};
            class foRoleMenu            {};
            class injectCommanderButton {};
        };
    };

    // Override A3A_fnc_artySupport
    class A3A {
        class AI {
            class artySupport {
                file = QPATHTOFOLDER(functions\fn_artySupport.sqf);
            };
        };
    };

    // Override SCRT_fnc_ui_toggleCommanderMenu
    class SCRT {
        class ui {
            class toggleCommanderMenu {
                file = QPATHTOFOLDER(functions\fn_toggleCommanderMenu.sqf);
            };
        };
    };
};
