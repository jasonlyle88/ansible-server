#!/usr/bin/env bash

function main() {
    ############################################################################
    #
    # Functions
    #
    ############################################################################
    function usage() {
        printf -- 'Add or edit variables in a shell script file.\n'
        printf -- '\n'
        printf -- 'Edit variables with name=value syntax or zstyle syntax.\n'
        printf -- 'Only one type of variable can be specified at once (variables or zstyle).\n'
        printf -- '\n'
        printf -- 'The following arguments are recognized (* = required)\n'
        printf -- '\n'
        printf -- '* -f {file}              --  The file in which to add/edit values.\n'
        printf -- '* -n {variable name}     --  Specify the variable name.\n'
        printf -- '                             Required if modifying name/value variable.\n'
        printf -- '* -v {variable value}    --  Specify the variable value.\n'
        printf -- '                             Required if modifying name/value variable.\n'
        printf -- '* -p {zstyle pattern}    --  Specify the zstyle pattern.\n'
        printf -- '                             Required if modifying zstyle values.\n'
        printf -- '* -s {zstyle style}      --  Specify the zstyle style.\n'
        printf -- '                             Required if modifying zstyle values.\n'
        printf -- '* -z {zstyle value}      --  Specify the zstyle value.\n'
        printf -- '                             Required if modifying zstyle values.\n'
        printf -- '  -h                     --  Show this help.\n'
        printf -- '\n'
        printf -- 'Example:\n'
        # shellcheck disable=2016
        printf -- '  %s -f "${home}/.zshrc" -n "foo" -v "bar"\n' "${scriptName}"
        # shellcheck disable=2016
        printf -- '  %s -f "${home}/.zshrc" -n "faa" -v ""\n' "${scriptName}"
        # shellcheck disable=2016
        printf -- '  %s -f "${home}/.zshrc" -p "pat" -s "sty" -z "val"\n' "${scriptName}"
        printf -- '\n'

        return 0
    } # usage

    function toUpperCase() {
        ########################################################################
        #   toUpperCase
        #
        #   Return a string with all upper case letters
        #
        #   All parameters are taken as a single string to get in all upper case
        #
        #   upperCaseVar="$(toUpperCase "${var}")"
        ########################################################################
        local string="$*"

        printf -- '%s' "${string}" | tr '[:lower:]' '[:upper:]'

        return 0
    } # toUpperCase

    function toLowerCase() {
        ########################################################################
        #   toLowerCase
        #
        #   Return a string with all lower case letters
        #
        #   All parameters are taken as a single string to get in all lower case
        #
        #   toLowerCase="$(toUpperCase "${var}")"
        ########################################################################
        local string="${*}"

        printf -- '%s' "${string}" | tr '[:upper:]' '[:lower:]'

        return 0
    } # toUpperCase

    function getCanonicalPath() {
        ########################################################################
        #   getCanonicalPath
        #
        #   Return a path that is both absolute and does not contain any
        #   symbolic links. Always returns without a trailing slash.
        #
        #   The first parameter is the path to canonicalize
        #
        #   canonicalPath="$(getCanonicalPath "${somePath}")"
        ########################################################################
        local target="${1}"

        if [ -d "${target}" ]; then
            # dir
            (cd "${target}" || exit; pwd -P)
        elif [ -f "${target}" ]; then
            # file
            if [[ "${target}" = /* ]]; then
                # Absolute file path
                (cd "$(dirname "${target}")" || exit; printf -- '%s/%s\n' "$(pwd -P)" "$(basename "${target}")")
            elif [[ "${target}" == */* ]]; then
                # Relative file with path
                printf -- '%s\n' "$(cd "${target%/*}" || exit; pwd -P)/${target##*/}"
            else
                # Relative file without path
                printf -- '%s\n' "$(pwd -P)/${target}"
            fi
        fi
    } # getCanonicalPath

    ############################################################################
    #
    # Variables
    #
    ############################################################################

    ############################################################################
    ##  Configurable variables
    ############################################################################

    ############################################################################
    ##  Script info
    ############################################################################
    local scriptName
    local scriptPath

    # shellcheck disable=SC2034
    scriptName="$(basename -- "${BASH_SOURCE[0]}")"
    # shellcheck disable=SC2034
    scriptPath="$(getCanonicalPath "$(dirname -- "${BASH_SOURCE[0]}")")"

    ############################################################################
    ##  Parameter variables
    ############################################################################
    local OPTIND
    local OPTARG
    local opt

    local fFlag='false'
    local nFlag='false'
    local vFlag='false'
    local pFlag='false'
    local sFlag='false'
    local zFlag='false'

    local fileName
    local variableName
    local variableValue
    local zstylePattern
    local zstyleStyle
    local zstyleValue

    ############################################################################
    ##  Constants
    ############################################################################
    # shellcheck disable=SC2034,SC2155
    local h1="$(printf "%0.s-" {1..80})"
    # shellcheck disable=SC2034,SC2155
    local h2="$(printf "%0.s-" {1..60})"
    # shellcheck disable=SC2034,SC2155
    local h3="$(printf "%0.s-" {1..40})"
    # shellcheck disable=SC2034,SC2155
    local h4="$(printf "%0.s-" {1..20})"
    # shellcheck disable=SC2034,SC2155
    local hs="$(printf "%0.s-" {1..2})"
    # shellcheck disable=SC2034
    local originalPWD="${PWD}"
    # shellcheck disable=SC2034
    local originalIFS="${IFS}"

    ############################################################################
    ##  Procedural variables
    ############################################################################

    ############################################################################
    #
    # Option parsing
    #
    ############################################################################
    while getopts ':f:n:v:p:s:z:h' opt
    do

        case "${opt}" in
        'f')
            fFlag='true'
            fileName="$(getCanonicalPath "${OPTARG}")"
            ;;
        'n')
            nFlag='true'
            variableName="${OPTARG}"
            ;;
        'v')
            vFlag='true'
            variableValue="${OPTARG}"
            ;;
        'p')
            pFlag='true'
            zstylePattern="${OPTARG}"
            ;;
        's')
            sFlag='true'
            zstyleStyle="${OPTARG}"
            ;;
        'z')
            zFlag='true'
            zstyleValue="${OPTARG}"
            ;;
        'h')
            usage
            return $?
            ;;
        '?')
            printf -- 'ERROR: Invalid option -%s\n\n' "${OPTARG}" >&2
            usage >&2
            return 3
            ;;
        ':')
            printf -- 'ERROR: Option -%s requires an argument.\n' "${OPTARG}" >&2
            return 4
            ;;
        esac

    done

    ############################################################################
    #
    # Parameter handling
    #
    ############################################################################
    if [[ "${fFlag}" != 'true' ]]; then
        printf -- 'ERROR: File (-f) must be specified.\n' >&2
        return 11
    fi

    if [[ ! -f "${fileName}" || ! -r "${fileName}" || ! -w "${fileName}" ]]; then
        printf -- 'ERROR: Specified file (-f) must be a readable and writable file.\n' >&2
        return 12
    fi

    if [[
        "${nFlag}" == "false" &&
        "${vFlag}" == "false" &&
        "${pFlag}" == "false" &&
        "${sFlag}" == "false" &&
        "${zFlag}" == "false"
    ]]
    then
        printf -- 'ERROR: Variable information must be provided.\n' >&2
        printf -- 'ERROR: Either a set of -n and -v parameters or -p, -s, and -z parameters.\n' >&2
        return 13
    fi

    if
        [[ "${nFlag}" == "true" || "${vFlag}" == "true" ]] &&
        [[ "${pFlag}" == "true" || "${sFlag}" == "true" || "${zFlag}" == "true" ]]
    then
        printf -- 'ERROR: Only one type of parameter can be modified at a time.\n' >&2
        printf -- 'ERROR: -n and -v cannot be used with -p, -s, and -z.\n' >&2
        return 14
    fi

    if [[ "${nFlag}" == "true" && -z "${variableName}" ]]; then
        printf -- 'ERROR: Specified variable name (-n) must have a value.\n' >&2
        return 15
    fi

    if [[ "${pFlag}" == "true" && -z "${zstylePattern}" ]]; then
        printf -- 'ERROR: Specified zstyle pattern (-p) must have a value.\n' >&2
        return 16
    fi

    if [[ "${sFlag}" == "true" && -z "${zstyleStyle}" ]]; then
        printf -- 'ERROR: Specified zstyle style (-s) must have a value.\n' >&2
        return 17
    fi

    ############################################################################
    #
    # Function Logic
    #
    ############################################################################
    printf -- '%s\n' "${h1}"
    printf -- '%s\n' "${h1}"
    printf -- '%s %s\n' "${hs}" "Edit script variables"
    printf -- '%s\n' "${h1}"
    printf -- '%s\n' "${h1}"

    printf -- '\n'
    printf -- '%s\n' "${h1}"
    printf -- '%s %s\n' "${hs}" "Parameter specification"
    printf -- '%s\n' "${h1}"
    printf -- '%-16s: "%s"\n' "File" "${fileName}"

    if [[ "${nFlag}" == 'true' ]]; then
        printf -- '%-16s: "%s"\n' "Variable name" "${variableName}"
        printf -- '%-16s: "%s"\n' "Variable value" "${variableValue}"
    elif [[ "${pFlag}" == 'true' ]]; then
        printf -- '%-16s: "%s"\n' "ZStyle Pattern" "${zstylePattern}"
        printf -- '%-16s: "%s"\n' "ZStyle Style" "${zstyleStyle}"
        printf -- '%-16s: "%s"\n' "ZStyle Value" "${zstyleValue}"
    fi

    #TODO: REGEX work
    #TODO: REGEX for zstyle without value "^(\s+)?(#+)?(\s+)?zstyle\s+([\'""])?${zstylePattern}([\'""])?\s+([\'""])?${zstyleStyle}([\'""])?"
    #TODO: REGEX for zstyle with value "^(\s+)?(#+)?(\s+)?zstyle\s+([\'""])?${zstylePattern}([\'""])?\s+([\'""])?${zstyleStyle}([\'""])?\s+([\'""])?${zstyleValue}"
    #TODO REGEX Tests, not real code yet...
    pcre2grep -i -o0 "^\s*#*\s*(?:export|local)?\s*([^[:space:]=]+)=" .zshrc
    pcre2grep -i "^\s*#*\s*(?:export|local)?\s*([^[:space:]=]+)=" .zshrc

} # main

main "$@"
