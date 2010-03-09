#coding=utf-8
#
# project wiznmp
# Author: lostsnow <lostsnow@gmail.com>
#
# $Id$

__appname__ = 'Wiznmp'
__author__ = 'lostsnow'

from mako.template import Template
from mako.runtime import Context
from StringIO import StringIO

class Conf:
    def __init__(self, tmpl_file, conf_data=None):
        self.tmpl_file = tmpl_file
        self.conf_data = conf_data

    def render(self):
        mytemplate = Template(filename=self.tmpl_file)
        buf = StringIO()
        ctx = Context(buf, data=self.conf_data)
        mytemplate.render_context(ctx)
        return buf.getvalue().strip('\n')

def store(path_file, content):
    f = file(path_file, 'w')
    f.write (content)
    f.close()

def Version():
    import version

    return """%s - version: %s""" % (__appname__, version.version)

if __name__ == '__main__':
    tmpl_file = 'conf/nginx.conf.tmpl'
    conf_data = {'ngx_worker_num' : 8, 'ngx_errlog_path' : '/var/log/nginx/error.log',
                 'ngx_pid_path' : '/usr/local/nginx/nginx.pid',
                 'ngx_accesslog_path' : '/var/log/nginx/access.log',
                 'ngx_conf_path' : '/usr/local/nginx/conf'}
    cf = Conf(tmpl_file, conf_data)
    print(cf.render())
