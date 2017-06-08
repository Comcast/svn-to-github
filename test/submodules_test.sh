#!/bin/bash

#misc

export SVN_DIR="/app/var/foo/test/recover/svn_repo/svn_repo"
export TRUNK='(T|t)(R|r)(U|u)(N|n)(K|k)'
export BRANCH='((B|b)(R|r)(A|a)(N|n)(C|c)(H|h)(E|e)(S|s)|(B|b)(R|r)(A|a)(N|n)(C|c)(H|h))'
export TAG='((T|t)(A|a)(G|g)(S|s)|(T|t)(A|a)(G|g))'
export SAVEIFS=$IFS
export IFS=$(echo -en "\n\b")
export WORK_DIR="/app/var/foo/test/recover/svn_repo"
export NOORG=true
export NTID='swizzley'
export TOKEN='d938a09236f449cas5ea9f6bcfbcb64basadscda55e620'
export GITHUB="github.com"
export GITHUB_API="https://$GITHUB"
export REPO_NAME="foo"

  # Dirs
  export SVN_DIR="$WORK_DIR/$REPO_NAME"
  export NEW_DIR="$WORK_DIR/$REPO_NAME.git"
  export TMP_DIR="$WORK_DIR/$REPO_NAME.clone"
  export LOG_DIR="$WORK_DIR/$REPO_NAME.log"
  export RPO_DIR="$WORK_DIR/$REPO_NAME.github"
  export SUB_DIR="$WORK_DIR/$REPO_NAME.submodules"
  export CLN_DIR="$LOG_DIR/clone"
  export CVT_DIR="$LOG_DIR/convert"
  export PSH_DIR="$LOG_DIR/push"
  # Logs
  export TREELOG="$LOG_DIR/tree.log"
  export COLOG="$LOG_DIR/checkout.log"
  export CNLOG="$LOG_DIR/clone.log"
  export STATUS="$LOG_DIR/status.log"
  export SVNLOG="$LOG_DIR/svnserve.log"
  export CNVLOG="$LOG_DIR/convert.log"
  export CRTLOG="$LOG_DIR/create.log"
  export UNDLOG="$LOG_DIR/undo.log"
  export PHLOG="$LOG_DIR/push.log"
  export IMPLOG="$LOG_DIR/import.log"
  export FAMILY="$LOG_DIR/family.log"
  export GHLOG="$LOG_DIR/github.log"
  export LFSLOG="$LOG_DIR/lfs.log"
  export PRNLOG="$LOG_DIR/parent.log"
  export BFGLOG="$LOG_DIR/bfg.log"
  export RPTLOG="$LOG_DIR/report.log"
  export CPLOG="$LOG_DIR/copy.log"
  export DBGLOG="$LOG_DIR/debug.log"


  export MODULES=$(find "$SVN_DIR" -mindepth 1 -type d -regextype posix-extended -regex "^.*/$TRUNK"|grep -Ev "/$TAG/"|grep -Ev "/$BRANCH/"|rev|cut -d / -f 2-|rev|sort -u)



create_submodules ()
{
#echo "$MODULES"
"$TMP_DIR/svn_repo.git"
  if [ -n "$MODULES" ]; then
  #  echo "Creating submodules in github..."
    declare -gA SubModules
    declare -gA ClonePids
    declare -gA ModuleNames
    declare -gA ModulePaths
    declare -gA ModuleUrls
    declare -gA ModuleRelatives
    declare -gA ChildPaths
    declare -ga ModuleOrigins
    declare -ga Modules
#echo "RELATIVES ARRAY = ${ModuleRelatives[@]}"
    if [ ! -d "$SUB_DIR" ]; then
      mkdir "$SUB_DIR"
    fi
  #TODO cleanup
  #for module in $(echo "$MODULES"|tail -2) ; do
    for module in $MODULES ; do
#echo "DEBUG Adding $module to array"
      relative_path=$(echo $module|awk -F "$SVN_DIR/" '{print $2}')
#echo "relative_path = $relative_path"
      name=$(basename $module)
#echo "subdir is $SUB_DIR"
      real_name=$(grep "$name" $SUB_DIR/svn_repo|head -1)
#echo "DEBUG Adding real name $real_name to array"
    #  if is_empty "$module"; then
    #    echo "NOTICE: Skipping empty \"$name\"" >> "$TREELOG"
    #  else
        # if [ ! -f "$RPO_DIR/$real_name.json" ]; then
        #   #Setup Arrays
#         if [ -n $real_name ]; then
# #          SubModules["$real_name"]="wtf" #for adding submodules
#         #   ClonePids["$real_name"]="" #for Pids
#     #       ModuleNames["$real_name"]="$name" #for name tanslation
#         #   ModuleUrls["$real_name"]="$EVC/$REPO_NAME/$relative_path" #for cloning svn
#         #   ModulePaths["$real_name"]="$module" #for location reference
# echo "DEBUG adding realname $real_name with relative path $relative_path to ModuleRelatives"
            #ModuleRelatives["$real_name"]="$relative_path" #for et_al filter exception
            git submodule add "https://$NTID:$TOKEN@$GITHUB/$NTID/$real_name" "$relative_path"
            #echo ${ModuleRelatives["$real_name"]}
#         fi
#         #   #TODO FIX?
        #   #ModuleOrigins+=("$module",) #for et_al filter
        #   ModuleOrigins+=("$relative_path",) #for et_al filter
        #   Modules+=("$real_name") #for multi-threading loops
        #
        #   # if [ $(echo "$real_name"|grep ^$REPO_NAME_lower--) ]; then
        #   #   #Create list "$SUB_DIR/$real_parent" of nested submodules
        #   #   ChildPaths["$real_name"]="$(get_child_path "$module")" #for location reference of nested repo
        #   #   real_parent=$(resolve_name "$(get_parent "$module")")
        #   #   echo "$real_name " >> "$SUB_DIR/$real_parent"
        #   # # else
        #   # #   echo "$real_name" >> "$SUB_DIR/$REPO_NAME"
        #   # #   real_parent=$REPO_NAME
        #   # fi
        #   # if ! $DRYRUN ; then
        #   #   #Create the repo in github
        #   #   submodule_repo "$real_name" "$real_parent"
        #   # fi
        # fi
      #fi
    done

  fi


}
add_submodules ()
{
echo "DEBUG: ADD_SUBMODULE"
  if [ -f "$SUB_DIR/$1" ]; then
    cd "$TMP_DIR/$1.git"
    git checkout master

    declare -A Children

    #Create Array of Children
    for child in $(cat "$SUB_DIR/$1"); do
      Children["$child"]="$child"
    done

#echo "CHILDREN = ${Children[@]}"
#exit
    #Loop through processing children until all children are done cloning
    while [ "${#Children[@]}" -ne 0 ]; do
      for child in "${Children[@]}" ; do
        #child_pid=${SubModules["$child"]}
        #if [ "$1" == "$REPO_NAME" ]; then
          original_path=${ModuleRelatives["$child"]}
        #else
        #  original_path=${ChildPaths["$child"]}
        #fi
echo "DEBUG: ADD_SUBMODULES child = $child original path = $original_path"
exit
  #      if [ ! "$(ps aux|awk '{print $2}'|grep ^$child_pid$)" ] && [ -n "$child_pid" ]; then
          #if [ -f .gitmodules] && [ ! "$(grep $original_path .gitmodules)" ]
          if $NOORG ; then
            git submodule add "https://$NTID:$TOKEN@$GITHUB/$NTID/$child" "$original_path" &>> "$PRNLOG"
            unset Children["$child"]
          else
            #git submodule add "https://$NTID:$TOKEN@$GITHUB/$ORG/$child" "$original_path" &>> "$PRNLOG"
            unset Children["$child"]
          fi
  #      fi
      done
      echo "Waiting for children of submodule ${ModuleNames["$1"]} to finish cloning. Sleeping $sleep_time seconds..." | tee -a "$STATUS"
      sleep $sleep_time
    done
    unset Children

    #Remove NTID & Token from git URL
    sed -i s/"https://$NTID:$TOKEN@$GITHUB/"/"git@$GITHUB:"/g .gitmodules

    #Add submodules to repo
    git add .gitmodules
  fi
}
create_submodules
#add_submodules "svn_repo"
