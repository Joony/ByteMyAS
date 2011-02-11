package ch.forea.bytemyas.tags {

  import flash.utils.ByteArray;

  import ch.forea.bytemyas.Tag;
    
  public class ScriptLimits extends Tag{

    public function ScriptLimits(id:uint, length:uint, data:ByteArray){
      super(id, length, data, ['maxRecursionDepth', 'scriptTimeoutSeconds']);
    }

    public function get maxRecursionDepth():uint {
      var tempData:ByteArray = data;
      tempData.position = 2;
      return tempData.readUnsignedShort();
    }
    public function set maxRecursionDepth(n:uint):void {
      var tempData:ByteArray = data;
      tempData.position = 2;
      tempData.writeShort(n);
      data = tempData;
    }

    public function get scriptTimeoutSeconds():uint {
      var tempData:ByteArray = data;
      tempData.position = 4;
      return tempData.readUnsignedShort();
    }
    public function set scriptTimeoutSeconds(n:uint):void {
      var tempData:ByteArray = data;
      tempData.position = 4;
      tempData.writeShort(n);
      data = tempData;
    }

  }

}
