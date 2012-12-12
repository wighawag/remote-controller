package com.wighawag.controller;
import flash.Lib;
import flash.events.KeyboardEvent;
import flash.events.AccelerometerEvent;
import haxe.Timer;
import flash.sensors.Accelerometer;
import msignal.Signal;
import com.wighawag.p2p.P2PGroupConnection;
class AccelerometerController {

    public static var DATA = "AccelerometerData";

    private var p2pConnection : P2PGroupConnection;
    private var accel : Accelerometer;
    public var onDataSent : Signal1<Dynamic>;
    private var timer : Timer;

    public function new(p2pConnection : P2PGroupConnection) {
        onDataSent = new Signal1();
        this.p2pConnection = p2pConnection;
    }

    private function accelUpdate(event:AccelerometerEvent):Void {
        // TODO check why we need the following transformation of coordinates:
        var data = {x : -event.accelerationY, y : event.accelerationX, z: event.accelerationZ};
        sendData(data);
    }

    private function sendData(data : Dynamic) : Void{
        onDataSent.dispatch(data);
        p2pConnection.sendData(data, DATA);
    }

    public function start() : Void{
        if (Accelerometer.isSupported) {
            accel = new Accelerometer();
            accel.setRequestedUpdateInterval(20);
            accel.addEventListener(AccelerometerEvent.UPDATE, accelUpdate);
        }else {
            timer = new Timer(30);
            timer.run = fakeAccelerometer;
        }
    }


    private function fakeAccelerometer() : Void{
        var stage = Lib.current.stage;
        var computedX = (stage.mouseX - stage.stageWidth /2) /(stage.stageWidth/2);
        var computedY = - (stage.mouseY - stage.stageHeight /2) /(stage.stageHeight/2);
        sendData( {x : computedY, y : - computedX, z : 0 });
    }


    public function stop() : Void{
        if (accel != null){
            accel.removeEventListener(AccelerometerEvent.UPDATE, accelUpdate);
            accel = null;
        }
        if (timer!= null){
            timer.stop();
            timer = null;
        }
    }
}
