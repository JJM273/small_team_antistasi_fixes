# FO Role + Post-Fire Battery Movement Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a CBA PBO mod (`@A3A_SmallTeam`) that lets the Antistasi commander delegate artillery call authority to FO players and automatically moves committed batteries to the next waypoint after each fire mission.

**Architecture:** Two CBA function overrides (`A3A_fnc_artySupport` and `SCRT_fnc_ui_toggleCommanderMenu`) handle access and menu injection. Three server-authoritative `publicVariable` globals (`STA_foPlayers`, `STA_batteryPool`, `STA_batteryWaypoints`) hold session state. All inter-machine communication uses `remoteExec`; no spawning or despawning of units.

**Tech Stack:** Arma 3 SQF, CBA3 (addons: cba_main), Antistasi Ultimate (A3A_main, SCRT addons). Build tool: Mikero PBO tools or BI Tools `makepbo`. Load order: our mod after Antistasi.

**Compatibility note:** The `fn_artySupport.sqf` override is a full file replacement. If Antistasi Ultimate updates that function, the override must be re-synced manually.

---

## File Map

```
@A3A_SmallTeam/
  addons/
    sta_fo/
      $PBOPREFIX$                        ← "STA\sta_fo"
      config.cpp                         ← CfgPatches + #includes
      CfgFunctions.hpp                   ← our functions + two A3A/SCRT overrides
      CfgSettings.hpp                    ← three CBA addon settings
      dialogs.hpp                        ← STA_batteryDialog (idd 57001) + STA_foDialog (idd 57002)
      script_component.hpp               ← CBA PREFIX macro
      functions/
        fn_initServer.sqf                ← init STA_* globals, server only
        fn_initClient.sqf                ← register FO keybind, inject commander button hook
        fn_artySupport.sqf               ← OVERRIDE of A3A_fnc_artySupport
        fn_toggleCommanderMenu.sqf       ← OVERRIDE of SCRT_fnc_ui_toggleCommanderMenu
        fn_postFireMonitor.sqf           ← server: wait unitReady → move battery
        fn_commitBattery.sqf             ← server: add vehicle to STA_batteryPool
        fn_removeBattery.sqf             ← server: remove vehicle + clear waypoints
        fn_setBatteryWaypoints.sqf       ← server: store waypoint cycle for battery
        fn_grantFoRole.sqf               ← server: add UID to STA_foPlayers
        fn_revokeFoRole.sqf              ← server: remove UID from STA_foPlayers
        fn_batteryManageMenu.sqf         ← client: open + wire battery management dialog
        fn_foRoleMenu.sqf                ← client: open + wire FO role dialog
```

---

## Task 1: PBO Scaffold

**Files:**
- Create: `@A3A_SmallTeam/addons/sta_fo/$PBOPREFIX$`
- Create: `@A3A_SmallTeam/addons/sta_fo/script_component.hpp`
- Create: `@A3A_SmallTeam/addons/sta_fo/config.cpp`
- Create: `@A3A_SmallTeam/addons/sta_fo/CfgFunctions.hpp`
- Create: `@A3A_SmallTeam/addons/sta_fo/CfgSettings.hpp`
- Create: `@A3A_SmallTeam/addons/sta_fo/dialogs.hpp`
- Create: all 12 stub `functions/*.sqf` files

- [ ] **Step 1: Create the directory tree**

```bash
mkdir -p @A3A_SmallTeam/addons/sta_fo/functions
```

- [ ] **Step 2: Write `$PBOPREFIX$`**

File content (exactly one line, no newline):
```
STA\sta_fo
```

- [ ] **Step 3: Write `script_component.hpp`**

```cpp
#define COMPONENT sta_fo
#define COMPONENT_BEAUTIFIED STA FO
#include "\x\cba\addons\main\script_macros.hpp"
```

- [ ] **Step 4: Write `config.cpp`**

```cpp
#include "script_component.hpp"

class CfgPatches {
    class sta_fo {
        units[] = {};
        weapons[] = {};
        requiredVersion = 1.0;
        requiredAddons[] = {"cba_main", "A3A_main", "SCRT_main"};
    };
};

#include "CfgFunctions.hpp"
#include "CfgSettings.hpp"
#include "dialogs.hpp"
```

- [ ] **Step 5: Write `CfgFunctions.hpp`**

```cpp
class CfgFunctions {
    // Our own functions
    class STA {
        class default {
            file = QPATHTOFOLDER(functions);
            class initServer      { postInit = 1; serverInit = 1; };
            class initClient      { postInit = 1; };
            class postFireMonitor {};
            class commitBattery   {};
            class removeBattery   {};
            class setBatteryWaypoints {};
            class grantFoRole     {};
            class revokeFoRole    {};
            class batteryManageMenu {};
            class foRoleMenu      {};
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
```

- [ ] **Step 6: Write `CfgSettings.hpp`** (stub — real content added in Task 2)

```cpp
// CBA addon settings registered in fn_initClient.sqf
```

- [ ] **Step 7: Write `dialogs.hpp`** (stub — real content added in Task 8/9)

```cpp
// Dialogs defined in Tasks 8 and 9
```

- [ ] **Step 8: Create stub SQF files**

Create each of the following with a single-line body `// stub`:

```
functions/fn_initServer.sqf
functions/fn_initClient.sqf
functions/fn_artySupport.sqf
functions/fn_toggleCommanderMenu.sqf
functions/fn_postFireMonitor.sqf
functions/fn_commitBattery.sqf
functions/fn_removeBattery.sqf
functions/fn_setBatteryWaypoints.sqf
functions/fn_grantFoRole.sqf
functions/fn_revokeFoRole.sqf
functions/fn_batteryManageMenu.sqf
functions/fn_foRoleMenu.sqf
```

- [ ] **Step 9: Commit**

```bash
git add @A3A_SmallTeam/
git commit -m "feat: scaffold sta_fo PBO structure"
```

---

## Task 2: CBA Settings

**Files:**
- Modify: `functions/fn_initClient.sqf`

CBA settings must be registered at mission start on every client via `CBA_fnc_addSetting`. The three settings below are global (server-side value applies to all).

- [ ] **Step 1: Write settings registration in `fn_initClient.sqf`**

Replace the stub with:

```sqf
// fn_initClient.sqf
// Runs postInit on every client (and server if it hosts)
#include "script_component.hpp"

// Register CBA addon settings
[
    "STA_setting_foRequireRadio",
    "CHECKBOX",
    ["Require radio for FO", "FO must carry a radio to open the artillery interface (mirrors boss radio check)"],
    "A3A Small Team",
    true,
    true
] call CBA_fnc_addSetting;

[
    "STA_setting_foCanSetWaypoints",
    "CHECKBOX",
    ["FOs can set waypoints", "Allows FO-role players to configure battery firing positions (boss can always do this)"],
    "A3A Small Team",
    false,
    true
] call CBA_fnc_addSetting;

[
    "STA_setting_postFireMoveDelay",
    "SLIDER",
    ["Post-fire move delay (s)", "Seconds after last round before battery moves to next position"],
    "A3A Small Team",
    [0, 120, 5, 30],   // [min, max, step, default]
    true
] call CBA_fnc_addSetting;

// Remaining client init goes in Task 11
```

- [ ] **Step 2: Verify settings appear in game**

Launch Arma 3 with CBA and the mod loaded (no Antistasi needed for this step). Open **Configure Addons** → confirm three settings appear under "A3A Small Team".

- [ ] **Step 3: Commit**

```bash
git add functions/fn_initClient.sqf
git commit -m "feat: register CBA addon settings"
```

---

## Task 3: Server Init

**Files:**
- Modify: `functions/fn_initServer.sqf`

Initialises the three global state variables on the server and broadcasts them. Uses `serverInit = 1` in CfgFunctions so it runs automatically.

- [ ] **Step 1: Write `fn_initServer.sqf`**

```sqf
// fn_initServer.sqf
// Runs postInit on server only (serverInit = 1 in CfgFunctions)
#include "script_component.hpp"

if (!isServer) exitWith {};

// Authoritative session state
STA_foPlayers       = [];           // array of player UIDs with FO role
STA_batteryPool     = [];           // array of committed artillery vehicles
STA_batteryWaypoints = createHashMap; // vehicle -> [[pos,...], currentIndex]

publicVariable "STA_foPlayers";
publicVariable "STA_batteryPool";
publicVariable "STA_batteryWaypoints";
```

- [ ] **Step 2: Verify initialisation via debug console (server)**

In the Arma 3 editor, run as server or host:
```sqf
hint str [typeName STA_foPlayers, typeName STA_batteryPool, typeName STA_batteryWaypoints];
```
Expected hint: `["ARRAY","ARRAY","HASHMAP"]`

- [ ] **Step 3: Commit**

```bash
git add functions/fn_initServer.sqf
git commit -m "feat: initialise server-side STA_* global state"
```

---

## Task 4: Post-Fire Monitor

**Files:**
- Modify: `functions/fn_postFireMonitor.sqf`

Called via `remoteExec` on the server after each fire mission. Waits until the battery finishes firing, applies the configured delay, clears stale waypoints, and issues a move order to the next position in the cycle.

- [ ] **Step 1: Write `fn_postFireMonitor.sqf`**

```sqf
// fn_postFireMonitor.sqf
// Called server-side via remoteExec ["STA_fnc_postFireMonitor", 2]
// params: [netId string of the battery vehicle]
#include "script_component.hpp"

params ["_netId"];
[_netId] spawn {
    params ["_netId"];
    private _vehicle = objectFromNetId _netId;
    if (isNull _vehicle) exitWith {};

    private _timeout = time + 600; // 10-minute safety timeout

    // Wait until the gun is done and not busy
    waitUntil {
        sleep 2;
        !alive _vehicle || { unitReady _vehicle } || { time > _timeout }
    };

    if (!alive _vehicle || time > _timeout) exitWith {};

    // Apply configured delay before moving
    sleep STA_setting_postFireMoveDelay;

    // Look up waypoint cycle for this battery
    private _waypointData = STA_batteryWaypoints getOrDefault [_vehicle, [[], 0]];
    _waypointData params ["_positions", "_idx"];
    if (_positions isEqualTo []) exitWith {}; // no waypoints set, stay put

    // Advance cycle index (wraps around)
    private _nextPos   = _positions select _idx;
    private _nextIdx   = (_idx + 1) mod count _positions;
    STA_batteryWaypoints set [_vehicle, [_positions, _nextIdx]];
    publicVariable "STA_batteryWaypoints";

    // Clear queued waypoints then issue move order
    private _grp = group (gunner _vehicle);
    while { count waypoints _grp > 0 } do { deleteWaypoint [_grp, 0] };
    _grp setCurrentWaypoint [_grp addWaypoint [_nextPos, 0]];
};
```

- [ ] **Step 2: Test the monitor in isolation (editor, run as server)**

Place an artillery vehicle in editor. Open debug console and run:

```sqf
// Setup fake battery with 2 waypoints
private _veh = (nearestObjects [player, ["B_MBT_01_arty_F"], 200]) select 0;
STA_batteryWaypoints = createHashMap;
STA_batteryWaypoints set [_veh, [[getPos player vectorAdd [200,0,0], getPos player vectorAdd [400,0,0]], 0]];
STA_setting_postFireMoveDelay = 5;

// Trigger the monitor
[netId _veh] remoteExec ["STA_fnc_postFireMonitor", 2];
hint "Monitor started - vehicle should move in ~5s if unitReady";
```

Expected: vehicle group moves toward `player pos + [200,0,0]` within ~7 seconds. Run again → moves to `+[400,0,0]`. Run again → wraps back to `+[200,0,0]`.

- [ ] **Step 3: Commit**

```bash
git add functions/fn_postFireMonitor.sqf
git commit -m "feat: post-fire battery movement monitor"
```

---

## Task 5: Server Battery Functions

**Files:**
- Modify: `functions/fn_commitBattery.sqf`
- Modify: `functions/fn_removeBattery.sqf`
- Modify: `functions/fn_setBatteryWaypoints.sqf`

These run server-side, called via `remoteExec ["STA_fnc_X", 2]` from clients.

- [ ] **Step 1: Write `fn_commitBattery.sqf`**

```sqf
// fn_commitBattery.sqf
// params: [netId string]
// Adds vehicle to STA_batteryPool if valid and not already present
#include "script_component.hpp"

params ["_netId"];
private _vehicle = objectFromNetId _netId;
if (isNull _vehicle || !alive _vehicle) exitWith {};
if (getNumber (configFile >> "CfgVehicles" >> typeOf _vehicle >> "artilleryScanner") != 1) exitWith {};
if (_vehicle in STA_batteryPool) exitWith {};

STA_batteryPool pushBack _vehicle;
publicVariable "STA_batteryPool";
```

- [ ] **Step 2: Write `fn_removeBattery.sqf`**

```sqf
// fn_removeBattery.sqf
// params: [netId string]
// Removes vehicle from pool and clears its waypoint cycle
#include "script_component.hpp"

params ["_netId"];
private _vehicle = objectFromNetId _netId;
STA_batteryPool = STA_batteryPool - [_vehicle];
STA_batteryWaypoints deleteAt _vehicle;
publicVariable "STA_batteryPool";
publicVariable "STA_batteryWaypoints";
```

- [ ] **Step 3: Write `fn_setBatteryWaypoints.sqf`**

```sqf
// fn_setBatteryWaypoints.sqf
// params: [netId string, [[x,y,z],...] positions array]
// Stores or replaces the waypoint cycle for a battery; resets index to 0
#include "script_component.hpp"

params ["_netId", "_positions"];
private _vehicle = objectFromNetId _netId;
if (isNull _vehicle) exitWith {};

STA_batteryWaypoints set [_vehicle, [_positions, 0]];
publicVariable "STA_batteryWaypoints";
```

- [ ] **Step 4: Test battery functions (editor, server debug console)**

```sqf
// Place an arty vehicle in editor first, get its netId
private _veh = (nearestObjects [player, ["B_MBT_01_arty_F"], 500]) select 0;
private _id = netId _veh;

// Test commit
[_id] remoteExec ["STA_fnc_commitBattery", 2];
sleep 0.5;
hint format ["Pool size: %1", count STA_batteryPool];
// Expected hint: "Pool size: 1"

// Test setWaypoints
[_id, [getPos player vectorAdd [300,0,0]]] remoteExec ["STA_fnc_setBatteryWaypoints", 2];
sleep 0.5;
hint str (STA_batteryWaypoints get _veh);
// Expected: "[[<pos>],0]"

// Test remove
[_id] remoteExec ["STA_fnc_removeBattery", 2];
sleep 0.5;
hint format ["Pool size after remove: %1", count STA_batteryPool];
// Expected: "Pool size after remove: 0"
```

- [ ] **Step 5: Commit**

```bash
git add functions/fn_commitBattery.sqf functions/fn_removeBattery.sqf functions/fn_setBatteryWaypoints.sqf
git commit -m "feat: server-side battery pool management functions"
```

---

## Task 6: Server FO Role Functions

**Files:**
- Modify: `functions/fn_grantFoRole.sqf`
- Modify: `functions/fn_revokeFoRole.sqf`

- [ ] **Step 1: Write `fn_grantFoRole.sqf`**

```sqf
// fn_grantFoRole.sqf
// params: [UID string]
// Adds UID to STA_foPlayers if not already present
#include "script_component.hpp"

params ["_uid"];
if (_uid in STA_foPlayers) exitWith {};
STA_foPlayers pushBack _uid;
publicVariable "STA_foPlayers";
```

- [ ] **Step 2: Write `fn_revokeFoRole.sqf`**

```sqf
// fn_revokeFoRole.sqf
// params: [UID string]
// Removes UID from STA_foPlayers
#include "script_component.hpp"

params ["_uid"];
STA_foPlayers = STA_foPlayers - [_uid];
publicVariable "STA_foPlayers";
```

- [ ] **Step 3: Test FO role functions (editor, server debug console)**

```sqf
private _uid = getPlayerUID player;

[_uid] remoteExec ["STA_fnc_grantFoRole", 2];
sleep 0.5;
hint format ["FO list: %1", STA_foPlayers];
// Expected: FO list contains your UID

[_uid] remoteExec ["STA_fnc_revokeFoRole", 2];
sleep 0.5;
hint format ["FO list after revoke: %1", STA_foPlayers];
// Expected: FO list is empty []
```

- [ ] **Step 4: Commit**

```bash
git add functions/fn_grantFoRole.sqf functions/fn_revokeFoRole.sqf
git commit -m "feat: server-side FO role grant/revoke functions"
```

---

## Task 7: Battery Management Dialog

**Files:**
- Modify: `dialogs.hpp`
- Modify: `functions/fn_batteryManageMenu.sqf`

- [ ] **Step 1: Add battery dialog to `dialogs.hpp`**

```cpp
class RscTitle;
class RscListBox;
class RscButtonMenu;

class STA_batteryDialog {
    idd = 57001;
    movingEnable = false;
    enableSimulation = true;
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
```

- [ ] **Step 2: Write `fn_batteryManageMenu.sqf`**

```sqf
// fn_batteryManageMenu.sqf
// Opens the battery management dialog and wires all buttons.
// Must run on the commander's client only.
#include "script_component.hpp"

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

// ── Commit New ──────────────────────────────────────────────────────────────
(_display displayCtrl 57102) ctrlAddEventHandler ["ButtonClick", {
    closeDialog 0;
    [] spawn {
        if (!visibleMap) then { openMap true };
        ["Battery Commit", "Click the map position of the artillery vehicle to commit."] call A3A_fnc_customHint;

        STA_commitClickPos = nil;
        onMapSingleClick "STA_commitClickPos = _pos; onMapSingleClick '';";
        waitUntil { sleep 0.1; !isNil "STA_commitClickPos" || !visibleMap };

        if (isNil "STA_commitClickPos") exitWith { [] call STA_fnc_batteryManageMenu };
        private _pos  = STA_commitClickPos;
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
        sleep 0.6; // allow publicVariable to propagate
        [] call STA_fnc_batteryManageMenu;
    };
}];

// ── Set Waypoints ────────────────────────────────────────────────────────────
(_display displayCtrl 57103) ctrlAddEventHandler ["ButtonClick", {
    disableSerialization;
    private _selIdx = lbCurSel (findDisplay 57001 displayCtrl 57101);
    if (_selIdx < 0) exitWith {
        ["Battery Waypoints", "Select a battery from the list first."] call A3A_fnc_customHint;
    };
    // Check if FO is allowed to set waypoints (setting checked here, not server-side)
    // Boss always allowed; FOs need STA_setting_foCanSetWaypoints = true (irrelevant here since
    // batteryManageMenu is boss-only, but wired through the same button for completeness)
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

// ── Remove Battery ───────────────────────────────────────────────────────────
(_display displayCtrl 57104) ctrlAddEventHandler ["ButtonClick", {
    disableSerialization;
    private _selIdx = lbCurSel (findDisplay 57001 displayCtrl 57101);
    if (_selIdx < 0) exitWith {
        ["Battery Remove", "Select a battery from the list first."] call A3A_fnc_customHint;
    };
    private _battery = STA_batteryPool select _selIdx;
    [netId _battery] remoteExec ["STA_fnc_removeBattery", 2];
    sleep 0.6;
    closeDialog 0;
    [] call STA_fnc_batteryManageMenu;
}];

// ── Close ─────────────────────────────────────────────────────────────────────
(_display displayCtrl 57105) ctrlAddEventHandler ["ButtonClick", { closeDialog 0; }];
```

- [ ] **Step 3: Test dialog in editor**

In editor as the commander (make player `== theBoss` or temporarily bypass the check), run:
```sqf
[] call STA_fnc_batteryManageMenu;
```
Expected: dialog opens. Commit a nearby arty vehicle via map click → listbox updates. Set 2 waypoints → hint confirms. Remove → listbox shrinks.

- [ ] **Step 4: Commit**

```bash
git add dialogs.hpp functions/fn_batteryManageMenu.sqf
git commit -m "feat: battery management dialog"
```

---

## Task 8: FO Role Management Dialog

**Files:**
- Modify: `dialogs.hpp`
- Modify: `functions/fn_foRoleMenu.sqf`

- [ ] **Step 1: Add FO dialog to `dialogs.hpp`** (append below the battery dialog)

```cpp
class STA_foDialog {
    idd = 57002;
    movingEnable = false;
    enableSimulation = true;
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
            text = "Grant FO →";
            x = 0.35; y = 0.52; w = 0.135; h = 0.04;
        };
        class BtnRevoke: RscButtonMenu {
            idc = 57203;
            text = "← Revoke FO";
            x = 0.495; y = 0.52; w = 0.135; h = 0.04;
        };
        class BtnClose: RscButtonMenu {
            idc = 57204;
            text = "Close";
            x = 0.43; y = 0.57; w = 0.14; h = 0.04;
        };
    };
};
```

- [ ] **Step 2: Write `fn_foRoleMenu.sqf`**

```sqf
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

// Build current FO list by name
lbClear _foCtrl;
{
    private _uid = _x;
    private _unit = (playableUnits select { isPlayer _x && getPlayerUID _x == _uid }) param [0, objNull];
    if (!isNull _unit) then { _foCtrl lbAdd name _unit };
} forEach STA_foPlayers;

// ── Grant FO ────────────────────────────────────────────────────────────────
(_display displayCtrl 57202) ctrlAddEventHandler ["ButtonClick", {
    disableSerialization;
    private _selIdx = lbCurSel (findDisplay 57002 displayCtrl 57201);
    if (_selIdx < 0) exitWith {
        ["FO Roles", "Select a player from the left list first."] call A3A_fnc_customHint;
    };
    private _humanPlayers = playableUnits select { isPlayer _x && !(_x isEqualTo theBoss) };
    private _target = _humanPlayers select _selIdx;
    private _uid = getPlayerUID _target;
    [_uid] remoteExec ["STA_fnc_grantFoRole", 2];
    sleep 0.6;
    closeDialog 0;
    [] call STA_fnc_foRoleMenu;
}];

// ── Revoke FO ────────────────────────────────────────────────────────────────
(_display displayCtrl 57203) ctrlAddEventHandler ["ButtonClick", {
    disableSerialization;
    private _selIdx = lbCurSel (findDisplay 57002 displayCtrl 57206);
    if (_selIdx < 0) exitWith {
        ["FO Roles", "Select a player from the right list first."] call A3A_fnc_customHint;
    };
    private _uid = STA_foPlayers select _selIdx;
    [_uid] remoteExec ["STA_fnc_revokeFoRole", 2];
    sleep 0.6;
    closeDialog 0;
    [] call STA_fnc_foRoleMenu;
}];

// ── Close ─────────────────────────────────────────────────────────────────────
(_display displayCtrl 57204) ctrlAddEventHandler ["ButtonClick", { closeDialog 0; }];
```

- [ ] **Step 3: Test in editor with two players**

As boss, run:
```sqf
[] call STA_fnc_foRoleMenu;
```
Expected: left list shows other players; right list shows current FOs (empty initially). Grant one → right list updates. Revoke → right list shrinks.

- [ ] **Step 4: Commit**

```bash
git add dialogs.hpp functions/fn_foRoleMenu.sqf
git commit -m "feat: FO role management dialog"
```

---

## Task 9: Commander Menu Injection

**Files:**
- Modify: `functions/fn_toggleCommanderMenu.sqf`

This is a complete replacement of `SCRT_fnc_ui_toggleCommanderMenu`. The only change from the original is two lines after `SCRT_fnc_ui_populateCommanderMenu` runs: show a small "Manage Artillery" action button.

- [ ] **Step 1: Write `fn_toggleCommanderMenu.sqf`**

This is a verbatim copy of the original `SCRT_fnc_ui_toggleCommanderMenu.sqf` from Antistasi with our additions marked:

```sqf
// fn_toggleCommanderMenu.sqf
// Override of SCRT_fnc_ui_toggleCommanderMenu
// Only change: injects "Manage Artillery" and "Manage FO Roles" buttons after
// the commander menu is opened. All other logic is identical to Antistasi original.
#include "script_component.hpp"

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

        // ── STA ADDITION: inject buttons into the open commander menu ──────────
        [] call STA_fnc_injectCommanderButton;
        // ──────────────────────────────────────────────────────────────────────
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
```

- [ ] **Step 2: Add `fn_injectCommanderButton` to `CfgFunctions.hpp`**

Inside the `class STA { class default {` block, add:
```cpp
class injectCommanderButton {};
```

- [ ] **Step 3: Create `functions/fn_injectCommanderButton.sqf`**

```sqf
// fn_injectCommanderButton.sqf
// Programmatically adds two buttons to the already-open commanderMenu display.
// Called immediately after createDialog "commanderMenu".
#include "script_component.hpp"

disableSerialization;
private _display = findDisplay 70000; // commanderMenu IDD — verify against Antistasi dialogs.hpp
if (isNull _display) exitWith {};

// "Manage Artillery" button
private _btnArty = _display ctrlCreate ["RscButtonMenu", -1];
_btnArty ctrlSetPosition [0.01, 0.9, 0.16, 0.04];
_btnArty ctrlSetText "Manage Artillery";
_btnArty ctrlCommit 0;
_btnArty ctrlAddEventHandler ["ButtonClick", {
    closeDialog 0; // close commander menu
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
```

**Important:** The IDD `70000` and button position `[0.01, 0.9, ...]` are best-guess values. Before finalising, open the Antistasi `commanderMenu` dialog class in Antistasi's `UILayouts/` or `dialogs.hpp` and confirm the IDD and available screen space so the buttons don't overlap existing controls.

- [ ] **Step 4: Test in editor with Antistasi loaded**

As the commander, press the commander menu keybind. Confirm:
- Commander menu opens normally with all Antistasi tabs intact
- Two new buttons appear ("Manage Artillery", "Manage FO Roles") without overlapping existing controls
- Clicking "Manage Artillery" closes the commander menu and opens the battery dialog
- Clicking "Manage FO Roles" closes the commander menu and opens the FO dialog

- [ ] **Step 5: Commit**

```bash
git add functions/fn_toggleCommanderMenu.sqf functions/fn_injectCommanderButton.sqf CfgFunctions.hpp
git commit -m "feat: inject Manage Artillery and FO Roles buttons into commander menu"
```

---

## Task 10: `fn_artySupport` Override

**Files:**
- Modify: `functions/fn_artySupport.sqf`

This is the largest task. The file is a complete replacement of `A3A_fnc_artySupport`. Only the **top block** (role check + group sourcing) and **the very end** (post-fire event) differ from the Antistasi original. Everything in the middle is copied verbatim.

- [ ] **Step 1: Copy the original `A3A_fnc_artySupport` into `fn_artySupport.sqf`**

Fetch the current source:
```bash
gh api repos/Antistasi-Ultimate-Community/A3-Antistasi-Ultimate/contents/A3A/addons/core/functions/AI/fn_artySupport.sqf \
  --jq '.content' | base64 -d > functions/fn_artySupport.sqf
```

- [ ] **Step 2: Replace the opening block**

The original begins:
```sqf
if (count hcSelected player == 0) exitWith {[localize "STR_A3A_ai_artySupport_header", localize "STR_A3A_ai_artySupport_must_select"] call A3A_fnc_customHint;};

private ["_groups","_artyArray", ...];

_groups = hcSelected player;
_fdc = leader (_groups select 0);
_unitsX = [];
{_groupX = _x;
{_unitsX pushBack _x} forEach units _groupX;
} forEach _groups;
```

Replace everything **up to and including the `forEach _groups;` line** with:

```sqf
// ── STA: Role gate ────────────────────────────────────────────────────────────
#include "script_component.hpp"
private _isBoss = player isEqualTo theBoss;
private _isFO   = (getPlayerUID player) in STA_foPlayers;
if (!_isBoss && !_isFO) exitWith {};

if (STA_setting_foRequireRadio && { !([player] call A3A_fnc_hasRadio) }) exitWith {
    [localize "STR_A3A_ai_artySupport_header", "You need a radio to call artillery."] call A3A_fnc_customHint;
};
// ─────────────────────────────────────────────────────────────────────────────

private ["_groups","_artyArray","_artyRoundsArr","_hasAmmunition","_areReady","_hasArtillery","_areAlive","_soldierX","_veh","_typeAmmunition","_typeArty","_positionTel","_artyArrayDef1","_artyRoundsArr1","_piece","_isInRange","_positionTel2","_rounds","_roundsMax","_markerX","_size","_forcedX","_textX","_mrkFinal","_mrkFinal2","_timeX","_eta","_countX","_pos","_ang"];

// ── STA: Group sourcing ───────────────────────────────────────────────────────
if (_isBoss) then {
    if (count hcSelected player == 0) exitWith {
        [localize "STR_A3A_ai_artySupport_header", localize "STR_A3A_ai_artySupport_must_select"] call A3A_fnc_customHint;
    };
    _groups = hcSelected player;
} else {
    // FO path: use committed battery pool instead of HC selection
    private _liveBatteries = STA_batteryPool select { alive _x };
    if (_liveBatteries isEqualTo []) exitWith {
        [localize "STR_A3A_ai_artySupport_header", "No batteries committed by commander."] call A3A_fnc_customHint;
    };
    _groups = _liveBatteries apply { group (gunner _x) };
    _groups = _groups select { !isNull _x && { count units _x > 0 } };
    if (_groups isEqualTo []) exitWith {
        [localize "STR_A3A_ai_artySupport_header", "No active batteries available."] call A3A_fnc_customHint;
    };
};
// ─────────────────────────────────────────────────────────────────────────────

_fdc = leader (_groups select 0);
_unitsX = [];
{_groupX = _x;
{_unitsX pushBack _x} forEach units _groupX;
} forEach _groups;
```

- [ ] **Step 3: Add the post-fire event at the end**

Find this line near the end of the file (just before `sleep 10;`):
```sqf
    [player,"sideChat",localize "STR_chats_splash_out"] remoteExec ["A3A_fnc_commsMP",[teamPlayer,civilian]];
    };
```

After that closing brace (end of the non-BARRAGE splash block), add:

```sqf
// ── STA: trigger post-fire monitor for each battery that fired ────────────────
{ [netId _x] remoteExec ["STA_fnc_postFireMonitor", 2] } forEach _artyArrayDef1;
// ─────────────────────────────────────────────────────────────────────────────
```

- [ ] **Step 4: Test boss path unchanged**

As commander with HC artillery selected, press the existing arty keybind. Confirm:
- Ammo dialog opens, map clicks work, rounds fire — identical to vanilla Antistasi behavior
- After splash, post-fire monitor moves the battery (if waypoints set)

- [ ] **Step 5: Test FO path**

With FO role granted to a second player, commit a battery, set waypoints. FO presses FO keybind (Task 11). Confirm:
- Ammo dialog opens, map click targets, rounds fire
- Battery moves to next waypoint after `STA_setting_postFireMoveDelay` seconds

- [ ] **Step 6: Test FO blocked without role**

As a player without FO role or boss role, press FO keybind. Confirm nothing happens (keybind exits silently).

- [ ] **Step 7: Commit**

```bash
git add functions/fn_artySupport.sqf
git commit -m "feat: artySupport override — FO role check and battery pool substitution"
```

---

## Task 11: Client Init + FO Keybind

**Files:**
- Modify: `functions/fn_initClient.sqf`

Append to the existing settings registration block (Task 2) to add the FO keybind and ensure STA_* globals exist on clients that join after server init.

- [ ] **Step 1: Append to `fn_initClient.sqf`**

```sqf
// (appended after the CBA_fnc_addSetting calls from Task 2)

// Ensure globals exist on clients (server broadcasts on init, but joining clients
// may connect after that; fall back to empty values if not yet received)
if (isNil "STA_foPlayers")        then { STA_foPlayers        = [] };
if (isNil "STA_batteryPool")      then { STA_batteryPool      = [] };
if (isNil "STA_batteryWaypoints") then { STA_batteryWaypoints = createHashMap };

// FO keybind: Ctrl+Shift+A (DIK_A = 30)
// Opens the artillery interface for FOs (and boss as fallback).
// Boss already has the vanilla arty keybind via Antistasi; this adds FO access.
[
    "sta_fo",
    "STA_FO_Artillery",
    ["FO Artillery", "Open the artillery fire mission interface (FO or commander)"],
    {
        // action
        if (player getVariable ["incapacitated", false]) exitWith {};
        if (player getVariable ["owner", player] != player) exitWith {};
        private _isBoss = player isEqualTo theBoss;
        private _isFO   = (getPlayerUID player) in STA_foPlayers;
        if (!_isBoss && !_isFO) exitWith {};
        [] spawn A3A_fnc_artySupport;
    },
    {},           // conditions (none extra)
    [30, [true, true, false]], // Ctrl+Shift+A default
    false,        // not overridable
    false         // works while on foot and in vehicle
] call CBA_fnc_addKeybind;
```

- [ ] **Step 2: Test keybind appears in controls**

Launch Arma 3 with both CBA and the mod. Open **Options → Controls → Configure Addons → STA FO**. Confirm "FO Artillery" keybind is listed with default Ctrl+Shift+A.

- [ ] **Step 3: Test keybind fires correctly**

As FO (role granted), press Ctrl+Shift+A → arty interface opens.
As non-FO non-boss, press Ctrl+Shift+A → nothing happens.

- [ ] **Step 4: Commit**

```bash
git add functions/fn_initClient.sqf
git commit -m "feat: FO keybind and client-side global fallbacks"
```

---

## Task 12: Integration Test

No new files. Full end-to-end validation in the Arma 3 editor.

- [ ] **Step 1: Editor setup**

- Place 2 playable units
- Place 1 `B_MBT_01_arty_F` (Paladin) or `B_Mortar_01_F` with AI crew
- Load: CBA, Antistasi Ultimate, `@A3A_SmallTeam` (our mod, after Antistasi in load order)
- Host as Player 1 (commander / theBoss equivalent — use Antistasi's boss transfer if needed)
- Player 2 joins as FO candidate

- [ ] **Step 2: Grant FO role**

Commander opens commander menu → "Manage FO Roles" → grants Player 2 as FO.
Verify: `hint str STA_foPlayers` on Player 2's machine shows their UID.

- [ ] **Step 3: Commit battery**

Commander → "Manage Artillery" → "Commit New" → clicks arty vehicle on map.
Verify: listbox shows the vehicle. `hint str (count STA_batteryPool)` → `1`.

- [ ] **Step 4: Set 3 waypoints**

Commander selects battery → "Set Waypoints" → clicks 3 positions on map → closes map.
Verify: hint confirms 3 positions. `hint str (STA_batteryWaypoints get (STA_batteryPool select 0))` shows 3-element array.

- [ ] **Step 5: FO calls fire mission**

Player 2 presses Ctrl+Shift+A → selects ammo → clicks target → selects round count → confirms.
Verify: arty vehicle fires rounds. After `STA_setting_postFireMoveDelay` seconds, vehicle moves toward waypoint 1.

- [ ] **Step 6: Second fire mission, verify cycle**

Player 2 calls another fire mission. After completion, vehicle moves to waypoint 2.

- [ ] **Step 7: Boss retains access throughout**

Commander presses existing Antistasi arty keybind with HC group selected. Confirm unaffected.

- [ ] **Step 8: Blocked access**

Add a 3rd player with no FO role. Ctrl+Shift+A → nothing. Verify no error in RPT.

- [ ] **Step 9: Battery destroyed mid-mission**

Commit a battery, set waypoints, FO calls fire. While mid-fire, delete the vehicle via editor.
Verify: no RPT errors, monitor exits cleanly.

- [ ] **Step 10: Final commit**

```bash
git add -A
git commit -m "test: integration test checklist complete"
```

---

## Known Limitations / Follow-Up

- `fn_artySupport.sqf` override must be re-synced when Antistasi Ultimate updates that function.
- Commander menu button positions (`fn_injectCommanderButton.sqf`) need visual tuning against Antistasi's actual IDD layout.
- FO waypoint-setting (when `STA_setting_foCanSetWaypoints = true`) is not yet exposed via a keybind — it could be added as a follow-up menu entry.
- Phase 2 (Support Caller role / TAB menu delegation) is a separate plan.
