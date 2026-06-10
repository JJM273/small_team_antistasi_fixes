class CfgFunctions {
    // Our own functions
    class STA {
        class default {
            file = "\sta_fo\functions"; // TODO: replace with QPATHTOFOLDER(functions) once CBA header is resolvable
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
                file = "\sta_fo\functions\fn_artySupport.sqf"; // TODO: QPATHTOFOLDER(functions\fn_artySupport.sqf)
            };
        };
    };

    // Override SCRT_fnc_ui_toggleCommanderMenu
    class SCRT {
        class ui {
            class toggleCommanderMenu {
                file = "\sta_fo\functions\fn_toggleCommanderMenu.sqf"; // TODO: QPATHTOFOLDER(functions\fn_toggleCommanderMenu.sqf)
            };
        };
    };
};
