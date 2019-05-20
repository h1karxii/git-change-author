#!/bin/sh
# https://github.com/h1karxii/git-change-author

exit_err() {
    [ $# -gt 0 ] && echo "$*" 1>&2
    exit 1
}

validate_email(){
    # https://regex101.com/r/n74ZEc/1
    if ! [[ "$1" =~ ^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$ ]]; then
        exit_err "Error: email address $1 is invalid."
    fi
}

command_error(){
    exit_err "Usage: $0 [-o <OLD_EMAIL>] [-n <NEW_EMAIL>] [-u <NEW_USERNAME>]"
}

# ############### check for input arguments ###############

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
if [[ -z "$OLD_EMAIL" || -z "$NEW_EMAIL" || -z "$NEW_USERNAME" ]]; then
    echo "Error: missing required argument."
    command_error
fi

# ############### assurance ###############

echo -e '\nAre you sure to change commiter and author of all commits of all branches'
echo "from <$OLD_EMAIL> to <$NEW_EMAIL> [y/n]?"
read assurance

if ! [[ ${assurance} == 'y' || ${assurance} == 'Y' ]]; then
    exit 0
fi

# ############### set command for git ###############

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

# ############### reset committer and author ###############

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