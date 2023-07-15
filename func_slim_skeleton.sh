#!/bin/bash
# -*- mode: shell-script ; -*-
#
# func_slim_skeleton: Template of shell script without side effect for "source".
#                by Uji Nanigashi (53845049+nanigashi-uji@users.noreply.github.com)
#                https://github.com/nanigashi-uji/bash_script_skeleton.git
#

if [ "$0" != "${BASH_SOURCE:-$0}" ]; then
    __func_slim_skeleton_bk__="$(declare -f func_slim_skeleton)"
    __undef_func_slim_skeleton_bk__="$(declare -f undef_func_slim_skeleton)"

    if declare -F which_source 1>/dev/null 2>&1 ; then
        __func_slim_skeleton_location__="$(which_source "${BASH_SOURCE}")"
    else
        for ___i in "which_source" "$(dirname "${BASH_SOURCE}")/which_source.sh" "which_source.sh" "${REALPATH:-realpath}" "grealpath" ; do
            which -s "${___i}" && {  __func_slim_skeleton_location__="$("${___i}" "${BASH_SOURCE}")" ; break ; }
        done
        unset ___i
    fi
    if [ -z "${__func_slim_skeleton_location__}" ]; then
        ___i="$(dirname "${BASH_SOURCE}")"
        ___adir="$(cd "${___i}" 2>/dev/null && pwd -L || echo "${___i}")"
        __func_slim_skeleton_location__="${_adir%/}/${BASH_SOURCE##*/}"
        unset ___i ___adir
    fi
fi

function func_slim_skeleton () {
    # Description
    local desc="Template of shell script without side effect for 'source'"

    local funcstatus=0 tmpfiles=() tmpdirs=()
    local echo_usage_bk="$(declare -f echo_usage)"
    local cleanup_bk="$(declare -f cleanup)"

    function  echo_usage () {
        if [ "$0" == "${BASH_SOURCE:-$0}" ]; then
            local this="$0"
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
        
        # remove temporary files and directories
        [ ${#tmpfiles} -gt 0 ] &&  rm -f "${tmpfiles[@]}"
        [ ${#tmpdirs}  -gt 0 ] &&  rm -rf "${tmpdirs[@]}"

        # Restore  signal handler
        [ -n "${hndlrhup_bk}"  ] && eval "${hndlrhup_bk}"  || trap --  1
        [ -n "${hndlrint_bk}"  ] && eval "${hndlrint_bk}"  || trap --  2
        [ -n "${hndlrquit_bk}" ] && eval "${hndlrquit_bk}" || trap --  3
        [ -n "${hndlrterm_bk}" ] && eval "${hndlrterm_bk}" || trap -- 15

        # Restore alias and functions

        unset echo_usage
        [ -n "${echo_usage_bk}" ] && { local echo_usage_bk="${echo_usage_bk%\}}"' \\; }'; eval "${echo_usage_bk//\; : \}/\; : \; \}}" ; }
        unset cleanup
        [ -n "${cleanup_bk}"    ] && { local cleanup_bk="${cleanup_bk%\}}"' \\; }'      ; eval "${cleanup_bk//\; : \}/\; : \; \}}"    ; }

        return
        :
    }

    # Analyze command line options
    local OPT OPTARG OPTIND
    local dest="" 
    while getopts "d:h" OPT;  do
        case ${OPT} in
            d) local dest="${OPTARG}" ;;
            h)  echo_usage ; cleanup ; return 0 ;;
            \?) echo_usage ; cleanup ; return 1 ;;
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
    # Invoked by command
    _runas="${0##*/}"
    declare -F "${_runas%.sh}" 1>/dev/null 2>&1 && { "${_runas%.sh}" "$@" ; __status=$? ; }
    unset _runas
    trap "unset __status" EXIT
    exit ${__status:-1}
else

    function undef_func_slim_skeleton () {

        unset func_slim_skeleton
        [ -n "${__func_slim_skeleton_bk__}" ] \
            &&  { local __func_slim_skeleton_bk__="${__func_slim_skeleton_bk__%\}}"' \\; }'; \
                  eval "${__func_slim_skeleton_bk__//\; : \}/\; : \; \}}"  ; }
        unset undef_func_slim_skeleton
        [ -n "${__undef_func_slim_skeleton_bk__}" ] \
            && { local __undef_func_slim_skeleton_bk__="${__undef_func_slim_skeleton_bk__%\}}"' \\; }'; \
                 eval "${__undef_func_slim_skeleton_bk__//\; : \}/\; : \; \}}"  ; }
        
        unset __func_slim_skeleton_location__
        unset __func_slim_skeleton_bk__ __undef_func_slim_skeleton_bk__

        return
        :
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
  name, except for main function `func_slim_skeleton`.

- Sample of the interrupt handlers with back-up/restore procedure of
  the global definition and calling the global interrupt handler after
  its procecdures. The sample code is one of the most popular case,
  temporaly files/directory removeing.

## Usage

1. Rename `func_slim_skeleton` (Two places) with proper name as new
   commands.

2. Update help messages in `echo_usage`.

3. Implement the treatment of command line arguments by `getopts`.

4. Implement commands itself, it starts after the temporaly
   file/directory definstions until before the last clean-up
   procedure.

5. Update `cleanup` functions, if necessary. (For example, adding the
   restore procedure if addtional sub-function/alias are defined.

6. Update signal handlers if necessary.
