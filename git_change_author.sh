#!/bin/sh

validate_email(){
    # https://regex101.com/r/n74ZEc/1
    # https://stackoverflow.com/questions/32291127/bash-regex-email
    # http://tldp.org/LDP/Bash-Beginners-Guide/html/sect_04_01.html#sect_04_01_01
    # http://godleon.blogspot.com/2007/06/variable-shell-script-variable-object.html
    # https://stackoverflow.com/questions/38757862/what-does-12-mean-in-bash
    if ! [[ "$1" =~ ^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$ ]]; then
        echo "Email address $1 is invalid." 1>&2;
        exit 1;
    fi
}

command_error(){
    echo "Usage: $0 [-o <OLD_EMAIL>] [-n <NEW_EMAIL>] [-u <NEW_USERNAME>]" 1>&2;
    exit 1;
}

# ##### ##### ##### check for input ##### ##### #####
# https://blog.yegle.net/2011/04/21/parsing-non-option-argument-bash-getopts/
# http://www.cnblogs.com/FrankTan/archive/2010/03/01/1634516.html
# https://stackoverflow.com/questions/16483119/an-example-of-how-to-use-getopts-in-bash

# get values from user input and validate
while getopts ":o:n:u:" opt; do
    case $opt in
        o)
            validate_email $OPTARG
            OLD_EMAIL=$OPTARG
            ;;
        n)
            validate_email $OPTARG
            NEW_EMAIL=$OPTARG
            ;;
        u)
            NEW_USERNAME=$OPTARG
            ;;
        *)
            command_error
            ;;
    esac
done

# check necessary values are not empty
if [[ -z "$OLD_EMAIL" || -z "$NEW_EMAIL" || -z "$NEW_USERNAME" ]] ; then
    command_error
fi

# ##### ##### ##### set command for git ##### ##### #####

# merge strings
vars="
    OLD_EMAIL=$OLD_EMAIL
    CORRECT_NAME=$NEW_USERNAME
    CORRECT_EMAIL=$NEW_EMAIL
"
reset_command='
    if [ "$GIT_COMMITTER_EMAIL" = "$OLD_EMAIL" ]
    then
        export GIT_COMMITTER_NAME="$CORRECT_NAME"
        export GIT_COMMITTER_EMAIL="$CORRECT_EMAIL"
    fi
    if [ "$GIT_AUTHOR_EMAIL" = "$OLD_EMAIL" ]
    then
        export GIT_AUTHOR_NAME="$CORRECT_NAME"
        export GIT_AUTHOR_EMAIL="$CORRECT_EMAIL"
    fi
'

# ##### ##### ##### reset committer and author ##### ##### #####

git filter-branch -f --env-filter "$vars$reset_command" --tag-name-filter cat -- --branches --tags

# get return code from previous step
# success result in "0"
# failed result in other
RETURN_CODE=$?

if [ ${RETURN_CODE} == 0 ]; then
    rm -Rf .git/refs/original/refs/heads
    git reflog expire --all --expire=now
    git gc --prune=now
fi