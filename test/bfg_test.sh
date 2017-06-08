#!/bin/bash

git_bfg_lfs ()
{
exportWORK_DIR="/app/foo/var/test/recover/var"
BFGPROG="/app/foo/var/test/recover/var/bfg-1.12.12.jar"
TMP_DIR="/app/foo/var/test/recover/var/svn_repo.clone"
BFGLOG=../bfg.log
LFSLOG=../lfs.log
LFS="50M"
BLOB_LIMIT="50M"
IFS=$(echo -en "\n\b")

  if [ ! -f "$BFGPROG" ]; then
    cd "$WORK_DIR"
    curl -O -k -s "$BFG_DOWNLOAD"
  fi

  cd "$TMP_DIR/$1.git"
  lfs=$(find "$TMP_DIR/$1.git" -type f -size +"$LFS"|grep -Ev '.svn|.subversion|/.git')

  echo "" > "$BFGLOG"
  for big_file in $lfs; do
    if [ "$(basename $big_file|grep .)" ]; then
     extension=$(echo $big_file|rev|awk -F "." '{print $1}'|rev)
     echo pattern="'*.$extension'" >> "$BFGLOG"
    else
     echo patten="'$(basename $big_file)'" >> "$BFGLOG"
    fi
  done

  for lfs_pattern in $(cat "$BFGLOG"|grep pattern|awk -F "pattern=" '{print $2}'|sort -u); do
echo "DEBUG: $BFGPROG pattern $lfs_pattern"
    java -jar "$BFGPROG" --convert-to-git-lfs $lfs_pattern --no-blob-protection
  done

  #TODO
  # git reflog expire --expire=now --all && git gc --prune=now &>> "$BFGLOG"
  git lfs install &>> "$LFSLOG"

  for file in $lfs; do
    track_file=$(echo "$file"|awk -F "$(pwd)/" '{print $2}')
echo "DEBUG: track file is $track_file"
    git lfs track "$track_file" &>> "$LFSLOG"
    git add "$track_file" &>> "$LFSLOG"
    git commit -m "Tracking large file \"$track_file\" with lfs" &>> "$LFSLOG"
    git lfs push origin master &>> "$LFSLOG"
    git rm "$track_file" &>> "$LFSLOG"
  done

  java -jar "$BFGPROG" --strip-blobs-bigger-than "$BLOB_LIMIT"
  git reflog expire --expire=now --all && git gc --prune=now &>> "$BFGLOG"

  git add .gitattributes &>> "$LFSLOG"
  git commit -m "Large file(s) converted to LFS pointers" &>> "$LFSLOG"

}

git_bfg_lfs "svn_repo"
