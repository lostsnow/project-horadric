package 
{
    import flash.display.Sprite;
    import adobe.utils.CustomActions;
    import flash.display.*;
    import flash.events.*;
    import flash.text.TextField;
    import flash.utils.Timer;
    import flash.external.ExternalInterface;
    import flash.system.System;
	import flash.display.MovieClip;

    public class clipboard extends Sprite 
    {
        public function clipboard():void {
            stage.scaleMode = StageScaleMode.NO_SCALE;
            init();
        }
        
        private function init():void {
			var txt:TextField = new TextField();
			txt.text = '';
			txt.selectable = false;
            txt.addEventListener(MouseEvent.CLICK, clickHandler);
            addChild(txt);
        }
        
        private function clickHandler(evt:Event):void {
			var content:String = stage.loaderInfo.parameters.data || '';
            System.setClipboard(content);
			var callback:String = stage.loaderInfo.parameters.callback || 'copySuccess';
            ExternalInterface.call(callback);
        }
    }
    
}