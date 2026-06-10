class CfgPatches
{
	class sta_fo
	{
		units[]={};
		weapons[]={};
		requiredVersion=1;
		requiredAddons[]=
		{
			"cba_main"
		};
	};
};
class CfgFunctions
{
	class STA
	{
		class default
		{
			file="\sta_fo\functions";
			class initServer
			{
				postInit=1;
				serverInit=1;
			};
			class initClient
			{
				postInit=1;
			};
			class postFireMonitor
			{
			};
			class commitBattery
			{
			};
			class removeBattery
			{
			};
			class setBatteryWaypoints
			{
			};
			class grantFoRole
			{
			};
			class revokeFoRole
			{
			};
			class batteryManageMenu
			{
			};
			class foRoleMenu
			{
			};
			class injectCommanderButton
			{
			};
		};
	};
	class A3A
	{
		class AI
		{
			class artySupport
			{
			};
		};
	};
	class SCRT
	{
		class ui
		{
			class ui_toggleCommanderMenu
			{
			};
		};
	};
};
class RscTitle;
class RscListBox;
class RscButtonMenu;
class STA_batteryDialog
{
	idd=57001;
	movingEnable="false";
	enableSimulation="true";
	class Controls
	{
		class Title: RscTitle
		{
			idc=57100;
			text="Battery Management";
			x=0.30000001;
			y=0.079999998;
			w=0.40000001;
			h=0.039999999;
		};
		class BatteryList: RscListBox
		{
			idc=57101;
			x=0.30000001;
			y=0.13;
			w=0.40000001;
			h=0.38;
		};
		class BtnCommit: RscButtonMenu
		{
			idc=57102;
			text="Commit New";
			x=0.30000001;
			y=0.51999998;
			w=0.125;
			h=0.039999999;
		};
		class BtnWaypoints: RscButtonMenu
		{
			idc=57103;
			text="Set Waypoints";
			x=0.435;
			y=0.51999998;
			w=0.125;
			h=0.039999999;
		};
		class BtnRemove: RscButtonMenu
		{
			idc=57104;
			text="Remove Battery";
			x=0.56999999;
			y=0.51999998;
			w=0.125;
			h=0.039999999;
		};
		class BtnClose: RscButtonMenu
		{
			idc=57105;
			text="Close";
			x=0.43000001;
			y=0.56999999;
			w=0.14;
			h=0.039999999;
		};
	};
};
class STA_foDialog
{
	idd=57002;
	movingEnable="false";
	enableSimulation="true";
	class Controls
	{
		class Title: RscTitle
		{
			idc=57200;
			text="Manage FO Roles";
			x=0.34999999;
			y=0.079999998;
			w=0.30000001;
			h=0.039999999;
		};
		class FoStatusTitle: RscTitle
		{
			idc=57205;
			text="Current FOs:";
			x=0.64999998;
			y=0.079999998;
			w=0.2;
			h=0.039999999;
		};
		class PlayerList: RscListBox
		{
			idc=57201;
			x=0.34999999;
			y=0.13;
			w=0.28;
			h=0.38;
		};
		class FoList: RscListBox
		{
			idc=57206;
			x=0.64999998;
			y=0.13;
			w=0.2;
			h=0.38;
		};
		class BtnGrant: RscButtonMenu
		{
			idc=57202;
			text="Grant FO ->";
			x=0.34999999;
			y=0.51999998;
			w=0.13500001;
			h=0.039999999;
		};
		class BtnRevoke: RscButtonMenu
		{
			idc=57203;
			text="<- Revoke FO";
			x=0.495;
			y=0.51999998;
			w=0.13500001;
			h=0.039999999;
		};
		class BtnClose: RscButtonMenu
		{
			idc=57204;
			text="Close";
			x=0.43000001;
			y=0.56999999;
			w=0.14;
			h=0.039999999;
		};
	};
};
class cfgMods
{
	author="DeltaEagle55";
	timepacked="1781108103";
};
