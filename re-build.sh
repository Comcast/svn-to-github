#!/bin/bash

# SETUP BUILD
if [ ! -f ~/.rpmmacros ]; then cp .rpmmacros ~/ ; fi
if [ ! -x /bin/rpmdev-setuptree ]; then yum -y install rpmdevtools ; fi
if [ ! -x /bin/rpmbuild ]; then yum -y install rpm-build ; fi
if [ ! -x /bin/git ]; then yum -y install git ; fi
cd ~/
rm -rf rpmbuild

if [ ! -d ~/svn-to-github ]; then
  git clone https://github.com/Comcast/svn-to-github.git
else
  pushd ~/svn-to-github && git pull && popd
fi

rpmdev-setuptree

if [ -z "$1" ] ; then echo "specify a version" ;  exit 1 ; fi
if [ -z "$2" ] ; then echo "specify a release" ;  exit 1 ; fi
if [ -z "$3" ] ; then echo "specify a build" ;  exit 1 ; fi

cp ~/svn-to-github/svn-to-github.spec ~/rpmbuild/SPECS/svn-to-github.spec
cp -r ~/svn-to-github ~/svn-to-github-$1.$2.$3
tar czf svn-to-github-$1.$2.$3.tar.gz svn-to-github-$1.$2.$3/
mv ~/svn-to-github-$1.$2.$3 ~/rpmbuild/SOURCES/
mv svn-to-github-$1.$2.$3.tar.gz ~/rpmbuild/SOURCES/
sed -i "s/Version: [0-9].*/Version: $1\.$2\.$3/g" ~/rpmbuild/SPECS/svn-to-github.spec
sed -i "s/Release: [0-9].*/Release: $3/g" ~/rpmbuild/SPECS/svn-to-github.spec
sed -i "s/Source0: svn-to-github-[0-9]{1,2}.[0-9]{1,2}.[0-9]{1,2}.tar.gz/Source0: svn-to-github-$1.$2.$3.tar.gz/g" ~/rpmbuild/SPECS/svn-to-github.spec
rpmbuild -ba ~/rpmbuild/SPECS/svn-to-github.spec
