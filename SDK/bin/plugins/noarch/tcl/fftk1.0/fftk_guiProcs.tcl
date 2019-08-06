#
# $Id: fftk_guiProcs.tcl,v 1.4 2012/01/27 20:57:03 johns Exp $
#

#======================================================
#   PTE GUI PROCS
#======================================================

#------------------------------------------------------
# GENERAL
#------------------------------------------------------
proc ::ForceFieldToolKit::gui::init {} {

    # BuildPar Tab Setup
    # Initialize BuildPar namespace
    ::ForceFieldToolKit::BuildPar::init
    # Initialize GenZMatrix GUI settings
    set ::ForceFieldToolKit::gui::bparVDWInputParFile {}
    set ::ForceFieldToolKit::gui::bparVDWele {}
    set ::ForceFieldToolKit::gui::bparVDWparSet {}
    set ::ForceFieldToolKit::gui::bparVDWtvNodeIDs {}
    set ::ForceFieldToolKit::gui::bparVDWrefComment {}

    # GeomOpt Tab Setup
    # Initialize GeomOpt namespace
    ::ForceFieldToolKit::GeomOpt::init
    # Initialize GeomOpt GUI settings

    # GenZMatrix Tab Setup
    # Initialize GenZMatrix namespace
    ::ForceFieldToolKit::GenZMatrix::init
    # Initialize GenZMatrix GUI settings
    set ::ForceFieldToolKit::gui::gzmAtomLabels {}
    set ::ForceFieldToolKit::gui::gzmVizSpheresDon {}
    set ::ForceFieldToolKit::gui::gzmVizSpheresAcc {}
    set ::ForceFieldToolKit::gui::gzmVizSpheresBoth {}
    set ::ForceFieldToolKit::gui::gzmCOMfiles {}
    set ::ForceFieldToolKit::gui::gzmLOGfiles {}
    
    # ChargeOpt Tab Setup
    # Initialize ChargeOpt namespace
    ::ForceFieldToolKit::ChargeOpt::init
    # Initialize ChargeOpt GUI Settings
    set ::ForceFieldToolKit::gui::coptAtomLabel "None"
    set ::ForceFieldToolKit::gui::coptAtomLabelInd {}
    set ::ForceFieldToolKit::gui::coptPSFNewPath ""
    set ::ForceFieldToolKit::gui::coptPrevLogFile ""
    set ::ForceFieldToolKit::gui::coptBuildScript 0
    set ::ForceFieldToolKit::gui::coptStatus "IDLE"
    set ::ForceFieldToolKit::gui::coptFinalChargeTotal {}
    # Clear Edit Data Boxes
    ::ForceFieldToolKit::gui::coptClearEditData "cconstr"
    ::ForceFieldToolKit::gui::coptClearEditData "wie"
    ::ForceFieldToolKit::gui::coptClearEditData "results"
    
    # GenBonded Tab Setup
    # Initialize GenBonded Namespace
    ::ForceFieldToolKit::GenBonded::init
    # Initialize GenBonded GUI Settings
    
    # BondAngleOpt Tab Setup
    # Initialize BondAngleOpt Namespace
    ::ForceFieldToolKit::BondAngleOpt::init
    # Initialize BondAngleOpt GUI Settings
    set ::ForceFieldToolKit::gui::baoptStatus "IDLE"
    set ::ForceFieldToolKit::gui::baoptBuildScript 0
    # Clear Edit Data Boxes
    set ::ForceFieldToolKit::gui::baoptEditBA {}
    set ::ForceFieldToolKit::gui::baoptEditDef {}
    set ::ForceFieldToolKit::gui::baoptEditFC {}
    set ::ForceFieldToolKit::gui::baoptEditEq {}
    
    # GenDihScan Tab Setup
    # Initialize GenDihScan Namespace
    ::ForceFieldToolKit::GenDihScan::init
    # Initialize GUI Settings
    set ::ForceFieldToolKit::gui::gdsAtomLabels {}
    set ::ForceFieldToolKit::gui::gdsRepName {}
    # Clear Edit Data Boxes
    set ::ForceFieldToolKit::gui::gdsEditIndDef {}
    set ::ForceFieldToolKit::gui::gdsEditEqVal {}
    set ::ForceFieldToolKit::gui::gdsEditPlusMinus {}
    set ::ForceFieldToolKit::gui::gdsEditStepSize {}
    
    
    # DihOpt Tabl Setup
    # Initialize DihOpt Namespace
    ::ForceFieldToolKit::DihOpt::init
    # Initialize DihOpt GUI Settings
    set ::ForceFieldToolKit::gui::doptStatus "IDLE"
    set ::ForceFieldToolKit::gui::doptBuildScript 0
    set ::ForceFieldToolKit::gui::doptPlotQME 1
    set ::ForceFieldToolKit::gui::doptPlotMME 1
    # Clear Edit Data Boxes
    set ::ForceFieldToolKit::gui::doptEditDef {}
    set ::ForceFieldToolKit::gui::doptEditFC {}
    set ::ForceFieldToolKit::gui::doptEditMult {}
    set ::ForceFieldToolKit::gui::doptEditDelta {}
    set ::ForceFieldToolKit::gui::doptQMEStatus "EMPTY"
    set ::ForceFieldToolKit::gui::doptMMEStatus "EMPTY"
    set ::ForceFieldToolKit::gui::doptDihAllStatus "EMPTY"
    set ::ForceFieldToolKit::gui::doptEditColor {}
    set ::ForceFieldToolKit::gui::doptResultsPlotHandle {}
    set ::ForceFieldToolKit::gui::doptResultsPlotWin {}
    set ::ForceFieldToolKit::gui::doptResultsPlotCount {}
    set ::ForceFieldToolKit::gui::doptRefineStatus "IDLE"
    set ::ForceFieldToolKit::gui::doptRefineCount 0
    
    
    # INITIALIZE THE CONSOLE
    set ::ForceFieldToolKit::gui::consoleMessageCount 0
    set ::ForceFieldToolKit::gui::consoleState 1
    set ::ForceFieldToolKit::gui::consoleMaxHistory 100
            
}
#======================================================
proc ::ForceFieldToolKit::gui::resizeToActiveTab {} {
    # change the window size to match the active notebook tab
    
    # need to force gridder to update
    update idletasks

    # uncomment line below to resize width as well
    #set dimW [winfo reqwidth [.fftk_gui.hlf.nb select]]
    # line below does not resize width, as all tabs are designed with gracefull extension of width
    # note +/- for offset can be +- (multimonitor setup), so the expression needs to allow for BOTH symbols;
    # hend "[+-]+"
    regexp {([0-9]+)x[0-9]+[\+\-]+[0-9]+[\+\-]+[0-9]+} [wm geometry .fftk_gui] all dimW
    # manually set dimw to 750
    #set dimW 700
    set dimH [winfo reqheight [.fftk_gui.hlf.nb select]]
    #puts "${dimW}x${dimH}"
    #set dimW [expr {$dimW + 44}]
    if { $::ForceFieldToolKit::gui::consoleState } {
        set dimH [expr {$dimH + 170}]
    } else {
        set dimH [expr {$dimH + 90}]
    }
    wm geometry .fftk_gui [format "%ix%i" $dimW $dimH]
    # note: 44 and 47 take care of additional padding between nb tab and window edges
    
    update idletasks

}
#======================================================
proc ::ForceFieldToolKit::gui::consoleMessage { desc } {
    # send a message to the console
    
    # only send messages to console if it's turned on
    if { $::ForceFieldToolKit::gui::consoleState } {
        # lookup and format some data
        set count [format "%03d" $::ForceFieldToolKit::gui::consoleMessageCount]
        set timestamp [clock format [clock seconds] -format {%m/%d/%Y -- %I:%M:%S %p}]
        
        # write the message to the console
        .fftk_gui.hlf.console.log insert {} 0 -values [list $count $desc $timestamp]
        
        # increment the count
        incr ::ForceFieldToolKit::gui::consoleMessageCount
        
        # if number of messages exceeds max, remove last node
        # this is important to prevent taking too much memory
        set itemList [.fftk_gui.hlf.console.log children {}]
        if { [llength $itemList] > $::ForceFieldToolKit::gui::consoleMaxHistory } {
            .fftk_gui.hlf.console.log delete [lindex $itemList end]
        }
    }
}
#======================================================

#------------------------------------------------------
# BuildPar Specific
#------------------------------------------------------
proc ::ForceFieldToolKit::gui::bparLoadRefVDWData {} {
    # general controller function for loading reference VDW
    # topology+parameter data into the treevew box
    
    #tk_messageBox -type ok -icon info \
    #    -message "Loading a Topology + Parameter File Pair" \
    #    -detail "The following dialogs will first request"
    
    
    # request the topology and parameter files
    set topFile [tk_getOpenFile -title "Select the TOPOLOGY File" -filetypes $::ForceFieldToolKit::gui::topType]
    set parFile [tk_getOpenFile -title "Select the PARAMETER File" -filetypes $::ForceFieldToolKit::gui::parType]
    
    # rudimentary file validation
    if { $topFile eq "" || $parFile eq "" || ![file exists $topFile] || ![file exists $parFile] } {
        tk_messageBox -type ok -icon warning -message "Load FAILED" -detail "Inappropriate files selected."
        return
    }
    
    # process the input files
    array set vdwData [::ForceFieldToolKit::gui::bparBuildVDWarray [list [list $topFile $parFile]]]
    
    # load the information into the treeview box
    foreach key [array names vdwData] {
        set ele [lindex $vdwData($key) 0]
        set type [lindex $vdwData($key) 1]
        set pars [lindex $vdwData($key) 2]
        set filename [lindex $vdwData($key) 3]
        set comments [lindex $vdwData($key) 4]
        lappend ::ForceFieldToolKit::gui::bparVDWtvNodeIDs [.fftk_gui.hlf.nb.buildpar.vdwPars.refvdw.tv insert {} end -values [list $ele $type $pars $filename $comments]]
    }
    # clean up
    array unset vdwData
    
    # rebuild the elements and parSet drop down menus
    set eleList {}
    set parLis {}
    # find all elements in loaded par sets
    foreach entry [.fftk_gui.hlf.nb.buildpar.vdwPars.refvdw.tv children {}] {
        lappend eleList [lindex [.fftk_gui.hlf.nb.buildpar.vdwPars.refvdw.tv item $entry -values] 0]
        lappend parList [lindex [.fftk_gui.hlf.nb.buildpar.vdwPars.refvdw.tv item $entry -values] 3]
    }
    # sort the elements
    set eleList [lsort -unique $eleList]
    set parList [lsort -unique $parList]
    # clear the old menu
    .fftk_gui.hlf.nb.buildpar.vdwPars.refvdw.ele.menu delete 0 end
    .fftk_gui.hlf.nb.buildpar.vdwPars.refvdw.parSet.menu delete 0 end
    # rebuild the new menus
    # ele menu
    .fftk_gui.hlf.nb.buildpar.vdwPars.refvdw.ele.menu add command -label "ALL" -command { set ::ForceFieldToolKit::gui::bparVDWele "ALL"; ::ForceFieldToolKit::gui::bparVDWshowEle }
    .fftk_gui.hlf.nb.buildpar.vdwPars.refvdw.ele.menu add separator
    foreach entry $eleList {
        .fftk_gui.hlf.nb.buildpar.vdwPars.refvdw.ele.menu add command -label $entry -command "set ::ForceFieldToolKit::gui::bparVDWele $entry; ::ForceFieldToolKit::gui::bparVDWshowEle"
    }
    # parSet menu
    .fftk_gui.hlf.nb.buildpar.vdwPars.refvdw.parSet.menu add command -label "ALL" -command { set ::ForceFieldToolKit::gui::bparVDWparSet "ALL"; ::ForceFieldToolKit::gui::bparVDWshowEle }
    .fftk_gui.hlf.nb.buildpar.vdwPars.refvdw.parSet.menu add separator
    foreach entry $parList {
        .fftk_gui.hlf.nb.buildpar.vdwPars.refvdw.parSet.menu add command -label $entry -command "set ::ForceFieldToolKit::gui::bparVDWparSet $entry; ::ForceFieldToolKit::gui::bparVDWshowEle"
    }
    

    # show only the selected ele
    if { $::ForceFieldToolKit::gui::bparVDWele == {} } { set ::ForceFieldToolKit::gui::bparVDWele "ALL" }
    if { $::ForceFieldToolKit::gui::bparVDWparSet == {} } { set ::ForceFieldToolKit::gui::bparVDWparSet "ALL" }
    
    ::ForceFieldToolKit::gui::bparVDWshowEle
    
}
#======================================================
proc ::ForceFieldToolKit::gui::bparVDWshowEle {} {
    # shows only the tv items for the selected element and parfile
    
    # detach all nodes currently in tv
    foreach item [.fftk_gui.hlf.nb.buildpar.vdwPars.refvdw.tv children {}] {
        .fftk_gui.hlf.nb.buildpar.vdwPars.refvdw.tv detach $item
    }
    
    # cycle through all nodes in the node list and if ele/parSet match, reattach node using the move cmd
    # the node is added when...
    # ele = ALL    &&  parSet = ALL
    # ele = match  &&  parSet = ALL
    # ele = ALL    &&  parSet = match
    # ele = match  &&  parSet = match
    
    foreach item $::ForceFieldToolKit::gui::bparVDWtvNodeIDs {
        if { $::ForceFieldToolKit::gui::bparVDWele eq "ALL" && $::ForceFieldToolKit::gui::bparVDWparSet eq "ALL" } {
            .fftk_gui.hlf.nb.buildpar.vdwPars.refvdw.tv move $item {} 0
        } elseif { [.fftk_gui.hlf.nb.buildpar.vdwPars.refvdw.tv set $item ele] eq $::ForceFieldToolKit::gui::bparVDWele && $::ForceFieldToolKit::gui::bparVDWparSet eq "ALL" } {
            .fftk_gui.hlf.nb.buildpar.vdwPars.refvdw.tv move $item {} 0
        } elseif { $::ForceFieldToolKit::gui::bparVDWele eq "ALL" && [.fftk_gui.hlf.nb.buildpar.vdwPars.refvdw.tv set $item filename] eq $::ForceFieldToolKit::gui::bparVDWparSet } {
            .fftk_gui.hlf.nb.buildpar.vdwPars.refvdw.tv move $item {} 0
        } elseif { [.fftk_gui.hlf.nb.buildpar.vdwPars.refvdw.tv set $item ele] eq $::ForceFieldToolKit::gui::bparVDWele && [.fftk_gui.hlf.nb.buildpar.vdwPars.refvdw.tv set $item filename] eq $::ForceFieldToolKit::gui::bparVDWparSet} {
            .fftk_gui.hlf.nb.buildpar.vdwPars.refvdw.tv move $item {} 0
        }
    }


    # sort the treeview
    set eleTypeList {}
    foreach item [.fftk_gui.hlf.nb.buildpar.vdwPars.refvdw.tv children {}] {
        set currEle [lindex [.fftk_gui.hlf.nb.buildpar.vdwPars.refvdw.tv item $item -values] 0]
        set currType [lindex [.fftk_gui.hlf.nb.buildpar.vdwPars.refvdw.tv item $item -values] 1]
        set currFile [lindex [.fftk_gui.hlf.nb.buildpar.vdwPars.refvdw.tv item $item -values] 3]
        lappend eleTypeList [list $currEle $currType $currFile $item]
    }
    set orderedItemList {}
    foreach entry [lsort -dictionary $eleTypeList] {
        lappend orderedItemList [lindex $entry 3]
    }
    .fftk_gui.hlf.nb.buildpar.vdwPars.refvdw.tv children {} $orderedItemList
}
#======================================================
proc ::ForceFieldToolKit::gui::bparBuildVDWarray { fileList } {
    # builds an array containing VDW information
    
    #puts "filelist: $fileList"; flush stdout
    
    # build an array to match element to atomic weight
    # these are supported atoms
    array set eleByMass {
        0 H
        1 H
        4 HE
        12 C
        14 N
        16 O
        19 F
        20 NE
        23 NA
        24 MG
        27 AL
        31 P
        32 S
        35 CL
        39 K
        40 CA
        56 FE
        65 ZN
        80 BR
        127 I
        133 CS
    }
    
    # initialize
    array set vdwData {}
    
    # fileList should read:
    # {  {top1 par1} {top2 par2} ... {topN parN}  }
    
    foreach filePair $fileList {
        #puts "Processing filePair: $filePair"; flush stdout
        set topFile [lindex $filePair 0]
        set parFile [lindex $filePair 1]
        
        # TOPOLOGY FILE
        # parse MASS statments from topology
        set topIn [open $topFile r]
        while { ![eof $topIn] } {
            set inLine [gets $topIn]
            if { [regexp {^MASS} $inLine] } {
                set type [lindex $inLine 2]
                set massNum [expr {round([lindex $inLine 3])}]
                set comment [string trim [lindex [split $inLine !] end]]
                if { [info exists eleByMass($massNum)] } {
                    # if the mass number is supported, add the element
                    set vdwData($type) [list $eleByMass($massNum) {} {} {} {}]
                } else {
                    # otherwise declare the element as unknown
                    set vdwData($type) [list UNK {} {} {} {}]
                }
                lset vdwData($type) 1 $type
                lset vdwData($type) 4 $comment
            } else {
                continue
            }
        }; # end of reading topFile (while)

        close $topIn
        
        #puts "vdwData After topology parsing"
        #foreach key [array names vdwData] { puts "\t$vdwData($key)" }
        #flush stdout
        
        # PARAMETER FILE
        set rawParData {}
        set parIn [open $parFile r]
        # read in the NONBONDED section, with comments
        set readstate 0
        while { ![eof $parIn] } {
            set inLine [gets $parIn]
            switch -regexp $inLine {
                {^[ \t]*$} { continue }
                {^[ \t]*\*.*} { continue }
                {^[a-z]+} { continue }
                {^BONDS.*} { set readstate 0 }
                {^ANGLES.*} { set readstate 0 }
                {^DIHEDRALS.*} { set readstate 0 }
                {^IMPROPER.*} { set readstate 0 }
                {^CMAP.*} { set readstate 0 }
                {^NONBONDED.*} { set readstate 1 }
                {^HBOND.*} { set readstate 0 }
                {^END.*} { break }
                default {
                    if { $readstate } {
                        lappend rawParData $inLine
                    }
                }
            
            }; # end of lineread (switch)
        }; # end of reading parIn (while)
        
        close $parIn
        
        #puts "rawParData After reading parameter file"
        #foreach ele $rawParData { puts "\t$ele" }
        #flush stdout
        
        # process the vdw parameter data
        # burn the header
        while { [regexp {^[ \t]*!} [lindex $rawParData 0]] } {
            set rawParData [lreplace $rawParData 0 0]
        }
        
        #puts "rawParData After burning the header:"
        #foreach ele $rawParData { puts "\t$ele" }
        #flush stdout
        
        # build the processed vdw par data by folding two-line comments into one line
        set procParData {}
        foreach ele $rawParData {
            if { [regexp {^[ \t]+!} $ele] } {
                # line is a comment, append to previous line
                lset procParData end [concat [lindex $procParData end] $ele]
            } else {
                # line is not a comment, add to new processed list
                lappend procParData $ele
            }
        }
        
        #puts "procParData After folding comments:"
        #foreach ele $procParData { puts "\t$ele" }
        #flush stdout
        
        # reprocess the parameter data and insert into the vdwData array
        foreach ele $procParData {
            # split along comment denotation (!)
            set splitData [split $ele !]
            # parse out LJ data
            set ljData [string trim [lindex $splitData 0]]
            # build a comments list
            set comData {}
            for {set i 1} {$i < [llength $splitData]} {incr i} {
                lappend comData [string trim [lindex $splitData $i]]
            }
            # insert the data into the appropriate vdwData
            set type [lindex $ljData 0]
            set ljnorm [lrange $ljData 2 3]
            set lj14 [lrange $ljData 5 6]
            if { [info exists vdwData($type)] } {
                lset vdwData($type) 2 [list $ljnorm $lj14]
                lset vdwData($type) 3 [file tail $parFile]
                lset vdwData($type) 4 [linsert $comData 0 [lindex $vdwData($type) 4]]
            }
        }

        # message the console
        ::ForceFieldToolKit::gui::consoleMessage "VDW/LJ parameters loaded for [file rootname [file tail [lindex $filePair 1]]]"

    }; # end of cycling through file pairs (foreach)
    
    return [array get vdwData]
}
#======================================================


#------------------------------------------------------
# GenZMat Specific
#------------------------------------------------------
proc ::ForceFieldToolKit::gui::gzmToggleLabels {} {
    # toggles atom labels for TOP molecule to help determine donor and acceptor indices
    
    variable gzmAtomLabels
    
    if { [llength $gzmAtomLabels] > 0 } {
        foreach label $gzmAtomLabels {graphics top delete $label}
        set gzmAtomLabels {}
    } else {
        draw color lime
        foreach ind [[atomselect top all] get index] {
            set sel [atomselect top "index $ind"]
            lappend gzmAtomLabels [draw text [join [$sel get {x y z}]] $ind size 3]
            $sel delete
        }
    }
}
#======================================================
proc ::ForceFieldToolKit::gui::gzmToggleSpheres {} {
    # toggles colored spheres for atoms in donor and acceptor lists to help check indices
    # blue spheres for donors
    # red spheres for acceptors
    # gree sphere for both donor AND acceptors
    
    variable gzmVizSpheresDon
    variable gzmVizSpheresAcc
    variable gzmVizSpheresBoth
    
    graphics top materials on
    graphics top material Diffuse
    
    # initialize local lists
    set donList $::ForceFieldToolKit::GenZMatrix::donList
    set accList $::ForceFieldToolKit::GenZMatrix::accList
    set bothList {}

    # find the overlap
    foreach ele $donList {
        if { [lsearch $accList $ele] != -1 } { lappend bothList $ele }
    }
    # remove overlaps from don and acc lists
    foreach ele $bothList {
        # remove from donList
        set donInd [lsearch $donList $ele]
        if { $donInd != -1 } { lreplace $donList $donInd $donInd }
        # remove from accList
        set accInd [lsearch $accList $ele]
        if { $accInd != -1 } { lreplace $accList $accInd $accInd }
    }

    # toggle the graphics elements    
    if { [llength $gzmVizSpheresDon] > 0 } {
        foreach sphere $gzmVizSpheresDon {graphics top delete $sphere}
        set gzmVizSpheresDon {}
    } else {
        draw color blue
        foreach ind $donList {
            set sel [atomselect top "index $ind"]
            lappend gzmVizSpheresDon [graphics top sphere [join [$sel get {x y z}]] radius 0.2 resolution 30]
            $sel delete
        }
    }
    
    if { [llength $gzmVizSpheresAcc] > 0 } {
        foreach sphere $gzmVizSpheresAcc {graphics top delete $sphere}
        set gzmVizSpheresAcc {}
    } else {
        draw color red
        foreach ind $accList {
            set sel [atomselect top "index $ind"]
            lappend gzmVizSpheresAcc [graphics top sphere [join [$sel get {x y z}]] radius 0.2 resolution 30]
            $sel delete
        }
    }
    
    if { [llength $gzmVizSpheresBoth] > 0 } {
        foreach sphere $gzmVizSpheresBoth {graphics top delete $sphere}
        set gzmVizSpheresBoth {}
    } else {
        draw color green
        foreach ind $bothList {
            set sel [atomselect top "index $ind"]
            lappend gzmVizSpheresBoth [graphics top sphere [join [$sel get {x y z}]] radius 0.2 resolution 30]
            $sel delete
        }
    }
    
}
#======================================================
proc ::ForceFieldToolKit::gui::gzmAutoDetect {} {
    # very simple method to autodetecting donors and acceptors
    
    # add all hydrogens
    set ::ForceFieldToolKit::GenZMatrix::donList [[atomselect top "element H"] get index]
    
    # add all heavy atoms with less than 4 bonded atoms (generally tetrahedral)
    set ::ForceFieldToolKit::GenZMatrix::accList {}
    foreach hvyatom [[atomselect top "all and not element H"] get index] {
        set sel [atomselect top "index $hvyatom"]
        if { [llength [lindex [$sel getbonds] 0]] < 4 } {
            lappend ::ForceFieldToolKit::GenZMatrix::accList $hvyatom
            if { [$sel get element] eq "C" } {
                lappend ::ForceFieldToolKit::GenZMatrix::donList $hvyatom
            }
        }
        $sel delete
    }
    
}
#======================================================


#------------------------------------------------------
# ChargeOpt Specific
#------------------------------------------------------
proc ::ForceFieldToolKit::gui::coptShowAtomLabels {} {
    # shows labels to aid in setting up charge optimizations
    # label can be none, index, name, type, charge
    
    variable coptAtomLabel
    variable coptAtomLabelInd

    # reset graphics
    foreach ind $coptAtomLabelInd {graphics top delete $ind}
    set $coptAtomLabelInd {}
    draw color lime

    # set new labels    
    foreach atomInd [[atomselect top all] get index] {
        set sel [atomselect top "index $atomInd"]
        switch -exact $coptAtomLabel {
            "Index"  { lappend coptAtomLabelInd [draw text [join [$sel get {x y z}]] "[$sel get index]" size 3]  }
            "Name"   { lappend coptAtomLabelInd [draw text [join [$sel get {x y z}]] "[$sel get name]" size 3]   }
            "Type"   { lappend coptAtomLabelInd [draw text [join [$sel get {x y z}]] "[$sel get type]" size 3]   }
            "Charge" { lappend coptAtomLabelInd [draw text [join [$sel get {x y z}]] "[format "%0.3f" [$sel get charge]]" size 3] }
            default  {}
        }
        $sel delete
    }
}
#======================================================
proc ::ForceFieldToolKit::gui::coptSetEditData { box } {
    # grabs data from the currently selected Log File entry and copies into the Edit Box
    

    if { $box eq "cconstr" } {
        # for the Charge Constraints box (cconstr)
        set editData [.fftk_gui.hlf.nb.chargeopt.cconstr.chargeData item [.fftk_gui.hlf.nb.chargeopt.cconstr.chargeData selection] -values]
        set ::ForceFieldToolKit::gui::coptEditGroup [lindex $editData 0]
        set ::ForceFieldToolKit::gui::coptEditInit [lindex $editData 1]
        set ::ForceFieldToolKit::gui::coptEditLowBound [lindex $editData 2]
        set ::ForceFieldToolKit::gui::coptEditUpBound [lindex $editData 3]
        unset editData
    } elseif { $box eq "wie" } {
        # for the Water Interaction Energies box (wie)
        set editData [.fftk_gui.hlf.nb.chargeopt.qmt.wie.logData item [.fftk_gui.hlf.nb.chargeopt.qmt.wie.logData selection] -values]
        set ::ForceFieldToolKit::gui::coptEditLog [lindex $editData 0]
        set ::ForceFieldToolKit::gui::coptEditAtomName [lindex $editData 1]
        set ::ForceFieldToolKit::gui::coptEditWeight [lindex $editData 2]
        unset editData
    } elseif { $box eq "results" } {
        set editData [.fftk_gui.hlf.nb.chargeopt.results.container1.cgroups item [.fftk_gui.hlf.nb.chargeopt.results.container1.cgroups selection] -values]
        set ::ForceFieldToolKit::gui::coptEditFinalCharge [lindex $editData 1]
    }

}
#======================================================
proc ::ForceFieldToolKit::gui::coptClearEditData { box } {

    if {$box eq "cconstr"} {
        # clear charge constraints edit boxes
        set ::ForceFieldToolKit::gui::coptEditGroup {}
        set ::ForceFieldToolKit::gui::coptEditInit {}
        set ::ForceFieldToolKit::gui::coptEditLowBound {}
        set ::ForceFieldToolKit::gui::coptEditUpBound {}
    } elseif {$box eq "wie"} {
        # clear the water interaction energy edit boxes
        set ::ForceFieldToolKit::gui::coptEditLog {}
        set ::ForceFieldToolKit::gui::coptEditAtomName {}
        set ::ForceFieldToolKit::gui::coptEditWeight {}
    } elseif {$box eq "results" } {
        set ::ForceFieldToolKit::gui::coptEditFinalCharge {}
    }

}
#======================================================
proc ::ForceFieldToolKit::gui::coptGuessChargeGroups {} {

    # initialize some variables
    array set indexTree {}
    set typeFPList {}
    
    set cgNames {}
    set cgInit {}
    set cgLowBound {}
    set cgUpBound {}
    
    
    # set the list of all atoms
    set allList [lsort -dictionary [[atomselect top all] get index]]
    
    # cycle through each atom as the root
    foreach rootAtom $allList {
    
        # initialize the indexTree array for this particular atom
        # by setting node 0
        set indexTree($rootAtom) $rootAtom
        
        # initialize the traveledList
        set traveledList $rootAtom
        
        # initialize nodeCounter
        set nodeCount 1
        # traverse nodes until all atoms are covered
        while { [lsort -dictionary $traveledList] != $allList } {
        
            # initialize a temporary list to hold new atoms for this node
            set tmpNodeList {}
        
            # find bonded atoms for each atom in the preceeding node
            foreach precNodeAtom [lindex $indexTree($rootAtom) [expr {$nodeCount - 1}]] {
        
                # find the atoms
                set bondedAtoms [lindex [[atomselect top "index $precNodeAtom"] getbonds] 0]
                # check to see if we've already traveled to any of these atoms
                foreach bAtom $bondedAtoms {
                    if { [lsearch -exact -integer $traveledList $bAtom] == -1 } {
                        # new atom, append it to the list of atoms that we've been to so that we won't come back
                        lappend traveledList $bAtom
                        # add to the temp current node list
                        lappend tmpNodeList $bAtom
                    } else {
                        # we've already been to this atom, so skip it
                    }
                }; # end of travelList check foreach
                
            }; # end of node cycle foreach
    
            # now that we have only atoms that we haven't traveled to
            # we can write them to the current node
            lappend indexTree($rootAtom) $tmpNodeList
        
            # increment the node counter to move onto the next node
            incr nodeCount
            
        }; # end of while statement that traverses the atom tree
    
        # convert the indexTree into type fingerprint
        set typeFP {} 
        foreach node $indexTree($rootAtom) {
            set nodeAtomTypes {}
            foreach atom $node {
                lappend nodeAtomTypes [[atomselect top "index $atom"] get type]
            }
            lappend typeFP [lsort -dictionary $nodeAtomTypes]
        }
    
        # append the fingerprint to the full list of fingerprints
        # if everything sorted properly, then the index should match the atom index
        lappend typeFPList $typeFP
    
    }; # end of foreach that cycles through each atom
    
    
    # define charge groups based on the type fingerprints
    set cgInd {}
    foreach atom $allList {
        # find the current atom's finger print
        set atomFP [lindex $typeFPList $atom]
        # search against the full list of finger prints, and sort the matches
        set fpMatches [lsort -dictionary [lsearch -exact -all $typeFPList $atomFP]]
        # append the matches to the master match file
        lappend cgInd $fpMatches
    }
    # remove duplicate matches
    set cgInd [lsort -dictionary -unique $cgInd]
    
    # if charge group is HA (non-polar hydrogens), then remove them
    # work from end to beginning so that items can be removed without shifting contents
    for {set i [expr {[llength $cgInd] - 1}] } {$i >= 0} {incr i -1} {
        set atomInd [lindex [lindex $cgInd $i] 0]
        set atomType [[atomselect top "index $atomInd"] get type]
        if { $atomType eq "HA" } {
            set cgInd [lreplace $cgInd $i $i]
        }
    }
    
    # convert to indices to atom name
    foreach cg $cgInd {
        set atomNames {}
        foreach atom $cg {
            lappend atomNames [[atomselect top "index $atom"] get name]
        }
        lappend cgNames $atomNames
    }
    
    # decide some guess parameters
    for {set i 0} {$i < [llength $cgInd]} {incr i} {
        set atomIndex [lindex [lindex $cgInd $i] 0]
        set temp [atomselect top "index $atomIndex"]
        
        # init value: grab PSF reCharge charge value
        lappend cgInit [format "%.4f" [$temp get charge]]
        
        # bounds
        switch -exact [$temp get element] {
            "H" {
                lappend cgLowBound "0.0"
                lappend cgUpBound "1.0"
            }
            
            "C" {
                lappend cgLowBound "-1.0"
                lappend cgUpBound "1.0"
            }
            
            "O" {
                lappend cgLowBound "-1.0"
                lappend cgUpBound "1.0"
            }
            
            "N" {
                lappend cgLowBound "-1.0"
                lappend cgUpBound "1.0"
            }
            
            default {
                lappend cgLowBound "-2.0"
                lappend cgHighBound "2.0"
            }
        }; # end switch
        
        $temp delete
        
    }
    
    #puts "Charge Groups: $cgNames"
    #puts "Init: $cgInit"
    #puts "Lower Bound: $cgLowBound"
    #puts "Upper Bound: $cgUpBound"
    
    # insert data into treeview box
    for {set i 0} {$i < [llength $cgNames]} {incr i} {
        .fftk_gui.hlf.nb.chargeopt.cconstr.chargeData insert {} end -values [list "[lindex $cgNames $i]" "[lindex $cgInit $i]" "[lindex $cgLowBound $i]" "[lindex $cgUpBound $i]"]
    }

}
#======================================================
proc ::ForceFieldToolKit::gui::coptCalcChargeSum {} {
    # calculates the charge sum based on current charges
    # and the defined charge groups
    
    # build an exclude list for the atoms in the charge groups
    set excludeList {}
    foreach entry [.fftk_gui.hlf.nb.chargeopt.cconstr.chargeData children {}] {
        foreach atom [.fftk_gui.hlf.nb.chargeopt.cconstr.chargeData set $entry group] {
            lappend excludeList $atom
        }
    }
    
    # find atom names
    set temp [atomselect top all]
    set atomNames [$temp get name]
    unset temp
    
    # cycle through each atom name
    # if it's not defined in the charge groups, add the current charge
    set csum 0
    foreach atom $atomNames {
        if { [lsearch $excludeList $atom] == -1 } {
            set temp [atomselect top "name $atom"]
            set csum [expr {$csum + [$temp get charge]}]
            unset temp
        }
    }

    # return the charge sum    
    return [format "%0.2f" [expr {-1*$csum}]]
}
#======================================================
proc ::ForceFieldToolKit::gui::coptRunOpt {} {
    # procedure for button to run the charge optimization
    
    # reset some variables
    set ::ForceFieldToolKit::ChargeOpt::parList {}
    set ::ForceFieldToolKit::ChargeOpt::chargeGroups {}
    set ::ForceFieldToolKit::ChargeOpt::chargeInit {}
    set ::ForceFieldToolKit::ChargeOpt::chargeBounds {}
    set ::ForceFieldToolKit::ChargeOpt::logFileList {}
    set ::ForceFieldToolKit::ChargeOpt::atomList {}
    set ::ForceFieldToolKit::ChargeOpt::indWeights {}
    
    # build and set the parList from treeview data
    foreach tvItem [.fftk_gui.hlf.nb.chargeopt.input.parFilesBox children {}] {
        lappend ::ForceFieldToolKit::ChargeOpt::parList [lindex [.fftk_gui.hlf.nb.chargeopt.input.parFilesBox item $tvItem -values] 0]
    }
    
    # build and set the charge constraints from treeview data
    foreach tvItem [.fftk_gui.hlf.nb.chargeopt.cconstr.chargeData children {}] {
        set datavals [.fftk_gui.hlf.nb.chargeopt.cconstr.chargeData item $tvItem -values]
        lappend ::ForceFieldToolKit::ChargeOpt::chargeGroups [lindex $datavals 0]
        lappend ::ForceFieldToolKit::ChargeOpt::chargeInit [lindex $datavals 1]
        lappend ::ForceFieldToolKit::ChargeOpt::chargeBounds [list [lindex $datavals 2] [lindex $datavals 3]]
    }
    
    # build and set the logFileList, atomList, and indWeights from treeview data
    foreach tvItem [.fftk_gui.hlf.nb.chargeopt.qmt.wie.logData children {}] {
        set datavals [.fftk_gui.hlf.nb.chargeopt.qmt.wie.logData item $tvItem -values]
        lappend ::ForceFieldToolKit::ChargeOpt::logFileList [lindex $datavals 0]
        lappend ::ForceFieldToolKit::ChargeOpt::atomList [lindex $datavals 1]
        lappend ::ForceFieldToolKit::ChargeOpt::indWeights [lindex $datavals 2]
    }
    

    # print setup settings in debugging mode
    if { $::ForceFieldToolKit::ChargeOpt::debug } {
        ::ForceFieldToolKit::ChargeOpt::printSettings stdout
    }
    
    # run the optimization
    # first, check to see if build script setting is checked
    # if yes, then write a script that can be run independently
    # if no, then run optimization as normal
    if { $::ForceFieldToolKit::gui::coptBuildScript } {
        set ::ForceFieldToolKit::gui::coptStatus "Writing to script..."
        update idletasks
        ::ForceFieldToolKit::ChargeOpt::buildScript [file dirname $::ForceFieldToolKit::ChargeOpt::outFileName]/ChargeOptScript.tcl
        set ::ForceFieldToolKit::gui::coptStatus "IDLE"
        ::ForceFieldToolKit::gui::consoleMessage "Charge optimization script written"
    } else {
        set ::ForceFieldToolKit::gui::coptStatus "Running..."
        ::ForceFieldToolKit::gui::consoleMessage "Charge optimization started"
        update idletasks
        # run the optimization
        ::ForceFieldToolKit::ChargeOpt::optimize
        # clear any old results and then load the new results
        .fftk_gui.hlf.nb.chargeopt.results.container1.cgroups delete [.fftk_gui.hlf.nb.chargeopt.results.container1.cgroups children {}]
        foreach returnCharge $::ForceFieldToolKit::ChargeOpt::returnFinalCharges {
            .fftk_gui.hlf.nb.chargeopt.results.container1.cgroups insert {} end -values [list [lindex $returnCharge 0] [lindex $returnCharge 1]]
        }
        # update the charge total
        ::ForceFieldToolKit::gui::coptCalcFinalChargeTotal
        
        # set the staus label to idle
        set ::ForceFieldToolKit::gui::coptStatus "IDLE"
        ::ForceFieldToolKit::gui::consoleMessage "Charge optimization finished"
    }
    
    # DONE
    
}
#======================================================
proc ::ForceFieldToolKit::gui::coptParseLog { logFile } {
    # reads a log file from a previous charge optimization and imports
    # the final charge groups into the results treeview box

    # simple validation
    if { $logFile eq "" || ![file exists $logFile] } {
        tk_messageBox -type ok -icon warning -message "Action halted on error!" -detail "Cannot find charge optimization LOG file."
        return
    }

    # open the file
    set inFile [open $logFile r]
    set readState 0
    
    # read through the file a line at a time
    while { [eof $inFile] != 1 } {
        set inLine [gets $inFile]
        
        # determine if we've reached the data that we're interested in, and read if we are
        switch -exact $inLine {
            "FINAL CHARGES" { set readState 1 }
            "END" { set readState 0 }
            default {
                if { $readState } {
                    .fftk_gui.hlf.nb.chargeopt.results.container1.cgroups insert {} end -values [list [lindex $inLine 0] [lindex $inLine 1]]
                } else {
                    continue
                }
            }
        }; # end switch
    }; # end of log file
    
    # update the charge total
    ::ForceFieldToolKit::gui::coptCalcFinalChargeTotal
    
    # clean up
    close $inFile
}
#======================================================
proc ::ForceFieldToolKit::gui::coptCalcFinalChargeTotal {} {
    variable coptFinalChargeTotal
    
    set cumsum 0
    
    # cycle through all items in the final charge groups box and sum the charge values
    foreach entryItem [.fftk_gui.hlf.nb.chargeopt.results.container1.cgroups children {}] {
        set data [.fftk_gui.hlf.nb.chargeopt.results.container1.cgroups item $entryItem -values]
        set cumsum [expr {$cumsum + ([llength [lindex $data 0]] * [lindex $data 1])}]
    }
    
    # set the final cumulative sum
    set coptFinalChargeTotal [format "%0.3f" $cumsum]
}
#======================================================
proc ::ForceFieldToolKit::gui::coptWriteNewPSF {} {
    # writes a PSF file with the updated charges
    
    # simple validation
    if { $::ForceFieldToolKit::ChargeOpt::psfPath eq "" || ![file exists $::ForceFieldToolKit::ChargeOpt::psfPath] } {
        tk_messageBox -type ok -icon warning -message "Action halted on error!" -detail "Cannot find PSF file."
        return
    }
    if { $::ForceFieldToolKit::ChargeOpt::pdbPath eq "" || ![file exists $::ForceFieldToolKit::ChargeOpt::pdbPath] } {
        tk_messageBox -type ok -icon warning -message "Action halted on error!" -detail "Cannot find PDB file."
        return
    }
    if { $::ForceFieldToolKit::gui::coptPSFNewPath eq "" } {
        tk_messageBox -type ok -icon warning -message "Action halted on error!" -detail "Updated PSF filename was not specified."
        return
    }
    if { ![file writable [file dirname $::ForceFieldToolKit::gui::coptPSFNewPath]] } {
        tk_messageBox -type ok -icon warning -message "Action halted on error!" -detail "Cannot write to output directory."
        return
    }

    # reload the PSF/PDB file pair
    mol new $::ForceFieldToolKit::ChargeOpt::psfPath
    mol addfile $::ForceFieldToolKit::ChargeOpt::pdbPath
    
    # reType/reCharge, taking into account reChargeOverride settings (if set)
    ::ForceFieldToolKit::SharedFcns::reTypeFromPSF $::ForceFieldToolKit::ChargeOpt::psfPath "top"
    ::ForceFieldToolKit::SharedFcns::reChargeFromPSF $ParaToolExt::ChargeOpt::psfPath "top"
    if { $::ForceFieldToolKit::ChargeOpt::reChargeOverride } {
        foreach ovr $::ForceFieldToolKit::ChargeOpt::reChargeOverrideCharges {
            set temp [atomselect top "name [lindex $ovr 0]"]
            $temp set charge [lindex $ovr 1]
            $temp delete
        }
    }
    
    # cycle through loaded results data
    foreach CGentry [.fftk_gui.hlf.nb.chargeopt.results.container1.cgroups children {}] {
    
        # parse data values as a whole
        set data [.fftk_gui.hlf.nb.chargeopt.results.container1.cgroups item $CGentry -values]
        
        # parse charge
        set charge [lindex $data 1]
        
        # reset the charge for each atom in the charge groups
        foreach atomName [lindex $data 0] {
            [atomselect top "name $atomName"] set charge $charge
        }
    }
    
    # write the psf file
    [atomselect top all] writepsf $::ForceFieldToolKit::gui::coptPSFNewPath
    
    # cleanup
    mol delete top

}
#======================================================


#------------------------------------------------------
# BondAngleOpt Specific
#------------------------------------------------------
proc ::ForceFieldToolKit::gui::baoptRunOpt {} {
    # procedure for button to run the bonds/angles optimization
    
    # reset some variables (only those explicitely set here)
    set ::ForceFieldToolKit::BondAngleOpt::bondtypelist {}
    set ::ForceFieldToolKit::BondAngleOpt::angtypelist {}
    set ::ForceFieldToolKit::BondAngleOpt::bondangFCs {}
    set ::ForceFieldToolKit::BondAngleOpt::bondEqs {}
    set ::ForceFieldToolKit::BondAngleOpt::angEqs {}
    set ::ForceFieldToolKit::BondAngleOpt::parlist {}
    
    # build type, FC, and Eq lists
    set tempBondFCs {}
    set tempAngleFCs {}
    # cycle through each item in the treeview box
    foreach tvItem [.fftk_gui.hlf.nb.bondangleopt.pconstr.pars2opt children {}] {
        # grab the data from tv item
        set itemData [.fftk_gui.hlf.nb.bondangleopt.pconstr.pars2opt item $tvItem -values]
        # separate data between bonds and angles
        # directly set typelist and Eqs, build temp FC lists
        if { [lindex $itemData 0] eq "bond" } {
            lappend ::ForceFieldToolKit::BondAngleOpt::bondtypelist [lindex $itemData 1]
            lappend tempBondFCs [lindex $itemData 2]
            lappend ::ForceFieldToolKit::BondAngleOpt::bondEqs [lindex $itemData 3]
        } elseif { [lindex $itemData 0] eq "angle" } {
            lappend ::ForceFieldToolKit::BondAngleOpt::angtypelist [lindex $itemData 1]
            lappend tempAngleFCs [lindex $itemData 2]
            lappend ::ForceFieldToolKit::BondAngleOpt::angEqs [lindex $itemData 3]
        }
    }
    # set the full FC list (bonds then angles) and clean up
    set ::ForceFieldToolKit::BondAngleOpt::bondangFCs [concat $tempBondFCs $tempAngleFCs]
    unset tempBondFCs tempAngleFCs
    
    # build the list of parameter files
    foreach tvItem [.fftk_gui.hlf.nb.bondangleopt.input.parFiles children {}] {
        lappend ::ForceFieldToolKit::BondAngleOpt::parlist [lindex [.fftk_gui.hlf.nb.bondangleopt.input.parFiles item $tvItem -values] 0]
    }
    
    
    # run the optimization
    # first, check to see if build script setting is checked
    if { $::ForceFieldToolKit::gui::baoptBuildScript } {
        # build a script instead of running directly
        set ::ForceFieldToolKit::gui::baoptStatus "Writing to script..."
        update idletasks
        ::ForceFieldToolKit::BondAngleOpt::buildScript BondAngleOptScript.tcl
        set ::ForceFieldToolKit::gui::baoptStatus "IDLE"
    } else {
        # run optimization directly 
        set ::ForceFieldToolKit::gui::baoptStatus "Running..."
        update idletasks
        ::ForceFieldToolKit::BondAngleOpt::optimize
        set ::ForceFieldToolKit::gui::baoptStatus "IDLE"
    }
    
    # DONE

}
#======================================================


#------------------------------------------------------
# GenDihScan Specific
#------------------------------------------------------
#======================================================
proc ::ForceFieldToolKit::gui::gdsToggleLabels {} {
    # toggles atom labels for TOP molecule
    
    variable gdsAtomLabels
    
    if { [llength $gdsAtomLabels] > 0 } {
        foreach label $gdsAtomLabels {graphics top delete $label}
        set gdsAtomLabels {}
    } else {
        draw color lime
        foreach ind [[atomselect top all] get index] {
            set sel [atomselect top "index $ind"]
            lappend gdsAtomLabels [draw text [join [$sel get {x y z}]] $ind size 3]
            $sel delete
        }
    }
}
#======================================================
proc ::ForceFieldToolKit::gui::gdsImportDihedrals { psf pdb parfile } {
    # reads in a molecule and parameter file
    # if the molecule contains dihedrals that are defined in the parfile
    # returns the indices and current value for the dihedral
    
    # TODO
    # proc doesn't recognize chemically equivalent dihedrals
    # of which only one needs to be scanned

    # validation
    set errorList {}
    set errorText ""

    if { $psf eq "" || ![file exists $psf] } { lappend errorList "Cannot find PSF file." }
    if { $pdb eq "" || ![file exists $pdb] } { lappend errorList "Cannot find PDB file." }
    if { $parfile eq "" || ![file exists $parfile] } { lappend errorList "Cannot find parameter file." }

    if { $errorList > 0 } {
        foreach ele $errorList {
            set errorText [concat $errorText\n$ele]
        }
        tk_messageBox -type ok -icon warning -message "Action halted on error!" -detail $errorText
        return
    }

    
    # read the parameter file and parse out the dihedrals section
    set dihPars [lindex [::ForceFieldToolKit::SharedFcns::readParFile $parfile] 2]
    # build a 1D search index of unique type defs
    set dihTypeIndex {}
    foreach dih $dihPars {
        lappend dihTypeIndex [lindex $dih 0]
    }
    set dihTypeIndex [lsort -unique $dihTypeIndex]
    

    # load the molecule
    mol new $psf; mol addfile $pdb
    # retype from psf (can be removed once VMD psf reader is fixed to support CGenFF-styled types)
    ::ForceFieldToolKit::SharedFcns::reTypeFromPSF $psf top
    
    # grab the indices for all dihedrals (parse out only index information)
    set indDefList {}
    foreach entry [topo getdihedrallist] {
        lappend indDefList [lrange $entry 1 4]
    }
    
    # convert the index def list to type def list and element def list
    set typeDefList {}
    set eleDefList {}
    # cycle through each dihedral
    foreach dih $indDefList {
        set typeDef {}
        set eleDef {}
        # cycle through each index
        foreach ind $dih {
            set temp [atomselect top "index $ind"]
            lappend typeDef [$temp get type]
            lappend eleDef [$temp get element]
            $temp delete
        }
        # write the full typeDef to the list
        lappend typeDefList $typeDef
        lappend eleDefList $eleDef
    }


    # cycle through the typeDefLst
    # if the typeDef is in the dihTypeIndex (from par file),
    # then grab the index definition and measure the dihedral
    set unqCentralBondInds {}
    set returnData {}
    for {set i 0} {$i < [llength $typeDefList]} {incr i} {
        if { [lsearch -exact $dihTypeIndex [lindex $typeDefList $i]] != -1 || \
             [lsearch -exact $dihTypeIndex [lreverse [lindex $typeDefList $i]]] != -1 } {
             
                 # check to see if either end index is a hydrogen
                 if { [lindex $eleDefList $i 0] == "H" || [lindex $eleDefList $i 3] == "H" } { continue }

                 # check to see if the central bond is a duplicate (repeat scan)
                 set bondInds [lsort -increasing [lrange [lindex $indDefList $i] 1 2]]
                 if { [lsearch $unqCentralBondInds $bondInds] != -1 } { continue } else { lappend unqCentralBondInds $bondInds }
                
                 # grab the index def and measure the dihedral value
                 set currIndDef [lindex $indDefList $i]
                 set currDihVal [format "%.0f" [measure dihed $currIndDef]]
                 
                 # append the data to return
                 lappend returnData [list $currIndDef $currDihVal]
                 
        } else {
            continue
        }
    }

    
    # clean up
    mol delete top
    
    # return the data
    return $returnData
    
}
#======================================================
proc ::ForceFieldToolKit::gui::gdsShowSelRep {} {
    # shows a representation of the selected tv entries in VMD
    # via a CPK representation

    # build a list of indices to include in the representation
    # based on the tv selection
    set indexList {}
    foreach ele [.fftk_gui.hlf.nb.genDihScan.dihs2scan.tv selection] {
        foreach ind [.fftk_gui.hlf.nb.genDihScan.dihs2scan.tv set $ele indDef] {
            lappend indexList $ind
        }
    }
    
    # build a list of rep names for the top molecule
    set currRepNames {}
    for {set i 0} {$i < [molinfo top get numreps]} {incr i} {
        lappend currRepNames [mol repname top $i]
    }
    
    # determine if there is already a representation in place
    # and if that rep still exists (i.e., the user hasn't deleted it)
    if { $::ForceFieldToolKit::gui::gdsRepName eq "" || [lsearch $currRepNames $::ForceFieldToolKit::gui::gdsRepName] == -1 } {
        # we need a new rep
        mol selection "index $indexList"
        mol representation CPK
        mol color Name
        mol addrep top
        
        set ::ForceFieldToolKit::gui::gdsRepName [mol repname top [expr {[molinfo top get numreps]-1}]]
        
    } else {
        # update the old rep
        set currRepId [mol repindex top $::ForceFieldToolKit::gui::gdsRepName]
        mol modselect $currRepId top "index $indexList"
    }
}
#======================================================


#------------------------------------------------------
# DihedralOpt Specific
#------------------------------------------------------
proc ::ForceFieldToolKit::gui::doptRunOpt {} {
    # procedure for button to run the dihedral optimization
    
    # initialize/reset some variables that will explicitely set by GUI
    set ::ForceFieldToolKit::DihOpt::parlist {}
    set ::ForceFieldToolKit::DihOpt::GlogFiles {}
    set ::ForceFieldToolKit::DihOpt::parDataInput {}
    
    # build the parameter files list (parlist) from the TV box
    foreach tvItem [.fftk_gui.hlf.nb.dihopt.input.parFiles children {}] {
        lappend ::ForceFieldToolKit::DihOpt::parlist [lindex [.fftk_gui.hlf.nb.dihopt.input.parFiles item $tvItem -values] 0]
    }
        
    # build the gaussian log files list (qm target data) from the TV box
    foreach tvItem [.fftk_gui.hlf.nb.dihopt.qmt.tv children {}] {
        lappend ::ForceFieldToolKit::DihOpt::GlogFiles [.fftk_gui.hlf.nb.dihopt.qmt.tv item $tvItem -values]
    }

    # build the parameter data input list
    # requires the form:
    # {
    #   {typedef} {k mult delta}
    # }
    foreach tvItem [.fftk_gui.hlf.nb.dihopt.parSet.tv children {}] {
        set dihPars [.fftk_gui.hlf.nb.dihopt.parSet.tv item $tvItem -values]
        set typeDef [lindex $dihPars 0]
        set fc [lindex $dihPars 1]
        set mult [lindex $dihPars 2]
        set delta [lindex $dihPars 3]
        # if phase shift is 180, flip the sign of k and reset delta to 0
        if { $delta == 180 } {
            set fc [expr {-1*$fc}]
            set delta 0
        }
        
        lappend ::ForceFieldToolKit::DihOpt::parDataInput [list $typeDef [list $fc $mult $delta]]
    }
    
    if { $::ForceFieldToolKit::gui::doptBuildScript } {
        # build a script instead of running directly
        set ::ForceFieldToolKit::gui::doptStatus "Writing to script..."
        update idletasks
        ::ForceFieldToolKit::DihOpt::buildScript [file dirname $::ForceFieldToolKit::DihOpt::outFileName]/DihOptScript.tcl
        #puts "the build script function is not currently implemented"
        set ::ForceFieldToolKit::gui::doptStatus "IDLE"
        ::ForceFieldToolKit::gui::consoleMessage "Dihedral optimization run script written"
    } else {
        # run optimization directly
        set ::ForceFieldToolKit::gui::doptStatus "Running..."
        ::ForceFieldToolKit::gui::consoleMessage "Dihedral optimization started"
        update idletasks
        set finalOptData [::ForceFieldToolKit::DihOpt::optimize]
        if { $finalOptData == -1 } { 
            set ::ForceFieldToolKit::gui::doptStatus "Halted on ERROR"
            ::ForceFieldToolKit::gui::consoleMessage "Dihedral optimization halted on error"
            update idletasks
            return
        }
        set ::ForceFieldToolKit::gui::doptStatus "Loading Results..."
        update idletasks
        
        # test QME, MMEi, and dihAll; update status labels in Vis. Results accordingly
        if { [llength $::ForceFieldToolKit::DihOpt::EnQM] != 0 } {
            set ::ForceFieldToolKit::gui::doptQMEStatus "Loaded"
        } else {
            set ::ForceFieldToolKit::gui::doptQMEStatus "ERROR"
        }
        if { [llength $::ForceFieldToolKit::DihOpt::EnMM] != 0 } {
            set ::ForceFieldToolKit::gui::doptMMEStatus "Loaded"
        } else {
            set ::ForceFieldToolKit::gui::doptMMEStatus "ERROR"
        }
        if { [llength $::ForceFieldToolKit::DihOpt::dihAllData] != 0 } {
            set ::ForceFieldToolKit::gui::doptDihAllStatus "Loaded"
        } else {
            set ::ForceFieldToolKit::gui::doptDihAllStatus "ERROR"
        }
        update idletasks
        
        # clear the Vis. Results treeview
        .fftk_gui.hlf.nb.dihopt.results.data.tv delete [.fftk_gui.hlf.nb.dihopt.results.data.tv children {}]
        set ::ForceFieldToolKit::gui::doptRefineCount 1
        # add the data to the Vis. Results treeview
        .fftk_gui.hlf.nb.dihopt.results.data.tv insert {} end -values [list "orig" [format "%.3f" [lindex $finalOptData 0]] "blue" [lindex $finalOptData 1] [lindex $finalOptData 2]]

        # clear and then build the refinement parameter definitions from the final values
        .fftk_gui.hlf.nb.dihopt.refine.parSet.tv delete [.fftk_gui.hlf.nb.dihopt.refine.parSet.tv children {}]
#        set finalParList [lindex $finalOptData 2]
#        foreach ele $finalParList {
#            set typedef [lrange $ele 0 3]
#            set k [lindex $ele 4]
#            set mult [lindex $ele 5]
#            set delta [lindex $ele 6]
#            .fftk_gui.hlf.nb.dihopt.refine.parSet.tv insert {} end -values [list $typedef $k $mult $delta]
#        }
        
        # update the status label
        set ::ForceFieldToolKit::gui::doptStatus "IDLE"
        ::ForceFieldToolKit::gui::consoleMessage "Dihedral optimization finished"
        update idletasks
        
    }
    
    # DONE

}
#======================================================
proc ::ForceFieldToolKit::gui::doptRunRefine {} {
    # procedure for button to run the dihedral refinement/refitting
    
    # initialize some variables that will be explicitely set by GUI
    set ::ForceFieldToolKit::DihOpt::refineParDataInput {}
    
    # build the parameter data input list
    # requires the form:
    # {
    #   {typedef} {k mult delta}
    # }
    foreach tvItem [.fftk_gui.hlf.nb.dihopt.refine.parSet.tv children {}] {
        set dihPars [.fftk_gui.hlf.nb.dihopt.refine.parSet.tv item $tvItem -values]
        set typeDef [lindex $dihPars 0]
        set fc [lindex $dihPars 1]
        set mult [lindex $dihPars 2]
        set delta [lindex $dihPars 3]
        # if phase shift is 180, flip the sign of k and reset delta to 0
        if { $delta == 180 } {
            set fc [expr {-1*$fc}]
            set delta 0
        }        
        lappend ::ForceFieldToolKit::DihOpt::refineParDataInput [list $typeDef [list $fc $mult $delta]]
    }
    
    # launch the refinement
    set ::ForceFieldToolKit::gui::doptStatus "Running..."
    ::ForceFieldToolKit::gui::consoleMessage "Dihedral refinement started"
    update idletasks
    set finalRefineData [::ForceFieldToolKit::DihOpt::refine]
    if { $finalRefineData == -1 } { 
        set ::ForceFieldToolKit::gui::doptStatus "Halted on ERROR"
        ::ForceFieldToolKit::gui::consoleMessage "Dihedral refinement halted on error"
        update idletasks
        return
    }

    set ::ForceFieldToolKit::gui::doptStatus "Loading Results..."
    update idletasks
    
    # add the data to the Viz. Results treeview
    .fftk_gui.hlf.nb.dihopt.results.data.tv insert {} end -values [list "r[format "%02d" $::ForceFieldToolKit::gui::doptRefineCount]" [format "%.3f" [lindex $finalRefineData 0]] "blue" [lindex $finalRefineData 1] [lindex $finalRefineData 2]]
    incr ::ForceFieldToolKit::gui::doptRefineCount
    
    # update the status label
    set ::ForceFieldToolKit::gui::doptStatus "IDLE"
    ::ForceFieldToolKit::gui::consoleMessage "Dihedral refinement finished"
    update idletasks
    
    # DONE
    
}
#======================================================
proc ::ForceFieldToolKit::gui::doptSetColor {} {
    # sets the color for all selected data sets
    # very simple program, but simplifies menu construction
    
    foreach dataId [.fftk_gui.hlf.nb.dihopt.results.data.tv selection] {
        .fftk_gui.hlf.nb.dihopt.results.data.tv set $dataId color $::ForceFieldToolKit::gui::doptEditColor
    }
}
#======================================================
proc ::ForceFieldToolKit::gui::doptBuildPlotWin {} {
    # builds the window for plotting the results data
    
    # localize variables
    variable doptP
    variable doptResultsPlotHandle
    
    # if the multiplot window already exists, then deiconify it
    if { [winfo exists .pte_plot] } {
        wm deiconify .pte_plot
        return
    }

    # build the window
    set doptP [toplevel ".pte_plot"]
    wm title $doptP "Plot DihOpt Results"
    
    # allow window to expand with .
    grid columnconfigure $doptP 0 -weight 1
    grid rowconfigure $doptP 0 -weight 1
    
    # set a default initial geometry
    wm geometry $doptP 700x500
    
    # build/grid a frame to hold the embedded multiplot
    ttk::frame $doptP.plotFrame
    grid $doptP.plotFrame -column 0 -row 0 -sticky nswe
    
    # build the multiplot
    set doptResultsPlotHandle [multiplot embed $doptP.plotFrame \
        -title "Selected DihOpt Fit Data" -xlabel "Conformation" -ylabel "Energy\n(kcal/mol)" \
        -xsize 680 -ysize 450 -ymin 0 -ymax 10 -xmin auto -xmax auto \
        -lines -linewidth 3]
    
    # test
    #$doptResultsPlotHandle add {0 1 2 3} {1 4 9 16} -plot
    
#    # setup bindings to manipulate plot in response to changes in window
#    bind .pte_plot <Configure> {
#        puts "window size is now %w, %h"
#    }
    # when the window is closed, clean up
    bind .pte_plot <Destroy> { 
        #$::ForceFieldToolKit::gui::doptResultsPlotHandle quit
        set ::ForceFieldToolKit::gui::doptResultsPlotHandle {}
        set ::ForceFieldToolKit::gui::doptP {}
    }
    
    # return the window
    return $doptP
    
}
#======================================================
proc ::ForceFieldToolKit::gui::doptPlotData { datasets colorsets legend } {
    # plots input y-coordinate datasets in an embedded multiplot window
    
    # localize variable
    variable doptP
    variable doptResultsPlotHandle
    
    # clear the dataset
    $doptResultsPlotHandle clear

    # cycle through each dataset
    for {set i 0} {$i < [llength $datasets] } {incr i} {
        # parse the y data
        set ydata [lindex $datasets $i]

        # build the x data
        set xdata {}
        for {set x 0} {$x < [llength $ydata]} {incr x} {
            lappend xdata $x
        }
        
        # parse out the plot color
        set plotColor [lindex $colorsets $i]
        
        # parse out the legend text
        set legendTxt [lindex $legend $i]
        
        # add the data to the plot
        $doptResultsPlotHandle add $xdata $ydata -lines -linewidth 3 -linecolor $plotColor -legend $legendTxt

    }
    
    # update the plot
    $doptResultsPlotHandle configure -xmin auto -xmax auto
    $doptResultsPlotHandle replot
    
}
#======================================================
proc ::ForceFieldToolKit::gui::doptLogParser { logfile } {
    # parses optimization and refinement logs and loads
    # the relevant information into the gui
    
    # initialize lists
    set qme {}
    set psf {}
    set pdb {}
    set mme {}
    set dihAll {}
    set rmse {}
    set mmef {}
    set parOut {}
    
    # open the log file for reading
    set inFile [open $logfile r]
    
    set readstate 0

    # read through the file a line at a time
    while { ![eof $inFile] } {
        set inLine [gets $inFile]
        
        # outter switch determines if we're entering or exiting a section of interest
        # inner switch write data to the appropriate list, or continues on
        switch -exact $inLine {
            "QMDATA" { set readstate qm }
            "PSF" { set readstate psf }
            "PDB" { set readstate pdb }
            "MME" { set readstate mme }
            "MMdihARRAY" { set readstate dih }
            "FINAL RMSE" { set readstate rmse }
            "FINAL STEP ENERGIES" { 
                set readstate mmef
                # burn a line
                gets $inFile
            }
            "FINAL PARAMETERS" { set readstate par }
            "END" { set readstate 0 }
            default {
                switch -exact $readstate {
                    "qm" { lappend qme [lindex $inLine 2]}
                    "psf" { set psf $inLine }
                    "pdb" { set pdb $inLine }
                    "mme" { lappend mme $inLine }
                    "dih" { lappend dihAll $inLine}
                    "rmse" { set rmse $inLine }
                    "mmef" { lappend mmef [lindex $inLine 2] }
                    "par" { lappend parOut [concat [lindex $inLine 1] [lrange $inLine 2 end]] }
                    default { continue }
                }
            }
            
        }
    }

    # close the input log file
    close $inFile
    
    # setup the GUI and appropriate namespace variables

    # qme and mme from log are raw and need to be normalized
    set ::ForceFieldToolKit::DihOpt::EnQM [::ForceFieldToolKit::DihOpt::renorm $qme]
    set ::ForceFieldToolKit::DihOpt::EnMM [::ForceFieldToolKit::DihOpt::renorm $mme]

    # dihAll, psf, and pdb value are all fine as-is
    set ::ForceFieldToolKit::DihOpt::dihAllData $dihAll
    set ::ForceFieldToolKit::DihOpt::psf $psf
    set ::ForceFieldToolKit::DihOpt::pdb $pdb
 
    # update labels
    if { $::ForceFieldToolKit::DihOpt::EnQM ne "" } {
        set ::ForceFieldToolKit::gui::doptQMEStatus "Loaded"
    } else {
        set ::ForceFieldToolKit::gui::doptQMEStatus "ERROR"
    }
    
    if { $::ForceFieldToolKit::DihOpt::EnMM ne "" } {
        set ::ForceFieldToolKit::gui::doptMMEStatus "Loaded"
    } else {
        set ::ForceFieldToolKit::gui::doptMMEStatus "ERROR"
    }
    
    if { $::ForceFieldToolKit::DihOpt::dihAllData ne "" } {
        set ::ForceFieldToolKit::gui::doptDihAllStatus "Loaded"
    } else {
        set ::ForceFieldToolKit::gui::doptDihAllStatus "ERROR"
    }

    # add rmse, mmef, and parOut to the results data box
    .fftk_gui.hlf.nb.dihopt.results.data.tv insert {} end -values [list "import" $rmse "blue" $mmef $parOut]

}
#======================================================
proc ::ForceFieldToolKit::gui::doptLogWriter { filename rmse mmef parData } { 
    # writes a dihedral optimization -styled log file
    
    # basename is used for a filename
    # rmse, mmef, and parData are important components of a log file
    
    # open the log file for writing
    set outFile [open $filename w]
    
    # write a header
    puts $outFile "============================================================="
    puts $outFile "Log file written directly from GUI for refit/refinement"
    puts $outFile "It will contain all necessary information for additional"
    puts $outFile "refitting/refining, and updating parameters in BuildPar"
    puts $outFile "but it will look a little different than the initial log file"
    puts $outFile "============================================================="
    
    # write "QMDATA"
    # since only QME is read in and stored from logs, this is all we can write
    # but it must be formatted in a similar manner
    
    puts $outFile "\nQMDATA"
    foreach ele $::ForceFieldToolKit::DihOpt::EnQM {
        puts $outFile "placeHolder placeHolder $ele"
    }
    puts $outFile "END"
    
    # write the psf path
    puts $outFile "\nPSF"
    puts $outFile "$::ForceFieldToolKit::DihOpt::psf"
    puts $outFile "END"
    
    # write the pdb path
    puts $outFile "\nPDB"
    puts $outFile "$::ForceFieldToolKit::DihOpt::pdb"
    puts $outFile "END"
    
    # write MME (subsection of MMDATA)
    puts $outFile "\nMME"
    foreach ele $::ForceFieldToolKit::DihOpt::EnMM {
        puts $outFile "$ele"
    }
    puts $outFile "END"
    
    # write the dihAllData
    puts $outFile "\nMMdihARRAY"
    foreach ele $::ForceFieldToolKit::DihOpt::dihAllData {
        puts $outFile "$ele"
    }
    puts $outFile "END"
    
    # write the final rmse
    puts $outFile "\nFINAL RMSE"
    puts $outFile "$rmse"
    puts $outFile "END"
    
    # write the step energies (mmef)
    puts $outFile "\nFINAL STEP ENERGIES"
    puts $outFile "QME\tMME(i)\tMME(f)\tQME-MME(f)"
    foreach ele $mmef {
        puts $outFile "placeholder placeholder $ele placeholder"
    }
    puts $outFile "END"
    
    # write the final paramater data
    puts $outFile "\nFINAL PARAMETERS"
    foreach ele $parData {
        puts $outFile "dihedral [list [lrange $ele 0 3]] [lindex $ele 4] [lindex $ele 5] [lindex $ele 6]"
    }
    puts $outFile "END"
    
    # clean up
    close $outFile
    
}
#======================================================
