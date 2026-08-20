#Requires AutoHotkey v2.0
#SingleInstance Force

; ============================================================
; DESTINY 2 - ALL IN ONE (MULTI-RESOLUTION)
; ============================================================
; Supported resolutions:
; - 1680x1050
; - 1920x1080
; - 2304x1440
; - 2560x1440
;
; IMPORTANT:
; DualityChunk and TeamKill use resolution-specific loadout coordinates.
; The profiles below contain the currently configured coordinates for
; each supported resolution. If a new resolution is added, create a new
; profile and verify its loadout coordinates manually.
;
; F1 = Resync       -> Character menu bind + F8, lock input, wait 30s, F8 off
; F2 = DoT          -> Detected Super bind + F5 on/off
; F3 = DualityChunk -> Refresh keybinds + resolution, then F6/loadout cycle
; F4 = TeamKill     -> Refresh keybinds + resolution, then F7/loadout swap + fire hold
; ============================================================


; ============================================================
; RESOLUTION PROFILES
; ============================================================
; DualityChunk and TeamKill use resolution-specific loadout
; coordinates. The active fullscreen resolution is read from
; Destiny 2's cvars.xml each time one of those macros starts.
;
; The script specifically reads:
; fullscreen_resolution_width
; fullscreen_resolution_height
;
; It intentionally does NOT use the windowed resolution values.
; ============================================================

global SelectedResolution := ""
global LoadoutProfiles := Map()
global mouseMonitorActive := false

; Destiny 2 keybinds read from cvars.xml.
; These are refreshed immediately before each macro is activated so
; the script always uses the latest saved local keybind settings.
; Resolution is refreshed immediately before F3/F4 because those macros
; use resolution-dependent mouse coordinates.
global SuperBind := "z"
global CharacterMenuBind := "i"
global SpecialWeaponBind := "2"
global FireBind := "LButton"
global teamKillHoldStart := 0
global teamKillHoldTriggered := false

; A macro is available only when every bind it requires is detected.
global ResyncAvailable := false
global DoTAvailable := false
global DualityAvailable := false
global TeamKillAvailable := false

LoadoutProfiles["1680x1050"] := Map(
    "Duality1", [107, 446],
    "Duality2", [175, 446],
    "Duality3", [263, 446],
    "Duality4", [350, 446],
    "TeamKill5", [107, 529],
    "TeamKill6", [175, 529]
)

LoadoutProfiles["1920x1080"] := Map(
    "Duality1", [123, 380],
    "Duality2", [215, 380],
    "Duality3", [307, 380],
    "Duality4", [399, 380],
    "TeamKill5", [123, 480],
    "TeamKill6", [215, 480]
)

LoadoutProfiles["2304x1440"] := Map(
    "Duality1", [147, 613],
    "Duality2", [240, 613],
    "Duality3", [360, 613],
    "Duality4", [480, 613],
    "TeamKill5", [147, 725],
    "TeamKill6", [240, 725]
)

LoadoutProfiles["2560x1440"] := Map(
    "Duality1", [164, 507],
    "Duality2", [287, 507],
    "Duality3", [409, 507],
    "Duality4", [532, 507],
    "TeamKill5", [164, 640],
    "TeamKill6", [287, 640]
)

; ============================================================
; SHARED COORDINATES
; ============================================================
; These variables are refreshed immediately before F3/F4 runs from
; Destiny 2's current fullscreen resolution.
; ============================================================

global Loadout1X, Loadout1Y
global Loadout2X, Loadout2Y
global Loadout3X, Loadout3Y
global Loadout4X, Loadout4Y
global TeamKill5X, TeamKill5Y
global TeamKill6X, TeamKill6Y

CoordMode "Mouse", "Screen"

UpdateResolutionProfile()
{
    global SelectedResolution, LoadoutProfiles
    global Loadout1X, Loadout1Y
    global Loadout2X, Loadout2Y
    global Loadout3X, Loadout3Y
    global Loadout4X, Loadout4Y
    global TeamKill5X, TeamKill5Y
    global TeamKill6X, TeamKill6Y

    cvarsPath := A_AppData "\Bungie\DestinyPC\prefs\cvars.xml"

    if !FileExist(cvarsPath)
    {
        MsgBox "Could not find Destiny 2 cvars.xml:`n`n" cvarsPath, "Destiny 2 Macro Suite"
        return false
    }

    try
        cvars := FileRead(cvarsPath, "UTF-8")
    catch
    {
        MsgBox "Could not read Destiny 2 cvars.xml:`n`n" cvarsPath, "Destiny 2 Macro Suite"
        return false
    }

    if !RegExMatch(cvars, 'i)<cvar\s+name="fullscreen_resolution_width"\s+value="(\d+)"', &widthMatch)
        || !RegExMatch(cvars, 'i)<cvar\s+name="fullscreen_resolution_height"\s+value="(\d+)"', &heightMatch)
    {
        MsgBox "Could not read Destiny 2 fullscreen resolution from cvars.xml.", "Destiny 2 Macro Suite"
        return false
    }

    SelectedResolution := widthMatch[1] "x" heightMatch[1]

    if !LoadoutProfiles.Has(SelectedResolution)
    {
        MsgBox "Unsupported Destiny 2 resolution detected:`n`n" SelectedResolution "`n`nAdd a matching coordinate profile to AllInOne.ahk before using DualityChunk or TeamKill at this resolution.", "Destiny 2 Macro Suite"
        return false
    }

    profile := LoadoutProfiles[SelectedResolution]

    Loadout1X := profile["Duality1"][1]
    Loadout1Y := profile["Duality1"][2]
    Loadout2X := profile["Duality2"][1]
    Loadout2Y := profile["Duality2"][2]
    Loadout3X := profile["Duality3"][1]
    Loadout3Y := profile["Duality3"][2]
    Loadout4X := profile["Duality4"][1]
    Loadout4Y := profile["Duality4"][2]
    TeamKill5X := profile["TeamKill5"][1]
    TeamKill5Y := profile["TeamKill5"][2]
    TeamKill6X := profile["TeamKill6"][1]
    TeamKill6Y := profile["TeamKill6"][2]

    return true
}

; ============================================================
; DESTINY 2 KEYBIND DETECTION
; ============================================================
; Reads these values from Destiny 2's cvars.xml:
; - super                             -> Super
; - ui_open_start_menu_alternative    -> Character menu
; - special_weapon                    -> Second weapon slot
; - fire                              -> Mouse / fire input
;
; Keybinds are re-read immediately before each macro activation.
; This keeps the macro synchronized with the latest saved cvars.xml
; without leaving a background scanner running.
;
; The cvars.xml values look like:
;     value="z!unused"
;     value="left mouse button!unused"
;
; Only the value before "!unused" is used.
; ============================================================

NormalizeDestinyBind(bindName)
{
    bindName := StrLower(Trim(bindName))

    ; Destiny uses "unused" for an unbound control.
    if (bindName = "" || bindName = "unused")
        return ""

    static bindMap := Map(
        "left mouse button", "LButton",
        "right mouse button", "RButton",
        "middle mouse button", "MButton",
        "mouse button 4", "XButton1",
        "mouse button 5", "XButton2",
        "space", "Space",
        "control", "Ctrl",
        "ctrl", "Ctrl",
        "shift", "Shift",
        "alt", "Alt",
        "enter", "Enter",
        "escape", "Esc",
        "esc", "Esc",
        "tab", "Tab",
        "backspace", "Backspace",
        "delete", "Delete",
        "insert", "Insert",
        "home", "Home",
        "end", "End",
        "page up", "PgUp",
        "page down", "PgDn",
        "up", "Up",
        "down", "Down",
        "left", "Left",
        "right", "Right"
    )

    if bindMap.Has(bindName)
        return bindMap[bindName]

    ; Single letters, numbers, punctuation, and F-keys can be passed
    ; through directly to AHK.
    return bindName
}

ReadDestinyCvar(cvars, cvarName, &bindValue)
{
    pattern := 'i)<cvar\s+name="' cvarName '"\s+value="([^"]+)"'
    if !RegExMatch(cvars, pattern, &match)
        return false

    bindValue := StrSplit(match[1], "!")[1]
    return true
}

UpdateKeybinds()
{
    global SuperBind, CharacterMenuBind, SpecialWeaponBind, FireBind
    global ActiveFireDownHotkey, ActiveFireUpHotkey
    global ResyncAvailable, DoTAvailable, DualityAvailable, TeamKillAvailable

    ; Start each scan in a safe state. If cvars.xml cannot be read,
    ; no macro should attempt to use stale or unknown bindings.
    ResyncAvailable := false
    DoTAvailable := false
    DualityAvailable := false
    TeamKillAvailable := false

    cvarsPath := A_AppData "\Bungie\DestinyPC\prefs\cvars.xml"

    if !FileExist(cvarsPath)
    {
        return false
    }

    try
        cvars := FileRead(cvarsPath, "UTF-8")
    catch
    {
        return false
    }

    required := Map(
        "super", "",
        "ui_open_start_menu_alternative", "",
        "special_weapon", "",
        "fire", ""
    )

    for cvarName, _ in required
    {
        value := ""
        if !ReadDestinyCvar(cvars, cvarName, &value)
        {
            return false
        }

        required[cvarName] := NormalizeDestinyBind(value)
    }

    SuperBind := required["super"]
    CharacterMenuBind := required["ui_open_start_menu_alternative"]
    SpecialWeaponBind := required["special_weapon"]
    FireBind := required["fire"]

    ; Each macro validates only the bindings it actually needs.
    ResyncAvailable := (CharacterMenuBind != "")
    DoTAvailable := (SuperBind != "")
    DualityAvailable := (CharacterMenuBind != "")
    TeamKillAvailable := (
        CharacterMenuBind != ""
        && SpecialWeaponBind != ""
        && FireBind != ""
    )

    return true
}

SendDestinyBind(bind)
{
    ; AHK sends single alphanumeric characters directly. Named keys
    ; use braces so inputs such as "F12", "Space", "Left", or "RButton"
    ; are interpreted as keys instead of literal text.
    if RegExMatch(bind, "^[A-Za-z0-9]$")
        Send bind
    else
        Send "{" bind "}"
}

; ============================================================
; KEYBIND REFRESH
; ============================================================
; Keybinds are intentionally NOT scanned in the background.
; Each F1/F2/F3/F4 activation refreshes the current binds immediately
; before the macro starts. This keeps the script simple and ensures that
; a newly saved bind is picked up on the next macro activation.
; ============================================================

; ============================================================
; F1 = RESYNC
; ============================================================
; 1. Turn the 30K / F8 limit on.
; 2. Completely block keyboard and mouse input.
; 3. Wait 30 seconds.
; 4. Turn F8 off while input is still blocked.
; 5. Restore keyboard and mouse input.
; ============================================================

F1::
{
    global CharacterMenuBind, ResyncAvailable

    ; Refresh Destiny 2 keybinds immediately before the macro starts.
    if !UpdateKeybinds()
    {
        MsgBox "Could not read Destiny 2's keybinds from cvars.xml. Resync was not started.",
            "Destiny 2 Macro Suite"
        return
    }

    if !ResyncAvailable
    {
        MsgBox "Resync is unavailable because the Character Menu bind is unbound or could not be detected.",
            "Destiny 2 Macro Suite"
        return
    }

    SendDestinyBind CharacterMenuBind
    SendEvent "{F8}"

    BlockInput "On"

    try
    {
        Sleep 30000
        SendEvent "{F8}"
    }
    finally
    {
        BlockInput "Off"
    }
}


; ============================================================
; F2 = DOT
; ============================================================
; Press Z, then toggle the F5 control on. 
; Manual toggle off required
; ============================================================

F2::
{
    global SuperBind, DoTAvailable

    ; Refresh Destiny 2 keybinds immediately before the macro starts.
    if !UpdateKeybinds()
    {
        MsgBox "Could not read Destiny 2's keybinds from cvars.xml. DoT was not started.",
            "Destiny 2 Macro Suite"
        return
    }

    if !DoTAvailable
    {
        MsgBox "DoT is unavailable because the Super bind is unbound or could not be detected.",
            "Destiny 2 Macro Suite"
        return
    }

    SendDestinyBind SuperBind
    Sleep 40

    Send "{F5}"
    Sleep 40

    Send "{F5}"
}


; ============================================================
; F3 = DUALITY CHUNK
; ============================================================
; Uses:
; - Loadout 1 = final Duality loadout
; - Loadouts 2, 3, 4 = Lorentz Driver cycling loadouts
;
; The same resolution-selected coordinates are used for each
; loadout slot.
; ============================================================

F3::
{
    global DualityAvailable

    ; Refresh keybinds first.
    if !UpdateKeybinds()
    {
        MsgBox "Could not read Destiny 2's keybinds from cvars.xml. DualityChunk was not started.",
            "Destiny 2 Macro Suite"
        return
    }

    if !DualityAvailable
    {
        MsgBox "DualityChunk is unavailable because the Character Menu bind is unbound or could not be detected.",
            "Destiny 2 Macro Suite"
        return
    }

    ; Refresh the active resolution profile immediately before using coordinates.
    if !UpdateResolutionProfile()
        return

    RunLoadoutSequence()
}

RunLoadoutSequence()
{
    global Loadout1X, Loadout1Y
    global Loadout2X, Loadout2Y
    global Loadout3X, Loadout3Y
    global Loadout4X, Loadout4Y
    global CharacterMenuBind

    BlockInput "MouseMove"

    try
    {
        ; Turn F6 on.
        SendEvent "{F6}"

        ; Open the character/loadout screen.
        SendDestinyBind CharacterMenuBind
        Sleep 700

        ; Move into the loadout section.
        SendEvent "{Left}"
        Sleep 400

        cycleCoordinates := [
            [Loadout2X, Loadout2Y],
            [Loadout3X, Loadout3Y],
            [Loadout4X, Loadout4Y]
        ]

        ; Repeat the 2 -> 3 -> 4 cycle 60 times.
        Loop 60
        {
            coords := cycleCoordinates[Mod(A_Index - 1, 3) + 1]

            MouseMove coords[1], coords[2], 0
            Sleep 40

            Click
            Sleep 40
        }

        ; Finish on loadout 1.
        MouseMove Loadout1X, Loadout1Y, 0
        Sleep 40

        Click
        Sleep 40

        ; Close the character/loadout screen.
        SendDestinyBind CharacterMenuBind
        Sleep 550

        ; Turn F6 off.
        SendEvent "{F6}"
    }
    finally
    {
        BlockInput "MouseMoveOff"
    }
}


; ============================================================
; F4 = TEAM KILL
; ============================================================
; The player starts on loadout 6.
;
; Press F4 to:
; 1. Turn the 7500 / F7 limit on.
; 2. Swap from loadout 6 -> loadout 5.
; 3. Arm the Mouse 1 hold detector.
;
; Once Mouse 1 is held for 1.5 seconds:
; 1. Turn the 7500 / F7 limit off.
; 2. Swap from loadout 5 -> loadout 6.
; 3. Disarm the Mouse 1 detector.
;
; Loadout 6 = starting / return loadout (Slayer's Fang)
; Loadout 5 = second loadout (Duality)
; ============================================================

F4::
{
    global mouseMonitorActive
    global TeamKill5X, TeamKill5Y
    global CharacterMenuBind
    global SpecialWeaponBind
    global TeamKillAvailable

    ; Refresh keybinds first so the dynamic fire input is current.
    if !UpdateKeybinds()
    {
        MsgBox "Could not read Destiny 2's keybinds from cvars.xml. TeamKill was not started.",
            "Destiny 2 Macro Suite"
        return
    }

    if !TeamKillAvailable
    {
        MsgBox "TeamKill is unavailable because Character Menu, Special Weapon, or Fire is unbound or could not be detected.",
            "Destiny 2 Macro Suite"
        return
    }

    ; Refresh the active resolution profile immediately before using coordinates.
    if !UpdateResolutionProfile()
        return


    ; Make sure any previous Mouse 1 detection is disabled.
    mouseMonitorActive := false

    ; Turn F7 on.
    Send "{F7}"

    ; Open the character/loadout screen.
    Send CharacterMenuBind
    Sleep 700

    ; Move into the loadout section.
    Send "{Left}"
    Sleep 400

    ; The player starts on loadout 6.
    ; Swap to loadout 5 for the Team Kill setup.
    MouseMove TeamKill5X, TeamKill5Y, 0
    Sleep 40

    Click
    Sleep 40

    ; Close the character/loadout screen.
    SendDestinyBind CharacterMenuBind

    ; Arm the configured fire-input detector.
    mouseMonitorActive := true
    StartTeamKillFireDetector()
}

; ============================================================
; DYNAMIC FIRE INPUT = TEAM KILL SECOND HALF
; ============================================================
; Destiny's "fire" bind is read from cvars.xml before F4 starts.
;
; Instead of registering a dynamic AHK hotkey for that key, TeamKill
; uses a lightweight polling timer while the detector is armed.
; This works consistently for both mouse buttons and keyboard keys.
;
; The timer checks the configured fire input every 10 ms:
; - Start timing when the input becomes held.
; - Reset if it is released before 1.5 seconds.
; - Trigger the sequence once the hold reaches 1.5 seconds.
;
; This also fixes the issue where a short click/press could interfere
; with later valid holds.
; ============================================================

StartTeamKillFireDetector()
{
    global teamKillHoldStart, teamKillHoldTriggered

    teamKillHoldStart := 0
    teamKillHoldTriggered := false

    SetTimer CheckTeamKillHold, 10
}

StopTeamKillFireDetector()
{
    global teamKillHoldStart, teamKillHoldTriggered

    SetTimer CheckTeamKillHold, 0
    teamKillHoldStart := 0
    teamKillHoldTriggered := false
}

CheckTeamKillHold()
{
    global mouseMonitorActive
    global TeamKill6X, TeamKill6Y
    global SpecialWeaponBind, CharacterMenuBind
    global FireBind, TeamKillAvailable
    global teamKillHoldStart, teamKillHoldTriggered

    ; Stop monitoring if F4 is no longer armed or the required
    ; configuration is no longer available.
    if !mouseMonitorActive || !TeamKillAvailable
    {
        StopTeamKillFireDetector()
        return
    }

    ; Check the currently detected Destiny fire input.
    isHeld := GetKeyState(FireBind, "P")

    if !isHeld
    {
        ; A short click/press resets the timer so a later hold
        ; can be detected normally.
        teamKillHoldStart := 0
        teamKillHoldTriggered := false
        return
    }

    ; Start a fresh hold timer when the fire input becomes held.
    if teamKillHoldStart = 0
    {
        teamKillHoldStart := A_TickCount
        return
    }

    ; Ignore repeat checks after the sequence has already triggered.
    if teamKillHoldTriggered
        return

    ; Trigger after 1.5 seconds of continuous hold.
    if (A_TickCount - teamKillHoldStart) < 1500
        return

    teamKillHoldTriggered := true
    SetTimer CheckTeamKillHold, 0

    ; Turn F7 off.
    Send "{F7}"
    Sleep 200

    ; Prevent manual mouse movement from interfering with the
    ; automated return to loadout 6.
    BlockInput "Mouse"

    try
    {
        ; Press the configured second-slot weapon key.
        SendDestinyBind SpecialWeaponBind

        ; Open the character/loadout screen.
        SendDestinyBind CharacterMenuBind
        Sleep 700

        ; Move into the loadout section.
        Send "{Left}"
        Sleep 400

        ; Swap back to loadout 6.
        MouseMove TeamKill6X, TeamKill6Y, 0
        Sleep 40

        Click
        Sleep 40

        ; Close the character/loadout screen.
        SendDestinyBind CharacterMenuBind
    }
    finally
    {
        BlockInput "Off"
    }

    ; Require another F4 press before another TeamKill sequence.
    mouseMonitorActive := false
    StopTeamKillFireDetector()
}

