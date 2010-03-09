#coding=utf-8
#
# project wiznmp
# Author: lostsnow <lostsnow@gmail.com>
#
# $Id$

import os
import sys
import shutil
import optparse
import conf

def main(conf_data):
    tmpl_file = 'conf/php-fpm.conf.tmpl'

    cf = conf.Conf(tmpl_file, conf_data)
    return cf.render()

if __name__ == '__main__':
    parser = optparse.OptionParser(usage = sys.argv[0] + \
             " [OPTION...]",
             version = conf.Version())
    parser.add_option(
        '-p', '--phpdir',
        dest = 'php_dir',
        default = '/usr/local/php',
        help = '''nginx install directory.'''
    )

    parser.add_option(
        '-l', '--logdir',
        dest = 'log_dir',
        default = '/var/log/nginx',
        help = '''nginx log directory.'''
    )

    parser.add_option(
        '-c', '--children',
        dest = 'children',
        default = 128,
        help = '''web root directory.'''
    )
    options, args = parser.parse_args()
#    try:
#        output_dir = args[0]
#    except:
    output_dir = 'fpm_conf'
    if os.path.exists(output_dir):
        shutil.rmtree(output_dir)

    conf_data = {'fpm_pid_path' : options.php_dir + '/logs/php-fpm.pid',
                 'fpm_log_path' : options.log_dir + '/php-fpm.log',
                 'ngx_php_socket' : True,
                 'fpm_max_children' : options.children}
    mcontent = main(conf_data)

    os.makedirs(output_dir)
    conf.store(output_dir + '/php-fpm.conf', mcontent)