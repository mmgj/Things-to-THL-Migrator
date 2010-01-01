package no.martinjacobsen {

	import flash.external.ExternalInterface;

	public class XTrace {
		
		
		public function XTrace() { /*...*/ }
		
		public static var ENABLED:Boolean = true;
		private static var EI_AVAILABLE:Boolean = false;
		private static var SETUP_COMPLETE:Boolean = false;
		private static function setup():void {
			if (!SETUP_COMPLETE) {
				if (ExternalInterface.available) {
					trace("XTrace: ExternalInterface logging")
					EI_AVAILABLE = true;
				}else {

				}
				SETUP_COMPLETE = true;
			}
		}
		/**
		 * Attempts to output trace to console.log. If failed, trace as usual
		 */
		public static function log(...args:*) : void {
			setup();
			if(ENABLED){
				if(EI_AVAILABLE){
					for (var i:uint =0; i< args.length; i++){
						 ExternalInterface.call("console.log", args[i].toString());	
					}
				}
				trace(args);
			}
		}
	}
}