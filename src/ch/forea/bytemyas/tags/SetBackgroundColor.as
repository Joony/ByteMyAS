package ch.forea.bytemyas.tags {

  import flash.utils.ByteArray;

  import ch.forea.bytemyas.Tag;
    
  public class SetBackgroundColor extends Tag{

    public function SetBackgroundColor(id:uint, length:uint, data:ByteArray){
      super(id, length, data, ['backgroundColor']);
    }

    public function get backgroundColor():uint {
      var tempData:ByteArray = data;
      return (tempData[2] << 16) | (tempData[3] << 8) | tempData[4];
    }
    public function set backgroundColor(color:uint):void {
      var tempData:ByteArray = data;
      tempData[2] = color >> 16 & 0xFF;
      tempData[3] = color >> 8 & 0xFF;
      tempData[4] = color & 0xFF;
      data = tempData;
    }

  }

}
