package ch.forea.bytemyas.tags {

  import ch.forea.bytemyas.ComplexByteArray;
  import ch.forea.bytemyas.Tag;
    
  public class Metadata extends Tag{

    public function Metadata(id:uint, length:uint, data:ComplexByteArray){
      super(id, length, data, ['metadata']);
    }

    public function get metadata():String {
      var tempData:ComplexByteArray = data;
      tempData.position = length < 0x3F ? 2 : 6;
      return tempData.readUTFBytes(length);
    }
    public function set metadata(s:String):void {
      
    }

  }

}
