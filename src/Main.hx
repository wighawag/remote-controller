package ;

import flash.display.StageScaleMode;
import flash.display.StageAlign;
import flash.display.Sprite;
import com.wighawag.p2p.RemoteDeviceController;
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

class Main 
{
	private static function handleTrace(severity: Dynamic, ?posInfos : haxe.PosInfos ) {
        var channel = "";
        var extraParams = "";
        if (posInfos.customParams != null && posInfos.customParams.length > 0){
            channel = " {" + posInfos.customParams[0] + "}";

            for (i in 1...posInfos.customParams.length){
                var extraComma = ", ";
                if (i==1){
                    extraComma = " : ";
                }
                extraParams += extraComma + posInfos.customParams[i];
            }

        }

        var message : String = severity  + channel + extraParams;

        #if flash
			#if desktop
			log.appendText(message + "\n");
			#else
			log.appendText(message + "\n");//flash.Lib.trace(message);
			#end
		#elseif cpp
		    cpp.Lib.println(message);
		#else
            //trace(value, posInfos);
        #end
    }
	
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
        Lib.current.stage.align = StageAlign.TOP_LEFT;
        Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;
        //Lib.current.stage.allowsFullScreen = true;
        haxe.Log.trace = handleTrace;
		log = new TextField();
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
	
	private var remoteDeviceController : RemoteDeviceController;
	private var accel : Accelerometer;
	private var timer : Timer;
	private var accelText : TextField;
	
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
		if (Accelerometer.isSupported) {
			accel = new Accelerometer();
			accel.setRequestedUpdateInterval(20);
			accel.addEventListener(AccelerometerEvent.UPDATE, accelUpdate);
		}else {
			// debug purpose
			timer = new Timer(1000);
			timer.run = function():Void { remoteDeviceController.sendData( { x:1, y:1, z:1 } ); };
		}
		
	}
	
	function accelUpdate(event:AccelerometerEvent):Void {
			accelText.text = "" + event.accelerationX +"\n"+ event.accelerationY+",\n" + event.accelerationZ;
			remoteDeviceController.sendData( { x:-event.accelerationY, y:event.accelerationX, z:event.accelerationZ } );
	}
	
	private function deviceDisconnected() : Void {
		if (accel != null) {
			accel.removeEventListener(AccelerometerEvent.UPDATE, accelUpdate);
			accel = null;
		}
		if (timer != null) {
			timer.stop();
		}
		timer = new Timer(5000);
		timer.run = checkRemoteDevice;
	}
	
	private function checkRemoteDevice() : Void {
		remoteDeviceController = new RemoteDeviceController("dddd");
		remoteDeviceController.onConnect.add(deviceConnected);
		remoteDeviceController.onConnectionClosed.add(deviceDisconnected);
        remoteDeviceController.connect();
	}

	
}