package
{
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.TimerEvent;
    import flash.net.SharedObject;
    import flash.system.Security;
    import flash.external.ExternalInterface;
    import flash.utils.Timer;

    public class Fcache extends Sprite {

        Security.allowDomain("*"); // modifiy this domain
        private const storageName:String = "analydata";

        public function Fcache() {
            addExternalInterface();
        }

        private function addExternalInterface():void {
            function set(key:String, val:String = ""):void {
                var sobj:SharedObject = SharedObject.getLocal(storageName, "/", false);
                sobj.data[key] = val;
				trace('setting.....', key, val);
                sobj.flush();
            }

            function get(key:String):String{
                var sobj:SharedObject = SharedObject.getLocal(storageName, "/", false);
				trace('getting.....', key);
                return(sobj.data[key]);
            }

            function remove(key:String):void{
                var sobj:SharedObject = SharedObject.getLocal(storageName, "/", false);
                delete sobj.data[key];
				trace('removing.....', key);
                sobj.flush();
            }

            function isJavaScriptReady():Boolean {
				trace('check jsIsReady');
                var jsIsReady = stage.loaderInfo.parameters.checkjsready;
                if (!jsIsReady) {
                    jsIsReady = 'isJSReady';
                }
                var isReady:Boolean = ExternalInterface.call(jsIsReady);
                return isReady;
            }

            function jsReadyHandler():void {
                trace("javascript js ready");
                var Handler = stage.loaderInfo.parameters.handler;
                if (!Handler) {
                    Handler = 'flashReadyHandler';
                }
                ExternalInterface.addCallback("set", set);
                ExternalInterface.addCallback("get", get);
                ExternalInterface.addCallback("remove", remove);
                ExternalInterface.call(Handler);
            }

            if (ExternalInterface.available) {
                try {
                    if (isJavaScriptReady()) {
                        jsReadyHandler();
                    } else {
                        var timerReady:Timer = new Timer(100, 0);
                        timerReady.addEventListener(TimerEvent.TIMER, function(evt:TimerEvent):void {
                            trace("checking...");
                            if (isJavaScriptReady()) {
                                Timer(evt.target).stop();
                                jsReadyHandler();
                            }
                        });
                        timerReady.start();
                    }
                } catch (err:SecurityError) {
                    trace(err.message);
                } catch (err:Error) {
                    trace(err.message);
                }
            }
        }
    }
}
