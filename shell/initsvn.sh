#!/bin/bash

# Author: lostsnow (lostsnow@gmail.com)

function msg_exit()
{
    echo $1;
    exit 0;
}

dir_rand=$(dd if=/dev/urandom bs=1 count=4 2>/dev/null | od -t u4 | awk 'NR=1{print $2}')

base_dir="/srv/svn/lostsnow/"
echo "Please input project name:"
read -p "Project name:" projname
if [ "$projname" = "" ]; then
    msg_exit "Error: project name invalid."
fi

svnpath=$base_dir$projname

if [ -d $svnpath ]; then
    msg_exit "Error: project has exist."
fi

svnadmin create $svnpath

killall svnserve
svnserve -d -r $base_dir

if [ -d $dir_rand ]; then
    msg_exit "Error: directory structure has exist."
fi
mkdir -p $dir_rand/trunk
mkdir -p $dir_rand/branches
mkdir -p $dir_rand/tags

svn import $dir_rand file://$svnpath -m "Initial directory structure."

rm -rf $dir_rand
