#!/bin/bash
# -*- mode: shell-script ; -*-
#
# which_source: Seek the file path that can be load with "source/." from bash (script).
#               by Uji Nanigashi (53845049+nanigashi-uji@users.noreply.github.com)
#               https://github.com/nanigashi-uji/bash_script_skeleton.git
#

if [ "$0" != "${BASH_SOURCE:-$0}" ]; then
    __which_source_bk__="$(declare -f which_source)"
    __undef_which_source_bk__="$(declare -f undef_which_source)"
fi

function which_source () {
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
    __which_source_location__="$(which_source "${BASH_SOURCE:-$0}")"
    function undef_which_source () {
        unset which_source
        test -n "${__which_source_bk__}" \
            &&  { local __which_source_bk__="${__which_source_bk__%\}}"' \\; }'; \
                  eval "${__which_source_bk__//\; : \}/\; : \; \}}"  ; }
        unset undef_which_source
        test -n "${__undef_which_source_bk__}" \
            && { local __undef_which_source_bk__="${__undef_which_source_bk__%\}}"' \\; }'; \
                 eval "${__undef_which_source_bk__//\; : \}/\; : \; \}}"  ; }

        unset __which_source_location__
        unset __which_source_bk__ __undef_which_source_bk__

        return
        :
    }
    return
fi

# Contents below will be ignored. 
