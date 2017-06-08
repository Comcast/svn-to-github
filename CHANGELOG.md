## Added Config
  * added config file to swap between GHE and GH APIs n downloading external links 

## Ubuntu Deprecated
  * still possible to use with `skip-install` but no longer packaged

## Ubuntu release
  * Fixed --skip-install
  * Added Deb pkg

## First release
  * Fixed nested submodules of submodules
  * Fixed empty modules with nested submodules
  * Fixed / Deprecated blob to lfs conversion
  * Deprecated NEW_DIR
  * Fixed retry

## Beta
  * Add original Tree function / file to master
  * FIX this:
```
find: ‘’: No such file or directory
basename: invalid option -- ':'
Try 'basename --help' for more information.
./svn-to-github.sh: line 893: cd: -:: invalid option
cd: usage: cd [-L|[-P [-e]]] [dir]
dirname: invalid option -- ':'
Try 'dirname --help' for more information.
basename: missing operand
```

  * FIX: missing trunk branch results in missing trunk dir and false tree
  * FIX RENAME
  * Deprecate $NAME.git dir?
  * BFG TWICE? WHY?
  * FIX: et_al submodules (BAD REGEX, renaming work-dir to svn-to-github caused et_al to be ignored)
  * Remove username@ from repo description
  * FIX: SVN -> git BRANCH CONVERSION
  * FIX: Adding submodules to $subdir/trunk instead of $subdir ????
  * FIX: Fail to et_al_primary after (submodule add fails?)
  * FIX: sed replace [[:space:]] with _ in repo names `svn-prj` becomes `svn-prj`
  * FIX THIS: ```RA layer request failed: REPORT of '/svn/!svn/vcc/default': Could not read chunk size: Secure connection truncated (https://repo.net) at /usr/share/perl5/vendor_perl/Git/SVN/Ra.pm line 282.```
      - caused by read permissions being set on svn host. `git svn clone` combines git svn init && git svn fetch, git svn init --no-minimize-url  will or may resolve the permissions issue.
  * fix et_al_primary for primary containing trunk ```/app/svn-to-github/author_default.sh: No such file or directory```
  * fix --new-name $RENAME
  * add gzip of $.github as final step before report
  * deprecate --no-org by making ntid default
  * fix `xrealloc: cannot allocate 18446744071562067968 bytes (667648 bytes allocated)`
  * Add true 1 to 1 directory tree conversion
  * Fix Retry `CLONE: No such file or directory`
  * Fix svn Credentials expect to allow multiple Credentials with same base URL or (each conversion uses a unique user to store creds in their $HOME dir)
  * sanitize --ignore and --authors to seek relative dir first so full path isnt necessary
  * fix retry function `error no such dir`


# Alpha
  * fix ignore files for nested submodules to have relative ignores if unique attributes in svn are absent
  * Fix LFS loop to allow files with spaces
  * fix need to push primary 2x or just push it 2x (for some reason it prompts for creds twice)[is this still a problem?]
  * make service stop/start ?
  * make resume ?
  * Package
  * Ansible Playbook
  * verify ignore with spaces works, and ignore paths are preserved in submodules
  * no nested non repo directory that contains nested repos may begin with "-:-"
  * add repo to team option if team exists in org (could suck because team id's are just numeric, so users might not know what a team's id number is)
  * could just do a create team function at the same time importing the team members from the commit logs


# TODO
  * Change default unit of lfs and bfg to Megabytes
  * Add default READM.md with useful links and info
  * deprecate $NEW_DIR
  * daemonize and make job queue with .conf file
  * Add sleep or wait to BFG to ensure push for slow bfg jobs
  * NEW ISSUE: `real_parent=$(resolve_name "$(get_parent "$module")")` resulting in "Submodule of svn_repo-"
  * FIX:
```

```
  * Unknown Issue: [possible fix here](http://stackoverflow.com/questions/4929674/what-can-i-do-with-git-corruption-due-to-a-missing-object)
  * Add conf file for pkg to use in playbook
  * Add ntid as default if -z org
  * FIX Rename
  * FIX nested repo designation chars results in the following error:
```
find: ‘’: No such file or directory
basename: invalid option -- ':'
Try 'basename --help' for more information.
```
  * Add tar & gzip .github dir into "Jobs Archive"
__validate every argument works__
  * validated
    - svn
    - authors
    - org
    - ntid
    - token
    - ignore
    - work-dir
    - undo
    - no-tag-branches
    - no-branches
    - no-tags
    - no-org
    - safe
    - force

  * unvalidated
    + private
    + branches
    + tags
    + trunk
    + prefix
    + check-size
    + no-preserve-trunk
