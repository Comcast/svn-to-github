#!/bin/bash

export SAVEIFS=$IFS
export IFS=$(echo -en "\n\b")
export SVN_DIR="/app/foor/var/test/recover/var/bar"
export TAG='((T|t)(A|a)(G|g)(S|s)|(T|t)(A|a)(G|g))'
export BRANCH='((B|b)(R|r)(A|a)(N|n)(C|c)(H|h)(E|e)(S|s)|(B|b)(R|r)(A|a)(N|n)(C|c)(H|h))'
export TRUNK='(T|t)(R|r)(U|u)(N|n)(K|k)'
export MODULESS=$(find "$SVN_DIR" -mindepth 1 -type d -regextype posix-extended -regex "^.*/$TRUNK"|grep -Ev "/$TAG/"|grep -Ev "/$BRANCH/"|rev|cut -d / -f 2-|rev|sort -u)

#echo $MODULESS
create_submodules ()
{
  if [ -n "$MODULESS" ]; then
    #echo "Creating submodules in github..."
    # declare -gA SubModules
    # declare -gA ClonePids
    # declare -gA ConvertPids
    # declare -gA ModuleNames
    # declare -gA ModulePaths
    # declare -gA ModuleUrls
    # declare -gA ModuleRelatives
    # declare -gA ChildPaths
    declare -ga ModuleOriginss
    # declare -ga Modules

    # if [ ! -d "$SUB_DIR" ]; then
    #   mkdir "$SUB_DIR"
    # fi
  #TODO revert
  #for module in $(echo "$MODULES"|tail -1) ; do
  # echo "FOR LOOP HERE"
    for modulew in $MODULESS ; do
#      echo $modulew
      local relative_pathh=$(echo $modulew|awk -F "$SVN_DIR/" '{print $2}')
      # local name=$(basename $module)
      # local real_name=$(resolve_name "$module")

      # if is_empty "$module"; then
      #   echo "NOTICE: Skipping empty \"$name\"" >> "$TREELOG"
      # else
        # if [ ! -f "$RPO_DIR/$real_name.json" ]; then
          #Setup Arrays
          # SubModules["$real_name"]="" #for adding submodules
          # ClonePids["$real_name"]="" #for tracking Pids of Clone jobs
          # ConvertPids["$real_name"]="" #for tracking Pids of Convert jobs
          # ModuleNames["$real_name"]="$name" #for name tanslation
          # ModuleUrls["$real_name"]="$EVC/$REPO_NAME/$relative_path" #for cloning svn
          # ModulePaths["$real_name"]="$module" #for location reference
          # ModuleRelatives["$real_name"]="$relative_path" #for et_al filter exception
#echo $relative_pathh
          ModuleOriginss+=("$relative_pathh",) #for et_al filter
          # Modules+=("$real_name") #for multi-threading loops

          # if [ $(echo "$real_name"|grep ^$REPO_NAME_lower--) ]; then
          #   #Create list "$SUB_DIR/$real_parent" of nested submodules
          #   ChildPaths["$real_name"]="$(get_child_path "$module")" #for location reference of nested repo
          #   real_parent=$(resolve_name "$(get_parent "$module")")
          #   echo "$real_name " >> "$SUB_DIR/$real_parent"
          # else
          #   echo "$real_name" >> "$SUB_DIR/$REPO_NAME"
          #   real_parent=$REPO_NAME
          # fi
          # if ! $DRYRUN ; then
          #   #Create the repo in github
          #   submodule_repo "$real_name" "$real_parent"
          # fi
        # fi
      # fi
  #    echo "arry = ${ModuleOriginss[@]}"
    done

  fi
}

git_et_al_primary ()
{
  local search_dirr="$SVN_DIR"

  nested_projectss=$(find "$search_dirr" -mindepth 1 -maxdepth 1 -type d|grep -Ev "/$TRUNK/|/$TRUNK$|/$TAG/|/$TAG$|/$BRANCH/|/$BRANCH$|.svn|.subversion")
#echo $nested_projectss
  #if [ -n "$nested_projectss" ]; then
    et_al_dirss=$(find "$search_dirr" -type d|grep -Ev "/$TRUNK/|/$TRUNK$|/$TAG/|/$TAG$|/$BRANCH/|/$BRANCH$|.svn|.subversion|/.git|$search_dirr$")
#echo $et_al_dirss
     #filterr="($(echo "${ModuleOriginss[@]}"|sed s/',,'/'|'/g|sed s/' '/'[[:space:]]'/g|cut -c 2-|rev|cut -c 2-|rev))"
    filterr="($(echo "${ModuleOriginss[@]}"|sed s/', '/'|'/g|sed s/' '/'[[:space:]]'/g|rev|cut -c 2-|rev))"
echo $filterr
    other_dirss=$(echo "$et_al_dirss"|grep -Ev "$filterr")
    #echo $(echo "$et_al_dirss"|wc -l)
    #echo $(echo "$other_dirss"|wc -l)
    #echo "$other_dirss"
  #fi

#echo "DEBUG OTHER_DIRS = $other_dirss"

  # if [ -n "$other_dirs" ] || [ -n "$top_files" ]; then
  #   cd "$TMP_DIR/$name.git"
  #
  #   if [ -n "$other_dirs" ]; then
  #     echo "Adding directories and files from \"$SVN_REPO\" to \"$REPO_NAME\" that were not part of any trunk, branch, tag or meta-data..." | tee -a "$STATUS"
  #     for dir in $other_dirs; do
  #       et_al_files=$(find "$dir" -mindepth 1 -maxdepth 1 -type f|grep -Ev "/$TRUNK/|/$TRUNK$|/$TAG/|/$TAG$|/$BRANCH/|/$BRANCH$|.svn|.subversion|/.git|$1$")
  #       other_files=$(echo "$et_al_files"|grep -Ev "$filter")
  #       dir_path=$(echo $dir|awk -F "$SVN_DIR/" '{print $2}')
  #       dir_perm=$(stat -c "%a" $dir)
  #
  #       if [ ! -d "$TMP_DIR/$name.git/$dir_path" ]; then
  #         mkdir -p "$TMP_DIR/$name.git/$dir_path"
  #       fi
  #
  #       chmod $dir_perm "$TMP_DIR/$name.git/$dir_path"
  #
  #       for file in $other_files; do
  #         if [ -n "$dir_path" ]; then
  #           cp -pv "$file" "$TMP_DIR/$name.git/$dir_path/" &>> "$CPLOG"
  #         else
  #           cp -pv "$file" "$TMP_DIR/$name.git/" &>> "$CPLOG"
  #         fi
  #       done
  #     done
  #   fi
  #
  #   if [ -n "$top_files" ]; then
  #     echo "Adding top level files from \"$SVN_REPO\" to \"$REPO_NAME\" that were not part of a trunk, branch, tag or meta-data..." | tee -a "$STATUS"
  #     for file in $top_files; do
  #       cp -pv "$file" "$TMP_DIR/$name.git/" &>> "$CPLOG"
  #     done
  #   fi
  # fi
}

create_submodules
git_et_al_primary
