package ch.forea.swfeditor {

  import flash.display.Sprite;
  import flash.utils.ByteArray;

  import com.bit101.components.*;

  public class BinaryField extends Sprite {

    private var positions:Array = [10, 30, 50, 70,  100, 120, 140, 160,  190, 210, 230, 250,  280, 300, 320, 340];

    public function BinaryField(name:String, value:ByteArray) {
      new Label(this, 0, 0, capitalizedString(name) + ":");
      var i:uint;
      while(i < value.length) {
        new Label(this, positions[i % positions.length], 20 + int(i / positions.length) * 20, convertToHEX(value[i]));
	i++;
      }
    }

    private function convertToHEX(n:uint):String {
      var hex:String = n.toString(16).toUpperCase();
      if(hex.length == 1)
        hex = "0" + hex;
      return hex;
    }

    private function capitalizedString(s:String):String {
      return s.charAt(0).toUpperCase() + s.substr(1);
    }

  }

}
