package ch.forea.swfeditor {

  import flash.display.Sprite;
  import flash.events.MouseEvent;

  import com.bit101.components.*;

  import ch.forea.swfeditor.panels.*;

  public class TagPanel extends Sprite {

    private var panel:Panel;
    private var nameLabel:Label;
    private var idLabel:Label;
    private var lengthLabel:Label;

    private var fields:Vector.<Sprite> = new Vector.<Sprite>();
    private var _height:uint;

    private var tag:*;

    public function TagPanel(tag:*) {

      this.tag = tag;

      panel = new Panel(this);
      /*
      new Label(panel, 10, 10, "Tag name:");
      nameLabel = new Label(panel, 120, 10, name);
      
      new Label(panel, 10, 30, "ID:");
      idLabel = new Label(panel, 120, 30, String(id));

      new Label(panel, 10, 50, "Length:");
      lengthLabel = new Label(panel, 120, 50, length);
      */

      trace('-----------------------------------------------------------------------');
      trace(tag);
      for(var propertyName:String in tag) {
	switch(propertyName) {
	  case 'name':
	  case 'id':
	    addField(new LabelField(propertyName, tag[propertyName]));
	    break;
	  case 'length':
	    addField(new LabelField(propertyName, String(tag[propertyName])['commafy']() + " bytes"));
	    break;
	  case 'data':
	    //addField(new BinaryField(propertyName, tag[propertyName]));
	    break;
	  default:
	    processProperty(propertyName, tag[propertyName], tag.getPropertyType(propertyName));
	}

	if(propertyName != 'data') {
          trace(propertyName + ' = ' + tag[propertyName] + ' (' + tag.getPropertyType(propertyName) + ')');
	} else {
	  trace('data (' + tag.getPropertyType(propertyName) + ')');
        }
      }

      updateContainerHeight();

      this.addEventListener(EditorEvent.FIELD_UPDATE, updateField);

    }


    private function processProperty(name:String, value:*, type:String):void {
      trace('Process propety: name = ' + name + ', value = ' + value + ', type = ' + type);
      switch(type) {
	case 'Boolean':
	  addField(new BooleanField(name, value));
	  break;
	case 'Array':
	  addField(new LabelField(name, ''));
	  for(var i:uint = 0; i < value.length; i++) {
	    for(var propertyName:String in value[i]) {
	      processProperty(propertyName, value[i][propertyName], value[i].getPropertyType(propertyName));
	    }
          }
	  break;
	default:
	  addField(new LabelField(name, value));
      }
    }


    private function updateField(e:EditorEvent):void {
      trace("UpdateField:", e.propertyName, e.propertyValue);
      tag[e.propertyName] = e.propertyValue;
      trace("tag = " + tag);
    }

    protected function addField(field:Sprite):void{
      panel.addChild(field);
      fields.push(field);
    }

    protected function updateContainerHeight():void{
      var height:uint = 10;
      for each(var field:Sprite in fields) {
	field.x = 10;
	field.y = height;
	height += field.height ;
      }
      height += 10;
      _height = height;
      panel.setSize(483, _height);
    }

    public override function get height():Number {
      return _height;
    }

    public static function getClass(id:uint):Class{
      
      switch(id){
	case 82:
	  return DoABCPanel;
      }
      
      return null;
    }

  }

}
