import sys
import os
#from shutil import copytree
#from os.path import join, dirname
from os.path import join, dirname
from shutil import copy2, copystat

import stat
#from os.path import abspath
import fnmatch

class Error(EnvironmentError):
    pass


# http://bugs.python.org/file10417/copytree.patch
def ignore_patterns(*patterns):
    """Function that can be used as copytree() ignore parameter.
    Patterns is a sequence of glob-style patterns
    that are used to exclude files"""
    def _ignore_patterns(path, names):
        ignored_names = []
        for pattern in patterns:
            ignored_names.extend(fnmatch.filter(names, pattern))
        return set(ignored_names)
    return _ignore_patterns


def copytree_ig(src, dst, symlinks=False, ignore=None):
    """Recursively copy a directory tree using copy2().

    The destination directory must not already exist.
    If exception(s) occur, an Error is raised with a list of reasons.

    If the optional symlinks flag is true, symbolic links in the
    source tree result in symbolic links in the destination tree; if
    it is false, the contents of the files pointed to by symbolic
    links are copied.

    The optional ignore argument is a callable. If given, it
    is called with the `src` parameter, which is the directory
    being visited by copytree(), and `names` which is the list of
    `src` contents, as returned by os.listdir():

        callable(src, names) -> ignored_names

    Since copytree() is called recursively, the callable will be
    called once for each directory that is copied. It returns a
    list of names relative to the `src` directory, of elements
    that will not be copied.

    XXX Consider this example code rather than the ultimate tool.

    """
    names = os.listdir(src)
    if ignore is not None:
        ignored_names = ignore(src, names)
    else:
        ignored_names = set()

    os.makedirs(dst)
    errors = []
    for name in names:
        if name in ignored_names:
            continue
        srcname = os.path.join(src, name)
        dstname = os.path.join(dst, name)
        try:
            if symlinks and os.path.islink(srcname):
                linkto = os.readlink(srcname)
                os.symlink(linkto, dstname)
            elif os.path.isdir(srcname):
                copytree_ig(srcname, dstname, symlinks, ignore)
            else:
                copy2(srcname, dstname)
            # XXX What about devices, sockets etc.?
        except (IOError, os.error), why:
            errors.append((srcname, dstname, str(why)))
        # catch the Error from the recursive copytree so that we can
        # continue with other files
        except Error, err:
            errors.extend(err.args[0])
    try:
        copystat(src, dst)
    except OSError, why:
        if WindowsError is not None and isinstance(why, WindowsError):
            # Copying file access times may fail on Windows
            pass
        else:
            errors.extend((src, dst, str(why)))
    if errors:
        raise Error, errors

#def copy_directory(source, target):
#    if not os.path.exists(target):
#        os.mkdir(target)
#    for root, dirs, files in os.walk(source):
#        if '.svn' in dirs:
#            dirs.remove('.svn')  # don't visit .svn directories
#        for file in files:
#            if splitext(file)[-1] in ('.pyc', '.pyo', '.fs'):
#                continue
#            from_ = join(root, file)
#            to_ = from_.replace(source, target, 1)
#            to_directory = split(to_)[0]
#            if not exists(to_directory):
#                os.makedirs(to_directory)
#            copyfile(from_, to_)

PREFIX = dirname(__file__)


def ignore_new(dirname, filelist):
    ignore = []
    for i in filelist:
        if i == ".svn" or i.endswith(".pyc"):
            ignore.append(i)
    return ignore

def runcmd(argv):
    len_argv = len(argv)
    if not argv:
        return
    cmd = argv[0]
    if cmd == "new":
        if len_argv >= 2:
            name = argv[1]
            t = join(PREFIX, "project_template")
            copytree_ig(t, name, ignore=ignore_new)
#            copy_directory(t, name)

runcmd(sys.argv[1:])
