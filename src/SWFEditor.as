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

    /*
    private var fileName:Label;
    private var versionNumber:Label;
    private var uncompressedFileSize:Label;
    private var compressedFileSize:Label;
    private var xMin:Label;
    private var xMax:Label;
    private var yMin:Label;
    private var yMax:Label;
    private var frameRate:Label;
    private var frameCount:Label;
    private var compressed:RadioButton;
    private var uncompressed:RadioButton;
    */

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


      // set the filename to be this.loaderInfo.url and regex out the name and extension


      // create panel and buttons for loading and saving
      var buttonPanel:Panel = new Panel(this, 10, 10);
      buttonPanel.setSize(120, 70);
      
      var loadButton:PushButton = new PushButton(buttonPanel, 10, 10, "Load a .swf file", selectFile);
      loadButton.width = 100;

      var saveButton:PushButton = new PushButton(buttonPanel, 10, 40, "Save the .swf", save);
      loadButton.width = 100;



      /*

      // create a panel for the header
      var swfHeaderPanel:Panel = new Panel(this);
      addPanel(swfHeaderPanel);
      swfHeaderPanel.setSize(483, 100);

      new Label(swfHeaderPanel, 10, 10, "File name:");
      fileName = new Label(swfHeaderPanel, 120, 10, "swf_editor.swf");
      
      new Label(swfHeaderPanel, 10, 30, "Version:");
      versionNumber = new Label(swfHeaderPanel, 120, 30, binaryFile[3]);

      new Label(swfHeaderPanel, 10, 50, "Uncompressed file size:");
      binaryFile.position = 4;
      uncompressedFileSize = new Label(swfHeaderPanel, 120, 50, commafy(binaryFile.readUnsignedInt()) + " bytes");

      new Label(swfHeaderPanel, 10, 70, "Compressed file size:");
      compressedFileSize = new Label(swfHeaderPanel, 120, 70, "");


      // create a panel for the compression options
      var compressionPanel:Panel = new Panel(this);
      addPanel(compressionPanel);
      compressionPanel.setSize(483, 85);

      new Label(compressionPanel, 10, 10, "Compression:");
      compressed = new RadioButton(compressionPanel, 20, 35, "Compressed", true, compress);
      uncompressed = new RadioButton(compressionPanel, 20, 55, "Uncompressed", false, uncompress);

      if(binaryFile[0] == 0x43){
        compressed.selected = true;
	compressedFileSize.text = commafy(binaryFile.length) + " bytes";
      }else{
        uncompressed.selected = true;
	compressedFileSize.text = "Unknown.  Compress the swf to find out.";
      }

      
      // create a panel for the extended header
      var extendedHeaderPanel:Panel = new Panel(this);
      addPanel(extendedHeaderPanel);
      extendedHeaderPanel.setSize(483, 160);

      new Label(extendedHeaderPanel, 10, 10, "Dimensions:");
      new Label(extendedHeaderPanel, 60, 30, "xMin:");
      xMin = new Label(extendedHeaderPanel, 100, 30);
      new Label(extendedHeaderPanel, 60, 50, "xMax:");
      xMax = new Label(extendedHeaderPanel, 100, 50);
      new Label(extendedHeaderPanel, 60, 70, "yMin:");
      yMin = new Label(extendedHeaderPanel, 100, 70);
      new Label(extendedHeaderPanel, 60, 90, "xMax:");
      yMax = new Label(extendedHeaderPanel, 100, 90);

      new Label(extendedHeaderPanel, 10, 110, "Frame rate:");
      frameRate = new Label(extendedHeaderPanel, 80, 110);

      new Label(extendedHeaderPanel, 10, 130, "Frame count:");
      frameCount = new Label(extendedHeaderPanel, 80, 130);

      updateAttributes();
      listTags();

      */

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
      /*
      var height:uint = 10;
      for each(var p:Sprite in panels)
	height += p.height + 10;
      panel.x = 140;
      panel.y = height;
      */
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
    
    /*
    private function commafy(number:uint):String{
      return String(number).replace(/(^|[^\w.])(\d{4,})/g, function($0:*, $1:*, $2:*):* {
	    return $1 + $2.replace(/\d(?=(?:\d\d\d)+(?!\d))/g, "$&,");
	  });
    }
    */


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


      /*
      fileName.text = file.name;
      versionNumber.text = binaryFile[3];
      
      binaryFile.position = 4;
      uncompressedFileSize.text = commafy(binaryFile.readUnsignedInt()) + " bytes";


      if(binaryFile[0] == 0x43){
	compressed.selected = true;
	compressedFileSize.text = commafy(binaryFile.length) + " bytes";
      }else{
	uncompressed.selected = true;
	compressedFileSize.text = "Unknown.  Compress the swf to find out.";
      }
      */

      updateAttributes();

      listTags();
      
    }

    private function listTags():void{
      trace("listTags()");

      var tag:*;
      while(binaryFile.position < binaryFile.length){
	tag = binaryFile.readTag();
	
	/*
	trace('-----------------------------------------------------------------------');
	trace(tag);
        for(var n:String in tag){
	  //var type:* = describeType(tag)..accessor.(@name == n).@type;
	  if(n != "data") {
            trace(n + ' = ' + tag[n] + ' (' + tag.getPropertyType(n) + ')');
	  } else {
	    trace('data (' + tag.getPropertyType(n) + ')');
          }
        }
	*/

	var c:Class = TagPanel.getClass(tag.id);
	if(c) {
	  addPanel(new c(tag));
        } else {
          // addPanel(new TagPanel(tag.name, tag.id, commafy(tag.length) + " bytes"));
          addPanel(new TagPanel(tag));
	}
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
      //compressedFileSize.text = commafy(binaryFile.length) + " bytes";
    }

    private function uncompress(e:MouseEvent = null):void{
      if(binaryFile[0] == 0x46)
	return;
      binaryFile.uncompress();
      //compressedFileSize.text = "Unknown.  Compress the swf to find out.";
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