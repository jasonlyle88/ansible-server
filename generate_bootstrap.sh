#!/usr/bin/env bash

scriptDir="$(dirname "${BASH_SOURCE[0]}")"

function main() {
    local filesDirName="files"
    local filesDir="${scriptDir}/${filesDirName}"
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

    chmod a+x "${bootstrapScript}"

    cp -a "${bootstrapScript}" "${bootstrapDir}"
    cp -a "${gpgDir}" "${bootstrapDir}"

    #TODO: Remove this for final version.. this is just to make testing on
    #TODO: the vm easier
    if [ -f "${bootstrapDirName}.iso" ]; then
        rm "${bootstrapDirName}.iso"
    fi
    hdiutil makehybrid -iso -joliet -o "${bootstrapDirName}" "${bootstrapDir}"
    #TODO: End remove block

    return 0
}

main "$@"
