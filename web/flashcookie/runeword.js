/*
 * Author: Lostsnow
 * E-mail: lostsnow@gmail.com
 */

var Runeword = {};
Runeword.$ = function(id){
    var el = document.getElementById(id);
    return el;
}

Runeword.ready = function(f){
    var ie  = !!(window.attachEvent && !window.opera);
    var wk  = /webkit\/(\d+)/i.test(navigator.userAgent) && (RegExp.$1 < 525);
    var fn  = [];
    var run = function () { for (var i = 0; i < fn.length; i++) fn[i](); };
    var d   = document;

    if (!ie && !wk && d.addEventListener)
        return d.addEventListener('DOMContentLoaded', f, false);
    if (fn.push(f) > 1) return;
    if (ie)
        (function(){
            try { d.documentElement.doScroll('left'); run(); }
            catch (err) { setTimeout(arguments.callee, 0); }
        })();
    else if (wk)
        var t = setInterval(function () {
            if (/^(loaded|complete)$/.test(d.readyState))
                clearInterval(t), run();
        }, 0);
};

Runeword.fcache = {
    flashid: 'fcache',
    flashDom: 'fcache_dom',
    flashFile: './fcache.swf',
    checkjsFunc: 'Runeword.fcache.checkJS',
    handlerFunc: 'Runeword.fcache.handleJS',

    _bind: function () {
        var str = '<object id="' + this.flashid + '_ob" name="player" classid="clsid:d27cdb6e-ae6d-11cf-96b8-444553540000" codebase="http://fpdownload.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=9,0,0,0"' + ' width="1" height="1" align="middle">' + '<param name="allowScriptAccess" value="always" />' + '<param name="movie" value="' + this.flashFile + '" />' + '<param name="quality" value="high" />' + '<param name="allowFullScreen" value="true" />' + '<param name="wmode" value="window" />' + '<param name="flashvars" value="checkjsready=' + this.checkjsFunc + '&handler=' + this.handlerFunc + '" />' + '<embed id="' + this.flashid + '_em" name="player" src="' + this.flashFile + '"' + ' flashvars="checkjsready=' + this.checkjsFunc + '&handler=' + this.handlerFunc + '" quality="high"' + ' width="1" height="1" align="middle" allowScriptAccess="always" allowFullScreen="true" wmode="window" type="application/x-shockwave-flash" pluginspage="http://www.macromedia.com/go/getflashplayer">' + '</embed></object>';
        var dom = Runeword.$(this.flashDom);
        if (dom) {
            dom.innerHTML = str;
        }
    },
    _getFlash: function () {
        var flash = null;
        if (!Runeword.$(this.flashid + '_em') && !Runeword.$(this.flashid + '_ob')) {
            this._bind();
        }
        if (Runeword.$(this.flashid + '_em')) {
            flash = Runeword.$(this.flashid + '_em');
        } else {
            flash = Runeword.$(this.flashid + '_ob');
        }
        return flash;
    },

    init: function () {
        this._bind();
    },
    get: function (key) {
        var flash = this._getFlash();
        if (flash) {
            try {
                return flash.get(key);
            } catch (e) {
//                alert('GET: ERROR');
                return null;
            }
        } else {
            return null;
        }
    },
    set: function (key, value) {
        var flash = this._getFlash();
        if (flash) {
            try {
//                flash.remove(key);
                flash.set(key, value);
            } catch (e) {
//                alert('SET: ERROR');
            }
        }
    },
    remove: function(key){
        var flash = this._getFlash();
        if (flash) {
            try {
                flash.remove(key);
            } catch (e) {
//                alert('DEL: ERROR');
                flash.setCache(key, '');
            }
        }
    },

    checkJS: function () {
        return true;
    },
    handleJS: function () {
//        alert('test');
    }
};

Runeword.cookie = {
    get: function (name) {
        var tmp, reg = new RegExp("(^| )" + name + "=([^;]*)(;|$)", "gi");
        if (tmp = reg.exec(unescape(document.cookie))) return (tmp[2]);
        return null;
    },
    set: function (name, value, expires, path, domain) {
        var str = name + "=" + escape(value);
        if (expires) {
            if (expires == 'never') {
                expires = 100 * 365 * 24 * 60;
            }
            var exp = new Date();
            exp.setTime(exp.getTime() + expires * 60 * 1000);
            str += "; expires=" + exp.toGMTString();
        }
        if (path) {
            str += "; path=" + path;
        }
        if (domain) {
            str += "; domain=" + domain;
        }
        document.cookie = str;
    },
    remove: function (name, path, domain) {
        document.cookie = name + "=" + ((path) ? "; path=" + path : "") + ((domain) ? "; domain=" + domain : "") + "; expires=Thu, 01-Jan-70 00:00:01 GMT";
    }
};