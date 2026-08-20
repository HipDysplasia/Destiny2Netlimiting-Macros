# Destiny 2 Desync Macro Suite

A collection of **AutoHotkey v2** macros for Destiny 2 that automate the keyboard, mouse, and loadout sequences used alongside a separate **NetLimiter** configuration.

## Quick Navigation

- [Macro / NetLimiter Mapping](#macro-netlimiter-mapping)
- [NetLimiter Setup](#netlimiter-setup)
  - [NetLimiter used by this setup](#netlimiter-used-by-this-setup)
  - [Useful Destiny 2 Netlimiting References](#useful-destiny-2-netlimiting-references)
  - [What the port names mean](#what-the-port-names-mean-in-this-setup)
  - [Recommended filter structure](#recommended-filter-structure)
- [Supported Resolutions](#supported-resolutions)
- [Key Binding Storage](#key-binding-storage)
- [Macro Overview](#macro-overview)
- [F3 — DualityChunk](#f3--dualitychunk)
- [F2 — DoT](#f2--dot)
- [F4 — TeamKill](#f4--teamkill)
- [F1 — Resync](#f1--resync)
- [All-in-One](#all-in-one)
- [Installation / Setup Checklist](#installation--setup-checklist)
- [Troubleshooting](#troubleshooting)
- [Reference Images](#reference-images)
- [Important Notes](#important-notes)

  - [Suggested rule layout](#suggested-rule-layout)
  - [How to identify the correct connection](#how-to-identify-the-correct-connection)
- [Reference Image](#reference-image)

> [!WARNING]
> **These macros use my personal keybinds and resolution.** If your Destiny 2 settings are different, you will need to modify the scripts yourself so the inputs and mouse coordinates match your game.
>
> **Supported resolutions:** `1680x1050`, `1920x1080`, `2304x1440`, `2560x1440`

> [!NOTE]
> **AI / authorship note:** The Macros AHK script was written by me. AI was used to make readability/organization improvements to parts of the scripts for easier future editing. The README files and the reference image were generated with AI from my own notes and specifications.
>
> The AI was used as an editing and presentation aid; the macro logic and intended setup are based on my own work and notes.

## Keybind Compatibility

The script automatically reads the following Destiny 2 binds from `cvars.xml` **immediately before every F1–F4 macro activation**:

| CVAR | Used for |
|---|---|
| `equipment_ability` | Super |
| `ui_open_start_menu_alternative` | Character Menu |
| `special_weapon` | Second weapon slot |
| `fire` | Fire / shooting input |

There is **no background keybind scanner**. Each macro gets a fresh read immediately before it starts, so the latest saved local bindings are used.

## Key Binding Storage

### IMPORTANT — Key Binding Storage

> **Set Destiny 2 → Global → Key Binding Storage → Computer.**

This is required for reliable automatic keybind detection. With **Account (Default)** storage, Destiny may restore account-side bindings independently of the local `cvars.xml`, meaning the local file may contain older bindings instead of the user's latest settings.

A reference image showing this setting is included with the project.

### Weapon-slot requirement

For maximum compatibility, keep the weapon slots preferably bound to:

```text
1 = Primary weapon
2 = Special / second slot
3 = Heavy weapon
```

The macro specifically requires a usable **second weapon slot bind** because TeamKill uses it.

If a required bind is `unused` or otherwise cannot be read, only the macro(s) that need that bind are disabled. The rest of the suite remains available.

### Fixed input

```text
Left Arrow = Loadouts in the Character Menu
```

Left Arrow remains fixed because loadout navigation is not user-rebindable in the setup targeted by this project.

`F1`–`F4` remain the AHK macro activation keys. `F5`–`F8` remain the external NetLimiter control keys and are not taken from Destiny's in-game keybind settings.

## Loadout Layout

Destiny 2 uses 20 loadout slots arranged as 5 rows of 4:

```text
1  2  3  4
5  6  7  8
9 10 11 12
13 14 15 16
17 18 19 20
```

This project specifically uses:

- **Loadout 1:** Final **Duality** loadout for DualityChunk.
- **Loadouts 2, 3, 4:** The three **Lorentz Driver** loadouts cycled repeatedly by DualityChunk.
- **Loadout 6:** The starting **TeamKill** loadout using **Slayer's Fang**.
- **Loadout 5:** The second **TeamKill** loadout using **Duality**.

For TeamKill, loadout **6 → 5 → 6** is the intended cycle. The two TeamKill loadouts should otherwise remain identical outside of the exotic weapon.



---

# Macro / NetLimiter Mapping

The default setup is:

| AHK Hotkey | Macro | NetLimiter control | Port | Direction |
|---|---|---|---:|---|
| `F1` | Resync | `F8` | `30000` | — |
| `F2` | DoT | `F5` | `3074` | **DL** |
| `F3` | DualityChunk | `F6` | `3074` | **UL** |
| `F4` | TeamKill | `F7` | `7500` | — |

In other words:

```text
F1 → Resync      → F8 → 30000 (30k)
F2 → DoT         → F5 → 3074DL
F3 → DualityChunk→ F6 → 3074UL
F4 → TeamKill    → F7 → 7500
```

The Macros AHK script **does not communicate with NetLimiter directly**. They simply press the corresponding F5/F6/F7/F8 keys at the required points in their sequences. The F-key actions themselves therefore need to be configured separately in NetLimiter / the surrounding setup.

---

# NetLimiter Setup

## NetLimiter used by this setup

This setup uses **HarryWatch**, a NetLimiter-based tool/configuration used to control the required Destiny 2 network ports.

[**HarryWatch — GitHub**](https://github.com/HarrySpce/HarryWatch)

Install and configure HarryWatch separately from Macros.ahk. The AHK script does not directly control NetLimiter; they only send the corresponding `F5`–`F8` keybinds used by the external setup.

## Useful Destiny 2 Netlimiting References

These are additional pre-existing Destiny 2 netlimiting resources that may be useful for learning more about the general techniques and setups. They are **reference material only** and are not part of this project.

- [Destiny 2 Netlimiting Reference / Guide](https://docs.google.com/document/d/1CuFbJ4KlbSMqf22lVap2yiSMHxLWRJpiMO1eIIpgtJQ/edit?tab=t.0#heading=h.eiku4bk1didu)
- [Additional Destiny 2 Netlimiting Guide](https://docs.google.com/document/d/1MbvwJBDC_Pcic5_m6xuyCvDxMnV7vPcEojG97G71mto/edit?tab=t.0)
- [HarryWatch / NetLimiter Resources](https://nl5p.harry.report/)

## What the port names mean in this setup

For this project, the NetLimiter controls are referred to as:

- **3074DL** → the download limit/control for port `3074` → bound to `F5`
- **3074UL** → the upload limit/control for port `3074` → bound to `F6`
- **7500** → the limit/control for port `7500` → bound to `F7`
- **30000 / 30k** → the limit/control for port `30000` → bound to `F8`

NetLimiter supports custom filters based on the application, local/remote port, and transport protocol, and its rules can then be applied to the traffic selected by that filter. Multiple filter functions are evaluated together, which allows an application + port + protocol filter to be made specific. citeturn558867search0

## Important: these are the ports used by this setup

This project specifically uses these **single port numbers** in its NetLimiter configuration:

```text
3074  → F5 / F6
7500  → F7
30000 → F8
```

They should **not** be confused with Bungie's complete Destiny 2 PC networking list. Bungie currently documents broader destination-port ranges, including `3074`, `7500-7509`, and `30000-30009`, among others. citeturn558867search2

So this README documents **the ports used by this particular macro setup**, not every Destiny 2 network port.

## Recommended filter structure

For a NetLimiter filter, the useful combination is generally:

```text
Application: Destiny 2
Transport protocol: UDP
Port: the specific port used by the rule
```

NetLimiter provides both **Remote port in range** and **Local port in range** filter functions. Use whichever matches the actual connection shown by NetLimiter on the machine being configured; do not blindly assume the port is always local or always remote. citeturn558867search0

For the download/upload controls, create the appropriate **DL Limit** or **UL Limit** rule on the matching filter. NetLimiter's documentation describes DL Limit and UL Limit as separate rule directions. citeturn558867search7

### Suggested rule layout

| Rule / Filter | Port | NetLimiter direction | AHK control key |
|---|---:|---|---|
| `3074DL` | `3074` | Download | `F5` |
| `3074UL` | `3074` | Upload | `F6` |
| `7500` | `7500` | As required by the setup | `F7` |
| `30000` / `30k` | `30000` | As required by the setup | `F8` |

### How to identify the correct connection

NetLimiter's Activity view can be used to inspect the connections generated by the game. Check the connection's application, protocol, and local/remote port before creating the final filter. This matters because a rule targeting the wrong side of the connection will not catch the intended traffic. citeturn558867search0

---

# Supported Resolutions

The project is distributed as **one `Macros.ahk` package**.

There is no startup resolution selector.

Before **DualityChunk (F3)** or **TeamKill (F4)** starts, the script reads Destiny 2's current saved fullscreen resolution from `cvars.xml` and selects the matching coordinate profile.

The script specifically reads:

```text
fullscreen_resolution_width
fullscreen_resolution_height
```

The separate:

```text
windowed_resolution_width
windowed_resolution_height
```

values are intentionally ignored.

This resolution check runs **every time F3 or F4 is activated**, so a newly saved fullscreen resolution is picked up on the next coordinate-based macro.

| Resolution | Status |
|---|---|
| `1680x1050` | Supported |
| `1920x1080` | Supported |
| `2304x1440` | Supported |
| `2560x1440` | Supported |

### Current loadout coordinates

| Resolution | D1 | D2 | D3 | D4 | T5 | T6 |
|---|---|---|---|---|---|---|
| `1680x1050` | `(107,446)` | `(175,446)` | `(263,446)` | `(350,446)` | `(107,529)` | `(175,529)` |
| `1920x1080` | `(123,380)` | `(215,380)` | `(307,380)` | `(399,380)` | `(123,480)` | `(215,480)` |
| `2304x1440` | `(147,613)` | `(240,613)` | `(360,613)` | `(480,613)` | `(147,725)` | `(240,725)` |
| `2560x1440` | `(164,507)` | `(287,507)` | `(409,507)` | `(532,507)` | `(164,640)` | `(287,640)` |

These coordinates are tied to the Destiny 2 loadout-menu layout and may require manual adjustment if the game UI changes or another resolution is added.

# Macro Overview

| Macro | Default Hotkey | NetLimiter Key | Port | Purpose |
|---|---|---|---:|---|
| **DualityChunk** | `F3` | `F6` | `3074UL` | Creates the Duality weapon desync state through repeated loadout swaps |
| **DoT** | `F2` | `F5` | `3074DL` | Uses the F5 control after casting a DoT super, then turns it back off |
| **TeamKill** | `F4` | `F7` | `7500` | Performs the TeamKill loadout swap / weapon sequence and restores the original loadout |
| **Resync** | `F1` | `F8` | `30000` | Temporarily interrupts the selected traffic, then restores it to force a reconnect/resync |

---

# F3 — DualityChunk

**Default AHK hotkey:** `F3`  
**NetLimiter control:** `F6`  
**Port:** `3074UL`

## What it does

DualityChunk is the main **weapon desync** setup.

It first limits the **3074 upload traffic**, then repeatedly swaps through completely different loadouts in order to create the desync state.

The DualityChunk loadout layout is fixed as follows: **loadout 1 is the final Duality loadout**, while **loadouts 2, 3, and 4 are the three Lorentz Driver loadouts used in the repeated cycle**.

The cycling loadouts should be substantially different from one another:

- Different subclass
- Different kinetic weapon
- Different armor
- Different armor mods
- Other relevant loadout differences
- The **heavy weapon may remain the same** when needed so that an **Eager Edge sword** does not lose its ammo
- Each cycling loadout should have **Lorentz Driver** equipped as the exotic weapon

The sequence eventually ends on a loadout containing the **Duality** exotic weapon. This final Duality loadout may reuse items from the earlier loadouts because it is not part of the repeated desync cycle.

After the final loadout is selected, the macro removes the `3074UL` limit by sending `F6` again.

The intended result is that the game is left in a **desynced state**, allowing the damage behavior associated with the desync to be used while the player is holding the Duality exotic weapon.

## Sequence

```text
F3
 ↓
F6  → Limit 3074UL
 ↓
Detected Character Menu bind → Open Character / Loadout screen
 ↓
Left Arrow
 ↓
Loadout 2
 ↓
Loadout 3
 ↓
Loadout 4
 ↓
Repeat the 2 → 3 → 4 cycle 60 times
 ↓
Loadout 1
 ↓
I   → Close Character / Loadout screen
 ↓
550 ms
 ↓
F6  → Remove 3074UL limit
```

## Important macro details

The mouse is blocked from manual movement while the automated loadout sequence is running so that the cursor cannot be moved away from the intended loadout buttons.

## Outside the sequence

There is no permanent mouse hook or background loop left running after F3 finishes. The macro only blocks mouse movement while the automated loadout selection is taking place and restores it afterward.

---

# F2 — DoT

**Default AHK hotkey:** `F2`  
**NetLimiter control:** `F5`  
**Port:** `3074DL`

## What it does

DoT is intended for **Damage Over Time super** usage.

After casting the super, the macro uses the `F5` control and then turns the super off again after a short delay.

The only super types intended for this setup are **Damage Over Time supers**. The two recommended examples are:

- **Warlock — Chaos Reach**
- **Titan — Thundercrash**, specifically on impact

A **weakening weapon such as Tractor Cannon** is also highly recommended for the intended damage setup.

## Important timing note

The DoT macro only handles the short F5-side sequence. After it finishes, the **3074DL limit must be removed manually** if it has not already been handled by the external setup.

> [!WARNING]
> **Do not leave the 3074DL limit active for longer than 30 seconds maximum.** The user must manually unlimit the port after the DoT sequence if it is still limited.

## AHK sequence

```text
F2
 ↓
Detected Super bind → Cast super
 ↓
40 ms
 ↓
F5  → 3074DL control
```

The AHK source does not itself remove the 3074DL limit afterward.

## Outside the sequence

There is no loop, mouse listener, persistent state, or background process associated with DoT. Pressing F2 runs the short input sequence once.

---

# F4 — TeamKill

**Default AHK hotkey:** `F4`  
**NetLimiter control:** `F7`  
**Port:** `7500`

## What it does

TeamKill limits the **7500** traffic and then swaps the player into a second loadout.

The starting loadout is **loadout 6** and should use the **Slayer's Fang** exotic weapon.

The second loadout is **loadout 5** and should use the **Duality** exotic weapon.

Outside of those two exotic weapons, loadouts **5 and 6** should otherwise be **identical**. This is intended to keep the loadout change as controlled as possible while changing the exotic weapon.

Once the second loadout is active, the macro waits for the player to aim at a person and **hold the detected Fire input for 1.5 seconds**. Once that condition is met, the macro removes the 7500 limit and swaps the loadout back to the original setup so the sequence can be performed again.

> [!NOTE]
> The script uses **1.5 seconds**, not 1.5 milliseconds, for the Mouse 1 hold.

## Sequence

### Initial F4 sequence

```text
F4
 ↓
Read current Destiny keybinds
 ↓
Read current fullscreen resolution
 ↓
F7  → Limit port 7500
 ↓
Detected Character Menu bind
 ↓
700 ms
 ↓
Left Arrow
 ↓
400 ms
 ↓
Select loadout 5
 ↓
Detected Character Menu bind → Close
 ↓
Arm detected Fire-input detector
```

### Fire-input sequence

Once F4 has armed the detector:

```text
Detected Fire input becomes held
 ↓
Check every 10 ms
 ↓
Continuous 1.5-second hold
 ↓
F7  → Remove 7500 limit
 ↓
Block mouse input during automated swap
 ↓
Detected second-weapon bind
 ↓
Detected Character Menu bind
 ↓
Left Arrow
 ↓
Select loadout 6
 ↓
Detected Character Menu bind → Close
 ↓
Restore mouse input
 ↓
Detector becomes inactive
```

A short Fire press resets the 1.5-second timer, so a later valid hold can still trigger TeamKill.

, the Mouse 1 detector is disabled until F4 is pressed again.

## Outside the sequence

The TeamKill detector is a temporary polling timer that is active only after F4 arms it. It does nothing unless F4 has armed it. During the automated loadout swap, the script blocks mouse input to prevent manual movement from interfering with the cursor coordinates.

---

# F1 — Resync

**Default AHK hotkey:** `F1`  
**NetLimiter control:** `F8`  
**Port:** `30000` / `30k`

## What it does

Resync is used after creating a desynced state with the DualityChunk macro.

It limits the **30000 (30k)** port for **30 seconds** and locks keyboard and mouse input during the wait. Around this point the game should disconnect from the relevant connection state. The macro then removes the limit by pressing F8 again, allowing the game to reconnect and **resync**.

## Sequence

```text
F1
 ↓
I   → Open Character / Loadout screen
 ↓
F8  → Limit 30000
 ↓
30 seconds
 ↓
F8  → Remove 30000 limit / restore connection
```

The important timing value is:

```text
30,000 ms = 30 seconds
```

The 30-second delay is intentional and is the timing used by this setup to reach the game's disconnect/reconnect point.

## Outside the sequence

Resync has no loop, mouse listener, or persistent state. It simply performs the one-time F8-on / F8-off sequence when F1 is pressed.

---

# All-in-One

This project is intentionally distributed as **one AHK script: `Macros.ahk`**.

The script contains all four functions under one package:

```text
F1 → Resync
F2 → DoT
F3 → DualityChunk
F4 → TeamKill
```

There are no separate macro AHK files to manage.

Before **every F1–F4 activation**, the script re-reads the relevant Destiny 2 keybinds from `cvars.xml`.

Before **F3/F4**, it also re-reads the current fullscreen resolution and loads the matching coordinate profile.

TeamKill uses the freshly detected Fire bind as its trigger and polls that input every 10 ms while the detector is armed. A continuous 1.5-second hold is required; a short press resets the timer.

The `F5`–`F8` controls remain external NetLimiter controls; the AHK script only sends those keys at the appropriate points.

# Installation / Setup Checklist

1. Install **AutoHotkey v2**.
2. In Destiny 2, set:
   **Global → Key Binding Storage → Computer**
3. Preferably keep weapon slots bound to:
   - `1` = Primary
   - `2` = Special / second slot
   - `3` = Heavy
4. Keep `Left Arrow` available for loadout navigation.
5. Prepare the required loadouts:
   - Loadout 1 = Duality final loadout
   - Loadouts 2–4 = Lorentz Driver cycle
   - Loadout 6 = TeamKill starting / return Slayer's Fang loadout
   - Loadout 5 = TeamKill Duality loadout
6. Set up the four NetLimiter controls:
   - `F5` → `3074DL`
   - `F6` → `3074UL`
   - `F7` → `7500`
   - `F8` → `30000 / 30k`
7. Start `Macros.ahk`.
8. Use F1–F4 for the required macro.

The script re-reads keybinds before every macro activation and re-reads the
fullscreen resolution before F3/F4.

# Troubleshooting

### The loadout clicks miss

F3/F4 read the fullscreen resolution from `cvars.xml` every time they start.
Make sure the game is using one of the supported resolutions and that the
coordinate profile is correct for the current Destiny UI.

### The detected keybinds are wrong

Check:

```text
Destiny 2 → Global → Key Binding Storage → Computer
```

The script reads the current saved bindings immediately before every macro.
Account storage can cause the local `cvars.xml` to contain older values.

### A required bind is unbound

Destiny represents an unbound control as `unused`. The script treats that as
unavailable and disables only the macro(s) that require the missing input.

### TeamKill does not trigger on the configured Fire bind

The current TeamKill detector does not rely on a fixed Mouse 1 hotkey.

When F4 is pressed, the script reads the current `fire` CVAR and then polls
that detected input every 10 ms.

The Fire input must remain continuously held for **1.5 seconds**. A shorter
press resets the hold timer, so a later valid hold can still trigger TeamKill.

### F5/F6/F7/F8 do not affect the expected traffic

The AHK script only sends the key. Verify that the corresponding NetLimiter rule
is enabled and that its filter matches the correct Destiny 2 connection,
protocol, and local/remote port.

### The wrong traffic is being limited

Open NetLimiter's Activity view and inspect the actual connection before adjusting
the filter. NetLimiter supports separate local-port and remote-port filters, so
selecting the wrong side of the connection can cause the rule to miss the intended
traffic. citeturn558867search0

### Mouse input becomes stuck during a macro

The loadout macros use `BlockInput` while the automated cursor movements or loadout
swap are being performed. Cleanup logic restores normal input afterward.

### DoT is left limited

The DoT setup is intentionally different: the user must manually remove the
**3074DL** limit after the sequence, and it should **never remain limited for
longer than 30 seconds maximum**.

### Resync does not happen at exactly the same moment

The 30-second timer is a practical default for this setup, not a guaranteed
universal Destiny 2 disconnect threshold. Network/game state can affect the
actual disconnect timing.

# Reference Images

`Loadouts.png` & `Ports.png` are provided in the accompanying ZIP and contain the ports and loadouts as the visual reference for the NetLimiter configuration.

---

# Important Notes

- The macro suite is distributed as **one `Macros.ahk` package**.
- DualityChunk and TeamKill use resolution-specific hard-coded mouse coordinates.
- Fullscreen resolution is detected from `cvars.xml` immediately before F3/F4.
- The four relevant Destiny keybinds are re-read from `cvars.xml` immediately before every F1–F4 activation.
- **Key Binding Storage must be set to `Computer`** for local `cvars.xml` keybind detection to reliably reflect the user's current bindings.
- Detected keybinds:
  - `equipment_ability` → Super
  - `ui_open_start_menu_alternative` → Character Menu
  - `special_weapon` → second weapon slot
  - `fire` → Fire/shoot input
- `Left Arrow` remains fixed for loadout navigation.
- `unused` is treated as an unbound input; only affected macros are disabled.
- TeamKill polls the detected Fire input every 10 ms while armed and requires a continuous 1.5-second hold.
- `F1`–`F4` are the macro activation keys.
- `F5`–`F8` are the controls the macros send for the external network-limiting setup.
- The AHK script itself does **not** create or modify NetLimiter rules.
- Bungie's published Destiny 2 PC networking information contains broader port ranges than the four specific port numbers used by this project. The project-specific mappings above are therefore a description of this setup, not a complete list of Destiny 2 networking requirements. citeturn558867search2
