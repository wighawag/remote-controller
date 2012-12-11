package  com.wighawag.p2p;

import flash.events.AccelerometerEvent;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.NetStatusEvent;
import flash.net.GroupSpecifier;
import flash.net.NetConnection;
import flash.net.NetGroup;
import msignal.Signal;

class RemoteDeviceController {
	
	private var localNc:NetConnection;
	private var group:NetGroup;	
	private var connected:Bool = false;
	private var groupPin:String;
	public var onConnect(default, null) : Signal0;	
	public var onConnectionClosed(default, null) : Signal0;	

	public function new(groupPin : String){ 
		this.groupPin = groupPin;
		onConnect = new Signal0();
		onConnectionClosed = new Signal0();
	}
	
	public function connect():Void{
		localNc = new NetConnection();
		localNc.addEventListener(NetStatusEvent.NET_STATUS, netStatus);
		localNc.connect("rtmfp:");
	}
	
	public function close():Void{
		localNc.close();
		connected = false;
	}
	
	private function netStatus(event:NetStatusEvent):Void{
		Report.anInfo("Controller", event.info.code);
		switch(event.info.code){
			case "NetConnection.Connect.Success":
				setupGroup();
				
			
			case "NetGroup.Connect.Success":
				connected = true;
				onConnect.dispatch();
				
			
			case "NetConnection.Connect.Closed":
				connected = false;
				onConnectionClosed.dispatch();
				
			
			case "NetGroup.SendTo.Notify":
                Report.anInfo("Controller", event.info.message.timestamp, event.info.message.x, event.info.message.y, event.info.message.z);
				if(event.info.fromLocal == true){
					// We have reached final destination
					//trace("Received Message: "+event.info.message.value);
				}else{
					// Forwarding
				//	netGroup.sendToNearest(e.info.message, e.info.message.destination);
				}
				
		}
	}
	
	private function setupGroup():Void{
		var groupspec:GroupSpecifier = new GroupSpecifier("LocalDeviceControllers/PIN" + groupPin);
		groupspec.serverChannelEnabled = true;
		groupspec.multicastEnabled = true;
		groupspec.ipMulticastMemberUpdatesEnabled = true;
		groupspec.routingEnabled = true;
		groupspec.postingEnabled = true;
		groupspec.addIPMulticastAddress("225.225.0.1:30303");

		group = new NetGroup(localNc, groupspec.groupspecWithAuthorizations());
		group.addEventListener(NetStatusEvent.NET_STATUS,netStatus);

	}
	
	public function sendData(data:Dynamic):Void{
		if(connected){
            data.timestamp = haxe.Timer.stamp();
			group.sendToAllNeighbors(data);
		}          
	}
	
}
