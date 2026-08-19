#Requires AutoHotkey v2.0
#SingleInstance Force

; ============================================================
; F2 = DOT
; ============================================================
; Press F2 to:
; 1. Press Z.
; 2. Wait 40ms.
; 3. Press F5 to turn the DoT function on.
; 4. Press F5 again to turn it off.
;
; The short delay between the F5 inputs prevents the two
; toggle inputs from being sent at exactly the same moment.
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
