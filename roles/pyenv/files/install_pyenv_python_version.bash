#!/usr/bin/env bash

function main() {
    ############################################################################
    ##  Script info
    ############################################################################
    local scriptName

    # shellcheck disable=SC2034
    scriptName="$(basename "${BASH_SOURCE[0]}")"

    ############################################################################
    #
    # Functions
    #
    ############################################################################
    function usage() {
        printf -- 'This script installs a python version through pyenv\n'
        printf -- '\n'
        printf -- 'This script returns 0 if installed correctly, 1 if the\n'
        printf -- 'version is already installed, and 2 if the install fails'
        printf -- '\n'
        printf -- 'The following arguments are recognized (* = required)\n'
        printf -- '\n'
        printf -- '* -v     --  Python version to install\n'
        printf -- '  -h     --  Show this help.\n'
        printf -- '\n'
        printf -- 'Example:\n'
        printf -- '  %s -v 3.10\n' "${scriptName}"
        printf -- '\n'

        return 0
    } # usage

    function toLowerCase() {
        ########################################################################
        #   toLowerCase
        #
        #   Return a string with all lower case letters
        #
        #   The first parameter is the string to get in all lower case
        #
        #   lowerCaseVar="$(toLowerCase "${var}")"
        ########################################################################
        local string="$*"

        printf -- '%s' "${string}" | tr "[:upper:]" "[:lower:]"

        return 0
    } # toLowerCase

    ############################################################################
    #
    # Variables
    #
    ############################################################################

    ############################################################################
    ##  Parameter variables
    ############################################################################
    local OPTIND
    local OPTARG
    local opt

    local vFlag='false'

    local versionString

    ############################################################################
    ##  Constants
    ############################################################################
    # shellcheck disable=SC2034
    local h1='--------------------------------------------------------------------------------'
    # shellcheck disable=SC2034
    local h2='------------------------------------------------------------'
    # shellcheck disable=SC2034
    local hs='--'
    # shellcheck disable=SC2034
    local originalPWD="${PWD}"

    ############################################################################
    ##  Procedural variables
    ############################################################################
    local exitCode
    local resolvedVersionString

    ############################################################################
    #
    # Option parsing
    #
    ############################################################################
    while getopts ':v:h' opt
    do

        case "${opt}" in
        'v')
            vFlag='true'
            versionString="${OPTARG}"
            ;;
        'h')
            usage
            return 0
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
    # Check database type flag was provided
    if [[ "${vFlag}" != 'true' ]]; then
        printf -- 'ERROR: version must be provided\n' >&2
        return 11
    fi

    ############################################################################
    #
    # Function Logic
    #
    ############################################################################
    printf -- '%s\n' "${h1}"
    printf -- '%s %s\n' "${hs}" 'Install PyEnv python version'
    printf -- '%s\n' "${h1}"
    printf -- '\n'

    printf -- '%s\n' "${h2}"
    printf -- '%s %s\n' "${hs}" 'Resolve version to install'
    printf -- '%s\n' "${h2}"

    resolvedVersionString="$(pyenv latest -k "${versionString}" 2>/dev/null)"
    exitCode="$?"

    printf -- 'Supplied version: "%s"\n' "${versionString}"
    if [[ "${exitCode}" -eq 0 ]]; then
        printf -- 'Resolved version: "%s"\n' "${resolvedVersionString}"
    else
        printf 'ERROR: unable to resolve provided version\n' >&2
        return 21
    fi

    printf -- '\n'
    printf -- '%s\n' "${h2}"
    printf -- '%s %s\n' "${hs}" 'Check if version already installed'
    printf -- '%s\n' "${h2}"
    if pyenv versions --bare | grep -q "^${resolvedVersionString}$"; then
        printf 'Version already installed, aborting\n' >&2
        return 1
    else
        printf 'Version not installed\n'
    fi

    printf -- '\n'
    printf -- '%s\n' "${h2}"
    printf -- '%s %s\n' "${hs}" 'Install Python version'
    printf -- '%s\n' "${h2}"
    pyenv install "${resolvedVersionString}"
    exitCode=$?

    return "${exitCode}"

} # main

main "$@"
