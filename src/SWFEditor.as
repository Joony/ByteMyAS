package{

  import flash.utils.describeType;
  
  import flash.display.Sprite;
  import flash.display.StageScaleMode;
  import flash.display.StageAlign;

  import flash.events.Event;
  import flash.events.MouseEvent;

  import flash.external.ExternalInterface;

  import flash.net.FileReference;
  import flash.net.FileFilter;

  import ch.forea.bytemyas.SWFArray;
  import ch.forea.bytemyas.Tag;

  import ch.forea.swfeditor.HeaderPanel;
  import ch.forea.swfeditor.TagPanel;

  import com.bit101.components.*;

  public class SWFEditor extends Sprite{

    private var file:FileReference = new FileReference();
    private var binaryFile:SWFArray;
    private var headerPanel:HeaderPanel;
    private var panels:Vector.<Sprite> = new Vector.<Sprite>();

    private var container:Sprite = new Sprite();

    public function SWFEditor(){
      stage.scaleMode = StageScaleMode.NO_SCALE;
      stage.align = StageAlign.TOP_LEFT;

      String.prototype.commafy = function():String {
        return this.replace(/(^|[^\w.])(\d{4,})/g, function($0:*, $1:*, $2:*):* {
	  return $1 + $2.replace(/\d(?=(?:\d\d\d)+(?!\d))/g, "$&,");
	});
      }

      this.addChild(container);

      binaryFile = new SWFArray();
      loaderInfo.bytes.readBytes(binaryFile, 0, loaderInfo.bytes.length);


      // create panel and buttons for loading and saving
      var buttonPanel:Panel = new Panel(this, 10, 10);
      buttonPanel.setSize(120, 70);
      
      var loadButton:PushButton = new PushButton(buttonPanel, 10, 10, "Load a .swf file", selectFile);
      loadButton.width = 100;

      var saveButton:PushButton = new PushButton(buttonPanel, 10, 40, "Save the .swf", save);
      loadButton.width = 100;


      // create the header panel
      binaryFile.position = 4;
      headerPanel = new HeaderPanel(this.loaderInfo.url.split('/').pop(), binaryFile[3], String(binaryFile.readUnsignedInt())['commafy']() + " bytes", "Unknown.  Compress the swf to find out.", false);

      addPanel(headerPanel);

      updateAttributes();
      listTags();

      updateContainerHeight();

      ExternalInterface.addCallback('updatePosition', updatePosition);

    }

    private function updatePosition(offset:uint):void {
      container.y = -offset;
    }

    private function addPanel(panel:Sprite):void{
      container.addChild(panel);
      panels.push(panel);
    }

    private function updateContainerHeight():void{
      var height:uint = 10;
      for each(var panel:Sprite in panels) {
	panel.x = 140;
	panel.y = height;
	height += panel.height + 10;
      }
      ExternalInterface.call("setHeight", height);
    }

    private function selectFile(e:MouseEvent):void{
      stage.removeEventListener(MouseEvent.MOUSE_DOWN, selectFile);
      file.addEventListener(Event.SELECT, load);
      file.browse([new FileFilter("SWF", "*.swf")]);
    }

    private function load(e:Event):void{
      file.removeEventListener(Event.SELECT, load);
      file.addEventListener(Event.COMPLETE, onLoaded);
      file.load();
    }

    private function onLoaded(e:Event):void{
      file.removeEventListener(Event.COMPLETE, onLoaded);
      binaryFile.position = 0;
      binaryFile.length = 0;
      file.data.readBytes(binaryFile, 0, file.data.length);

      if((binaryFile[0] == 0x43 || binaryFile[0] == 0x46) && binaryFile[1] == 0x57 && binaryFile[2] == 0x53){
	trace("SWF header is valid");
      }else{
	//throw new Exception("File is not a valid .swf");
      }

      updateAttributes();

      listTags();
      
    }

    private function listTags():void{
      trace("listTags()");

      var tag:*;
      while(binaryFile.position < binaryFile.length){
	tag = binaryFile.readTag();
	
	var c:Class = TagPanel.getClass(tag.id);
	if(c)
	  addPanel(new c(tag));
        else
          addPanel(new TagPanel(tag));
      }

      
    }

    private function updateAttributes():void{
      var compressed:Boolean = binaryFile[0] == 0x43;
      if(compressed)
	uncompress();
      
      binaryFile.position = 8;
      var dimensions:Vector.<int> = binaryFile.readRECT();
      trace("[Dimensions " + dimensions[0] + ", " + dimensions[1] + ", " + dimensions[2] + ", " + dimensions[3]);

      /*
      xMin.text = String(dimensions[0]);
      xMax.text = String(dimensions[1]);
      yMin.text = String(dimensions[2]);
      yMax.text = String(dimensions[3]);
      frameRate.text = binaryFile.readFixed88() + " fps";
      frameCount.text = String(binaryFile.readUnsignedShort());
      */

      // temp
      binaryFile.readFixed88();
      binaryFile.readUnsignedShort();

      if(compressed)
	compress();
    }

    private function compress(e:MouseEvent = null):void{
      if(binaryFile[0] == 0x43)
	return;
      binaryFile.compress();
    }

    private function uncompress(e:MouseEvent = null):void{
      if(binaryFile[0] == 0x46)
	return;
      binaryFile.uncompress();
    }

    private function save(e:MouseEvent):void{
      var fileName:String = 'swf_editor.swf';
      try{
	fileName = file.name;
      }catch(e:Error){}
      file.save(binaryFile, fileName);
    }

  }

}