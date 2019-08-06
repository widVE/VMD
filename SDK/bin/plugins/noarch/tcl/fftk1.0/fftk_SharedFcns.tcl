#
# $Id: fftk_SharedFcns.tcl,v 1.3 2012/01/26 22:10:18 johns Exp $
#

namespace eval ::ForceFieldToolKit::SharedFcns {

}
#======================================================
proc ::ForceFieldToolKit::SharedFcns::reTypeFromPSF { psfFile molID } {
    # parses type from PSF and resets appropriately in VMD
    # necessary especially for long atom types (psfgen chokes)

    set reType {}
    set inFile [open $psfFile r]
    
    # read until !NATOMS section
    while { [lindex [gets $inFile] end] ne "\!NATOM" } {
        continue
    }
    
    # once in NATOMS, read until blank line (end of NATOMS)
    while { [set inline [gets $inFile]] ne "" } {
        lappend reType [lindex $inline 5]
    }
    
    close $inFile

    # reset type
    for {set i 0} {$i < [llength $reType]} {incr i} {
        set temp [atomselect $molID "index $i"]
        $temp set type [lindex $reType $i]
        $temp delete
    }
}
#======================================================
proc ::ForceFieldToolKit::SharedFcns::reChargeFromPSF { psfFile molID } {
    # parses charge from PSF and resets appropriately in VMD
    # necessary especially for long atom types (psfgen chokes) 

    set reCharge {}
    set inFile [open $psfFile r]
    
    # read until !NATOMS section
    while { [lindex [gets $inFile] end] ne "\!NATOM" } {
        continue
    }
    
    # once in NATOMS, read until blank line (end of NATOMS)
    while { [set inline [gets $inFile]] ne "" } {
        lappend reCharge [lindex $inline 6]
    }
    
    close $inFile

    # reset type and charge 
    for {set i 0} {$i < [llength $reCharge]} {incr i} {
        set temp [atomselect $molID "index $i"]
        $temp set charge [lindex $reCharge $i]
        $temp delete
    }
}
#======================================================
proc ::ForceFieldToolKit::SharedFcns::writeMinConf { name psf pdb parlist {extrabFile ""} } {

   set conf [open "$name.conf" w]
   puts $conf "structure          $psf"    
   puts $conf "coordinates        $pdb"
   puts $conf "paraTypeCharmm     on"
   foreach par $parlist {
      puts $conf "parameters       $par"
   }
   puts $conf "temperature         310"
   puts $conf "exclude             scaled1-4"
   puts $conf "1-4scaling          1.0"
   puts $conf "cutoff              1000.0"
   puts $conf "switching           on"
   puts $conf "switchdist          1000.0"
   puts $conf "pairlistdist        1000.0"
   puts $conf "timestep            1.0 "
   puts $conf "nonbondedFreq       2"
   puts $conf "fullElectFrequency  4 "
   puts $conf "stepspercycle       20"
   puts $conf "outputName          $name"
   puts $conf "restartfreq         1000"
   if { $extrabFile != "" } {
      puts $conf "extraBonds          yes"
      puts $conf "extraBondsFile $extrabFile"
   }
   puts $conf "minimize            1000"
   puts $conf "reinitvels          310"
   puts $conf "run 0"
   close $conf

}
#======================================================
proc ::ForceFieldToolKit::SharedFcns::readParFile { parFile } {
    # reads in a CHARMM parameter file and returns
    # the data as a list
    
    # initialize lists
    set bonds {}
    set angles {}
    set dihedrals {}
    set impropers {}
    set cmaps {}
    set vdws {}
    
    # initialize read state
    set readstate 0
    
    # open the input parameter file
    set inFile [open $parFile r]
    
    # read through it a line at a time
    while { ![eof $inFile] } {
        set inLine [gets $inFile]
        switch -regexp $inLine {
            {^[ \t]*$} { continue }
            {^[ \t]*\*.*} { continue }
            {^[ \t]*!.*} { continue }
            {^[a-z]+} { continue }
            {^BONDS.*} { set readstate BOND }
            {^ANGLES.*} { set readstate ANGLE }
            {^DIHEDRALS.*} { set readstate DIH }
            {^IMPROPER.*} { set readstate IMPROP }
            {^CMAP.*} { set readstate CMAP }
            {^NONBONDED.*} { set readstate VDW }
            {^HBOND.*} { continue }
            {^END.*} { break }
            default {
                set prmData [lindex [split $inLine \!] 0]
                if { [string trim [lindex [split $inLine \!] 1]] ne "" } {
                    set prmComment "\! [string trim [lindex [split $inLine \!] 1]]"                
                } else {
                    set prmComment {}
                }

                switch -exact $readstate {
                    0 { continue }
                    BOND {
                        #                           { type def }          { k b0 }      { comment }
                        lappend bonds [list [lrange $prmData 0 1] [lrange $prmData 2 3] $prmComment]
                    }
                    ANGLE {
                        #                            { type def }          { k theta }           { kub s }     { comment }
                        lappend angles [list [lrange $prmData 0 2] [lrange $prmData 3 4] [lrange $prmData 5 6] $prmComment]
                    }
                    DIH {
                        #                               { type def }         { k n delta }  { comment }
                        lappend dihedrals [list [lrange $prmData 0 3] [lrange $prmData 4 6] $prmComment]
                    }
                    IMPROP {
                        #                               { type def }                { kpsi                psi0 }     { comment }
                        lappend impropers [list [lrange $prmData 0 3] [list [lindex $prmData 4] [lindex $prmData 6]] $prmComment]
                    }
                    CMAP { continue }
                    VDW {
                        #                         { type def }   { epsilon Rmin/2 }  { eps,1-4 Rmin/2,1-4} { comment }
                        lappend vdws [list [lindex $prmData 0] [lrange $prmData 2 3] [lrange $prmData 5 6] $prmComment]
                    }
                }
                unset prmData; unset prmComment
            }
        }; # end of outer switch
    }; # end while (reading file)
    
    # clean up
    close $inFile
    
    # return
    return [list $bonds $angles $dihedrals $impropers $vdws]

}
#======================================================
proc ::ForceFieldToolKit::SharedFcns::writeParFile { pars filename } {
    # takes in a set of parameters (readcharmmpar format) and a filename
    # writes a charmm-styled parameter file

    # open the output file    
    set outFile [open $filename w]
    
    # HEADER
    # print the header
    puts $outFile "!*>>>>> CHARMM22 All-Hydrogen Parameter File for Proteins <<<<<<<<"
    puts $outFile "!*>>>>>>>>>>>>>>>>>>>> and Nucleic Acids <<<<<<<<<<<<<<<<<<<<<<<<<"
    puts $outFile "!* CHARMM-specific comments to ADM jr. via the CHARMM web site:"
    puts $outFile "!*                       www.charmm.org"
    puts $outFile "!*               parameter set discussion forum"
    puts $outFile "!*"
    puts $outFile "!"    
    puts $outFile "!============================================================="
    puts $outFile "!"
    puts $outFile "! Parameter file generated by the Force Field ToolKit (ffTK)"
    puts $outFile "!"
#    puts $outFile "! The Force Field ToolKit is a modular set of tools for the"
#    puts $outFile "! development of CHARMM-compatible parameters.  It is"
#    puts $outFile "! available free of charge as a VMD plugin."
    puts $outFile "! For additional information, see:"
    puts $outFile "! http://http://www.ks.uiuc.edu/Research/vmd/"
    puts $outFile "!"
    puts $outFile "! Authors:"
    puts $outFile "! Christopher G. Mayne"
    puts $outFile "! Beckman Institute for Advanced Science and Technology"
    puts $outFile "! University of Illinois, Urbana-Champaign"
    puts $outFile "! mayne@ks.uiuc.edu"
    puts $outFile "!"
    puts $outFile "! James C. Gumbart"
    puts $outFile "! Argonne National Laboratory"
    puts $outFile "! gumbart_mcs.anl.gov"
    puts $outFile "!"
#    puts $outFile "! Citing the Force Field ToolKit (ffTK)"
    puts $outFile "! If you use parameters developed using the ffTK, please cite:"
    puts $outFile "! Mayne, Tajkhorshid, Gumbart (2012), ..."
    puts $outFile "!"
    puts $outFile "!============================================================="
    
    # BONDS
    # determine the maximum field widths to make it look pretty
    set b1max 0
    set b2max 0
    foreach bondDef [lindex $pars 0] {
        set b1l [string length [lindex $bondDef 0 0]]
        set b2l [string length [lindex $bondDef 0 1]]
        if {$b1l > $b1max} {
            set b1max $b1l
        }
        if {$b2l > $b2max} {
            set b2max $b2l
        }
    }
    
    # print the bonds section
    puts $outFile "\nBONDS"
    puts $outFile "!V(bond) = Kb(b - b0)**2"
    puts $outFile "!"
    puts $outFile "!Kb: kcal/mole/A**2"
    puts $outFile "!b0: A"
    puts $outFile "!"
    puts $outFile "!atom type Kb b0"
    puts $outFile "!"
    foreach bondDef [lindex $pars 0] {
        set at1 [lindex $bondDef 0 0]
        set at2 [lindex $bondDef 0 1]
        set k [lindex $bondDef 1 0]
        set b [lindex $bondDef 1 1]
        set comment [lindex $bondDef 2]
        puts $outFile "[format %-*s $b1max $at1]  [format %-*s $b2max $at2]  [format %-9s [format %.3f $k]]  [format %-7s [format %.3f $b]]  $comment"
    }
    
    # ANGLES
    # determine the maximum field widths to make it look pretty
    set a1max 0
    set a2max 0
    set a3max 0
    foreach angleDef [lindex $pars 1] {
        set a1l [string length [lindex $angleDef 0 0]]
        set a2l [string length [lindex $angleDef 0 1]]
        set a3l [string length [lindex $angleDef 0 2]]
        if {$a1l > $a1max} {
            set a1max $a1l
        }
        if {$a2l > $a2max} {
            set a2max $a2l
        }
        if {$a3l > $a3max} {
            set a3max $a3l
        }
    }
    
    # print the angles section
    puts $outFile "\nANGLES"
    puts $outFile "!"
    puts $outFile "!V(angle) = Ktheta(Theta - Theta0)**2"
    puts $outFile "!"
    puts $outFile "!V(Urey-Bradley) = Kub(S - S0)**2"
    puts $outFile "!"
    puts $outFile "!Ktheta: kcal/mole/rad**2"
    puts $outFile "!Theta0: degrees"
    puts $outFile "!Kub: kcal/mole/A**2 (Urey-Bradley)"
    puts $outFile "!S0: A"
    puts $outFile "!"
    puts $outFile "!atom types     Ktheta    Theta0   Kub     S0"
    puts $outFile "!"
    puts $outFile "!"
    foreach angleDef [lindex $pars 1] {
        set at1 [lindex $angleDef 0 0]
        set at2 [lindex $angleDef 0 1]
        set at3 [lindex $angleDef 0 2]
        set ktheta [lindex $angleDef 1 0]
        set theta [lindex $angleDef 1 1]
        set kub [lindex $angleDef 2 0]
        if { $kub ne ""} { set kub "[format %-7s [format %.2f $kub]]" }
        set s [lindex $angleDef 2 1]
        if { $s ne "" } { set s "[format %-7s [format %.4f $s]]" }
        set command [lindex $angleDef 3]
        puts $outFile "[format %-*s $a1max $at1]  [format %-*s $a2max $at2]  [format %-*s $a3max $at3]  [format %-7s [format %.3f $ktheta]]  [format %-7s [format %.3f $theta]]  $kub  $s $comment"
    }
    
    # DIHEDRALS
    # determine the maximum field widths to make it look pretty
    set d1max 0
    set d2max 0
    set d3max 0
    set d4max 0
    foreach dihDef [lindex $pars 2] {
        set d1l [string length [lindex $dihDef 0 0]]
        set d2l [string length [lindex $dihDef 0 1]]
        set d3l [string length [lindex $dihDef 0 2]]
        set d4l [string length [lindex $dihDef 0 3]]
        if {$d1l > $d1max} {
            set d1max $d1l
        }
        if {$d2l > $d2max} {
            set d2max $d2l
        }
        if {$d3l > $d3max} {
            set d3max $d3l
        }
        if {$d4l > $d4max} {
            set d4max $d4l
        }
    }  
    
    # print the dihedrals section
    puts $outFile "\nDIHEDRALS"
    puts $outFile "!"
    puts $outFile "!V(dihedral) = Kchi(1 + cos(n(chi) - delta))"
    puts $outFile "!"
    puts $outFile "!Kchi: kcal/mole"
    puts $outFile "!n: multiplicity"
    puts $outFile "!delta: degrees"
    puts $outFile "!"
    puts $outFile "!atom types             Kchi    n   delta"
    puts $outFile "!"
    foreach dihDef [lindex $pars 2] {
        set at1 [lindex $dihDef 0 0]
        set at2 [lindex $dihDef 0 1]
        set at3 [lindex $dihDef 0 2]
        set at4 [lindex $dihDef 0 3]
        set k [lindex $dihDef 1 0]
        set n [lindex $dihDef 1 1]
        set delta [lindex $dihDef 1 2]
        set comment [lindex $dihDef 2]
        puts $outFile "[format %-*s $d1max $at1]  [format %-*s $d2max $at2]  [format %-*s $d3max $at3]  [format %-*s $d4max $at4]  [format %-7s [format %.4f $k]]  [format %-1s $n]  [format %-5s [format %.2f $delta]]  $comment"
    }
    
    # IMPROPERS
    # determine the maximum field widths to make it look pretty
    set i1max 0
    set i2max 0
    set i3max 0
    set i4max 0
    foreach imprDef [lindex $pars 3] {
        set i1l [string length [lindex $imprDef 0 0]]
        set i2l [string length [lindex $imprDef 0 1]]
        set i3l [string length [lindex $imprDef 0 2]]
        set i4l [string length [lindex $imprDef 0 3]]
        if {$i1l > $i1max} {
            set i1max $i1l
        }
        if {$i2l > $i2max} {
            set i2max $i2l
        }
        if {$i3l > $i3max} {
            set i3max $i3l
        }
        if {$i4l > $i4max} {
            set i4max $i4l
        }        
    }
    
    # print the impropers section
    puts $outFile "\nIMPROPER"
    puts $outFile "!"
    puts $outFile "!V(improper) = Kpsi(psi - psi0)**2"
    puts $outFile "!"
    puts $outFile "!Kpsi: kcal/mole/rad**2"
    puts $outFile "!psi0: degrees"
    puts $outFile "!note that the second column of numbers (0) is ignored"
    puts $outFile "!"
    puts $outFile "!atom types           Kpsi                   psi0"
    puts $outFile "!"
    foreach imprDef [lindex $pars 3] {
        set at1 [lindex $imprDef 0 0]
        set at2 [lindex $imprDef 0 1]
        set at3 [lindex $imprDef 0 2]
        set at4 [lindex $imprDef 0 3]
        set kpsi [lindex $imprDef 1 0]
        set n [lindex $imprDef 1 1]
        set psi0 [lindex $imprDef 1 2]
        if { $psi0 ne "" } { set psi0 [format %.2f $psi0] }
        set comment [lindex $imprDef 2]
        puts $outFile "[format %-*s $d1max $at1]  [format %-*s $d2max $at2]  [format %-*s $d3max $at3]  [format %-*s $d4max $at4]  [format %-7s [format %.4f $kpsi]]  [format %-1s $n]  [format %-5s $psi0]  $comment"
    }
    
    # NONBONDED
    # determine maximum field widths to make it look pretty
    set atmax 0
    foreach nonbDef [lindex $pars 4] {
        set atl [string length [lindex $nonbDef 0]]
        if {$atl > $atmax } {
            set atmax $atl
        }
    }
    
    # print the nonbonded section
    puts $outFile "\nNONBONDED nbxmod  5 atom cdiel shift vatom vdistance vswitch -"
    puts $outFile "cutnb 14.0 ctofnb 12.0 ctonnb 10.0 eps 1.0 e14fac 1.0 wmin 1.5 "
    puts $outFile "!"
    puts $outFile "!V(Lennard-Jones) = Eps,i,j\[(Rmin,i,j/ri,j)**12 - 2(Rmin,i,j/ri,j)**6\]"
    puts $outFile "!"
    puts $outFile "!epsilon: kcal/mole, Eps,i,j = sqrt(eps,i * eps,j)"
    puts $outFile "!Rmin/2: A, Rmin,i,j = Rmin/2,i + Rmin/2,j"
    puts $outFile "!"
    puts $outFile "!atom  ignored    epsilon      Rmin/2   ignored   eps,1-4       Rmin/2,1-4"
    puts $outFile "!"
    foreach nonbDef [lindex $pars 4] {
        # for whatever reason, ::Pararead::read_charmm_parameters appends the
        # END statement to non-bonded parameters, which throws an error
        if { [lindex $nonbDef 0] eq "END" } { continue }
        set at [lindex $nonbDef 0]
        set eps [lindex $nonbDef 1 0]
        set rmin [lindex $nonbDef 1 1]
        set eps2 [lindex $nonbDef 2 0]
        if { $eps2 ne "" } { set eps2 "0.0  [format %-8s [format %.6f $eps2]]" }
        set rmin2 [lindex $nonbDef 2 1]
        if { $rmin2 ne "" } { set rmin2 "[format %-8s [format %.6f $rmin2]]" }
        set comment [lindex $nonbDef 3]
        puts $outFile "[format %-*s $atmax $at]  0.0  [format %-8s [format %.6f $eps]]  [format %-8s [format %.6f $rmin]]  $eps2  $rmin2  $comment"
    }
    
    # WRAP UP
    puts $outFile "\nEND"
    
    close $outFile    
}
#======================================================
