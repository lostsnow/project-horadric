/*
 * CopyRight: Hanmei Team
 * Description: Hanmei Detecter
 */

var nTotalSelect = 0;
var softDownUrl = "http://mirror1.hanmei.com/_directory/";

function download(str, i, first)//多文件下载
{
    var btn = document.getElementsByName("button22");
    var a = document.getElementsByName(str);
    var n = a.length;
    var timeout = 300;

    if ( first == 1 )
    {
        //btn[0].disable = true;
        timeout = 1000;
        nTotalSelect = 0;

        for( var k=i; k<n; k++)
        {
            if (a[k].checked)
            {
                nTotalSelect++;
            }
        }
    }


    for (var k=i; k<n; k++)
    {
        if (a[k].checked)
        {
            a[k].checked = false;
            var ak_value = a[k].value;
            $content = ak_value.split('|');
            $link = "ssn://file|"+$content[2]+"|"+$content[1]+"|"+$content[0]+"/";
            if (!hmlinks($link + nTotalSelect + "/multi/")){
                 //btn[0].disaled = false;
                 //btn[1].disaled = false;
                 //btn[2].disaled = false;
                 return;
            }
            k++;
            window.setTimeout("download('"+str+"',"+k+",0)", timeout);
            return;
        }
      }

     //btn[0].disable = false;
}

// isOpenNewWindow 为false时直接转向, 否则弹窗
function ssnDownload(ssnObj, isOpenNewWindow)
{
    var ssnlink = ssnObj.getAttribute("ssnHref");
    var sRefPage = location.href;

    if (ssnlink.match(/^ssn:\/\/.*$/i))
    {
        var Huntmine = false;
        var dl_window;
        var agt = navigator.userAgent.toLowerCase();
        if (agt.indexOf('gecko') != -1)
        {
            try {
                window.location = ssnlink;
            }
            catch (e) {
                alert('下载该资源需安装huntmine软件,点击确定了解更多详情');
                if (isOpenNewWindow)
                {
                    dl_window = window.open(softDownUrl, 'dl_huntmine');
                    dl_window.focus();
                }
                else
                {
                    window.location = softDownUrl;
                }
                return false;
            }
        }
        else if (agt.indexOf('msie') != -1)
        {
            try {
                Huntmine = new ActiveXObject("HUNTMINE.Exist");
            }
            catch (e) {
                alert('下载该资源需安装huntmine软件,点击确定了解更多详情');
                if (isOpenNewWindow)
                {
                    dl_window = window.open(softDownUrl, 'dl_huntmine');
                    dl_window.focus();
                }
                else
                {
                    window.location = softDownUrl;
                }
                window.open(ssnlink);
                return false;
            }
            if (Huntmine)
                window.location = ssnlink;
        }
    }
    else 
    {
        if (isOpenNewWindow)
        {
            dl_window = window.open(ssnlink);
        }
        else
        {
            window.location = ssnlink;
        }
    }
    return true;
}

function ssnSetHref(ssnObj)
{
    var ssnDownloadURL = ssnObj.getAttribute("ssnHref");
    ssnObj.href = ssnDownloadURL;
}

function ssnUnsetHref(ssnObj)
{
    ssnObj.href = "javascript:;";
}

function hm_link_event_register()
{
    var hm_links = document.getElementsByTagName('A');
    var i = hm_links.length;
    while (i-- > 0)
    {
        if (hm_links.item(i).href.match(/^ssn:\/\/.*$/i))
        {
            hm_links.item(i).onclick = function(event)
            {
                var target;
                if (!event) event = window.event;
                if (!event.preventDefault)
                    event.returnValue = false;
                else
                    event.preventDefault();
                if (!event.target)
                    target = event.srcElement;
                else
                    target = event.target;
                while (target.nodeName != 'A')
                    target = target.parentNode;

                ssnDownload(target.href);
            }
        }
    }
}

function AddLinkToHM(Url, Location, Cookies)
{
    if (Url != "")
    {
        try
        {
            var hmAgent = new ActiveXObject("IE.HMUrlOptr.1");

            hmAgent.ClearAry();
            hmAgent.Init();

            hmAgent.CallHm_downloadFile(Url, Cookies, Location);

            delete hmAgent;
            hmAgent = null;
        }
        catch (e)
        {
            // 可能汉魅的IE.HMUrlOptr.1控件没有注册或者浏览器的安全设置阻止了控件的创建
            // TODO: 用浏览器打开Url 或者提示重新安装最新版汉魅
            window.location = Url;
        }
    }
}