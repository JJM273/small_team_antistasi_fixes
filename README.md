# A3A Small Team Fixes

A client/server mod for **Antistasi Ultimate** that makes artillery and the Forward Observer role playable in small groups (2–4 players). In vanilla Antistasi the commander delegates artillery to an HC squad and other players can't touch it; this mod changes that.

**Requirements:** Antistasi Ultimate, CBA_A3

---

## What it does

### Forward Observer (FO) role
The commander can designate any player as a Forward Observer. FOs get full access to the artillery fire mission interface — the same interface the commander uses — without needing to be the boss. This lets one player command while another handles fire support.

### Post-fire battery movement
After an artillery battery fires, it automatically moves to its next pre-set firing position after a configurable delay. This simulates counter-battery survivability without needing a dedicated driver. The battery cycles through all its waypoints in order, wrapping back to the start.

---

## Controls

| Keybind | Default | Who can use |
|---|---|---|
| Open artillery interface | **Ctrl + Shift + A** | Commander, any FO |

The keybind can be rebound in **Options → Controls → Configure Addons → A3A Small Team**.

---

## Commander setup

### 1. Commit artillery batteries

Before batteries can be used for fire missions you need to register them.

1. Open the **Commander Menu** (default: Tab)
2. Click **Manage Artillery**
3. Click **Commit New**
4. The map opens — click the map position of an artillery vehicle you own
5. The nearest uncommitted artillery vehicle within 50m of your click is added to the pool
6. Repeat for each battery

The list shows each committed battery's vehicle type and map grid position.

### 2. Set firing waypoints (post-fire movement)

For each battery you want to automatically displace after firing:

1. Open **Manage Artillery**, select the battery from the list
2. Click **Set Waypoints**
3. The map opens — click up to **5 firing positions** in the order you want the battery to cycle through
4. Close the map when done

After each fire mission the battery waits for the configured delay, then moves to the next position in the cycle. If no waypoints are set the battery stays put.

To update waypoints, select the battery and click **Set Waypoints** again — this replaces the existing waypoints.

### 3. Assign FO roles

1. Open the **Commander Menu** (Tab)
2. Click **Manage FO Roles**
3. The left list shows all connected players (excluding yourself)
4. Select a player and click **Grant FO →** to give them the FO role
5. To remove the role, select the player in the right list and click **← Revoke FO**

FO role persists for the session. Players who disconnect and reconnect retain the role.

### 4. Remove a battery

In **Manage Artillery**, select the battery and click **Remove Battery** to deregister it from the pool (e.g. if it was destroyed or you want to swap it out).

---

## Forward Observer usage

Once granted the FO role:

1. Press **Ctrl + Shift + A** to open the artillery fire mission interface (same as the commander's interface)
2. Select a battery and target — all committed batteries are available
3. The battery fires, then automatically displaces to its next waypoint after the post-fire delay

FOs use the same `STA_batteryPool` as the commander. There is no separate FO battery list — the commander controls which batteries are in the pool.

---

## CBA Settings

Found under **Options → Addon Options → A3A Small Team**:

| Setting | Default | Description |
|---|---|---|
| Require radio for FO | On | FO must carry a radio to open the artillery interface (mirrors the boss radio requirement) |
| FOs can set waypoints | Off | Allows FOs to configure battery firing positions via the waypoint tool (commander can always do this) |
| Post-fire move delay (s) | 5 | Seconds after the last round fires before the battery moves to its next position (0–120) |

---

## Installation

Copy `STA_sta_fo.pbo` (from `.hemttout/build/addons/`) into your `@A3A_SmallTeam\addons\` folder and load `@A3A_SmallTeam` as an Arma 3 mod alongside Antistasi Ultimate. Load on both server and all clients.
