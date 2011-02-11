package ch.forea.swfeditor {

  import flash.display.Sprite;

  import com.bit101.components.*;

  public class LabelField extends Sprite {

    public function LabelField(name:String, value:*) {
      new Label(this, 0, 0, capitalizedString(name) + ":");
      new Label(this, 110, 0, String(value));
    }

    private function capitalizedString(s:String):String {
      return s.charAt(0).toUpperCase() + s.substr(1);
    }

  }

}
