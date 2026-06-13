# A3A Small Team Fixes

A client/server mod for **Antistasi Ultimate** that makes artillery and the Forward Observer role playable in small groups (2–4 players). In vanilla Antistasi the commander delegates artillery to an HC squad and other players can't touch it; this mod changes that.

**Requirements:** Antistasi Ultimate, CBA_A3

---

## What it does

### Forward Observer (FO) role
The commander can designate any player as a Forward Observer. FOs get full access to the artillery fire mission interface — the same interface the commander uses — without needing to be the boss. This lets one player command while another handles fire support.

### Post-fire artillery displacement (`sta_extd_arty_movement`)
Artillery vehicles automatically advance to their next Zeus waypoint after completing a fire mission. The mod detects eligible artillery groups on a configurable timer, calculates cooldown from the vehicle's actual reload time, and advances the group's HOLD waypoint once the gun has gone quiet long enough. Compatible with Antistasi's mortyAI (infantry mortar crews that despawn/respawn the mortar at each position).

### Manual Zeus control (`sta_arty_move`)
A lighter script for one-off situations. Double-click any artillery vehicle in Zeus → Execute box → run the call below. The vehicle advances its waypoint chain after each salvo using a fixed cooldown you specify.

---

## Post-fire displacement: setup

### Auto mode (`sta_extd_arty_movement`)

**Server setup** (done once per session — the addon handles the rest):

1. In Zeus, give each artillery group a waypoint chain:
   - Place **HOLD** waypoints at each desired firing position
   - Place a **CYCLE** waypoint at the end to loop back
2. The addon detects eligible artillery groups automatically on the periodic scan interval (default: every 30 s)
3. After firing, the group waits for cooldown (derived from reload time × multiplier), then advances to the next waypoint

Eligibility: any group on the player side with a vehicle that has `artilleryScanner = 1` in config. Override with the included/excluded class settings.

**To force-monitor a specific vehicle** (skips eligibility check — useful for non-standard vehicles or immediate effect before the next scan):

Open Zeus → double-click the vehicle → Execute box (Local Exec):
```sqf
[vehicle this] call STA_fnc_extdArtyAddGroupMonitor;
```

---

### Manual mode (`sta_arty_move`)

In Zeus → double-click the vehicle → Execute box (Local Exec):
```sqf
// Default 15 s cooldown:
[vehicle this] call STA_fnc_artyMoveMonitor;

// Custom cooldown (seconds):
[vehicle this, 30] call STA_fnc_artyMoveMonitor;
```

Requires: the vehicle's group has at least one waypoint already set in Zeus, and the vehicle has a driver.

To stop monitoring early:
```sqf
_yourVehicle setVariable ["STA_artyMove_active", false, true];
```

---

## Forward Observer role: setup

### Assign FO roles

1. Open the **Commander Menu** (default: Tab)
2. Go to the **ARTILLERY** tab
3. Click **Manage FO Roles**
4. Select a player from the left list and click **Grant FO →**
5. To remove: select from the right list and click **← Revoke FO**

FO role persists for the session.

### Artillery tab buttons

| Button | Who | What it does |
|---|---|---|
| Manage Artillery | Commander | Register/remove artillery vehicles from the fire mission pool |
| Manage FO Roles | Commander | Grant or revoke FO designation for players |

---

## Controls

| Keybind | Default | Who can use |
|---|---|---|
| Open artillery interface | **Ctrl + Shift + A** | Commander, any FO |

Rebind in **Options → Controls → Configure Addons → A3A Small Team**.

---

## CBA Settings

Found under **Options → Addon Options → A3A Small Team**:

### `sta_extd_arty_movement` (server-side)

| Setting | Default | Description |
|---|---|---|
| Auto arty movement | On | Automatically attach post-fire waypoint advancement to eligible artillery groups |
| Scan interval (s) | 30 | How often to search for new eligible groups |
| Included vehicle classes | *(empty)* | Comma-separated classnames to force-include (overrides the `artilleryScanner` check) |
| Excluded vehicle classes | *(empty)* | Comma-separated classnames to exclude from auto-detection |
| Cooldown multiplier | 1.5 | Detected reload time is multiplied by this; result is the post-fire wait before advancing |
| Minimum cooldown (s) | 10 | Floor cooldown regardless of calculated value |
| Debug level | 0 | 0 = off. 1 = chat when groups reposition/arrive. 2 = verbose (scan, cooldown resets, HOLD checks) |

---

## Installation

Copy all `.pbo` files from `@A3A_SmallTeam/addons/` into your server's `@A3A_SmallTeam/addons/` folder. Load `@A3A_SmallTeam` as an Arma 3 mod on **both server and all clients**.

Build PBOs with [HEMTT](https://github.com/BrettMayson/HEMTT) from the `@A3A_SmallTeam/` directory:
```
cd @A3A_SmallTeam
hemtt build
```
