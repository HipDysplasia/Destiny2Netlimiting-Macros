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
; F1 = Resync       -> F8 on, lock input, wait 30s, F8 off
; F2 = DoT          -> Z + F5 on/off
; F3 = DualityChunk -> F6 on/off + loadout cycle
; F4 = TeamKill     -> F7 on/off + loadout swap
; ============================================================


; ============================================================
; RESOLUTION PROFILE SELECTION
; ============================================================
; Select the resolution used by Destiny 2 before the macros start.
; The selected profile supplies the mouse coordinates used by
; DualityChunk and TeamKill.
; ============================================================

global SelectedResolution := ""
global LoadoutProfiles := Map()
global mouseMonitorActive := false
global startupReady := false

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

SelectResolution()

SelectResolution()
{
    global SelectedResolution

    resolutionGui := Gui("+AlwaysOnTop", "Destiny 2 Macro Suite")
    resolutionGui.SetFont("s10")

    resolutionGui.AddText("xm ym w300", "Select your Destiny 2 resolution:")

    dropdown := resolutionGui.AddDropDownList(
        "xm y+12 w300 Choose1",
        ["1680x1050", "1920x1080", "2304x1440", "2560x1440"]
    )

    resolutionGui.AddText(
        "xm y+12 w300 cRed",
        "Select the resolution that matches Destiny 2. Coordinates are profile-specific."
    )

    continueButton := resolutionGui.AddButton("xm y+18 w140 Default", "Continue")
    cancelButton := resolutionGui.AddButton("x+10 w140", "Exit")

    continueButton.OnEvent("Click", (*) => SubmitResolution())
    cancelButton.OnEvent("Click", (*) => ExitApp())
    resolutionGui.OnEvent("Close", (*) => ExitApp())

    SubmitResolution(*)
    {
        global SelectedResolution, LoadoutProfiles

        SelectedResolution := dropdown.Text

        if !LoadoutProfiles.Has(SelectedResolution)
        {
            MsgBox "Please select a resolution first.", "Destiny 2 Macro Suite"
            return
        }

        resolutionGui.Destroy()
    }

    resolutionGui.Show("AutoSize Center")

    ; Keep the startup code paused until the resolution window closes.
    ; The Continue button validates the selection and closes the GUI.
    WinWaitClose "ahk_id " resolutionGui.Hwnd
}


; ============================================================
; SHARED COORDINATES
; ============================================================
; These variables are populated from the selected resolution
; profile and used by the resolution-dependent macros.
; ============================================================

global Loadout1X, Loadout1Y
global Loadout2X, Loadout2Y
global Loadout3X, Loadout3Y
global Loadout4X, Loadout4Y
global TeamKill5X, TeamKill5Y
global TeamKill6X, TeamKill6Y

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

CoordMode "Mouse", "Screen"

startupReady := true


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
    global startupReady
    if !startupReady
        return
    SendEvent "i"
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
    global startupReady
    if !startupReady
        return
    Send "z"
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
    global startupReady
    if !startupReady
        return
    RunLoadoutSequence()
}

RunLoadoutSequence()
{
    global Loadout1X, Loadout1Y
    global Loadout2X, Loadout2Y
    global Loadout3X, Loadout3Y
    global Loadout4X, Loadout4Y

    BlockInput "MouseMove"

    try
    {
        ; Turn F6 on.
        SendEvent "{F6}"

        ; Open the character/loadout screen.
        SendEvent "i"
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
        SendEvent "i"
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
    global startupReady
    global mouseMonitorActive
    global TeamKill5X, TeamKill5Y

    if !startupReady
        return

    ; Make sure any previous Mouse 1 detection is disabled.
    mouseMonitorActive := false

    ; Turn F7 on.
    Send "{F7}"

    ; Open the character/loadout screen.
    Send "i"
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
    Send "i"

    ; Arm Mouse 1 detection.
    mouseMonitorActive := true
}

; ============================================================
; MOUSE 1 = TEAM KILL SECOND HALF
; ============================================================
; Once F4 has armed the detector:
; - Press/hold Mouse 1.
; - A 1.5-second one-shot timer checks whether it is still held.
; - If still held, the Team Kill sequence completes.
; ============================================================

~LButton::
{
    global mouseMonitorActive

    if !mouseMonitorActive
        return

    ; Start a fresh 1.5-second hold check for this Mouse 1 press.
    SetTimer CheckTeamKillHold, -1500
}

~LButton Up::
{
    ; Releasing Mouse 1 cancels the pending hold check.
    SetTimer CheckTeamKillHold, 0
}

CheckTeamKillHold()
{
    global mouseMonitorActive
    global TeamKill6X, TeamKill6Y

    ; Do nothing if F4 is no longer armed.
    if !mouseMonitorActive
        return

    ; The hold is only valid if Mouse 1 is still physically held
    ; when the 1.5-second timer expires.
    if !GetKeyState("LButton", "P")
        return

    ; Turn F7 off.
    Send "{F7}"
    Sleep 200

    ; Prevent manual mouse movement from interfering with the
    ; automated return to loadout 6.
    BlockInput "Mouse"

    try
    {
        ; Press 2.
        Send "2"

        ; Open the character/loadout screen.
        Send "i"
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
        Send "i"
    }
    finally
    {
        BlockInput "Off"
    }

    ; Require another F4 press before another TeamKill sequence.
    mouseMonitorActive := false

    ; Make sure no old hold timer remains active.
    SetTimer CheckTeamKillHold, 0
}

