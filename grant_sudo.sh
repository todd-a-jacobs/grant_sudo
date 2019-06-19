#!/usr/bin/env bash

# Purpose:
#     Simplify the creation of passwordless users in sudoers.d, with
#     some minimal error checking to prevent clobbering or privilege
#     escalation.
# Author:
#     Copyright 1997-2019 Todd A. Jacobs
# License:
#     GPLv3 or later
# Usage:
#     # call as executable script
#     grant_sudo.sh <logname>
#
#     # import function
#     source grant_sudo.sh
#     grant_sudo <logname>

grant_sudo () {
    if [[ $# -ne 1 ]]; then
	    echo "usage: $(basename "$BASH_SOURCE") <logname>" >&2
	    return 2
    fi

    local file="/etc/sudoers.d/$1"
    local rule="$1 ALL=(ALL) NOPASSWD:ALL"

    sudo -v || return 1
    sudo \
	    -s `which bash` \
	    -c "set -o noclobber; echo '$rule' > '$file'"

    [[ $? -ne 0 ]] && echo
    echo "# contents: $file"
    sudo cat "$file"
    
    echo
    echo "# validating policy file"
    sudo visudo -cf "$file"
}

if [[ "$BASH_SOURCE" = "$0" ]]; then
    grant_sudo "$1"
fi
