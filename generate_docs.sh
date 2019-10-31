#!/bin/bash

# Disable color tags
export FASTLANE_DISABLE_COLORS=1

# Run fastlane to get the docs
ALL_DOCS=`fastlane action appcenter_upload | grep -A200 "appcenter_upload Options" | grep -B200 "appcenter_upload Output Variables"`

# Parse output. Note: does not work with appcenter_fetch yet
ALL_LINES=()
HEADER_COUNT=4
TAIL_COUNT=5

count=0
while read -r line ; do
  ALL_LINES[$count]=$line
  count=$(($count + 1))
done <<< "${ALL_DOCS}"

for id in `seq ${HEADER_COUNT} 1 $(($count - ${TAIL_COUNT}))` ; do
  line="${ALL_LINES[$id]}"
  new_action=`echo "${line}" | cut -d '|' -f 2 | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//'`
  new_doc=`echo "${line}" | cut -d '|' -f 3 | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//'`
  new_env=`echo "${line}" | cut -d '|' -f 4 | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//'`
  new_default=`echo "${line}" | cut -d '|' -f 5 | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//'`
  if [[ "$new_action" != "" ]] ; then
    if [[ "$default" != "" ]] ; then
      echo "| \`$action\` <br/> \`$env\` | $doc (default: \`$default\`) |"
    elif [[ "$action" != "" ]] ; then
      echo "| \`$action\` <br/> \`$env\` | $doc |"
    fi
    action=$new_action
    doc=$new_doc
    env=$new_env
    default=$new_default
  else
    doc="$doc $new_doc"
    env="$env$new_env"
    default="$default$new_default"
  fi
done
#echo "| \`$action\` | $doc |"

