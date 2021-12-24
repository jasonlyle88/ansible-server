#!/usr/bin/env bash

scriptDir="$(dirname "${BASH_SOURCE[0]}")"

function main() {
    local filesDirName="files"
    local filesDir="${scriptDir}/${filesDirName}"
    local sshDirName="ssh"
    local sshDir="${filesDir}/${sshDirName}"
    local gpgDirName="gpg"
    local gpgDir="${filesDir}/${gpgDirName}"
    local bootstrapScriptName="bootstrap.sh"
    local bootstrapScript="${filesDir}/${bootstrapScriptName}"
    local bootstrapDirName="bootstrap"
    local bootstrapDir="${scriptDir}/${bootstrapDirName}"


    if [ -d "${bootstrapDir}" ]; then
        rm -rf "${bootstrapDir:?}"
    fi

    mkdir "${bootstrapDir}"

    cp -a "${bootstrapScript}" "${bootstrapDir}"
    cp -a "${sshDir}" "${bootstrapDir}"
    cp -a "${gpgDir}" "${bootstrapDir}"

    #TODO: Remove this for final version.. this is just to make testing on
    #TODO: the vm easier
    hdiutil makehybrid -iso -joliet -o "${bootstrapDirName}" "${bootstrapDir}"

    return 0
}

main "$@"