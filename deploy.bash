#!/usr/bin/env bash

# GITKIT_DOCKER_TAG allows caller to supply the tag for the
# GitKit Deployer Docker container. This is used when testing
# to supply the tag for the branch being tested, or if one
# wants to pin the version number of the deployer.
#
# For instructions on how to pass variables through a GitPod
# URL, see: https://www.gitpod.io/docs/configure/projects/environment-variables#providing-one-time-environment-variables-via-url
#
# Here is an example of passing the default value (latest).
# https://gitpod.io/?autostart=true#GITKIT_DOCKER_TAG=latest/https://github.com/hfossedu/gitkit-deployer-gitpod
if [ -n "$GITKIT_DOCKER_TAG" ] ; then
    echo "GITKIT_DOCKER_TAG detected: ${GITKIT_DOCKER_TAG}"
else
    GITKIT_DOCKER_TAG="latest"
fi

echo "
(If you make a mistake press ^C and rerun ./deploy.bash)

Let's create a repository on GitHub that your students
will use as an upstream repository.

"

if [ -z "$REPO_NAME" ] ; then
    read -p "What should the new repository be named? " -r REPO_NAME
fi

if [ -z "$ORG_NAME" ] ; then
    read -p "In what organization or namespace on GitHub should we create it? " -r ORG_NAME
fi
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
docker run --rm -it -e GH_TOKEN -e REPO_NAME "registry.gitlab.com/hfossedu/kits/gitkit:$GITKIT_DOCKER_TAG" "$ORG_NAME"

echo "

Your new repository is ready. Give the URL below to your students.

    $REPO_URL

You may stop this workspace using the following command.

    gp stop
"
