; IMPORTANT INFO ABOUT GETTING STARTED: Lines that start with a
; semicolon, such as this one, are comments.  They are not executed.

; This script has a special filename and path because it is automatically
; launched when you run the program directly.  Also, any text file whose
; name ends in .ahk is associated with the program, which means that it
; can be launched simply by double-clicking it.  You can have as many .ahk
; files as you want, located in any folder.  You can also run more than
; one ahk file simultaneously and each will get its own tray icon.

g_LastCtrlKeyDownTime := 0
g_AbortSendEsc := false
g_ControlRepeatDetected := false

~*LControl::
    if (g_ControlRepeatDetected)
    {
        return
    }

    g_LastCtrlKeyDownTime := A_TickCount
    g_AbortSendEsc := false
    g_ControlRepeatDetected := true

    return

~*^a::
    g_AbortSendEsc := true
    return
~*^b::
    g_AbortSendEsc := true
    return
~*^c::
    g_AbortSendEsc := true
    return
~*^d::
    g_AbortSendEsc := true
    return
~*^e::
    g_AbortSendEsc := true
    return
~*^f::
    g_AbortSendEsc := true
    return
~*^g::
    g_AbortSendEsc := true
    return
~*^h::
    g_AbortSendEsc := true
    return
~*^i::
    g_AbortSendEsc := true
    return
~*^j::
    g_AbortSendEsc := true
    return
~*^k::
    g_AbortSendEsc := true
    return
~*^l::
    g_AbortSendEsc := true
    return
~*^m::
    g_AbortSendEsc := true
    return
~*^n::
    g_AbortSendEsc := true
    return
~*^o::
    g_AbortSendEsc := true
    return
~*^p::
    g_AbortSendEsc := true
    return
~*^q::
    g_AbortSendEsc := true
    return
~*^r::
    g_AbortSendEsc := true
    return
~*^s::
    g_AbortSendEsc := true
    return
~*^t::
    g_AbortSendEsc := true
    return
~*^u::
    g_AbortSendEsc := true
    return
~*^v::
    g_AbortSendEsc := true
    return
~*^w::
    g_AbortSendEsc := true
    return
~*^x::
    g_AbortSendEsc := true
    return
~*^y::
    g_AbortSendEsc := true
    return
~*^z::
    g_AbortSendEsc := true
    return
~*^Tab::
    g_AbortSendEsc := true
    return
~*^Up::
    g_AbortSendEsc := true
    return
~*^Down::
    g_AbortSendEsc := true
    return
~*^Left::
    g_AbortSendEsc := true
    return
~*^Right::
    g_AbortSendEsc := true
    return
~*^PgUp::
    g_AbortSendEsc := true
    return
~*^PgDn::
    g_AbortSendEsc := true
    return
~*^Home::
    g_AbortSendEsc := true
    return
~*^End::
    g_AbortSendEsc := true
    return
~*^Del::
    g_AbortSendEsc := true
    return
~*^Ins::
    g_AbortSendEsc := true
    return
~*^Enter::
    g_AbortSendEsc := true
    return
~*^Backspace::
    g_AbortSendEsc := true
    return

~*LControl Up::
    g_ControlRepeatDetected := false
    if (g_AbortSendEsc)
    {
        return
    }
    current_time := A_TickCount
    time_elapsed := current_time - g_LastCtrlKeyDownTime
    if (time_elapsed <= 250)
    {
        SendInput {Esc}
    }
    return