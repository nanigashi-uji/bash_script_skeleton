#!/bin/bash
# -*- mode: shell-script ; -*-
#
# func_skeleton: Template of shell script without side effect for "source".
#                by Uji Nanigashi (53845049+nanigashi-uji@users.noreply.github.com)
#                https://github.com/nanigashi-uji/bash_script_skeleton.git
#

if [ "$0" != "${BASH_SOURCE:-$0}" ]; then
    func_skeleton_bk="$(declare -f func_skeleton)"
    undef_func_skeleton="$(declare -f func_skeleton)"
fi

function func_skeleton () {
    # Description
    local desc="Template of shell script without side effect for 'source'"
    # Prepare Help Messages
    local funcstatus=0
    local echo_usage_bk="$(declare -f echo_usage)"
    local cleanup_bk="$(declare -f cleanup)"
    local tmpfiles=()
    local tmpdirs=()

    function  echo_usage () {
        if [ "$0" == "${BASH_SOURCE:-$0}" ]; then
            local this=$0
        else
            local this="${FUNCNAME[1]}"
        fi
        echo "[Usage] % $(basename ${this}) options"            1>&2
        echo "    ---- ${desc}"                                 1>&2
        echo "[Options]"                                        1>&2
        echo "           -d path   : Set destenation "          1>&2
        echo "           -h        : Show Help (this message)"  1>&2
        return
        :
    }

    local hndlrhup_bk="$(trap -p SIGHUP)"
    local hndlrint_bk="$(trap -p SIGINT)"
    local hndlrquit_bk="$(trap -p SIGQUIT)"
    local hndlrterm_bk="$(trap -p SIGTERM)"

    trap -- 'cleanup ; kill -1  $$' SIGHUP
    trap -- 'cleanup ; kill -2  $$' SIGINT
    trap -- 'cleanup ; kill -3  $$' SIGQUIT
    trap -- 'cleanup ; kill -15 $$' SIGTERM
    
    function cleanup () {
        
        # removr temporary files and directories
        if [ ${#tmpfiles} -gt 0 ]; then
            rm -f "${tmpfiles[@]}"
        fi
        if [ ${#tmpdirs} -gt 0 ]; then
            rm -rf "${tmpdirs[@]}"
        fi

        # Restore  signal handler
        if [ -n "${hndlrhup_bk}"  ] ; then eval "${hndlrhup_bk}"  ;  else trap --  1 ; fi
        if [ -n "${hndlrint_bk}"  ] ; then eval "${hndlrint_bk}"  ;  else trap --  2 ; fi
        if [ -n "${hndlrquit_bk}" ] ; then eval "${hndlrquit_bk}" ;  else trap --  3 ; fi
        if [ -n "${hndlrterm_bk}" ] ; then eval "${hndlrterm_bk}" ;  else trap -- 15 ; fi

        # Restore alias and functions

        unset echo_usage
        test -n "${echo_usage_bk}" &&  { local echo_usage_bk="${echo_usage_bk%\}}"' \\; }'; eval "${echo_usage_bk//\; : \}/\; : \; \}}"  ; }

        unset cleanup
        test -n "${cleanup_bk}" && { local cleanup_bk="${cleanup_bk%\}}"' \\; }'; eval "${cleanup_bk//\; : \}/\; : \; \}}"  ; }
        :
    }

    # Analyze command line options
    local OPT=""
    local OPTARG=""
    local OPTIND=""
    local dest="" 
    while getopts "d:h" OPT
    do
        case ${OPT} in
            d) local dest="${OPTARG}"
               ;;
            h) echo_usage
               cleanup
               return 0
               ;;
            \?) echo_usage
                cleanup
                return 1
                ;;
        esac
    done
    shift $((OPTIND - 1))

    local scriptpath="${BASH_SOURCE:-$0}"
    local scriptdir="$(dirname "${scriptpath}")"
    if [ "$0" == "${BASH_SOURCE:-$0}" ]; then
        local this="$(basename "${scriptpath}")"
    else
        local this="${FUNCNAME[0]}"
    fi

    local tmpdir0=$(mktemp -d "${this}.tmp.XXXXXX" )
    local tmpdirs=( "${tmpdirs[@]}" "${tmpdir0}" )
    local tmpfile0=$(mktemp   "${this}.tmp.XXXXXX" )
    local tmpfiles=( "${tmpfiles[@]}" "${tmpfile0}" )

    echo "------------------------------"
    echo "called as ${this}"
    echo "ARGS:" $*
    echo "------------------------------"
    echo_usage 0

    # clean up 
    cleanup
    return ${funcstatus}
    :
}

if [ "$0" == "${BASH_SOURCE:-$0}" ]; then
    func_skeleton "$@"
    exit $?
else
    function undef_func_skeleton () {
        unset func_skeleton
        test -n "${func_skeleton_bk}" \
            &&  { local func_skeleton_bk="${func_skeleton_bk%\}}"' \\; }'; \
                  eval "${func_skeleton_bk//\; : \}/\; : \; \}}"  ; }
        unset undef_func_skeleton
        test -n "${undef_func_skeleton_bk}" \
            && { local undef_func_skeleton_bk="${undef_func_skeleton_bk%\}}"' \\; }'; \
                 eval "${undef_func_skeleton_bk//\; : \}/\; : \; \}}"  ; }
    }
    return
fi

# Contents below will be ignored. 

# bash_script_skeleton
Template of shell script without side effect for "source".

## Features

- This script can be called as a standalone script file or as a
  function loaded by `source`.

- Internal shell variables are defined with `local`, and `env` command
  is used to set the environmental variables for sub-commands.

- Sample of the internal function/alias definisions with
  back-up/restore procedure of the global function/alias with the same
  name, except for main function `func_skeleton`.

- Sample of the interrupt handlers with back-up/restore procedure of
  the global definition and calling the global interrupt handler after
  its procecdures. The sample code is one of the most popular case,
  temporaly files/directory removeing.

## Usage

1. Rename `func_skeleton` (Two places) with proper name as new
   commands.

2. Update help messages in `echo_usage`.

3. Implement the treatment of command line arguments by `getopts`.

4. Implement commands itself, it starts after the temporaly
   file/directory definstions until before the last clean-up
   procedure.

5. Update `cleanup` functions, if necessary. (For example, adding the
   restore procedure if addtional sub-function/alias are defined.

6. Update signal handlers if necessary.
