package ;

import com.wighawag.p2p.MessageWrap;
import com.wighawag.p2p.ButtonPanelController;
import com.wighawag.p2p.AccelerometerController;
import com.wighawag.p2p.P2PGroupConnection;
import flash.display.StageScaleMode;
import flash.display.StageAlign;
import flash.display.Sprite;
import flash.events.AccelerometerEvent;
import flash.Lib;
import flash.sensors.Accelerometer;
import flash.text.TextField;
import flash.text.TextFieldType;
import flash.text.TextFieldAutoSize;
import haxe.Timer;

import flash.events.Event;
import flash.events.MouseEvent;

#if desktop
import flash.filesystem.File;
import flash.desktop.NativeApplication;
import flash.desktop.SystemIdleMode;
import flash.events.InvokeEvent;
import flash.events.KeyboardEvent;
import flash.ui.Keyboard;
#end

import flash.ui.Multitouch;
import flash.ui.MultitouchInputMode;

class Main 
{
	#if desktop
	static function main()  : Void {
		var app = NativeApplication.nativeApplication;
		app.addEventListener(InvokeEvent.INVOKE, onInvoked);
	}
	private static function onInvoked(e : InvokeEvent)  : Void {
	    NativeApplication.nativeApplication.addEventListener(Event.ACTIVATE, handleActivate, false, 0, true);
		NativeApplication.nativeApplication.addEventListener(Event.DEACTIVATE, handleDeactivate, false, 0, true);
		NativeApplication.nativeApplication.addEventListener(KeyboardEvent.KEY_DOWN, handleKeys, false, 0, true);

		ready();
	}

	private static function handleActivate(event:Event):Void{
        NativeApplication.nativeApplication.systemIdleMode = SystemIdleMode.KEEP_AWAKE;
    }

    private static function handleDeactivate(event:Event):Void{
        NativeApplication.nativeApplication.exit();
    }

    private static function handleKeys(event:KeyboardEvent):Void{
        if(event.keyCode == Keyboard.BACK)
            NativeApplication.nativeApplication.exit();
        else if(event.keyCode == Keyboard.HOME)
            NativeApplication.nativeApplication.exit();
    }

	#else
	static function main()  : Void {
		ready();
	}
	#end
	
	private static var log : TextField;
	
	static function ready() : Void {
        Multitouch.inputMode=MultitouchInputMode.TOUCH_POINT;
        Lib.current.stage.align = StageAlign.TOP_LEFT;
        Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;

		log = new TextField();
        haxe.Log.trace = new Logger(log).handleTrace;
		log.y = 70;
		log.mouseEnabled = false;
		log.multiline = true;
		log.autoSize = TextFieldAutoSize.LEFT;
		log.selectable = false;
		log.type = TextFieldType.DYNAMIC;
		Lib.current.addChild(log);
		var main = new Main();
		main.checkRemoteDevice();
	}
	
	private var p2pConnection : P2PGroupConnection;
	private var timer : Timer;
    private var accel : AccelerometerController;
	private var accelText : TextField;
    private var buttonPanel : ButtonPanelController;
	
	public function new() {
		accelText = new TextField();
		accelText.mouseEnabled = false;
		accelText.multiline = true;
		accelText.autoSize = TextFieldAutoSize.LEFT;
		accelText.selectable = false;
		accelText.type = TextFieldType.DYNAMIC;
		Lib.current.addChild(accelText);
	}
	
	private function deviceConnected() : Void {
        if (timer != null){
            timer.stop();
        }
		timer = null;
		accel = new AccelerometerController(p2pConnection);
        accel.onDataSent.add(function(data : Dynamic):Void{
            accelText.text = "" + data.x +"\n"+ data.y+",\n" + data.z;
        });
        accel.start();

        p2pConnection.onMessageReceived.add(function(wrap : MessageWrap, info : Dynamic):Void{
            Report.anInfo("Main", wrap.messageType, wrap.message, wrap.timestamp);
            if(info.fromLocal == true){
                // We have reached final destination
                //trace("Received Message: "+event.info.message.value);
            }else{
                // Forwarding
                //	netGroup.sendToNearest(e.info.message, e.info.message.destination);
            }
        });

        buttonPanel = new ButtonPanelController(p2pConnection, Lib.current.stage);
        buttonPanel.start();
	}

	private function deviceDisconnected() : Void {
		if (accel != null) {
			accel.stop();
		}
        if (buttonPanel != null) {
            buttonPanel.stop();
        }
		if (timer != null) {
			timer.stop();
		}
		timer = new Timer(5000);
		timer.run = checkRemoteDevice;
	}
	
	private function checkRemoteDevice() : Void {
		p2pConnection = new P2PGroupConnection("dddd");
		p2pConnection.onConnect.add(deviceConnected);
		p2pConnection.onConnectionClosed.add(deviceDisconnected);
        p2pConnection.connect();
	}

	
}