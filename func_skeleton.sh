#!/bin/bash
# -*- mode: shell-script ; -*-
#
# func_skeleton: Template of shell script without side effect for "source".
#                by Uji Nanigashi (53845049+nanigashi-uji@users.noreply.github.com)
#                https://github.com/nanigashi-uji/bash_script_skeleton.git
#

if [ "$0" != "${BASH_SOURCE:-$0}" ]; then
    __func_skeleton_bk__="$(declare -f func_skeleton)"
    __undef_func_skeleton_bk__="$(declare -f undef_func_skeleton)"

    which_source_bk="$(declare -f which_source)"
    function which_source () {
        local _arg="$@"
        if [[ "${_arg}" == / ]] ; then
            if which -s "${REALPATH:-realpath}" ; then
                "${REALPATH:-realpath}" "${_arg}"
            elif which -s grealpath ; then
                grealpath "${_arg}"
            else
                local _argdir="$(dirname "${_arg}")"
                local _adir="$(cd "${_argdir}" 2>/dev/null && pwd -L || echo "${_argdir}")"
                echo "${_adir%/}/${_arg##*/}"
            fi
        fi
        local _seekpath=
        shopt -q sourcepath          && local _seekpath="${_seekpath}${_seekpath:+:}${PATH}"
        test -z "${POSIXLY_CORRECT}" && local _seekpath="${_seekpath}${_seekpath:+:}${PWD}"
        local _scriptpath=
        local IFS=':'
        local _i=
        for _i in ${_seekpath}; do
            local _fp="${_i%/}/${_arg##*/}"
            if [ -f "${_fp}" ]; then
                local _scriptpath="${_fp}"
                break
            fi
        done
        echo "${_scriptpath}"
        return
        :
    }

    __func_skeleton_location__="$(which_source "${BASH_SOURCE:-$0}")"

    unset which_source
    test -n "${which_source_bk}" \
        &&  { local which_source_bk="${which_source_bk%\}}"' \\; }'; \
              eval "${which_source_bk//\; : \}/\; : \; \}}" ; }
    unset which_source_bk

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
    # func_skeleton "$@"
    # exit $?
    # Invoked by command
    _runas="${0##*/}"
    if declare -F "${_runas%.sh}" 1>/dev/null 2>&1 ;  then
        "${_runas%.sh}" "$@"
        __status=$?
    fi
    unset _runas
    trap "unset __status" EXIT
    exit ${__status:-1}
else
    function undef_func_skeleton () {

        unset func_skeleton
        test -n "${__func_skeleton_bk__}" \
            &&  { local __func_skeleton_bk__="${__func_skeleton_bk__%\}}"' \\; }'; \
                  eval "${__func_skeleton_bk__//\; : \}/\; : \; \}}"  ; }
        unset undef_func_skeleton
        test -n "${__undef_func_skeleton_bk__}" \
            && { local __undef_func_skeleton_bk__="${__undef_func_skeleton_bk__%\}}"' \\; }'; \
                 eval "${__undef_func_skeleton_bk__//\; : \}/\; : \; \}}"  ; }

        unset __func_skeleton_location__
        unset __func_skeleton_bk__ __undef_func_skeleton_bk__

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
