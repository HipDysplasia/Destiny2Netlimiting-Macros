#Requires AutoHotkey v2.0
#SingleInstance Force

; ============================================================
; DESTINY 2 - ALL IN ONE
; ============================================================
; F1 = Resync      -> F8 on, wait 18s, F8 off
; F2 = DoT         -> F5 on/off
; F3 = DualityChunk-> F6 on/off + loadout cycle
; F4 = TeamKill    -> F7 on/off + loadout swap
;
; The combined script keeps the same F1-F4 hotkeys and the
; same behavior as the individual macros.
; ============================================================


; ============================================================
; F1 = RESYNC
; ============================================================
; Press F1 to:
; 1. Open the character/loadout screen with I.
; 2. Press F8 to turn the 30K resync limit on.
; 3. Completely block keyboard and mouse input for 30 seconds.
; 4. Press F8 again to turn the limit off.
;
; Blocking input during the full 30-second window prevents
; keyboard or mouse activity from interfering with the timing
; or causing the game to reconnect before the intended point.
; ============================================================

F1::
{
    ; Open the character/loadout screen.
	Sleep 40
    SendEvent "i"

    ; Turn the 30K / F8 resync limit on.
    SendEvent "{F8}"

    ; Block all physical keyboard and mouse input for the
    ; entire resync window.
    BlockInput "On"

    try
    {
        ; Wait the full 30-second resync period.
        Sleep 30000

        ; Turn the 30K / F8 resync limit off while input
        ; is still blocked so nothing can interfere with it.
        SendEvent "{F8}"
    }
    finally
    {
        ; Always restore normal keyboard and mouse input
        ; once the resync sequence has finished.
        BlockInput "Off"
    }
}


; ============================================================
; F2 = DOT
; ============================================================
; Press Z, then turn F5 on and off with a short delay between
; the two toggle inputs.
; ============================================================

F2::
{
    ; Press Z.
    Send "z"
    Sleep 40

    ; Turn F5 on.
    Send "{F5}"
    Sleep 40

    ; Turn F5 off.
    Send "{F5}"
}


; ============================================================
; F3 = DUALITY CHUNK
; ============================================================

CoordMode "Mouse", "Screen"

; Coordinates for the Destiny 2 loadout slots.
Loadouts := Map(
    1, [147, 613],
    2, [240, 613],
    3, [360, 613],
    4, [480, 613]
)

F3::
{
    RunLoadoutSequence()
}

RunLoadoutSequence()
{
    global Loadouts

    ; Prevent manual mouse movement from interfering with
    ; the loadout coordinates while the macro is running.
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

        ; Cycle through loadouts 2 -> 3 -> 4.
        cycle := [2, 3, 4]

        ; Repeat the 2 -> 3 -> 4 cycle 60 times.
        Loop 60
        {
            ; Determine which loadout in the cycle should be selected.
            loadout := cycle[Mod(A_Index - 1, 3) + 1]
            coords := Loadouts[loadout]

            ; Move to the selected loadout.
            MouseMove coords[1], coords[2], 0
            Sleep 40

            ; Select the loadout.
            Click
            Sleep 40
        }

        ; Return to loadout 1.
        coords := Loadouts[1]
        MouseMove coords[1], coords[2], 0
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
        ; Always restore normal mouse movement when the macro ends.
        BlockInput "MouseMoveOff"
    }
}


; ============================================================
; F4 = TEAM KILL
; ============================================================

; Team Kill loadout coordinates.
; Loadout 6 = starting loadout
LoadoutX := 240
LoadoutY := 725
; Loadout 5 = second loadout
SecondLoadoutX := 147
SecondLoadoutY := 725

; Timing settings.
DelayAfter2     := 0
DelayAfterI1    := 700
DelayAfter0     := 0
DelayAfterLeft  := 400
DelayAfterMove  := 40
DelayAfterClick := 40
DelayBeforeSecondSwap := 200

global mouseMonitorActive := false

F4::
{
    global mouseMonitorActive
    global LoadoutX, LoadoutY
    global DelayAfter2, DelayAfterI1, DelayAfter0
    global DelayAfterLeft, DelayAfterMove, DelayAfterClick

    ; Disable the Mouse 1 detector while F4 is running.
    mouseMonitorActive := false

    ; Press 2.
    Send "2"
    Sleep DelayAfter2

    ; Open the character/loadout screen.
    Send "i"
    Sleep DelayAfterI1

    ; Turn F7 on.
    Send "{F7}"
    Sleep DelayAfter0

    ; Move one position to the left.
    Send "{Left}"
    Sleep DelayAfterLeft

    ; Move to loadout 6 (the starting Team Kill loadout).
    MouseMove LoadoutX, LoadoutY, 0
    Sleep DelayAfterMove

    ; Select loadout 6.
    Click
    Sleep DelayAfterClick

    ; Close the character/loadout screen.
    Send "i"

    ; Enable the Mouse 1 detector for the second half.
    mouseMonitorActive := true
}

; Hold Mouse 1 for 1.5 seconds after F4.
~LButton::
{
    global mouseMonitorActive
    global SecondLoadoutX, SecondLoadoutY
    global DelayBeforeSecondSwap
    global DelayAfter2, DelayAfterI1
    global DelayAfterLeft, DelayAfterMove, DelayAfterClick

    ; Ignore Mouse 1 unless F4 has enabled the detector.
    if !mouseMonitorActive
        return

    ; Wait up to 1.5 seconds for Mouse 1 to be released.
    released := KeyWait("LButton", "T1.5")

    ; Continue only if Mouse 1 is still held after 1.5s.
    if !released && GetKeyState("LButton", "P")
    {
        ; Turn F7 off.
        Send "{F7}"
        Sleep DelayBeforeSecondSwap

        ; Block physical mouse input during the loadout swap.
        BlockInput "Mouse"

        try
        {
            ; Press 2.
            Send "2"
            Sleep DelayAfter2

            ; Open the character/loadout screen.
            Send "i"
            Sleep DelayAfterI1

            ; Move one position to the left.
            Send "{Left}"
            Sleep DelayAfterLeft

            ; Move to loadout 5 (the second Team Kill loadout).
            MouseMove SecondLoadoutX, SecondLoadoutY, 0
            Sleep DelayAfterMove

            ; Select loadout 5.
            Click
            Sleep DelayAfterClick

            ; Close the character/loadout screen.
            Send "i"
        }
        finally
        {
            ; Restore normal mouse input.
            BlockInput "Off"
        }
    }

    ; One F4 cycle only; require another F4 to arm it again.
    mouseMonitorActive := false
}
