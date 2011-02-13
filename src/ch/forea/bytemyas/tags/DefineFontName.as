package ch.forea.bytemyas.tags {

  import ch.forea.bytemyas.ComplexByteArray;
  import ch.forea.bytemyas.Tag;
    
  public class DefineFontName extends Tag{

    public function DefineFontName(id:uint, length:uint, data:ComplexByteArray){
      super(id, length, data, ['fontID', 'fontName', 'fontCopyright']);
    }

    public function get fontID():uint {
      var tempData:ComplexByteArray = data;
      tempData.position = length < 0x3F ? 2 : 6;
      return tempData.readUnsignedShort();
    }
    public function set fontID(id:uint):void {
      var tempData:ComplexByteArray = data;
      tempData.position = length < 0x3F ? 2 : 6;
      tempData.writeShort(id);
      data = tempData;
    }

    public function get fontName():String {
      var tempData:ComplexByteArray = data;
      tempData.position = (length < 0x3F ? 2 : 6) + 2;
      var stringLength:uint;
      while(tempData.position < 2 + length) {
	stringLength++;
	if(tempData.readByte() == 0)
	  break;
      }
      tempData.position = (length < 0x3F ? 2 : 6) + 2;
      return tempData.readUTFBytes(stringLength);
    }

    public function get fontCopyright():String {
      var tempData:ComplexByteArray = data;
      tempData.position = (length < 0x3F ? 2 : 6) + 2;
      while(tempData.position < 2 + length && tempData.readByte() != 0) {
	// do nothing
      }
      var stringPosition:uint = tempData.position;
      var stringLength:uint;
      while(tempData.position < 2 + length) {
	stringLength++;
	if(tempData.readByte() == 0)
	  break;
      }
      trace(stringPosition, stringLength, length + 2);
      tempData.position = stringPosition;
      return tempData.readUTFBytes(stringLength);
    }



  }

}
