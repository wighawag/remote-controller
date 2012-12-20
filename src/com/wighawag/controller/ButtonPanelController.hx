package com.wighawag.controller;
import com.wighawag.controller.ButtonPanelController;
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

	public static var BUTTON_RELEASE : Int = 0;
	public static var BUTTON_PRESS : Int = 1;

	public static var BUTTON_1 : Int = 1;
	public static var BUTTON_2 : Int = 2;

    private var p2pConnection : P2PGroupConnection;
	private var container : DisplayObjectContainer;
    private var panel : Sprite;

	private var button1 : Sprite;
	private var button2 : Sprite;

    public function new(p2pConnection : P2PGroupConnection, container : DisplayObjectContainer) {
        this.p2pConnection = p2pConnection;
	    this.container = container;
        this.panel = new Sprite();
	    this.container.addChild(panel);
    }

    public function start() : Void{
        var panelWidth : Float;
        var panelHeight : Float;
        if (Std.is(container, Stage)){
            var stage = cast(container, Stage);
            panelWidth  = stage.stageWidth;
            panelHeight = stage.stageHeight;
        }else{
            panelWidth = panel.width;
            panelHeight = panel.height;
        }

        var midY = panelHeight /2 ;
        var buttonRadius = 30;

	    createButton(BUTTON_1,buttonRadius, midY, buttonRadius,0x48DA48);
	    createButton(BUTTON_2,panelWidth - buttonRadius, midY, buttonRadius, 0xFA5E5E);

    }

	private function createButton(id : Int, x : Float, y : Float, radius : Float, color : Int) : Void{
		var button = new Button(id);
		button.graphics.beginFill(color);
		button.graphics.drawCircle(x, y, radius);
		button.graphics.endFill();
		if(Multitouch.supportsTouchEvents){
			button.addEventListener(TouchEvent.TOUCH_BEGIN,onButtonPressed);
			button.addEventListener(TouchEvent.TOUCH_END,onButtonReleased);
		}else{
			button.addEventListener(MouseEvent.MOUSE_DOWN,onButtonPressed);
			button.addEventListener(MouseEvent.MOUSE_UP,onButtonReleased);
		}
		panel.addChild(button);
	}

	private function onButtonPressed(event : Event) : Void{
		var button : Button = cast(event.target);
		p2pConnection.sendData({button:button.id, state:BUTTON_PRESS}, DATA);
	}

	private function onButtonReleased(event : Event) : Void{
		var button : Button = cast(event.target);
		p2pConnection.sendData({button:button.id, state:BUTTON_RELEASE}, DATA);
	}

    public function stop() : Void{
       container.removeChild(panel);
    }
}

class Button extends Sprite{

	public var id : Int;

	public function new(id : Int) {
		super();
		this.id = id;
	}
}