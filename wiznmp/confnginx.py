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
    tmpl_file = 'conf/nginx.conf.tmpl'

    cf = conf.Conf(tmpl_file, conf_data)
    return cf.render()

def server(conf_data):
    tmpl_file = 'conf/nginx-server.tmpl'

    cf = conf.Conf(tmpl_file, conf_data)
    return cf.render()

def location(conf_data):
    tmpl_file = 'conf/nginx-location.tmpl'

    cf = conf.Conf(tmpl_file, conf_data)
    return cf.render()

if __name__ == '__main__':
    parser = optparse.OptionParser(usage = sys.argv[0] + \
             " [OPTION...]",
             version = conf.Version())
    parser.add_option(
        '-n', '--nginxdir',
        dest = 'nginx_dir',
        default = '/usr/local/nginx',
        help = '''nginx install directory.'''
    )

    parser.add_option(
        '-k', '--worker',
        dest = 'nginx_worker',
        default = 8,
        help = '''server domain'''
    )

    parser.add_option(
        '-l', '--logdir',
        dest = 'log_dir',
        default = '/var/log/nginx',
        help = '''nginx log directory.'''
    )

    parser.add_option(
        '-w', '--webdir',
        dest = 'web_dir',
        default = '/var/www',
        help = '''web root directory.'''
    )

    parser.add_option(
        '-d', '--domain',
        dest = 'domain',
        default = 'localhost',
        help = '''server domain'''
    )

    options, args = parser.parse_args()
#    try:
#        output_dir = args[0]
#    except:
    output_dir = 'ngx_conf_' + options.domain
    if os.path.exists(output_dir):
        shutil.rmtree(output_dir)

    lcontent = ''
#    conf_data = {
#        'ngx_location_title' : '/blog',
#        'ngx_location_content' : u'''# WordPress URL重写，如果你的wp目录不在根目录，请修改路径
#        if (!-e $request_filename) {
#            rewrite ^(.+)$ /blog/index.php?q=$1 last;
#        }'''
#    }
#    lcontent = location(conf_data)
#    lcontent2 = location(conf_data)
#    lcontent = lcontent + '\n\n' + lcontent2

    conf_data = {'ngx_srv_port' : 80, 'ngx_srv_name' : options.domain,
                 'ngx_srv_root' : options.web_dir, 'ngx_locations' : lcontent,
                 'ngx_location_php_enable' : True, 'ngx_php_socket' : True}
    scontent = server(conf_data)

    conf_data = {'ngx_worker_num' : options.nginx_worker, 'ngx_errlog_path' : options.log_dir + '/error.log',
                 'ngx_pid_path' : options.nginx_dir + '/nginx.pid',
                 'ngx_accesslog_path' : options.log_dir + '/access.log',
                 'ngx_conf_path' : options.nginx_dir + '/conf'}
    mcontent = main(conf_data)

    os.makedirs(output_dir + '/vhost')
    conf.store(output_dir + '/nginx.conf', mcontent)
    conf.store(output_dir + '/vhost/' + options.domain, scontent)
