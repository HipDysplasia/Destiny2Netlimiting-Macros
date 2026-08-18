#Requires AutoHotkey v2.0
#SingleInstance Force

; ============================================================
; F1 = RESYNC
; ============================================================
; Press F1 to:
; 1. Open the character/loadout screen with I.
; 2. Press F8 to turn the resync function on.
; 3. Wait 19 seconds.
; 4. Press F8 again to turn it off.
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
