#coding=utf-8
#!/usr/bin/python
import urllib, urllib2

def urlencode(str) :
    reprStr = repr(str).replace(r'\x', '%')
    return reprStr[1:-1]

# nyear3: 年
nyear3 = '2011'
# nmonth3: 月
nmonth3 = '01'
# nday3: 日
nday3 = '29'
# 车类型: 动车直达特快等. ('tFlagDC','DC'), ('tFlagZ','Z'), ('tFlagT','T'), ('tFlagK','K'), ('tFlagPK','PK'), ('tFlagPKE','PKE'), ('tFlagLK','LK')

# TODO: 车站编码转换
start = '53174e1300bdb6a1'
to = '6cf05cce03d6b2e0'

url = 'http://dynamic.12306.cn/TrainQuery/iframeLeftTicketByStation.jsp'
tu = [('lx','00'), ('nyear3',nyear3), ('nyear3_new_value','true'), ('nmonth3',nmonth3), ('nmonth3_new_value','true'),
('nday3',nday3), ('nday3_new_value','false'), ('startStation_ticketLeft',start),
('startStation_ticketLeft_new_value','false'), ('trainCode',''), ('trainCode_new_value','true'),
('rFlag','1'), ('arriveStation_ticketLeft',to), ('arriveStation_ticketLeft_new_value','false'),
('fdl', 'fdl'), ('ictQ', '7362'), ('tFlagDC','DC')]
parameters = dict(tu)
data = urllib.urlencode(parameters)    # Use urllib to encode the parameters
request = urllib2.Request(url, data)
request.add_header('User-Agent','Mozilla/5.0')
request.add_header('Referer', 'http://dynamic.12306.cn/TrainQuery/leftTicketByStation.jsp')
response = urllib2.urlopen(request)    # This request is sent in HTTP POST
page = response.read(2000000)
print page


# 显示数据
# python /var/www/py/ticket.py | grep -v "//" | grep addRow |awk -F, 'BEGIN{OFS="\t| "; print "车次信息\t\t| 发车时间\t| 到达时间\t| 历时\t| 硬座\t| 软座\t| 硬卧\t| 软卧\t| 特等\t| 一等\t| 二等\t| 高软\t| 无座"} {name=substr($3, 1, index($3, "^")-1); print name, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17}'
