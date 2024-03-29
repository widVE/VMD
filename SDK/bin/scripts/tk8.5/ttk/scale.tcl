# scale.tcl - Copyright (C) 2004 Pat Thoyts <patthoyts@users.sourceforge.net>
#
# Bindings for the TScale widget
#
# $Id: scale.tcl,v 1.1.4.1 2008/10/17 12:44:04 patthoyts Exp $

namespace eval ttk::scale {
    variable State
    array set State  {
	dragging 0
    }
}

bind TScale <ButtonPress-1>   { ttk::scale::Press %W %x %y }
bind TScale <B1-Motion>       { ttk::scale::Drag %W %x %y }
bind TScale <ButtonRelease-1> { ttk::scale::Release %W %x %y }

bind TScale <ButtonPress-2>   { ttk::scale::Jump %W %x %y }
bind TScale <B2-Motion>       { ttk::scale::Drag %W %x %y }
bind TScale <ButtonRelease-2> { ttk::scale::Release %W %x %y }

bind TScale <ButtonPress-3>   { ttk::scale::Jump %W %x %y }
bind TScale <B3-Motion>       { ttk::scale::Drag %W %x %y }
bind TScale <ButtonRelease-3> { ttk::scale::Release %W %x %y }

bind TScale <Left>            { ttk::scale::Increment %W -1 }
bind TScale <Up>              { ttk::scale::Increment %W -1 }
bind TScale <Right>           { ttk::scale::Increment %W 1 }
bind TScale <Down>            { ttk::scale::Increment %W 1 }
bind TScale <Control-Left>    { ttk::scale::Increment %W -10 }
bind TScale <Control-Up>      { ttk::scale::Increment %W -10 }
bind TScale <Control-Right>   { ttk::scale::Increment %W 10 }
bind TScale <Control-Down>    { ttk::scale::Increment %W 10 }
bind TScale <Home>            { %W set [%W cget -from] }
bind TScale <End>             { %W set [%W cget -to] }

proc ttk::scale::Press {w x y} {
    variable State
    set State(dragging) 0

    switch -glob -- [$w identify $x $y] {
	*track -
        *trough {
            set inc [expr {([$w get $x $y] <= [$w get]) ? -1 : 1}]
            ttk::Repeatedly Increment $w $inc
        }
        *slider {
            set State(dragging) 1
            set State(initial) [$w get]
        }
    }
}

# scale::Jump -- ButtonPress-2/3 binding for scale acts like
#	Press except that clicking in the trough jumps to the
#	clicked position.
proc ttk::scale::Jump {w x y} {
    variable State
    set State(dragging) 0

    switch -glob -- [$w identify $x $y] {
	*track -
        *trough {
            $w set [$w get $x $y]
            set State(dragging) 1
            set State(initial) [$w get]
        }
        *slider {
            Press $w $x $y
        }
    }
}

proc ttk::scale::Drag {w x y} {
    variable State
    if {$State(dragging)} {
	$w set [$w get $x $y]
    }
}

proc ttk::scale::Release {w x y} {
    variable State
    set State(dragging) 0
    ttk::CancelRepeat
}

proc ttk::scale::Increment {w delta} {
    if {![winfo exists $w]} return
    $w set [expr {[$w get] + $delta}]
}
