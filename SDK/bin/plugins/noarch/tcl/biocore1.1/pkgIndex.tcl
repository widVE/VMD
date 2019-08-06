# Tcl package index file, version 1.1
# This file is generated by the "pkg_mkIndex" command
# and sourced either when an application starts up or
# by a "package unknown" script.  It invokes the
# "package ifneeded" command to set up package-related
# information so that packages will be loaded automatically
# in response to "package require" commands.  When this
# script is sourced, the variable $dir must contain the
# full path name of this file's directory.

package ifneeded biocore 1.25 [list source [file join $dir biocore.tcl]]
package ifneeded biocoreHelper 1.1 [list source [file join $dir biocoreHelper.tcl]]
package ifneeded biocorechat 1.1 [list source [file join $dir biocorechat.tcl]]
package ifneeded biocorelogin 1.01 [list source [file join $dir biocorelogin.tcl]]
package ifneeded biocorepubsync 1.1 [list source [file join $dir biocorepubsync.tcl]]
package ifneeded biocoreutil 1.0 [list source [file join $dir biocoreutil.tcl]]

