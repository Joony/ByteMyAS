package ch.forea.swfeditor {

  import flash.events.Event;

  public class EditorEvent extends Event {

    public static const FIELD_UPDATE:String = "fieldUpdate";

    public var propertyName:String;
    public var propertyValue:*;

    public function EditorEvent(type:String, propertyName:String, propertyValue:*, bubbles:Boolean = true, cencelable:Boolean = false) {
      this.propertyName = propertyName;
      this.propertyValue = propertyValue;
      super(type, bubbles, cancelable);
    }

    public override function clone():Event {
      return new EditorEvent(type, propertyName, propertyValue, bubbles, cancelable);
    }

  }

}
