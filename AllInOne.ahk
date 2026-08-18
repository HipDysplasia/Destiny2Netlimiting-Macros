#Requires AutoHotkey v2.0
#SingleInstance Force

; ============================================================
; DESTINY 2 - ALL IN ONE
; ============================================================
; F1 = Resync      -> F8 on, wait 19s, F8 off
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
; Open the character/loadout screen, turn F8 on, wait 19s,
; then turn F8 off again.
; ============================================================

F1::
{
	Sleep 40

    ; Open the character/loadout screen.
    Send "i"

    ; Turn F8 on.
    Send "{F8}"

    ; Allow the resync sequence to run for 19 seconds.
    Sleep 19000

    ; Turn F8 off.
    Send "{F8}"
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

; Loadout coordinates.
LoadoutX := 147
LoadoutY := 725
SecondLoadoutX := 240
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

    ; Move to the first loadout slot.
    MouseMove LoadoutX, LoadoutY, 0
    Sleep DelayAfterMove

    ; Select the first loadout.
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

            ; Move to the second loadout slot.
            MouseMove SecondLoadoutX, SecondLoadoutY, 0
            Sleep DelayAfterMove

            ; Select the second loadout.
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
