package ch.forea.bytemyas.tags {

  import ch.forea.bytemyas.ComplexByteArray;
  import ch.forea.bytemyas.Tag;
    
  public class EnableDebugger2 extends Tag{

    public function EnableDebugger2(id:uint, length:uint, data:ComplexByteArray){
      super(id, length, data, ['password']);
    }

    // XXX: Need to verify this is correct
    public function get password():String {
      var tempData:ComplexByteArray = data;
      tempData.position = length < 0x3F ? 2 : 6;
      return tempData.readUTFBytes(length - 2);
    }
    public function set password(s:String):void {
      
    }

  }

}
