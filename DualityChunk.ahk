#Requires AutoHotkey v2.0
#SingleInstance Force

CoordMode "Mouse", "Screen"

; ============================================================
; LOADOUT COORDINATES
; ============================================================
; Coordinates for each Destiny 2 loadout slot.
; ============================================================

Loadouts := Map(
    1, [147, 613],
    2, [240, 613],
    3, [360, 613],
    4, [480, 613]
)

; ============================================================
; F3 = DUALITY CHUNK
; ============================================================
; Press F3 to:
; 1. Press F6 to turn the Duality function on.
; 2. Open the character/loadout screen.
; 3. Cycle loadouts 2 -> 3 -> 4 sixty times.
; 4. Return to loadout 1.
; 5. Close the character/loadout screen.
; 6. Press F6 again to turn the Duality function off.
; ============================================================

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

            ; Move the cursor to the selected loadout slot.
            MouseMove coords[1], coords[2], 0
            Sleep 40

            ; Select the loadout.
            Click
            Sleep 40
        }

        ; Return to loadout 1 after the 2 -> 3 -> 4 cycle.
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
