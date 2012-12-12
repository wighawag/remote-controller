package com.wighawag.controller;
import flash.display.Stage;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TouchEvent;
import flash.ui.Multitouch;
import flash.display.Sprite;
import flash.display.DisplayObjectContainer;
import com.wighawag.p2p.P2PGroupConnection;
class ButtonPanelController {

    public static var DATA : String = "ButtonData";

    private var p2pConnection : P2PGroupConnection;
    private var panel : DisplayObjectContainer;

    public function new(p2pConnection : P2PGroupConnection, panel : DisplayObjectContainer) {
        this.p2pConnection = p2pConnection;
        this.panel = panel;
    }

    public function start() : Void{
        var panelWidth : Float;
        var panelHeight : Float;
        if (Std.is(panel, Stage)){
            var stage = cast(panel, Stage);
            panelWidth  = stage.stageWidth;
            panelHeight = stage.stageHeight;
        }else{
            panelWidth = panel.width;
            panelHeight = panel.height;
        }

        var midY = panelHeight /2 ;
        var buttonRadius = 30;
        var button1 = new Sprite();
        button1.graphics.beginFill(0x48DA48);
        button1.graphics.drawCircle(buttonRadius, midY, buttonRadius);
        button1.graphics.endFill();
        function onButton1(event : Event) : Void{
            p2pConnection.sendData(32, DATA); //TODO SPACE ()use polygonal ui lib for these constants
        }
        if(Multitouch.supportsTouchEvents){
            button1.addEventListener(TouchEvent.TOUCH_END,onButton1);
        }else{
            button1.addEventListener(MouseEvent.CLICK,onButton1);
        }

        panel.addChild(button1);

        var button2 = new Sprite();
        button2.graphics.beginFill(0xFA5E5E);
        button2.graphics.drawCircle(panelWidth - buttonRadius, midY, buttonRadius);
        button2.graphics.endFill();
        function onButton2(event : Event) : Void{
            p2pConnection.sendData(32, DATA); //TODO SPACE ()use polygonal ui lib for these constants
        }
        if(Multitouch.supportsTouchEvents){
            button2.addEventListener(TouchEvent.TOUCH_END,onButton2);
        }else{
            button2.addEventListener(MouseEvent.CLICK,onButton2);
        }
        panel.addChild(button2);
    }

    public function stop() : Void{
        while(panel.numChildren > 0){
            panel.removeChildAt(0);
        }
    }
}