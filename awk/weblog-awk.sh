#!/bin/bash
D3=`date '+%H%M%S'`
echo $D3
#source_file = "/opt/tmp/log/200910.log"
#target_file = "/opt/tmp/log/200910.txt"

# log format
# [123.234.129.167] [-] [16/Oct/2009:16:00:01 +0800] [GET /?url=go.sohu.com/lenovoV450/index.php&pagename=null&a_vars[uid]=Saab&a_vars[pid]=Volvo&a_vars[key]=BMW&id=lenovoV450&res=1280x1024&col=32&localtime=1255680029859&flash=1&director=0&quicktime=0&realplayer=0&pdf=0&windowsmedia=1&java=1&os=WinXP&browser=Microsoft%20Internet%20Explorer&b_version=4&type=current&ref=yangtian.lenovo.com/promotions/battle-ax-new/index.html HTTP/1.1] [200] [31] [http://go.sohu.com/lenovoV450/index.php] [Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1) ; CIBA; .NET CLR 2.0.50727; 360SE)] [-] [CN370200] [-] [uid=4483873D0128D84AE5482B8A02242804]
# to format
# 'lenovoV450' '4483873D8E0CCE4AE348808902F1D703' '' '1024x768' '16' '1' '0' '0' '0' '1' '1' '0' 'WinXP' 'Microsoft%20Internet%20Explorer' '4' '202.101.160.154' 'CN33' 'go.sohu.com/lenovoV450/index.php' '' 'yangtian.lenovo.com/promotions/battle-ax-new/index.html%3FngAdID%3D41301' '' '' '20091009000014' '1255017612079' '' '' '' 'current' 

#here is log process for each hour
awk -F[ \
'BEGIN{ORS = "";months["Jan"]="01";months["Feb"]="02";months["Mar"]="03";months["Apr"]="04"; \
months["May"]="05";months["Jun"]="06";months["Jul"]="07";months["Aug"]="08";months["Sep"]="09"; \
months["Oct"]="10";months["Nov"]="11";months["Dec"]="12";} \
{if(substr($11,1,4) ~ /[CNcn][0-9][0-9]/)state=substr($11,1,4);else{state="unkn";} \
if(substr($12,1,3) == "uid")uid=substr($12,5,32);else{uid=substr($13,5,32);} \
para=substr($5,7,length($5)-17); \
ip=substr($2,1,length($2)-2); \
d=substr($4,8,4)months[substr($4,4,3)]substr($4,1,2)substr($4,13,2)substr($4,16,2)substr($4,19,2); \
data["id"] = ""; \
data["res"] = ""; \
data["col"] = ""; \
data["flash"] = ""; \
data["quicktime"]=""; \
data["realplayer"]=""; \
data["pdf"] = ""; \
data["windowsmedia"] = ""; \
data["java"] = ""; \
data["director"] = ""; \
data["os"]=""; \
data["browser"]=""; \
data["b_version"] = ""; \
data["url"] = ""; \
data["ref"] = ""; \
data["localtime"] = ""; \
data["gotourl"]=""; \
data["coordinatex"]=""; \
data["coordinatey"]=""; \
data["type"]=""; \
split(para, param, "&");print "\47""\47", "";for (key in param) {split(param[key], p, "="); \
if (p[1] in data) {data[p[1]] = p[2];}} \
print "\47"data["id"]"\47", \
"\47"uid"\47", \
"\47""\47", \
"\47"data["res"]"\47", \
"\47"data["col"]"\47", \
"\47"data["flash"]"\47", \
"\47"data["quicktime"]"\47", \
"\47"data["realplayer"]"\47", \
"\47"data["pdf"]"\47", \
"\47"data["windowsmedia"]"\47", \
"\47"data["java"]"\47", \
"\47"data["director"]"\47", \
"\47"data["os"]"\47", \
"\47"data["browser"]"\47", \
"\47"data["b_version"]"\47", \
"\47"ip"\47", \
"\47"state"\47", \
"\47"data["url"]"\47", \
"\47""\47", \
"\47"data["ref"]"\47", \
"\47""\47", \
"\47""\47", \
"\47"d"\47", \
"\47"data["localtime"]"\47", \
"\47"data["gotourl"]"\47", \
"\47"data["coordinatex"]"\47", \
"\47"data["coordinatey"]"\47", \
"\47"data["type"]"\47", \
"";print "\n";}' /opt/tmp/log/nginx.log > /opt/tmp/log/tablename.txt


D3=`date '+%H%M%S'`
echo $D3

mysqlimport -h127.0.0.1 -udbuser -ppasswd --fields-terminated-by=" "  --fields-enclosed-by="'" dbname --local /opt/tmp/log/tablename.txt

D3=`date '+%H%M%S'`
echo $D3

#2,806,340