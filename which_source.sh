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
    local desc="Locate a script file for bash 'source' in the user's path"
    
    # Prepare Help Messages
    local funcstatus=0
    local echo_usage_bk="$(declare -f echo_usage)"
    local realpath_sh_bk="$(declare -f realpath_sh)"
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
        echo "  -a : List all instances of executables found (instead of just the first one of each)."          1>&2
        echo "  -s : No output, just return 0 if all of the executables are found, or 1 if some were not found."  1>&2
        echo "  -h : Help (Show this message)"
        return
        :
    }

    function realpath_sh () {
        local _i _s=0
        for _i in "$@"; do
            local _idir="$(dirname "${_i}")"
            local _p="$(cd "${_idir}" 2>/dev/null && pwd || echo "${_idir}")"
            local _pth="${_idir%/}/${_i##*/}"
            echo "${_pth}"
            if [ -f "${_pth}" ]; then
                _s=1
            fi
        done
        return ${_s}
        :
    }

    
    if "${WHICH:-which}" -s "${REALPATH:-realpath}" ; then
        local realpath_cmd="${REALPATH:-realpath}"
    elif which -s grealpath ; then
        local realpath_cmd="grealpath"
    else
        local realpath_cmd="realpath_sh"
    fi

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

        unset realpath_sh
        test -n "${realpath_sh_bk}" &&  { local realpath_sh_bk="${realpath_sh_bk%\}}"' \\; }'; eval "${realpath_sh_bk//\; : \}/\; : \; \}}"  ; }

        unset cleanup
        test -n "${cleanup_bk}" && { local cleanup_bk="${cleanup_bk%\}}"' \\; }'; eval "${cleanup_bk//\; : \}/\; : \; \}}"  ; }
        :
    }

    # Analyze command line options
    local OPT=""
    local OPTARG=""
    local OPTIND=""
    local opt_statusonly=0
    local opt_showall=0
    while getopts "ash" OPT ; do
        case ${OPT} in
            a)  local opt_showall=1 ;;
            s)  local opt_statusonly=1 ;;
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

    #local tmpdir0=$(mktemp -d "${this}.tmp.XXXXXX" )
    #local tmpdirs=( "${tmpdirs[@]}" "${tmpdir0}" )
    #local tmpfile0=$(mktemp   "${this}.tmp.XXXXXX" )
    #local tmpfiles=( "${tmpfiles[@]}" "${tmpfile0}" )

    local _arg
    for _arg in "$@"; do
        local _is=0
        if [[ "${_arg}" == / ]] ; then
            if [ ${opt_statusonly:-0} -ne 0 ]; then
                "${realpath_cmd}" "${_arg}" 1>/dev/null 2>&1 || local is=1
            else
                "${realpath_cmd}" "${_arg}"                  || local is=1
            fi
        else
            local is=1 _seekpath=
            shopt -q sourcepath          && local _seekpath="${_seekpath}${_seekpath:+:}${PATH}"
            test -z "${POSIXLY_CORRECT}" && local _seekpath="${_seekpath}${_seekpath:+:}${PWD}"
            local oldIFS="${IFS}" _scriptpath= _i=
            local IFS=':'
            for _i in ${_seekpath}; do
                local _fp="${_i%/}/${_arg##*/}"
                if [ -f "${_fp}" ]; then
                    local _scriptpath="${_fp}"
                    if [ ${opt_statusonly:-0} -eq 0 ]; then
                        echo "${_scriptpath}"
                    fi
                    local is=0
                    if [ ${opt_statusonly:-0} -eq 0 ]; then
                        break
                    fi
                fi
            done
        fi
        if [ ${_is:-1} -ne 0 ]; then
            local funcstatus=1
        fi
    done
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
