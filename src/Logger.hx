package ;
import flash.text.TextField;
class Logger {

    private var log : TextField;

    public function new(log : TextField) {
        this.log = log;
    }

    public function handleTrace(severity: Dynamic, ?posInfos : haxe.PosInfos ) {
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
			#if air
            appendToLogTextField(log, message);
			#else
			appendToLogTextField(log, message);//flash.Lib.trace(message);
			#end
		#elseif cpp
		    cpp.Lib.println(message);
		#else
            //trace(value, posInfos);
        #end
    }

    inline private static function appendToLogTextField(log : TextField, message) : Void{
        log.appendText(message + "\n");
        if(log.numLines > log.bottomScrollV) {
            log.scrollV = log.maxScrollV;
        }
    }
}
