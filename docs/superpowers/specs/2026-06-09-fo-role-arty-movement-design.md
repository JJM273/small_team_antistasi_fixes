# FO Role + Post-Fire Battery Movement — Design Spec

**Date:** 2026-06-09
**Project:** A3A_SmallTeam — CBA PBO mod alongside Antistasi Ultimate
**Scope:** Phase 1 of 2 (this spec). Phase 2 will cover the Support Caller role.

---

## Problem

Antistasi Ultimate's artillery interface (`fn_artySupport`) is gated to the commander (`theBoss`) only. In small-group play (2–4 humans), this creates a bottleneck — the commander must personally call every fire mission while also managing the rest of the battle. Additionally, HC-committed artillery batteries stay stationary after firing, making them easy targets for counter-battery fire.

---

## Goals

1. Allow the commander to delegate artillery call authority to one or more players (FO role).
2. Allow the commander (and optionally FOs, via setting) to pre-define firing position cycles for committed batteries.
3. After each fire mission, automatically move the battery to the next position in its cycle.
4. Expose configuration via the CBA Configure Addons menu.

---

## Non-Goals

- No unit spawning or despawning. All batteries must already exist in the world.
- No changes to the Antistasi support pipeline (mortar/artillery supports that spawn AI).
- No new fire mission UI. The existing `fn_artySupport` dialogs are reused as-is.
- Phase 2 (Support Caller role / TAB menu delegation) is out of scope here.

---

## Delivery

**Mod name:** `@A3A_SmallTeam`
**Type:** CBA PBO, loads alongside Antistasi Ultimate
**Compatibility:** Does not fork or patch Antistasi files. Uses CBA `CfgFunctions` overrides only for `A3A_fnc_artySupport` and the commander menu population function.

---

## Architecture

### Server-Authoritative Global Variables

| Variable | Type | Description |
|---|---|---|
| `STA_foPlayers` | Array of UIDs | Players granted FO role this session |
| `STA_batteryPool` | Array of Objects | Vehicles committed by commander as FO-callable batteries |
| `STA_batteryWaypoints` | HashMap `Object -> [[pos,...], index]` | Firing position cycle per battery |

All three are set server-side and broadcast via `publicVariable` to keep all clients current.

### Data Flow

```
Boss UI action
  → remoteExec to server
    → update STA_* variable
      → publicVariable to all clients

FO presses keybind
  → gate check: UID in STA_foPlayers OR player == theBoss
  → if FO (not boss): substitute STA_batteryPool groups for hcSelected player
  → spawn A3A_fnc_artySupport  (existing function, unchanged from here)
    → existing dialogs: mortarType, strikeType, roundsNumber, map clicks
      → commandArtilleryFire (client-side, unchanged)
        → CBA global event "STA_postFireStart" fires to server with [vehicleNetId]
          → server post-fire monitor loop starts
            → polls unitReady every 2s (timeout 10 min)
              → doMove battery group to next waypoint
              → advance cycle index (wraps)
```

---

## Components

### 1. `fn_artySupport` Override

**File:** `functions/fo/fn_artySupport.sqf`
**Registered as:** override of `A3A_fnc_artySupport` via `CfgFunctions`

The only change from the original is the opening block:

- **Original:** `if (count hcSelected player == 0) exitWith {...}` then `_groups = hcSelected player`
- **Override:** Check `player isEqualTo theBoss OR UID in STA_foPlayers`. If boss, proceed with `hcSelected player` exactly as before. If FO, substitute: `_groups = STA_batteryPool apply { group (gunner _x) } select { !isNull _x }`. If pool is empty, show "No batteries committed by commander" hint and exit.

Everything after `_groups` is populated — ammo dialog, map clicks, `commandArtilleryFire` — runs unchanged.

After the fire commands issue, the override sends a CBA `targetEvent` (directed to server) `"STA_postFireStart"` with the netId of each battery that fired. The server handler picks this up and spawns `fn_postFireMonitor` per battery.

### 2. Commander Battery Management

**Entry point:** New button appended to the Antistasi commander menu via a `displayAddEventHandler ["KeyDown"]` hook on the `commanderMenu` display, or a CBA `addAction` on the map control — whichever attaches without touching `SCRT_fnc_ui_populateCommanderMenu` (avoiding a fragile full override of that function).

**Sub-actions available to boss only:**

- **Commit battery** — boss clicks a vehicle on the map; script checks `artilleryScanner = 1` in CfgVehicles; adds to `STA_batteryPool`; `remoteExec` to server; `publicVariable`.
- **Set waypoints** — boss selects a battery from pool, then clicks 2–5 map positions in order; stored in `STA_batteryWaypoints`; `remoteExec` to server.
- **Remove battery** — removes from pool and clears its waypoints.

If the CBA setting `STA_setting_foCanSetWaypoints` is true, FOs get access to "Set waypoints" only (not commit/remove).

### 3. FO Role Grant/Revoke

**Entry point:** Second new button in commander menu ("Manage FO Roles").

Shows the current player list (reuses Antistasi's `A3A_fnc_membersList` pattern). Boss toggles FO status per player. Change `remoteExec`es to server → updates `STA_foPlayers` array → `publicVariable`.

### 4. Post-Fire Movement Monitor

**File:** `functions/fo/fn_postFireMonitor.sqf`
**Triggered by:** CBA global event `STA_postFireStart`, server-side only.

```
params ["_vehicle"];
private _timeout = time + 600;
waitUntil {
    sleep 2;
    !alive _vehicle ||
    unitReady _vehicle ||
    time > _timeout
};
if (!alive _vehicle) exitWith {};
if (time > _timeout) exitWith {};

private _waypointData = STA_batteryWaypoints getOrDefault [_vehicle, [[], 0]];
_waypointData params ["_positions", "_idx"];
if (_positions isEqualTo []) exitWith {};

sleep STA_setting_postFireMoveDelay;

private _nextPos = _positions select _idx;
private _nextIdx = (_idx + 1) mod count _positions;
STA_batteryWaypoints set [_vehicle, [_positions, _nextIdx]];
publicVariable "STA_batteryWaypoints";

private _grp = group (gunner _vehicle);
while { count waypoints _grp > 0 } do { deleteWaypoint [_grp, 0] };
_grp setCurrentWaypoint [_grp addWaypoint [_nextPos, 0]];
```

### 5. CBA Settings

Registered in `CfgSettings` / Configure Addons menu under "A3A Small Team":

| Setting | ID | Type | Default | Description |
|---|---|---|---|---|
| FOs can set waypoints | `STA_setting_foCanSetWaypoints` | Bool | false | Allows FO-role players to configure battery firing positions |
| Post-fire move delay | `STA_setting_postFireMoveDelay` | Slider 0–120 | 30 | Seconds after last round before battery moves |
| Require radio for FO | `STA_setting_foRequireRadio` | Bool | true | FO must carry a radio to open the artillery interface |

---

## Error Handling

| Scenario | Behaviour |
|---|---|
| Battery not alive | Skipped in `_groups` construction; existing "no capability" hint fires |
| Battery out of range | Existing range check in `fn_artySupport` catches it |
| Battery already firing | Existing "busy" hint (`unitReady` false) |
| Pool empty when FO opens menu | "No batteries committed by commander" hint, exits before any dialog |
| FO lacks radio (if setting on) | Same `A3A_fnc_hasRadio` check Antistasi runs for boss |
| Battery destroyed during monitor | `isAlive` check before `doMove`; monitor exits cleanly |
| No waypoints set for battery | Monitor fires CBA event but skips move; battery stays put |
| Monitor timeout (10 min) | Loop exits; no move issued; no error |

---

## PBO Structure

```
@A3A_SmallTeam/
  addons/
    sta_fo/
      $PBOPREFIX$          ← sta_fo
      config.cpp           ← CfgFunctions, CfgSettings, script_component.hpp
      functions/
        fo/
          fn_artySupport.sqf        ← override
          fn_postFireMonitor.sqf    ← new
        commander/
          fn_commitBattery.sqf
          fn_setBatteryWaypoints.sqf
          fn_removeBattery.sqf
          fn_grantFoRole.sqf
          fn_revokeFoRole.sqf
          fn_injectCommanderButtons.sqf ← hooks into commanderMenu display EH; no populateCommanderMenu override
        init/
          fn_initServer.sqf         ← initialises STA_* variables on server
          fn_initClient.sqf         ← registers keybind, CBA event handlers
```

---

## Testing Checklist

1. FO keybind does nothing before role is granted; opens menu after.
2. Boss always retains access regardless of FO list state.
3. Commit a battery → appears in FO battery list; remove it → disappears.
4. Set 3 waypoints → after fire mission 1 battery moves to pos 2; after mission 2 moves to pos 3; after mission 3 wraps to pos 1.
5. Destroy battery mid-mission → monitor loop exits cleanly, no errors in RPT.
6. `STA_setting_foRequireRadio = true` → FO without radio sees hint and cannot proceed.
7. `STA_setting_foCanSetWaypoints = false` → FO cannot access waypoint UI.
8. Antistasi PATCOM mortars param disabled → no effect on our code path.
9. Two FOs simultaneously call different batteries → both fire missions proceed independently.
