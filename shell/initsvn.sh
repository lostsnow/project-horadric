#!/bin/bash

# Author: lostsnow (lostsnow@gmail.com)

function msg_exit()
{
    echo $1;
    exit 0;
}

dir_rand=$(dd if=/dev/urandom bs=1 count=4 2>/dev/null | od -t u4 | awk 'NR=1{print $2}')

base_dir="/var/svn/"
listen=192.168.128.131

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
svnserve -d --listen-host $listen -r $base_dir

if [ -d $dir_rand ]; then
    msg_exit "Error: directory structure has exist."
fi
mkdir -p $dir_rand/trunk
mkdir -p $dir_rand/branches
mkdir -p $dir_rand/tags

svn import $dir_rand file://$svnpath -m "Initial directory structure."

cat >$svnpath/hooks/pre-commit<<EOF
#!/bin/sh

export LANG=zh_CN.UTF-8

REPOS="\$1"
TXN="\$2"

# Make sure that the log message contains some text.
SVNLOOK=/usr/bin/svnlook
LOGMSG=\`\$SVNLOOK log -t "\$TXN" "\$REPOS" | grep "[^[:space:]+]" | grep -o "[^ ]\+\( \+[^ ]\+\)*" | wc -c\`
if [ "\$LOGMSG" -lt 5 ];
then
    echo -e "\nEmpty log message not allowed (minsize=5). Commit aborted!" 1>&2
    exit 1
fi

exit 0
EOF

rm -rf $dir_rand
