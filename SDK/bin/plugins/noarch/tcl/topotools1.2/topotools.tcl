#!/usr/bin/tclsh
# TopoTools, a VMD package to simplify manipulating bonds 
# other topology related properties in VMD.
#
# TODO: 
# - topotools.tcl : some operations on bonds can be very slow.
#                   we may need some optimized variants and/or special
#                   implementation in VMD for that.
# - topoamber.tcl : interface to amber's parmtop
#
# Copyright (c) 2009,2010,2011 by Axel Kohlmeyer <akohlmey@gmail.com>
# $Id: topotools.tcl,v 1.21 2011/04/04 02:02:27 akohlmey Exp $

namespace eval ::TopoTools:: {
    # for allowing compatibility checks in scripts 
    # depending on this package. we'll have to expect
    variable version 1.2
    # location of additional data files containing 
    # force field parameters or topology data.
    variable datadir $env(TOPOTOOLSDIR)
    # print a citation reminder in case the CG-CMM is used, but only once.
    variable cgcmmciteme 1
    # if nonzero, add a new representation with default settings,
    # when creating a new molecule. similar to what "mol new" does.
    variable newaddsrep 1

    # utility command exports. the other commands are
    # best used through the "topo" frontend command.
    # part 1: operations on whole systems/selections
    namespace export mergemols selections2mol replicatemol 
    # part 2: CGCMM forcefield tools
    namespace export parse_cgcmm_parms parse_cgcmm_topo canonical_cgcmm_ljtype
}

# help/usage/error message and online documentation.
proc ::TopoTools::usage {} {
    vmdcon -info "usage: topo <command> \[args...\] <flags>"
    vmdcon -info ""
    vmdcon -info "common flags:"
    vmdcon -info "  -molid     <num>|top    molecule id (default: 'top')"
    vmdcon -info "  -sel       <selection>  atom selection function or text (default: 'all')"
#    vmdcon -info "  -relindex  0|1          indices in arguments are interpreted as absolute"
    vmdcon -info "                          or relative. (default: '0')"
    vmdcon -info "flags only applicable to 'bond' commands:"
    vmdcon -info "  -bondtype  <typename>   bond type name (default: unknown)"
    vmdcon -info "  -bondorder <bondorder>  bond order parameter (default: 1)"
    vmdcon -info ""
    vmdcon -info "commands:"
    vmdcon -info "  help                    prints this message"
    vmdcon -info ""
    vmdcon -info "  numatoms                returns the number of unique atoms."
    vmdcon -info "  numatomtypes            returns the number of atom types."
    vmdcon -info "  atomtypenames           returns the list of atom types names."
    vmdcon -info ""
    vmdcon -info "  guessatom <what> <from> (re-)set atom data heuristically. currently supported:"
    vmdcon -info "    element from mass, element from name, element from type, mass from element,"
    vmdcon -info "    name from element, name from type, radius from element, type from element,"
    vmdcon -info "    type from name, lammps from data (= element<-mass, name & radius<-element)"
    vmdcon -info ""
    vmdcon -info "  numbonds                returns the number of unique bonds."
    vmdcon -info "  numbondtypes            returns the number of bond types."
    vmdcon -info "  bondtypenames           returns the list of bond types names."
    vmdcon -info "  clearbonds              deletes all bonds. "
    vmdcon -info "  retypebonds             resets all bond types. "
    vmdcon -info "  guessbonds              guesses bonds from atom radii (currently only works for selection 'all')."
    vmdcon -info ""
    vmdcon -info "  addbond <id1> <id2>     (re-)defines a single bond."
    vmdcon -info "  delbond <id1> <id2>     deletes a single bond, if it exists."
    vmdcon -info ""
    vmdcon -info "  getbondlist \[type|order|both|none\]"
    vmdcon -info "     returns a list of unique bonds, optionally"
    vmdcon -info "     including bond order and bond type."
    vmdcon -info "  setbondlist \[type|order|both|none\] <list>" 
    vmdcon -info "     resets all bonds from a list in the same"
    vmdcon -info "     format as returned by 'topo getbondlist'."
    vmdcon -info "     order or type are reset to defaults if not given."
    vmdcon -info ""
    vmdcon -info "  num(angle|dihedral|improper)s       returns the number of unique (angle|dihedral|improper)s"
    vmdcon -info "  num(angle|dihedral|improper)types   returns the number of (angle|dihedral|improper) types"
    vmdcon -info "  (angle|dihedral|improper)typenames  returns the list of bond type names"
    vmdcon -info "  clear(angle|dihedral|improper)s     deletes all (angle|dihedral|improper)s. "
    vmdcon -info "  sort(angle|dihedral|improper)s      sorts the list of (angle|dihedral|improper)s"
    vmdcon -info "                                      according to atom index and removes duplicates"
    vmdcon -info "  retype(angle|dihedral|improper)s    resets all angle types. "
    vmdcon -info ""
    vmdcon -info "  guess(angle|dihedral)s              guesses angle and dihedral definitions from bonds."
    vmdcon -info "  guessimproper \[tolerance <degrees>\] guesses improper definitions from bonds. impropers are only defined"
    vmdcon -info "                                      for atoms bonded to three other atoms with a near flat structure."
    vmdcon -info "                                      the tolerance flag changes the allowed deviation from 180 deg (default: 5 deg)."
    vmdcon -info ""
    vmdcon -info "  addangle <id1> <id2> <id3> \[<type>\] (re-defines) a single angle."
    vmdcon -info "  delangle <id1> <id2> <id3>  (re-defines) a single angle."
    vmdcon -info "  add(dihedral|improper) <id1> <id2> <id3> <id4> \[<type>\] (re-)defines a single (dihedral|improper)."
    vmdcon -info "  del(dihedral|improper) <id1> <id2> <id3> <id4> deletes a single (dihedral|improper)."
    vmdcon -info ""
    vmdcon -info ""
    vmdcon -info "  getanglelist  returns the list of angle definitions"
    vmdcon -info "                in the form {type <id1> <id2> <id3>}"
    vmdcon -info "  setanglelist <list>"
    vmdcon -info "                resets angle definitions from a list in the same"
    vmdcon -info "                format as retured by 'topo getanglelist'"
    vmdcon -info "  get(dihedral|improper)list  returns the list of (dihedral|improper) definitions"
    vmdcon -info "                in the form {type <id1> <id2> <id3> <id4>}"
    vmdcon -info "  set(dihedral|improper)list <list>"
    vmdcon -info "                resets (dihedral|improper) definitions from a list in the same"
    vmdcon -info "                format as retured by 'topo get(dihedral|improper)list'"
    vmdcon -info "NOTE: for angle, dihedral, and improper lists, the"
    vmdcon -info "      type field currently has to be always present."
    vmdcon -info ""
    vmdcon -info ""
    vmdcon -info "  readlammpsdata <filename> \[<atomstyle>\]"
    vmdcon -info "      read atom coordinates, properties, bond, angle, dihedral and other related data"
    vmdcon -info "      from a LAMMPS data file. 'atomstyle' is the value given to the 'atom_style'"
    vmdcon -info "      parameter. default value is 'full'."
    vmdcon -info "      this subcommand creates a new molecule and returns the molecule id or -1 on failure."
    vmdcon -info "      the -sel parameter is currently ignored."
    vmdcon -info ""
    vmdcon -info "  writelammpsdata <filename> \[<atomstyle>\]"
    vmdcon -info "      write atom properties, bond, angle, dihedral and other related data"
    vmdcon -info "      to a LAMMPS data file. 'atomstyle' is the value given to the 'atom_style'"
    vmdcon -info "      parameter. default value is 'full'."
    vmdcon -info "      Only data that is present is written. "
    vmdcon -info ""
    vmdcon -info "  readvarxyz <filename>"
    vmdcon -info "      read an xmol/xyz format trajectory with a varying numer of particles."
    vmdcon -info "      This is normally not supported by VMD and the script circumvents this"
    vmdcon -info "      restriction by automatically adding dummy particles and then indicating"
    vmdcon -info "      the presence of a given atom in a given frame by setting its user field"
    vmdcon -info "      to either 1.0 or -1.0 in case of an atom being present or not, respectively."
    vmdcon -info "      For efficiency reasons, atoms are sorted by atom type, so atom order and bonding"
    vmdcon -info "      are not preserved. The function returns the new molecule id or -1."
    vmdcon -info ""
    vmdcon -info "  writevarxyz <filename> \[selmod <selstring>\] \[first|last|step <frame>\]"
    vmdcon -info "      write an xmol/xyz format trajectory files with a varying number of particles."
    vmdcon -info "      This is the counter part to the 'readvarxyz' subcommand."
    vmdcon -info "      The optional selection string in the <selstring> argument indicates"
    vmdcon -info "      how to select the atoms. Its default is 'user > 0'."
    vmdcon -info ""
    vmdcon -info "  writegmxtop <filename>"
    vmdcon -info "      write a fake gromacs topology format file that can be used in combination"
    vmdcon -info "      with a .gro/.pdb coordinate file for generating .tpr files needed to use"
    vmdcon -info "      Some of the more advanced gromacs analysis tools for simulation data that"
    vmdcon -info "      was not generated with gromacs."
    vmdcon -info ""
    return
}

# the main frontend command.
# this takes care of all sanity checks on arguments and
# then dispatches the subcommands to the corresponding
# subroutines. 
proc TopoTools::topo { args } {

    set molid -1
    set seltxt all
    set selmol -1
    set bondtype unknown
    set bondorder 1.0

    set cmd ""

    # process generic arguments and remove them
    # from argument list.
    set newargs {}
    for {set i 0} {$i < [llength $args]} {incr i} {
        set arg [lindex $args $i]

        if {[string match -?* $arg]} {
            
            set val [lindex $args [expr $i+1]]
        
            switch -- $arg {
                -molid { 
                    if {[catch {molinfo $val get name} res]} {
                        vmdcon -error "Invalid -molid argument '$val': $res"
                        return
                    }
                    set molid $val
                    if {[string equal $molid "top"]} {
                        set molid [molinfo top]
                    }
                    incr i
                }

                -sel { 
                    if {[info commands $val] != ""} {
                        if {[catch {$val text} res]} {
                            vmdcon -error "Invalid -sel argument '$val': $res"
                            return
                        }
                        set selmol [$val molid]
                    } else {
                        set res $val
                    }
                    set seltxt $res
                    incr i
                }

                -bondtype { 
                    if {[string length $val] < 1} {
                        vmdcon -error "Invalid -bondtype argument '$val'"
                        return
                    }
                    set bondtype $val
                    incr i
                }

                -bondorder { 
                    if {[string length $val] < 1} {
                        vmdcon -error "Invalid -bondorder argument '$val'"
                        return
                    }
                    set bondorder $val
                    incr i
                }

                -- break

                default {
                    vmdcon -info "default: $arg"
                }
            }
        } else {
            lappend newargs $arg
        }
    }

    if {$molid < 0} { 
        set molid $selmol
    }
    if {$molid < 0} { 
        set molid [molinfo top]
    }

    set retval ""
    if {[llength $newargs] > 0} {
        set cmd [lindex $newargs 0]
        set newargs [lrange $newargs 1 end]
    } else {
        set newargs {}
        set cmd help
    }

    # we need a few special cases for reading coordinate/topology files.
    if {[string equal $cmd readlammpsdata]} {
        set style full
        if {[llength $newargs] < 1} {
            vmdcon -error "Not enough arguments for 'topo readlammpsdata'"
            usage
            return
        }
        set fname [lindex $newargs 0]
        if {[llength $newargs] > 1} {
            set style [lindex $newargs 1]
        }
        if {[checklammpsstyle $style]} {
            vmdcon -error "Atom style '$style' not supported."
            usage
            return
        }
        set retval [readlammpsdata $fname $style]
        if {[info exists sel]} {
            $sel delete
        }
        return $retval
    }

    if {[string equal $cmd readvarxyz]} {
        set fname [lindex $newargs 0]
        set retval [readvarxyz $fname]
        if {[info exists sel]} {
            $sel delete
        }
        return $retval
    }

    # help!!!
    if { ![string equal $cmd help] } {
        if {($selmol >= 0) && ($selmol != $molid)} {
            vmdcon -error "Molid from selection '$selmol' does not match -molid argument '$molid'"
            return
        }
        if {[catch {atomselect $molid $seltxt} sel]} {
            vmdcon -error "Problem with atom selection: $sel"
            return
        }
    }

    # branch out to the various subcommands
    switch -- $cmd {
        numatoms      -
        numatomtypes  -
        atomtypenames {
            if {[llength $newargs] < 1} {set newargs none}
            set retval [atominfo $cmd $sel $newargs]
        }

        guessatom {
            if {[llength $newargs] < 2} {
                vmdcon -error "'topo guessatom' requires two arguments: <what> <from>"
                return
            }
            set retval [guessatomdata $sel [lindex $newargs 0] [lindex $newargs 1]]
        }

        getbondlist   -
        bondtypenames -
        numbondtypes  -
        numbonds {
            if {[llength $newargs] < 1} {set newargs none}
            set retval [bondinfo $cmd $sel $newargs]
        }

        setbondlist  {
            set flag none
            if {[llength $newargs] > 1} {
                set flag [lindex $newargs 0]
                set newargs [lrange $newargs 1 end]
            }
            if {[llength $newargs] < 1} {set newargs none}
            set retval [setbondlist $sel $flag [lindex $newargs 0]]
        }

        retypebonds {
            set retval [retypebonds $sel] 
        }

        clearbonds {
            set retval [clearbonds $sel] 
        }

        guessbonds {
            set retval [guessbonds $sel] 
        }

        addbond {
            if {[llength $newargs] < 2} {
                vmdcon -error "Not enough arguments for 'topo addbond'"
                usage
                return
            }
            set retval [addbond $molid \
                            [lindex $newargs 0] \
                            [lindex $newargs 1] \
                            $bondtype $bondorder]
        }

        delbond {
            if {[llength $newargs] < 2} {
                vmdcon -error "Not enough arguments for 'topo addbond'"
                usage
                return
            }
            set retval [delbond $molid \
                            [lindex $newargs 0] \
                            [lindex $newargs 1] \
                            $bondtype $bondorder]
        }

        getanglelist   -
        angletypenames -
        numangletypes  -
        numangles {
            if {[llength $newargs] < 1} {set newargs none}
            set retval [angleinfo $cmd $sel $newargs]
        }

        setanglelist  {
            set retval [setanglelist $sel [lindex $newargs 0]]
        }

        retypeangles {
            set retval [retypeangles $sel] 
        }

        guessangles {
            set retval [guessangles $sel] 
        }

        sortangles {
            set retval [sortsomething angle $sel] 
        }

        clearangles {
            set retval [clearangles $sel] 
        }

        addangle {
            set atype unknown
            if {[llength $newargs] < 3} {
                vmdcon -error "Not enough arguments for 'topo addangle'"
                usage
                return
            }
            if {[llength $newargs] > 3} {
                set atype [lindex $newargs 3]
            }
            set retval [addangle $molid \
                            [lindex $newargs 0] \
                            [lindex $newargs 1] \
                            [lindex $newargs 2] \
                            $atype]
        }

        delangle {
            set atype unknown
            if {[llength $newargs] < 3} {
                vmdcon -error "Not enough arguments for 'topo delangle'"
                usage
                return
            }
            set retval [delangle $molid \
                            [lindex $newargs 0] \
                            [lindex $newargs 1] \
                            [lindex $newargs 2] ]
        }

        getdihedrallist   -
        dihedraltypenames -
        numdihedraltypes  -
        numdihedrals {
            if {[llength $newargs] < 1} {set newargs none}
            set retval [dihedralinfo $cmd $sel $newargs]
        }

        setdihedrallist  {
            set retval [setdihedrallist $sel [lindex $newargs 0]]
        }

        retypedihedrals {
            set retval [retypedihedrals $sel] 
        }

        guessdihedrals {
            set retval [guessdihedrals $sel] 
        }

        sortdihedrals {
            set retval [sortsomething dihedral $sel] 
        }

        cleardihedrals {
            set retval [cleardihedrals $sel] 
        }

        adddihedral {
            set atype unknown
            if {[llength $newargs] < 4} {
                vmdcon -error "Not enough arguments for 'topo adddihedral'"
                usage
                return
            }
            if {[llength $newargs] > 4} {
                set atype [lindex $newargs 4]
            }
            set retval [adddihedral $molid \
                            [lindex $newargs 0] \
                            [lindex $newargs 1] \
                            [lindex $newargs 2] \
                            [lindex $newargs 3] \
                            $atype]
        }

        deldihedral {
            set atype unknown
            if {[llength $newargs] < 4} {
                vmdcon -error "Not enough arguments for 'topo deldihedral'"
                usage
                return
            }
            set retval [deldihedral $molid \
                            [lindex $newargs 0] \
                            [lindex $newargs 1] \
                            [lindex $newargs 2] \
                            [lindex $newargs 3] ]
        }

        getimproperlist   -
        impropertypenames -
        numimpropertypes  -
        numimpropers {
            if {[llength $newargs] < 1} {set newargs none}
            set retval [improperinfo $cmd $sel $newargs]
        }

        setimproperlist  {
            set retval [setimproperlist $sel [lindex $newargs 0]]
        }

        retypeimpropers {
            set retval [retypeimpropers $sel] 
        }

        guessimpropers {
            set retval [guessimpropers $sel $newargs] 
        }

        sortimpropers {
            set retval [sortsomething improper $sel] 
        }

        clearimpropers {
            set retval [clearimpropers $sel] 
        }

        addimproper {
            set atype unknown
            if {[llength $newargs] < 4} {
                vmdcon -error "Not enough arguments for 'topo addimproper'"
                usage
                return
            }
            if {[llength $newargs] > 4} {
                set atype [lindex $newargs 4]
            }
            set retval [addimproper $molid \
                            [lindex $newargs 0] \
                            [lindex $newargs 1] \
                            [lindex $newargs 2] \
                            [lindex $newargs 3] \
                            $atype]
        }

        delimproper {
            set atype unknown
            if {[llength $newargs] < 4} {
                vmdcon -error "Not enough arguments for 'topo delimproper'"
                usage
                return
            }
            set retval [delimproper $molid \
                            [lindex $newargs 0] \
                            [lindex $newargs 1] \
                            [lindex $newargs 2] \
                            [lindex $newargs 3] ]
        }

        writelammpsdata { ;# NOTE: readlammpsdata is handled above to bypass check for sel/molid.
            set style full
            if {[llength $newargs] < 1} {
                vmdcon -error "Not enough arguments for 'topo writelammpsdata'"
                usage
                return
            }
            set fname [lindex $newargs 0]
            if {[llength $newargs] > 1} {
                set style [lindex $newargs 1]
            }
            if {[checklammpsstyle $style]} {
                vmdcon -error "Atom style '$style' not supported."
                usage
                return
            }
            set retval [writelammpsdata $molid $fname $style $sel]
        }

        writevarxyz { ;# NOTE: readvarxyz is handled above to bypass check for sel/molid.
            if {[llength $newargs] < 1} {
                vmdcon -error "Not enough arguments for 'topo writevarxyz'"
                usage
                return
            }
            set fname [lindex $newargs 0]
            set retval [writevarxyz $fname $molid $sel [lrange $newargs 1 end]]
        }

        writegmxtop { ;# NOTE: readgmxtop is handled above to bypass check for sel/molid.
            if {[llength $newargs] < 1} {
                vmdcon -error "Not enough arguments for 'topo writegmxtop'"
                usage
                return
            }
            set fname [lindex $newargs 0]
            set retval [writegmxtop $fname $molid $sel [lrange $newargs 1 end]]
        }

        help -
        default {
            usage
        }
    }
    if {[info exists sel]} {
        $sel delete
    }
    return $retval
}

# load middleware API
source [file join $env(TOPOTOOLSDIR) topoatoms.tcl]
source [file join $env(TOPOTOOLSDIR) topobonds.tcl]
source [file join $env(TOPOTOOLSDIR) topoangles.tcl]
source [file join $env(TOPOTOOLSDIR) topodihedrals.tcl]
source [file join $env(TOPOTOOLSDIR) topoimpropers.tcl]

# load high-level API
source [file join $env(TOPOTOOLSDIR) topolammps.tcl]
source [file join $env(TOPOTOOLSDIR) topogromacs.tcl]
source [file join $env(TOPOTOOLSDIR) topovarxyz.tcl]
source [file join $env(TOPOTOOLSDIR) topocgcmm.tcl]

# load high-level utility functions
source [file join $env(TOPOTOOLSDIR) topoutils.tcl]

# load internal helper functions
source [file join $env(TOPOTOOLSDIR) topohelpers.tcl]

# insert the "topo" frontend command into the normal namespace
interp alias {} topo {} ::TopoTools::topo

package provide topotools $::TopoTools::version

