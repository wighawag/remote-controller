package ;

import com.wighawag.p2p.P2PGroupConnection;
import com.wighawag.p2p.MessageWrap;
import com.wighawag.p2p.Lobby;
import com.wighawag.controller.ButtonPanelController;
import com.wighawag.controller.AccelerometerController;
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

#if air
import flash.filesystem.File;
import flash.desktop.NativeApplication;
import flash.desktop.SystemIdleMode;
import flash.events.InvokeEvent;
import flash.events.KeyboardEvent;
import flash.ui.Keyboard;
#end

import flash.ui.Multitouch;
import flash.ui.MultitouchInputMode;

class ControllerMain 
{
	#if air
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
		//log.autoSize = TextFieldAutoSize.LEFT;
        log.height = Lib.current.stage.stageHeight - 70;
        log.width = Lib.current.stage.stageWidth;
		log.selectable = false;
		log.type = TextFieldType.DYNAMIC;
		Lib.current.addChild(log);
		var main = new ControllerMain();
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
        if(Lib.current.stage == null){
            Lib.current.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
        }else{
            onAddedToStage();
        }

	}

    private function onAddedToStage(?event : Event = null) : Void{
        connectToLobbyGroup();
	    Report.anInfo("Main", "added to stage");
    }
	
	private function deviceConnected() : Void {

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


        var lobby = new Lobby(p2pConnection);
        lobby.waitForRequest().then(onPrivateChannelEstablished);
	}

    private function onPrivateChannelEstablished(p2pConnection : P2PGroupConnection) : Void{
        accel = new AccelerometerController(p2pConnection);
        accel.onDataSent.add(function(data : Dynamic):Void{
            accelText.text = "" + data.x +"\n"+ data.y+",\n" + data.z;
        });
        accel.start();

	    p2pConnection.onConnectionClosed.addOnce(deviceDisconnected);

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

		connectToLobbyGroup();
	}
	
	private function connectToLobbyGroup() : Void {
		p2pConnection = new P2PGroupConnection("dddd");
		p2pConnection.onConnect.addOnce(deviceConnected);
        p2pConnection.connect();
	}

}