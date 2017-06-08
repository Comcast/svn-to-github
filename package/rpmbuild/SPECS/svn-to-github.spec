Name: svn-to-github
Version: 1.16.0
Release: 0
Summary: Converts Svn Repos to Github Public or Enterprise in Bulk
URL: https://github.com/Comcast/svn-to-github
Source0: svn-to-github-1.16.0.tar.gz
License: GPL
BuildArch: noarch
BuildRoot: %{_tmppath}/%{name}-buildroot
Provides: svn-to-github
Requires: git >= 1.8.2, subversion, git-svn, java-1.7.0-openjdk, expect, curl, gawk, findutils, coreutils, sed, yum, grep, procps, glibc-common, which, initscripts, tree, bash >= 4.0
%description
This will convert svn repositories into Github repositories, if nested svn projects exist, those will be converted to git submodules preserving the directory tree.
%prep
%setup -q
%build
%install
install --directory $RPM_BUILD_ROOT/opt/svn-to-github
install --directory $RPM_BUILD_ROOT/etc/svn-to-github
install --directory $RPM_BUILD_ROOT/opt/svn-to-github/bin
install -m 0644 README.md $RPM_BUILD_ROOT/opt/svn-to-github/README.md
install -m 0644 README.md $RPM_BUILD_ROOT/opt/svn-to-github/config.yml
install -m 0755 svn-to-github $RPM_BUILD_ROOT/opt/svn-to-github/bin/svn-to-github
%clean
rm -rf $RPM_BUILD_ROOT
%post
ln -s /opt/svn-to-github/bin/svn-to-github /usr/local/bin/svn-to-github
ln -s /opt/svn-to-github/config.yml /etc/svn-to-github/config.yml
echo "svn-to-github installation complete! svn-to-github --help for Instructions"
%dir /opt/svn-to-github
%dir /opt/svn-to-github/bin
%dir /etc/svn-to-github
%files
/opt/svn-to-github/bin/svn-to-github
/opt/svn-to-github/README.md
/opt/svn-to-github/config.yml
