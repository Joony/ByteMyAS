package ch.forea.bytemyas.tags {

  import ch.forea.bytemyas.ComplexByteArray;
  import ch.forea.bytemyas.Tag;
    
  public class FrameLabel extends Tag{

    public function FrameLabel(id:uint, length:uint, data:ComplexByteArray){
      super(id, length, data, ['frameName', 'namedAnchor']);
    }

    public function get frameName():String {
      var tempData:ComplexByteArray = data;
      tempData.position = 2;
      var stringLength:uint;
      while(tempData.position < 2 + length) {
	stringLength++;
	if(tempData.readByte() == 0)
	  break;
      }
      tempData.position = 2;
      return tempData.readUTFBytes(stringLength);
    }

    public function get namedAnchor():Boolean {
      var tempData:ComplexByteArray = data;
      return tempData[2 + length - 1] != 0;
    }
    // TODO: setter for namedAnchor is going to mess with the length of the data

  }

}
