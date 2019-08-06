############################################################################
#cr
#cr            (C) Copyright 1995-2011 The Board of Trustees of the
#cr                        University of Illinois
#cr                         All Rights Reserved
#cr
############################################################################

# John Eargle
# July 2009 - June 2011
#
# networkSetup.tcl
#   A set of procs that automates the network analysis process:  preparation
#   of input files for carma, running carma, and preparation of the adjacency
#   matrix file for graphNetwork.  The toplevel proc is networkSetup.


# Load the pdb and psf files into VMD
# @param dcdFile Trajectory file
# @param psfFile Structure file
proc loadStructureFiles {pdbFile psfFile} {

    if {[string equal $psfFile ""]} {
	mol load pdb $pdbFile
    } else {
	mol load psf $psfFile
	mol addfile $pdbFile
    }

    return
}


# Load the psf file and first frame of the dcd into VMD
# @param dcdFile Trajectory file
# @param psfFile Structure file
proc loadFirstTrajectoryFrame {dcdFile psfFile} {

    mol load psf $psfFile
    mol addfile $dcdFile last 0

    return
}


# Load the whole dcd and psf files into VMD
# @param dcdFile Trajectory file
# @param psfFile Structure file
proc loadTrajectoryFiles {dcdFile psfFile} {

    mol load psf $psfFile
    mol addfile $dcdFile waitfor all

    return
}


# Make sure the atom types are recognizable by carma (CHARMM style, not amber)
# @param psfFileName Structure file
proc cleanPsf {psfFileName} {

    set tempPsfFileName "$psfFileName.temp"
    
    set psfFile [open $psfFileName r]
    set tempPsfFile [open $tempPsfFileName w]

    set line [gets $psfFile]
    while {![eof $psfFile]} {
	if {[regexp {GLY} $line]} {
	    set line [regsub {CT } $line "CT2"]
	} elseif {[regexp {PRO} $line]} {
	    set line [regsub {CT } $line "CP1"]
	} elseif {[regexp {CT } $line]} {
	    set line [regsub {CT } $line "CT1"]
	} elseif {[regexp {ADE  N1} $line]} {
	    set line [regsub {NC  } $line "NN3A"]
	} elseif {[regexp {ADE  N9} $line]} {
	    set line [regsub {NS } $line "NN2"]
	} elseif {[regexp {CYT  N1} $line]} {
	    set line [regsub {NS } $line "NN2"]
	} elseif {[regexp {GUA  N1} $line]} {
	    set line [regsub {NA  } $line "NN2G"]
	} elseif {[regexp {GUA  N9} $line]} {
	    set line [regsub {NS  } $line "NN2B"]
	} elseif {[regexp {URA  N1} $line]} {
	    set line [regsub {NS  } $line "NN2B"]
	} elseif {[regexp {RA   N1} $line]} {
	    set line [regsub {NC  } $line "NN3A"]
	} elseif {[regexp {RA   N9} $line]} {
	    set line [regsub {NS } $line "NN2"]
	} elseif {[regexp {RC   N1} $line]} {
	    set line [regsub {NS } $line "NN2"]
	} elseif {[regexp {RG   N1} $line]} {
	    set line [regsub {NA  } $line "NN2G"]
	} elseif {[regexp {RG   N9} $line]} {
	    set line [regsub {NS  } $line "NN2B"]
	} elseif {[regexp {RU   N1} $line]} {
	    set line [regsub {NS  } $line "NN2B"]
	} elseif {[regexp { A +N1} $line]} {
	    set line [regsub {NC  } $line "NN3A"]
	} elseif {[regexp { A +N9} $line]} {
	    set line [regsub {NS } $line "NN2"]
	} elseif {[regexp { C +N1} $line]} {
	    set line [regsub {NS } $line "NN2"]
	} elseif {[regexp { G +N1} $line]} {
	    set line [regsub {NA  } $line "NN2G"]
	} elseif {[regexp { G +N9} $line]} {
	    set line [regsub {NS  } $line "NN2B"]
	} elseif {[regexp { U +N1} $line]} {
	    set line [regsub {NS  } $line "NN2B"]
	} elseif {[regexp { 3AU +N1} $line]} {
	    set line [regsub {NS  } $line "NN2B"]
	} elseif {[regexp { 4SU +N1} $line]} {
	    set line [regsub {NS  } $line "NN2B"]
	} elseif {[regexp { 5MU +N1} $line]} {
	    set line [regsub {NS  } $line "NN2B"]
	} elseif {[regexp { 6MA +N1} $line]} {
	    set line [regsub {NC  } $line "NN3A"]
	} elseif {[regexp { 6MA +N9} $line]} {
	    set line [regsub {NS } $line "NN2"]
	} elseif {[regexp { 7MG +N1} $line]} {
	    set line [regsub {NA  } $line "NN2G"]
	} elseif {[regexp { 7MG +N9} $line]} {
	    set line [regsub {N2  } $line "NN2B"]
	} elseif {[regexp { DHU +N1} $line]} {
	    set line [regsub {NS  } $line "NN2B"]
	} elseif {[regexp { DMA +N1} $line]} {
	    set line [regsub {NC  } $line "NN3A"]
	} elseif {[regexp { DMA +N9} $line]} {
	    set line [regsub {NS } $line "NN2"]
	} elseif {[regexp { M4C +N1} $line]} {
	    set line [regsub {NS } $line "NN2"]
	} elseif {[regexp { MRC +N1} $line]} {
	    set line [regsub {NS } $line "NN2"]
	} elseif {[regexp { MRG +N1} $line]} {
	    set line [regsub {NA  } $line "NN2G"]
	} elseif {[regexp { MRG +N9} $line]} {
	    set line [regsub {NS  } $line "NN2B"]
	} elseif {[regexp { MRU +N1} $line]} {
	    set line [regsub {NS  } $line "NN2B"]
	} elseif {[regexp { GTP +N1} $line]} {
	    set line [regsub {NA  } $line "NN2G"]
	} elseif {[regexp { GTP +N9} $line]} {
	    set line [regsub {NS  } $line "NN2B"]
	} elseif {[regexp { SPA +N1} $line]} {
	    set line [regsub {NC  } $line "NN3A"]
	} elseif {[regexp { SPA +N9} $line]} {
	    set line [regsub {NS  } $line "NN2"]
	}
	#puts $line
	puts $tempPsfFile $line
	set line [gets $psfFile]
    }
    
    close $psfFile
    close $tempPsfFile
    
    set rc [catch {exec mv $tempPsfFileName $psfFileName} out]

    return
}


# Take a list of dcd files and concatenate them together
# @param dcdFileNames List of trajectory files
# @param outFile Output file
# @param indexFile File with atom indices for atoms that will be sent to carma
# @param stride Stepsize to take through the loaded trajectory
proc catdcdList {dcdFileNames outFile indexFile stride} {
    
    set rc ""

    if {[file exists $outFile]} {
	puts "Error: $outFile exists already.  catdcd will not be run because that would append to this file."
	return
    }

    if {![string equal $dcdFileNames ""]} {
	puts "catdcd -stride $stride -i $indexFile -o $outFile $dcdFileNames"
	set rc [catch {eval "exec catdcd -stride $stride -i $indexFile -o $outFile $dcdFileNames"} out]
    } else {
	puts "Error: No dcd filenames (>Dcds) found."
    }
    
    return
}


# Prepare stripped down pdb and psf files for getAdjacencyMatrix
# @param selString Atomselection string for atoms that will be sent to carma
# @param pdbFileName Output trajectory file that will be sent to carma
# @param psfFileName Structure file
proc prepStructureFiles {selString pdbFileName psfFileName} {
        
    set sel [atomselect top $selString]
    $sel writepdb $pdbFileName
    $sel writepsf $psfFileName
    cleanPsf $psfFileName
    $sel delete

    return
}


# Prepare stripped down dcd and psf files for carma or getAdjacencyMatrix
# @param dcdFileNames List of trajectory files
# @param selString Atomselection string for atoms that will be sent to carma
# @param dcdFileName Output trajectory file that will be sent to carma
# @param psfFileName Structure file
# @param indexFileName File with atom indices for atoms that will be sent to carma
# @param stride Stepsize to take through the loaded trajectory
proc prepTrajectoryFiles {dcdFileNames selString dcdFileName psfFileName indexFileName stride} {
        
    set sel [atomselect top $selString]
    $sel writepsf $psfFileName
    cleanPsf $psfFileName
    set indices [$sel get index]
    $sel delete

    set indexFile [open $indexFileName w]
    puts $indexFile $indices
    close $indexFile

    catdcdList $dcdFileNames $dcdFileName $indexFileName $stride

    return
}


# Run carma
# @param dcdFile Trajectory file
# @param psfFile Structure file
proc runCarma {dcdFile psfFile} {

    exec carma -verb -cov -dot -norm -atmid "ALLID" -mass -fit $psfFile $dcdFile
    exec carma -verb -cov -dot -norm -atmid "ALLID" -write $psfFile carma.fitted.dcd

    return
}


# Get line from parameter file
proc getParameterLine {paramFile} {

    set line [gets $paramFile]
    puts "line: $line"
    
    if {![string equal $line ""]} {
	set psfFileName $line
	puts $line
	return $line
    } else {
	puts "Error: empty line in parameter file"
	return
    }
    
    return line
}


# Get set of lines from parameter file
# @param paramFile File containing parameters for the setup of an adjacency matrix.
# @return List of next nonempty lines in paramFile.
proc getParameterLines {paramFile} {

    set line [gets $paramFile]
    set lines ""

    #while {![eof $paramFile] && [regexp {>} $line] == 0} {}
    while {![eof $paramFile] && ![string equal $line ""]} {
	lappend lines $line
	puts $line
	set line [gets $paramFile]
    }
            
    return $lines
}


# Run the whole shebang
# @param paramFileName Parameter file
proc networkSetup {paramFileName} {

    set carmaIndexFileName "carma.indices"
    set carmaPsfFileName "carma.psf"
    set carmaDcdFileName "carma.dcd"

    set adjmatIndexFileName "adjacency.indices"
    set adjmatPsfFileName "adjacency.psf"
    set adjmatPdbFileName "adjacency.pdb"
    set adjmatDcdFileName "adjacency.dcd"

    # Read in parameter file
    set paramFile [open $paramFileName "r"]
    set psfFileName ""
    set pdbFileName ""
    set firstDcdFileName ""
    set dcdFileNames ""
    set systemSelString ""
    set nodeSelString ""
    set selString ""
    
    set line [gets $paramFile]
    while {![eof $paramFile]} {
	if {[regexp {>Psf} $line]} {
	    set psfFileName [getParameterLine $paramFile]
	} elseif {[regexp {>Pdb} $line]} {
	    set pdbFileName [getParameterLine $paramFile]
	} elseif {[regexp {>Dcds} $line]} {
	    set lines [getParameterLines $paramFile]
	    if {[llength $lines] >= 1} {
		set firstDcdFileName [lindex $lines 0]
		set dcdFileNames [join $lines " "]
	    } else {
		puts "Error: strange number of lines ([llength $lines])"
	    }
	} elseif {[regexp {>SystemSelection} $line]} {
	    set systemSelString [getParameterLine $paramFile]
	} elseif {[regexp {>NodeSelection} $line]} {
	    set selString [getParameterLine $paramFile]
	}
	set line [gets $paramFile]
    }
    close $paramFile

    # Set up nodeSelString
    if {![string equal $systemSelString ""] &&
	![string equal $selString ""]} {
	set nodeSelString "($systemSelString) and ($selString)"
    } else {
	puts "Error: not possible to build nodeSelString: ($systemSelString) and ($selString)"
	return
    }
    
    # Load pdb without psf
    if { ![string equal $pdbFileName ""] &&
	 [string equal $psfFileName ""] &&
	 [string equal $dcdFileNames ""] } {
	loadStructureFiles $pdbFileName $psfFileName
	prepStructureFiles $systemSelString $adjmatPdbFileName $adjmatPsfFileName
	loadStructureFiles $adjmatPdbFileName ""
	getAdjacencyMatrix top $paramFileName "contact"
	return
    } elseif { ![string equal $pdbFileName ""] &&
	       ![string equal $psfFileName ""] &&
	       [string equal $dcdFileNames ""] } {
	# Load pdb and psf
	loadStructureFiles $pdbFileName $psfFileName
	prepStructureFiles $systemSelString $adjmatPdbFileName $adjmatPsfFileName
	loadStructureFiles $adjmatPdbFileName $adjmatPsfFileName
	getAdjacencyMatrix top $paramFileName "contact"
	return
    } elseif { ![string equal $psfFileName ""] &&
	       ![string equal $dcdFileNames ""] } {
	# Load dcd
	loadFirstTrajectoryFrame $firstDcdFileName $psfFileName
	prepTrajectoryFiles $dcdFileNames $nodeSelString $carmaDcdFileName $carmaPsfFileName $carmaIndexFileName 1
	runCarma $carmaDcdFileName $carmaPsfFileName
	prepTrajectoryFiles $dcdFileNames $systemSelString $adjmatDcdFileName $adjmatPsfFileName $adjmatIndexFileName 10
	loadTrajectoryFiles $adjmatDcdFileName $adjmatPsfFileName
	getAdjacencyMatrix top $paramFileName "contact" "carma.fitted.dcd.varcov.dat"
	return
    }

    puts "Error: invalid parameter file"

    return
}
