#Requires AutoHotkey v2.0
#SingleInstance Force

; ============================================================
; LOADOUT COORDINATES
; ============================================================
; Coordinates for the Team Kill loadouts:
; Loadout 6 is the starting loadout and loadout 5 is the
; loadout used for the second half of the sequence.
; ============================================================

; Loadout 6 (starting loadout)
LoadoutX := 240
LoadoutY := 725

; Loadout 5 (second loadout)
SecondLoadoutX := 147
SecondLoadoutY := 725

; ============================================================
; TIMING SETTINGS
; ============================================================

DelayAfter2     := 0
DelayAfterI1    := 700
DelayAfter0     := 0
DelayAfterLeft  := 400
DelayAfterMove  := 40
DelayAfterClick := 40

; Delay between the first F7 and the second loadout swap.
DelayBeforeSecondSwap := 200

global mouseMonitorActive := false

; ============================================================
; F4 = TEAM KILL
; ============================================================
; Press F4 to:
; 1. Press 2.
; 2. Open the character/loadout screen with I.
; 3. Press F7 to turn the Team Kill function on.
; 4. Select the first loadout.
; 5. Close the character/loadout screen.
; 6. Enable the Mouse 1 detector.
;
; Holding Mouse 1 for 1.5 seconds then performs the second
; loadout swap and presses F7 again to turn the function off.
; ============================================================

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

; ============================================================
; MOUSE 1 = SECOND TEAM KILL STEP
; ============================================================
; Hold Mouse 1 for 1.5 seconds after F4 has completed.
; This performs the second loadout swap and presses F7 again,
; turning the Team Kill function off.
; ============================================================

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

    ; If Mouse 1 is still held after 1.5 seconds, continue.
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
