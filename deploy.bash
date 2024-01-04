#!/usr/bin/env bash

echo "
(If you make a mistake press ^C and rerun ./deploy.bash)

Let's create a repository on GitHub that your students
will use as an upstream repository.

"
read -p "What should the new repository be named? " -r REPO_NAME
read -p "In what organization or namespace on GitHub should we create it? " -r ORG_NAME

REPO_URL="https://github.com/$ORG_NAME/$REPO_NAME"

echo "

To create the repository, we need a personal access token
with appropriate permissions.

Navigate to https://github.com/settings/tokens/new

Generate a token that expires in 7 days with the following scopes
    repo (all)
    workflow
    read:org (under admin:org)
"
unset GH_TOKEN
prompt="Please paste the token you generated: "
while IFS= read -p "$prompt" -r -s -n 1 char
do
    if [[ $char == $'\0' ]]
    then
        break
    fi
    prompt='*'
    GH_TOKEN+="$char"
done

echo "

Creating $REPO_URL ...
"
export GH_TOKEN
export REPO_NAME
export ORG_NAME
export REPO_URL
docker run --rm -it -e GH_TOKEN -e REPO_NAME registry.gitlab.com/hfossedu/kits/gitkit:latest "$ORG_NAME"

echo "

Your new repository is ready. Give the URL below to your students.

    $REPO_URL

You may stop this workspace using the following command.

    gp stop
"
