package ch.forea.swfeditor {

  import flash.display.Sprite;
  import flash.utils.ByteArray;
  import flash.events.MouseEvent;

  import com.bit101.components.*;

  public class BooleanField extends Sprite {

    private var checkbox:CheckBox;
    private var fieldName:String;

    public function BooleanField(name:String, value:Boolean) {
      //new Label(this, 10, 5, capitalizedString(name) + ":");
      fieldName = name;
      checkbox = new CheckBox(this, 10, 10, capitalizedString(fieldName), clicked);
      checkbox.selected = value;
    }

    private function clicked(e:MouseEvent):void {
      dispatchEvent(new EditorEvent(EditorEvent.FIELD_UPDATE, fieldName, checkbox.selected));
    }


    private function capitalizedString(s:String):String {
      return s.charAt(0).toUpperCase() + s.substr(1);
    }

    public override function get height():Number {
      return super.height;
    }

  }

}
