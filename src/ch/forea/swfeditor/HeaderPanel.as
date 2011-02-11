package ch.forea.swfeditor {

  import flash.display.Sprite;
  import flash.events.MouseEvent;

  import com.bit101.components.*;

  public class HeaderPanel extends Sprite {

    private var panel:Panel;
    private var fileNameLabel:Label;
    private var versionNumberLabel:Label;
    private var compressedFileSizeLabel:Label;
    private var uncompressedFileSizeLabel:Label;
    private var compressedButton:RadioButton;
    private var uncompressedButton:RadioButton;

    private var extendedHeader:Sprite;
    private var xMinLabel:Label;
    private var xMaxLabel:Label;
    private var yMinLabel:Label;
    private var yMaxLabel:Label;
    private var frameRateLabel:Label;
    private var frameCountLabel:Label;

    public function set xMin(coordinate:int):void {
      xMinLabel.text = String(coordinate);
    }

    public function set xMax(coordinate:int):void {
      xMaxLabel.text = String(coordinate);
    }

    public function set yMin(coordinate:int):void {
      yMinLabel.text = String(coordinate);
    }

    public function set yMax(coordinate:int):void {
      yMaxLabel.text = String(coordinate);
    }

    public function set frameRate(numberOfFrames:uint):void {
      frameRateLabel.text = String(numberOfFrames);
    }

    public function set frameCount(numberOfFrames:uint):void {
      frameCountLabel.text = String(numberOfFrames);
    }

    public function HeaderPanel(fileName:String, version:uint, uncompressedFileSize:String, compressedFileSize:String, compressed:Boolean, xMin:int = 0, xMax:int = 0, yMin:int = 0, yMax:int = 0, frameRate:uint = 0, frameCount:uint = 0) {

      panel = new Panel(this);

      new Label(panel, 10, 10, "File name:");
      fileNameLabel = new Label(panel, 120, 10, fileName);
      
      new Label(panel, 10, 30, "Version:");
      versionNumberLabel = new Label(panel, 120, 30, String(version));

      new Label(panel, 10, 50, "Uncompressed file size:");
      uncompressedFileSizeLabel = new Label(panel, 120, 50, uncompressedFileSize);

      new Label(panel, 10, 70, "Compressed file size:");
      compressedFileSizeLabel = new Label(panel, 120, 70, compressedFileSize);

      new Label(panel, 10, 90, "Compression:");
      compressedButton = new RadioButton(panel, 20, 115, "Compressed", compressed, compress);
      uncompressedButton = new RadioButton(panel, 20, 135, "Uncompressed", !compressed, uncompress);


      extendedHeader = new Sprite();
      extendedHeader.y = 155;
      if(!compressed)
	panel.addChild(extendedHeader);

      new Label(extendedHeader, 10, 0, "Dimensions:");
      new Label(extendedHeader, 60, 25, "xMin:");
      xMinLabel = new Label(extendedHeader, 100, 25, String(xMin));
      new Label(extendedHeader, 60, 45, "xMax:");
      xMaxLabel = new Label(extendedHeader, 100, 45, String(xMax));
      new Label(extendedHeader, 60, 65, "yMin:");
      yMinLabel = new Label(extendedHeader, 100, 65, String(yMin));
      new Label(extendedHeader, 60, 85, "xMax:");
      yMaxLabel = new Label(extendedHeader, 100, 85, String(yMax));

      new Label(extendedHeader, 10, 105, "Frame rate:");
      frameRateLabel = new Label(extendedHeader, 80, 105, String(frameRate));

      new Label(extendedHeader, 10, 125, "Frame count:");
      frameCountLabel = new Label(extendedHeader, 80, 125, String(frameCount));

      panel.setSize(483, compressed ? 155 : 305);

    }

    public override function get height():Number {
      return !contains(extendedHeader) ? 155 : 305;
    }

    private function compress(e:MouseEvent = null):void {

    }

    private function uncompress(e:MouseEvent = null):void {

    }


  }

}
