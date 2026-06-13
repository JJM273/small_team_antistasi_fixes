class RscTitle;
class RscListBox;
class RscButtonMenu;

class STA_batteryDialog {
    idd = 57001;
    movingEnable = 0;
    enableSimulation = 1;
    class Controls {
        class Title: RscTitle {
            idc = 57100;
            text = "Battery Management";
            x = 0.3; y = 0.08; w = 0.4; h = 0.04;
        };
        class BatteryList: RscListBox {
            idc = 57101;
            x = 0.3; y = 0.13; w = 0.4; h = 0.38;
        };
        class BtnCommit: RscButtonMenu {
            idc = 57102;
            text = "Commit New";
            x = 0.3;  y = 0.52; w = 0.125; h = 0.04;
        };
        class BtnWaypoints: RscButtonMenu {
            idc = 57103;
            text = "Set Waypoints";
            x = 0.435; y = 0.52; w = 0.125; h = 0.04;
        };
        class BtnRemove: RscButtonMenu {
            idc = 57104;
            text = "Remove Battery";
            x = 0.57;  y = 0.52; w = 0.125; h = 0.04;
        };
        class BtnClose: RscButtonMenu {
            idc = 57105;
            text = "Close";
            x = 0.43;  y = 0.57; w = 0.14; h = 0.04;
        };
    };
};

class STA_foDialog {
    idd = 57002;
    movingEnable = 0;
    enableSimulation = 1;
    class Controls {
        class Title: RscTitle {
            idc = 57200;
            text = "Manage FO Roles";
            x = 0.35; y = 0.08; w = 0.3; h = 0.04;
        };
        class FoStatusTitle: RscTitle {
            idc = 57205;
            text = "Current FOs:";
            x = 0.65; y = 0.08; w = 0.2; h = 0.04;
        };
        class PlayerList: RscListBox {
            idc = 57201;
            x = 0.35; y = 0.13; w = 0.28; h = 0.38;
        };
        class FoList: RscListBox {
            idc = 57206;
            x = 0.65; y = 0.13; w = 0.2; h = 0.38;
        };
        class BtnGrant: RscButtonMenu {
            idc = 57202;
            text = "Grant FO ->";
            x = 0.35; y = 0.52; w = 0.135; h = 0.04;
        };
        class BtnRevoke: RscButtonMenu {
            idc = 57203;
            text = "<- Revoke FO";
            x = 0.495; y = 0.52; w = 0.135; h = 0.04;
        };
        class BtnClose: RscButtonMenu {
            idc = 57204;
            text = "Close";
            x = 0.43; y = 0.57; w = 0.14; h = 0.04;
        };
    };
};
