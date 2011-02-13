package ch.forea.bytemyas.tags.exportassets {

  import flash.utils.ByteArray;
  import flash.utils.Endian;

  import ch.forea.bytemyas.DataObject;

  public class Asset extends DataObject {

    private var _data:ByteArray;

    public function Asset(data:ByteArray) {
      _data = data;
      super(['tag', 'name']);
    }

    public function get tag():uint {
      _data.position = 0;
      return _data.readUnsignedShort();
    }
    public function set tag(n:uint):void {
      _data.position = 0;
      _data.writeShort(n);
    }

    public function get name():String {
      _data.position = 2;
      return _data.readUTFBytes(data.length - 2);
    }

    public function get data():ByteArray {
      var temp:ByteArray = new ByteArray();
      temp.endian = Endian.LITTLE_ENDIAN;
      temp.writeBytes(_data);
      return temp;
    }
    
  }

}
