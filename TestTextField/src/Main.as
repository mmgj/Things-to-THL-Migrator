package { 
	
	import flash.display.Sprite;
	import classes.XTrace;

	import flash.events.MouseEvent;
	import flash.text.TextField;

	[SWF(width='550', height='400', backgroundColor='#FFFFFF', frameRate='60')]

public class Main extends Sprite {

		private var textField : TextField;
		private var sprite : Sprite;
	public function Main () {
		sprite = new Sprite();
		sprite.x = sprite.y = 100;
		textField = new TextField();
		textField.text = "hello world"
		addChild(sprite);
		sprite.addChild(textField);
		
		addEventListener(MouseEvent.CLICK, resizeSprite);
		
		}

		private function resizeSprite(m:MouseEvent) : void {
			sprite.width += 20;
			sprite.height += 20;
		}

	}

}