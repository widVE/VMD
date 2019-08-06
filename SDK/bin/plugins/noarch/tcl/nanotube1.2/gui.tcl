# Carbon Nanostructure Builder GUI

package require topotools 1.1

namespace eval ::Nanotube:: {
    variable w            ; # handle of the GUI's toplevel widget
    variable version  1.2 ; # version number of this plugin

    variable l   5        ; # nanotube length
    variable n   5        ; # nanotube chirality parameter n
    variable m  10        ; # nanotube chirality parameter m

    variable lx  5        ; # x-length of graphene sheet.
    variable ly 10        ; # y-length of graphene sheet.
    variable lz  3.0      ; # distance between layers in stack
    variable type armchair; # graphene sheet boundary type.
    variable nlayers    1 ; # number of sheets in stack
    variable stacking  AB ; # AA, AB, ABC

    variable bonds      1 ; # generate bonds  
    variable angles     1 ; # generate angles
    variable dihedrals  1 ; # generate dihedrals
    variable impropers  1 ; # generate impropers

}
package provide nanotube $::Nanotube::version

proc ::Nanotube::nanotube_gui {} {
    variable w
    variable version

    variable l
    variable n
    variable m

    variable lx
    variable ly
    variable lz
    variable type
    variable nlayers
    variable stacking

    variable bonds
    variable angles
    variable dihedrals
    variable impropers


    if { [winfo exists .nanotube] } {
        wm deiconify $w
        return
    }

    set w [toplevel ".nanotube"]
    wm title $w "Carbon Nanostructure Builder"
    wm resizable $w no no
    set row 0

    #Add a menubar
    frame $w.menubar -relief raised -bd 2 -padx 10
    grid  $w.menubar -padx 1 -column 0 -columnspan 4 -row $row -sticky ew
    menubutton $w.menubar.help -text "Help" -underline 0 \
        -menu $w.menubar.help.menu
    $w.menubar.help config -width 5
    pack $w.menubar.help -side right
    menu $w.menubar.help.menu -tearoff no
    $w.menubar.help.menu add command -label "About" \
        -command {tk_messageBox -type ok -title "About Carbon Nanostructure Builder" \
                      -message "Tool for building selected\ncarbon nanostructures.\n\nVersion $::Nanotube::version\n\n(c) 2009-2011 \nby Robert R. Johnson\n <robertjo@physics.upenn.edu>\nand\nAxel Kohlmeyer\n<akohlmey@gmail.com>"}
    $w.menubar.help.menu add command -label "Help..." \
        -command "vmd_open_url [string trimright [vmdinfo www] /]/plugins/nanotube"
    incr row

    grid [label $w.topoopts -justify center -relief raised -text "Topology Building Options:"] \
        -row $row -column 0 -columnspan 4 -sticky nsew
    incr row
    grid [checkbutton $w.topobonds -variable ::Nanotube::bonds -text Bonds \
              -command [namespace code \
                            {
                                if {$bonds} {
                                    $w.topoangles configure -state active
                                    $w.topodihedrals configure -state active
                                    $w.topoimpropers configure -state active
                                } {
                                    $w.topoangles configure -state disabled
                                    $w.topodihedrals configure -state disabled
                                    $w.topoimpropers configure -state disabled}
                            } ] ] \
        -row $row -column 0 -sticky nsew
    grid [checkbutton $w.topoangles -variable ::Nanotube::angles -text Angles] \
        -row $row -column 1 -sticky nsew
    grid [checkbutton $w.topodihedrals -variable ::Nanotube::dihedrals -text Dihedrals] \
        -row $row -column 2 -sticky nsew
    grid [checkbutton $w.topoimpropers -variable ::Nanotube::impropers -text Impropers] \
        -row $row -column 3 -sticky nsew
    incr row

    grid [label $w.tubeopts -justify center -relief raised -text "Nanotube Building Options:"] \
        -row $row -column 0 -columnspan 4 -sticky nsew
    incr row
    grid [label $w.nlabel -text "Nanotube chiral index n: "] \
        -row $row -column 0 -columnspan 3 -sticky w
    grid [entry $w.n -width 7 -textvariable ::Nanotube::n] \
        -row $row -column 3 -columnspan 1 -sticky ew
    incr row

    grid [label $w.mlabel -text "Nanotube chiral index m: "] \
        -row $row -column 0 -columnspan 3 -sticky w
    grid [entry $w.m -width 7 -textvariable ::Nanotube::m] \
        -row $row -column 3 -columnspan 1 -sticky ew
    incr row

    grid [label $w.llabel -text "Nanotube length (nm): "] \
        -row $row -column 0 -columnspan 3 -sticky w
    grid [entry $w.l -width 7 -textvariable ::Nanotube::l] \
        -row $row -column 3 -columnspan 1 -sticky ew
    incr row

    grid [button $w.gotube -text "Generate Nanotube" \
              -command [namespace code \
                            { 
                                vmdcon -info "calling nanotube_core -l $l -n $n -m $m -b $bonds -a $angles -d $dihedrals -i $impropers"
                  nanotube_core -l "$l" -n "$n" -m "$m" -b "$bonds" -a "$angles" -d "$dihedrals" -i "$impropers"
              } ]] -row $row -column 0 -columnspan 4 -sticky nsew
    incr row

    grid [label $w.sheetopts -justify center -relief raised -text "Graphene Sheet Building Options:"] \
        -row $row -column 0 -columnspan 4 -sticky nsew
    incr row
    grid [label $w.lxlabel -text "Edge length along x (nm): "] \
        -row $row -column 0 -columnspan 3 -sticky w
    grid [entry $w.lx -width 7 -textvariable ::Nanotube::lx] \
        -row $row -column 3 -columnspan 1 -sticky ew
    incr row

    grid [label $w.lylabel -text "Edge length along y (nm): "] \
        -row $row -column 0 -columnspan 3 -sticky w
    grid [entry $w.ly -width 7 -textvariable ::Nanotube::ly] \
        -row $row -column 3 -columnspan 1 -sticky ew
    incr row

    grid [label $w.layerlabel -text "Number of layers: "] \
        -row $row -column 0 -columnspan 3 -sticky w
    grid [entry $w.nlayers -width 7 -textvariable ::Nanotube::nlayers] \
        -row $row -column 3 -columnspan 1 -sticky ew
    incr row

    grid [label $w.typelabel -text "Graphene edge type: "] \
        -row $row -column 0 -columnspan 2 -sticky w
    grid [radiobutton $w.armchair -text "Armchair" -value "armchair" -variable ::Nanotube::type] \
        -row $row -column 2 -columnspan 1 -sticky w
    grid [radiobutton $w.zigzag -text "Zigzag"   -value "zigzag"   -variable ::Nanotube::type] \
        -row $row -column 3 -columnspan 1 -sticky w
    incr row

    grid [button $w.gosheet -text "Generate Sheet(s)" \
              -command [namespace code {
                  vmdcon -info "calling graphene_core -lx $lx -ly $ly -type $type -nlayers $nlayers -b $bonds -a $angles -d $dihedrals -i $impropers"
                  graphene_core -lx "$lx" -ly "$ly" -type "$type" -nlayers "$nlayers" \
                      -b "$bonds" -a "$angles" -d "$dihedrals" -i "$impropers"
              } ]] -row $row -column 0 -columnspan 4 -sticky nsew
}

proc nanotube_tk {} {
  ::Nanotube::nanotube_gui
  return $::Nanotube::w
}
