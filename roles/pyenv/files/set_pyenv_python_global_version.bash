#!/usr/bin/env bash

main() {
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
        printf -- 'This script sets the pyenv global python version\n'
        printf -- '\n'
        printf -- 'This script returns 0 if pyenv global version is changed\n'
        printf -- 'correctly, 1 if the pyenv global version is already set to\n'
        printf -- 'the specified verfsion, and 2 if the set fails'
        printf -- '\n'
        printf -- 'The following arguments are recognized (* = required)\n'
        printf -- '\n'
        printf -- '* -v     --  Python version to set\n'
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
    local currentVersion

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
    printf -- '%s %s\n' "${hs}" 'Set PyEnv global python version'
    printf -- '%s\n' "${h1}"
    printf -- '\n'

    if [[ "${versionString}" == 'system' ]]; then
        resolvedVersionString="${versionString}"
    else
        printf -- '%s\n' "${h2}"
        printf -- '%s %s\n' "${hs}" 'Resolve version to set'
        printf -- '%s\n' "${h2}"

        resolvedVersionString="$(pyenv latest "${versionString}" 2>/dev/null)"
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
        printf -- '%s %s\n' "${hs}" 'Check if version is installed'
        printf -- '%s\n' "${h2}"
        if pyenv versions --bare | grep -q "^${resolvedVersionString}$"; then
            printf 'Version installed\n'
        else
            printf 'Version not installed\n' >&2
            return 22
        fi
        printf '\n'
    fi

    printf -- '%s\n' "${h2}"
    printf -- '%s %s\n' "${hs}" 'Get current global version'
    printf -- '%s\n' "${h2}"
    currentVersion="$(pyenv global)"
    printf -- 'Current global version: "%s"\n' "${currentVersion}"

    printf -- '\n'
    printf -- '%s\n' "${h2}"
    printf -- '%s %s\n' "${hs}" 'Check current version against requested version'
    printf -- '%s\n' "${h2}"
    if [[ "${resolvedVersionString}" == "${currentVersion}" ]]; then
        printf 'Global version already set correctly\n' >&2
        return 1
    else
        printf 'Global version is different than requested version\n'
    fi

    printf -- '\n'
    printf -- '%s\n' "${h2}"
    printf -- '%s %s\n' "${hs}" 'Set global python version'
    printf -- '%s\n' "${h2}"
    pyenv global "${resolvedVersionString}"
    exitCode=$?

    if [[ "${exitCode}" -eq 0 ]]; then
        printf -- 'Done\n'
    else
        printf -- 'Error setting global version' >&2
    fi

    return "${exitCode}"

} # main

main "$@"
