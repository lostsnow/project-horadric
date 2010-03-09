#coding=utf-8

# sort large file used by python 2.6 & 3.x
# based on Recipe 466302: Sorting big files the Python 2.4 way
# by Nicolas Lehuen

import os
import sys
from tempfile import gettempdir
from itertools import islice, cycle
from collections import namedtuple
import heapq

Keyed = namedtuple("Keyed", ["key", "obj"])

def merge(key=None, *iterables):
    # based on code posted by Scott David Daniels in c.l.p.
    # http://groups.google.com/group/comp.lang.python/msg/484f01f1ea3c832d

    if key is None:
        keyed_iterables = iterables
    else:
        keyed_iterables = [(Keyed(key(obj), obj) for obj in iterable)
                            for iterable in iterables]
    for element in heapq.merge(*keyed_iterables):
        yield element.obj


def batch_sort(input, output, key=None, buffer_size=32000, tempdirs=None):
    if tempdirs is None:
        tempdirs = []
    if not tempdirs:
        tempdirs.append(gettempdir())

    chunks = []
    try:
        with open(input,'rb',64*1024) as input_file:
            input_iterator = iter(input_file)
            for tempdir in cycle(tempdirs):
                current_chunk = list(islice(input_iterator,buffer_size))
                if not current_chunk:
                    break
#                # test for python3.x, current_chunk's item is type of bytes not str
#                for line in current_chunk:
#                    print(type(line))

                current_chunk.sort(key=key)
                output_chunk = open(os.path.join(tempdir,'%06i'%len(chunks)),'w+b',64*1024)
                chunks.append(output_chunk)
                output_chunk.writelines(current_chunk)
                output_chunk.flush()
                output_chunk.seek(0)
        with open(output,'wb',64*1024) as output_file:
            output_file.writelines(merge(key, *chunks))
    finally:
        for chunk in chunks:
            try:
                chunk.close()
                os.remove(chunk.name)
            except Exception:
                pass

if __name__ == '__main__':
    import optparse
    import time

    st = time.time()
    parser = optparse.OptionParser(usage = sys.argv[0] + \
          " [OPTION...] [source_file] [target_file]",
          version = "WizLog - version 0.1")
    parser.add_option(
        '-b','--buffer',
        dest='buffer_size',
        type='int',default=32000,
        help='''Size of the line buffer. The file to sort is
            divided into chunks of that many lines. Default : 32,000 lines.'''
    )
    parser.add_option(
        '-k','--key',
        dest='key',
        help='''Python expression used to compute the key for each
            line, "lambda line:" is prepended.\n
            Example : -k "line[5:10]". By default, the whole line is the key.'''
    )
    parser.add_option(
        '-t','--tempdir',
        dest='tempdirs',
        action='append',
        default=[],
        help='''Temporary directory to use. You might get performance
            improvements if the temporary directory is not on the same physical
            disk than the input and output directories. You can even try
            providing multiples directories on differents physical disks.
            Use multiple -t options to do that.'''
    )
    parser.add_option(
        '-p','--psyco',
        dest='psyco',
        action='store_true',
        default=False,
        help='''Use Psyco.'''
    )
    options,args = parser.parse_args()

#    if options.key:
#        options.key = eval('lambda line : (%s)'%options.key)

    if options.psyco:
        try:
            import psyco
            psyco.full()
        except ImportError:
            pass

    if sys.version_info[0] == 3:
        # for python3.x, convert bytes to str (line)
        options.key = lambda line : (line.decode().split(' ')[1].strip("'"), line.decode().split(' ')[2].strip("'"),
                                     line.decode().split(' ')[7].strip("'"), line.decode().split(' ')[6].strip("'"))
    elif sys.version_info[0] == 2 and sys.version_info[1] == 6:
        options.key = lambda line : (line.split(' ')[1].strip("'"), line.split(' ')[2].strip("'"),
                                     line.split(' ')[7].strip("'"), line.split(' ')[6].strip("'"))
    else:
        raise Exception("this script only sopport python 2.6.x & 3.x")

#    l = """'' 'bar2' 'E2520A0A9155564BA2746867020E935E' '221.233.20.38' 'CN42' 'news.sohu.com/s2009/contenta/' '20100120090002' '1263949054727' '' '' '' '' 'e ' ''"""

    batch_sort(args[0],args[1],options.key,options.buffer_size,options.tempdirs)

    et = time.time()
    print(str(et-st))
