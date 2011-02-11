package ch.forea.bytemyas.tags {

  import flash.utils.ByteArray;

  import ch.forea.bytemyas.SWFArray;
  import ch.forea.bytemyas.Tag;
    
  public class FileAttributes extends Tag{

    private static const USE_DIRECT_BLIT:uint = 0x40; // 64
    private static const USE_GPU:uint = 0x20; // 32
    private static const HAS_METADATA:uint = 0x10; // 16
    private static const ACTIONSCRIPT3:uint = 0x8; // 8
    private static const USE_NETWORK:uint = 0x1; // 1

    public function FileAttributes(id:uint, length:uint, data:ByteArray){
      super(id, length, data, ['useDirectBlit', 'useGPU', 'hasMetadata', 'actionScript3', 'useNetwork']);
    }

    public function get useDirectBlit():Boolean{
      return (data[2] & USE_DIRECT_BLIT) == USE_DIRECT_BLIT;
    }
    public function set useDirectBlit(b:Boolean):void {
      updateBitFlag(USE_DIRECT_BLIT, b);
    }

    public function get useGPU():Boolean {
      return (data[2] & USE_GPU) == USE_GPU;
    }
    public function set useGPU(b:Boolean):void {
      updateBitFlag(USE_GPU, b);
    }

    public function get hasMetadata():Boolean{
      return (data[2] & HAS_METADATA) == HAS_METADATA;
    }
    public function set hasMetadata(b:Boolean):void {
      updateBitFlag(HAS_METADATA, b);
    }

    public function get actionScript3():Boolean{
      return (data[2] & ACTIONSCRIPT3) == ACTIONSCRIPT3;
    }
    public function set actionScript3(b:Boolean):void {
      updateBitFlag(ACTIONSCRIPT3, b);
    }

    public function get useNetwork():Boolean{
      return (data[2] & USE_NETWORK) == USE_NETWORK;
    }
    public function set useNetwork(b:Boolean):void {
      updateBitFlag(USE_NETWORK, b);
    }

    private function updateBitFlag(flag:uint, value:Boolean):void {
      var tempData:ByteArray = data;
      tempData.position = 2;
      var flags:uint = tempData.readUnsignedByte();
      if((value && flags & flag) || (!value && !(flags & flag)))
        return;
      tempData.position = 2;
      tempData.writeByte(value ? flags | flag : flags ^ flag);
      data = tempData;
    }

    public override function toString():String{
      return '[object FileAttributes] ' + SWFArray.formatBinaryByte(data[2]) + ', ' + SWFArray.formatBinaryByte(data[3]) + ', ' + SWFArray.formatBinaryByte(data[4]) + ', ' + SWFArray.formatBinaryByte(data[5]);
    }

    

  }

}
