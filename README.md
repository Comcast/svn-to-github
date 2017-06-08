# svn-to-github
SVN to Github Tool for Public and Enterprise
[![GitHub release](https://img.shields.io/github/release/qubyte/rubidium-v1.16.0-blue.svg)](https://github.com/comcast/svn-to-github/releases/tag/v1.16.0) [![GitHub issues](https://img.shields.io/github/issues/badges/shields.svg)](https://github.com/Comcast/svn-to-github/issues) [![GitHub contributors](https://img.shields.io/github/contributors/cdnjs/cdnjs.svg)](https://github.com/Comcast/svn-to-github/graphs/contributors) [![license](https://img.shields.io/github/license/mashape/apistatus.svg)](https://github.com/Comcast/svn-to-github/blob/master/LICENSE)

## Overview

This routine will convert an SVN repo to github. If it has nested projects, those projects will become git submodules linked to their nearest ancestor.
The git master branch is created from trunk, and a .gitinore file is added from svn properties.
Trunk is left intact and untouched as a branch, unless `--no-branches` or `--no-preserve-trunk` is used, in which case only master will exist, which will be the original trunk converted
There is a .gitignore file that is created from the original repo, and used as the first commit on the new master branch.
Files and folders above the trunk are considered part of the repository and are added to the new master branch as the final conversion commit.
Trunk directories are created in each master branch and point to the trunk branch to maintain the trunk directory tree for trunks, but can be disabled through option `--no-preserve-trunk`.
Nested repos Under Trunk only exist in the master branch, and not in the trunk branch.
LDAP is required to be configured in order for svn Author lookups to work when building the "SVN Authors File" for full names and email addresses, otherwise svn commits will not be linked to their users in github.

__Conversion time could very greatly__
Conversion time factors are, directory size, commit length of branches/tags and trunk(s) and the greatest factor of all is missing branches or tags. When a branch is deleted from svn permanently, the conversion process must start over from the beginning of the commit chain for every occurrence. It is highly advisable one does not attempt to prune out unwanted branches or tags prior to conversion, but rather after because doing so will result in longer conversion time and errors in the logs.

## Features

1. Preserves the 'svn trunk' directory structure using git submodules [see caveats and limitations]
2. Handles naming conflicts in both the source repo and in github
  * Duplicate named projects in svn will be prefixed with their nearest ancestor's repo name
  * If a repo exists in github with the same name in the same namespace for a submodule, that submodule will be suffixed with the first non-conflicting integer
3. The program will fail immediately if the source repo name already exists in github in the namespace specified
4. Converts files of a specified size to git-lfs for tracking independently of git compression
5. Will remove deleted files of a specified size from git history
6. The original svn tree is saved in the parent repo's master branch in a hidden file called `.svn_tree`
7. All logs are preserved in the archive directory for each job
8. Ability remove repos from github that were converted as a batch using the `--undo` flag along with the `--svn`, `--ghuser`, and `--token` flags and also the `--org` flag if writen to a particular Org's namespace. Useful for sandboxing and redoing jobs with different parameters. Only the `*.json` files need to be preserved which are also saved in the archive dir.
9. Removes the ability to make revisions back to SVN, this is a 1 way conversion, repo syncing is disabled intentionally, revs made during a conversion will not be reflected, so prepare to wait. Conversion time is a function of `revs * branches||tags`

#### Options

All options from the command line must be given in the form of `--option=value` including the csv list ie: `--tags=tags,tag,releases`

* __ghuser__            `[default: prompt ]` [Join Github github.com/join](https://github.com/join)
* __token__             `[default: prompt ]` [github.com/settings/tokens/new](https://github.com/settings/tokens/new)
* __svn-url__           `[default: prompt ]` The SVN Source URL
* __svn-user__          `[default: null ]`   The SVN Source Username
* __svn-pass__          `[default: null ]`   The SVN Source Password
* __org__               `[default: prompt ]` [Organization Docs help.github.com/articles/about-organizations](https://help.github.com/articles/about-organizations/)
* __no-org__            `[default: false ]` - don't create repos under an org, but rather under a user instead, caveat is repo(s) cannot already exist in user's primary Organization
* __no-branches__       `[default: false ]` - do not convert branches, ignore all branches, should NOT be combined with `--no-preserve-trunk`
* __no-tags__           `[default: false ]` - do not convert tags, ignore all tags
* __no-tag-branches__   `[default: false ]` - do not allow tags to be branches, convert tags to releases only
* __no-preserve-trunk__ `[default: false ]` - do not keep the trunk directory, so trunk becomes the root of master, should NOT be combined with `--no-branches`
* __no-other-repos__    `[default: false ]` - do not create submodule repos, only create the primary repo but nest them if they already exist
* __private__           `[default: false ]` - make all repo(s) private in github
* __check-size__        `[default: false ]` - estimate the size on disk needed for conversion of non-standard-layouts, can be very time consuming
* __safe__              `[default: false ]` - be prompted before all github repository creations or deletions when combined with the undo option
* __install__           `[default: false ]` - dependency installation, Warning: May Fail if dependencies are not met.
* __force__             `[default: false ]` - force the creation, will delete all data from previous run and possibly create duplicate submodule repos with suffixes in github
* __undo__              `[default: false ]` - delete the github repos from a previous run, but preserve all log data
* __new-name__          `[default: null ]` - rename your new repo name in github, required if name already exists in github under user or organization
* __trunk__             `[default: null ]` - a csv list of alternative trunk dir names or specify just one
* __tags__              `[default: null ]` - a csv list of alternative tag dir names or specify just one
* __branches__          `[default: null ]` - a csv list of alternative branch dir names or specify just one
* __svn-prefix__        `[default: null ]` - specify a prefix given to an otherwise standard-layout of svn directories
* __authors__           `[default: null ]` - path of authors file rather than generate one, may not provide correct email address for users who do not conform to first_last@cable.comcast.com
* __ignore__            `[default: null  ]` - path of import file for gitignore file rather than convert it from the existing svn ignore attributes
* __lfs-limit__         `[default: 150 ]` - specify the large-file-size limit, 2 ~ 2 Megabytes, 100K ~ 100 Kilobytes, maximum in github is 50, [2-5] is optimal
* __blob-limit__        `[default: 150 ]` - specify the max size of blobs allowed, 50 ~ 50 Megabytes, maximum in github is 50, < 50 is optimal
* __work-dir__          `[default: /opt/svn-to-github ]` - to specify a working directory for creating files

#### Requirements

  * Must be used on an Enterprise Linux 7 system (RHEL/CentOS/Fedora/Oracle) or with the prerequisites met use `--skip-install` __NOTE:__ git > 1.8.2 package on el6 does not exist thus requires src build, which is why EL7 is the requirement for the package install, early builds ran on Debian LTS but have since been discontinued
  * Must have account in github with permissions to create repos in organization
  * Must have root access or the package `git-svn and `git-lfs` already installed
  * __FOR ENTERPRISE ONLY__ without LDAP access, the script cannot query the directory for real names and email addresses of authors found in the svn history, therefore all historical commits will have generic & invalid names and email addresses Unknown_ghuser Missing_ghuser@yourdomain.com

#### Software

The software used to perform the tasks are common tools loaded from any bash 4.x shell, the following are installed required on EL systems:

 * git >= 1.8.2
 * bash >= 4.0
 * subversion
 * git-lfs (installed by first run)
 * git-svn
 * java-1.7.0-openjdk
 * expect
 * curl
 * gawk
 * findutils
 * coreutils
 * sed
 * yum
 * grep
 * procps
 * glibc-common
 * which
 * initscripts
 * tree

## Setup

1. Create a personal access API token with full permissions in github. [github.com/settings/tokens/new](https://github.com/settings/tokens/new)

__TOKEN IS REQUIRED__ a password is not sufficient when using --org=organization

  * Install the git-lfs
`
yum -y install https://packagecloud.io/github/git-lfs/packages/el/7/git-lfs-2.1.1-1.el7.x86_64.rpm/download
`
  * Install from RPM on EL7
`
yum -y install https://github.com/comcast/svn-to-github/releases/download/v1.16.0/svn-to-github-1.16.0.el7.noarch.rpm
`

## Usage

__USE NOHUP__ because your session could likely timeout before conversion completes. Or Feel free to send a pull request

__Logs:__ `/opt/svn-to-git/$REPO/$REPO.log`
__Jobs:__ `/opt/svn-to-git/archive`

__Convert a Single Repo to Org:__
`
nohup svn-to-github --no-other-repos --org=svn2git --svn-url=http://svn.yourdomain.net/repos/svn_repo --ghuser=swizzley --token=d938a09236f449c5ea9f6bcfbcb64bacda55e620 &
`


__Convert a Repo to Org:__
`
nohup svn-to-github --org=svn2git --svn-url=http://svn.yourdomain.net/repos/svn_repo --ghuser=swizzley --token=d938a09236f449c5ea9f6bcfbcb64bacda55e620 &
`

__Convert a Repo to User:__
`
nohup svn-to-github --no-org --svn-url=http://svn.yourdomain.net/repos/svn_repo --ghuser=swizzley --token=d938a09236f449c5ea9f6bcfbcb64bacda55e620 &
`

__Convert a Secure SVN Repo:__
`
nohup svn-to-github --no-org --svn-url=http://svn.yourdomain.net/repos/svn_repo --svn-user=svn2gituser --svn-pass='s3cret!' --ghuser=swizzley --token=d938a09236f449c5ea9f6bcfbcb64bacda55e620 &
`
The password must be quoted in single quotes if a standard escape character is part of the string

__Convert a SVN Repo to a Private Repo:__
`
nohup svn-to-github --private --svn-url=http://svn.yourdomain.net/repos/svn_repo --ghuser=swizzley --token=d938a09236f449c5ea9f6bcfbcb64bacda55e620 --org=aps &
`

__Convert with lots of options:__
`
nohup svn-to-github --private --svn-url=http://svn.yourdomain.net/repos/svn_repo --ghuser=swizzley --token=d938a09236f449c5ea9f6bcfbcb64bacda55e620 --org=aps --check-size --lfs-limit=50 --blob-limit=50 --work-dir=/home/swizzley --new-name=myrepo  --svn-user=svn2gituser --svn-pass=s3cret --no-tag-branches --no-preserve-trunk --no-other-repos --install --force &
`
check-size can take a very long time, but a drop in the bucket for large repos with long chains.
forcing will delete a previous checkout

__Convert but provide pre-formatted Authors file:__
`
nohup svn-to-github --private --svn-url=http://svn.yourdomain.net/repos/svn_repo --ghuser=swizzley --token=d938a09236f449c5ea9f6bcfbcb64bacda55e620 --no-org --blob-limit=50 --work-dir=/home/swizzley --authors=/home/swizzley/svn_authors.txt &
`

__Convert but provide Ignore file:__
`
nohup svn-to-github --private --svn-url=http://svn.yourdomain.net/repos/svn_repo --ghuser=swizzley --token=d938a09236f449c5ea9f6bcfbcb64bacda55e620 --no-org --blob-limit=50 --work-dir=/home/swizzley --ignore=/home/swizzley/svn_ignore.txt &
`
Ignore file is Global to repo and all sub repos, if a conflict exists in dir levels for nested repos, modify the ignore attributes in SVN before hand or provide a file to use instead and resolve the conflicts after the conversion, anything ignored will not be added to the final git repo(s)

__Convert but provide Unique Names for SVN Dirs:__
`
nohup svn-to-github --private --svn-url=http://svn.yourdomain.net/repos/svn_repo --ghuser=swizzley --token=d938a09236f449c5ea9f6bcfbcb64bacda55e620 --no-org --branches=patches,releases,Patch,Revs --tags=10-14-2003,Jun_2014 --svn-prefix=_svn- &
`
This is in addition to, not in replacement of svn standard-layout directories (trunk,tags,branches)

__Convert and manually approve every GHE repo name one by one:__
`
nohup svn-to-github --private --svn-url=http://svn.yourdomain.net/repos/svn_repo --ghuser=swizzley --token=d938a09236f449c5ea9f6bcfbcb64bacda55e620 --no-org --safe &
`
Requires user to type 'yes' before every repo is created, and requires the checkout to be complete, (NOT Advisable for long commit chains, large repos over ssh due to timeouts)

__Convert and rename the GHE Repo:__
`
nohup svn-to-github --private --svn-url=http://svn.yourdomain.net/repos/svn_repo --ghuser=swizzley --token=d938a09236f449c5ea9f6bcfbcb64bacda55e620 --no-org --new-name=myrepo &
`
This will all rename the Prefix of all submodules nested inside

__Undo Conversion by DELETING ALL REPOS converted in GHE under Org:__
`
svn-to-github --svn-url=http://svn.yourdomain.net/repos/svn_repo --org=aps --ghuser=swizzley --token=d938a09236f449c5ea9f6bcfbcb64bacda55e620 --undo
`

__Undo Conversion by DELETING ALL REPOS converted in GHE under User:__
`
svn-to-github --svn-url=http://svn.yourdomain.net/repos/svn_repo --no-org --ghuser=swizzley --token=d938a09236f449c5ea9f6bcfbcb64bacda55e620 --undo
`

## Log-Analysis

Under each conversion job is a log directory, inside that directory shows the real-time status of any particular stage of the job. These logs along with the json files used to create and delete repos with --undo in GHE are archived in the working-dir's archive folder with the name and date that the job finished. The `report.log` file will show any failures, conversion failures typically occur when the commit chain in svn is broken and cannot be resolved automatically through the git svn clone process. These failures must be resolved by hand afterwards, typically by specifying the Rev number in SVN or by ignoring what was broken. There is a `retry.log` that shows when a process failed for some reason, and that process is given three attempts to work before being logged as a failure.

## Post-Conversion-Git-Usage

__Clone the Full Repo:__
`
git clone --recursive $REPO_URL
`

__Clone a particular branch Only:__
`
git clone -b $BRANCH_NAME $REPO_URL
`

__Update all submodules:__
`
git submodule update --recursive
`

## Caveats and Limitations for non-standard svn repo layouts

1. Branches only get converted if they exist in a case insensitive dir `*/branches` by default
  * alternative branch directories can be specified as a csv list using the Argument `--branches=/path/to/file.csv`
  * or specify a single alternative with the name of the label, like this:  `--branches=some_label`
  * skip branches entirely with `--no-branches` any alternative branch label must be specified with `--branches` or the contents will be added as files under master
  * original branch directories are __NOT PRESERVED__
2. Tags get converted to tags and branches by default
  * skip converting tags to branches with `--tags-not-branches`
  * skip tags entirely with `--no-tags`
  * original tag directories are __NOT PRESERVED__
3. Spaces in repo names will be replaced with underscores to avoid ugly unicode in github
4. Trunks nested under tags or branches are __NOT PRESERVED__
5. Empty directories are __NOT PRESERVED__
6. Large files are tracked using `git lfs`, which uses patterns, those patterns are based on the file extension of a file equal to or over the `--lfs-limit`, if that file does not have an extension, the full name of the file is used.
7. Directory tree overall is preserved except directories for tags and branches which become git tags and git branches, and trunk directory is only preserved if it was named trunk, otherwise one can use the `--no-preserve-trunk` option to accept the converted directory structure without any trunk directories

### Routine

1. Collect svn source repo location; use the svn argument to skip prompt eg: `--svn=https://server/svn/myrepo`
2. Creates a work dir in `/opt/svn-to-github/$myrepo`; but one can be specified using `--work-dir=/opt/myrepo`
3. Collect and or validate authentication to github; specify the org, ghuser and token arguments to skip prompt eg: `--org=myorg --ghuser=username --token=password`
4. Checks to see if svn repo name exists in github; if it does it fails and prompts to run again using the argument `--rename=my-new-repo-name`
5. Checks for `--undo` flag to see if user wants to reverse the process from a previous run, in which case it will remove any repos that it created in github and exit afterwards
6. Checks that the user running is `root`; if not it will check if requirements exist; otherwise it will exit
7. Checks to see if requirements are installed and permissions in work-dir are met
8. Optionally checks disk space and repo's size to estimate if adequate disk space exists in work-dir mount (off by default because checking a remote location is slow)
9. Checkout local copy of svn repo URL
10. Generates authors file from svn log to maintain commit history in github, [optionally] using `---authors=some_file` skips this step
11. Checks for nested repos
12. Creates all repo(s) in github, nested repos are created with a prefix of their parent repo's name in github, any duplicates will have a suffix number
13. Begins cloning any nested repos individually and concurrently
14. Nested repos that have finished cloning are then converted completely with branches and tags as well as concurrently as soon as they are finished cloning
15. Any parent repo that has finished must wait for all child repos to finish converting before it can begin converting so that all submodules will be added prior to completion
16. The top scope/primary parent repo is then created or converted and all nested repos are added to it as submodules

## Useful_Links

  * [git svn crash course](http://git.or.cz/course/svn.html)
  * [git-svn Manual](https://git-scm.com/docs/git-svn)
  * [git blob cleaner](https://rtyley.github.io/bfg-repo-cleaner)
  * [git-lfs extension](https://github.com/github/git-lfs)
  * [git submodules](https://git-scm.com/book/en/v2/Git-Tools-Submodules)
  * [github API](https://developer.github.com/v3/)


## TODO

  * Add full directory tree mirroring support for branches and tags
