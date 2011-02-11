package ch.forea.bytemyas.tags {

  import flash.utils.ByteArray;

  import ch.forea.bytemyas.Tag;
    
  public class DoABC extends Tag{

    private static const K_DO_ABC_LAZY_INITIALIZE:uint = 0x1; // 1

    public function DoABC(id:uint, length:uint, data:ByteArray){
      super(id, length, data, ['kDoAbcLazyInitialize', 'doAbcName']);
    }

    public function get kDoAbcLazyInitialize():Boolean {
      var tempData:ByteArray = data;
      tempData.position = length < 0x3F ? 2 : 6;
      return (tempData.readUnsignedInt() & K_DO_ABC_LAZY_INITIALIZE) == K_DO_ABC_LAZY_INITIALIZE;
    }
    public function set kDoAbcLazyInitialize(b:Boolean):void {
      updateBitFlag(K_DO_ABC_LAZY_INITIALIZE, b);
    }

    private function updateBitFlag(flag:uint, value:Boolean):void {
      var tempData:ByteArray = data;
      tempData.position = length < 0x3F ? 2 : 6;
      var flags:uint = tempData.readUnsignedByte();
      if((value && flags & flag) || (!value && !(flags & flag)))
        return;
      tempData.position = length < 0x3F ? 2 : 6;
      tempData.writeByte(value ? flags | flag : flags ^ flag);
      data = tempData;
    }

    public function get doAbcName():String {
      var tempData:ByteArray = data;
      tempData.position = (length < 0x3F ? 2 : 6) + 4;
      var stringLength:uint;
      while(tempData.position < 2 + length) {
	stringLength++;
	if(tempData.readByte() == 0)
	  break;
      }
      tempData.position = (length < 0x3F ? 2 : 6) + 4;
      return tempData.readUTFBytes(stringLength);
    }

    


  }

}
