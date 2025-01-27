#!/usr/bin/env bash
NON_INTERACTIVE_OPTION=$1
DEPENDENCY=$2

check_installed() {
  if ! type "$1" > /dev/null; then
    echo "Please ensure you have $1 installed."
    exit 1
  fi
}

check_installed curl

# check if xmllint is installed
if type xmllint > /dev/null; then
  USE_XMLLINT=1 #true
else
  echo "warning: xmllint is not installed - will try with 'grep' as a fallback..."
  USE_XMLLINT=0 #false
fi

declare -A repos=(
  [overflowdb]=https://repo1.maven.org/maven2/io/shiftleft/overflowdb-core
  [overflowdbCodegen]=https://repo1.maven.org/maven2/io/shiftleft/overflowdb-codegen_2.12
)

function latest_version {
  local NAME=$1
  local REPO_URL=${repos[$NAME]}
  local MVN_META_URL=$REPO_URL/maven-metadata.xml
  local CURL_PARAMS="--silent --show-error $MVN_META_URL"

  if (( $USE_XMLLINT ))
  then
    curl $CURL_PARAMS | xmllint --xpath "/metadata/versioning/latest/text()" -
  else
    curl $CURL_PARAMS | grep '<latest>' | sed 's/[ ]*<latest>\([0-9.]*\)<\/latest>/\1/'
  fi
}

function update {
  local NAME=$1
  if [[ -z "${repos[$NAME]}" ]]; then
    echo "error: no repo url defined for $NAME"
    exit 1;
  fi

  local VERSION=$(latest_version $NAME)
  local SEARCH="val ${NAME}Version\([ ]*\)= .*"
  local OLD_VERSION=$(grep "$SEARCH" build.sbt | sed 's/.*"\(.*\)"/\1/')

  if [ "$VERSION" == "$OLD_VERSION" ]
  then
    echo "$NAME: unchanged ($VERSION)"
  else
    local REPLACE="val ${NAME}Version\1= \"$VERSION\""

    if [ "$NON_INTERACTIVE_OPTION" == "--non-interactive" ]
    then
      echo "non-interactive mode, auto-updating $NAME: $OLD_VERSION -> $VERSION"
      sed -i "s/$SEARCH/$REPLACE/" build.sbt
    else
      echo "update $NAME: $OLD_VERSION -> $VERSION? [Y/n]"
      read ANSWER
      if [ -z $ANSWER ] || [ "y" == $ANSWER ] || [ "Y" == $ANSWER ]
      then
        sed -i "s/$SEARCH/$REPLACE/" build.sbt
      fi
    fi
  fi
}

if [ "$DEPENDENCY" == "" ]; then
  update overflowdb
  update overflowdbCodegen
else
  DEPENDENCY="${DEPENDENCY#--only=}"
  update $DEPENDENCY
fi
