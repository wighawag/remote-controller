package com.wighawag.p2p;

class MessageWrapper<MessageType> {
    public var message(default,null) : MessageType;
    public var timestamp(default,null) : Float;
    public var messageType(default, null) : String;

    public function new(message : MessageType, messageType : String, timestamp : Float){
        this.message = message;
        this.timestamp = timestamp;
        this.messageType = messageType;
    }

    public static function parse<MessageType>(dyn : Dynamic) : MessageWrapper<MessageType>{
        return new MessageWrapper(dyn.message, dyn.messageType, dyn.timestamp);
    }
}

