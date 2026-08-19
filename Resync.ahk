#Requires AutoHotkey v2.0
#SingleInstance Force

; ============================================================
; F1 = RESYNC
; ============================================================
; Press F1 to:
; 1. Open the character/loadout screen with I.
; 2. Press F8 to turn the resync function on.
; 3. Completely block keyboard and mouse input for 19 seconds.
; 4. Press F8 again to turn the resync function off.
;
; Blocking input during the 19-second window prevents accidental
; keyboard or mouse input from interfering with the resync timing
; or leaving the game before the connection is restored.
; ============================================================

F1::
{
    ; Open the character/loadout screen.
    SendEvent "i"

    ; Turn F8 on.
    SendEvent "{F8}"

    ; Block all physical keyboard and mouse input during the
    ; entire resync window.
    BlockInput "On"

    try
    {
        ; Allow the resync sequence to run for 19 seconds.
        Sleep 19000

        ; Turn F8 off while input is still blocked so that the
        ; physical keyboard/mouse cannot interfere with this input.
        SendEvent "{F8}"
    }
    finally
    {
        ; Always restore normal keyboard and mouse input when
        ; the resync sequence is finished.
        BlockInput "Off"
    }
}
