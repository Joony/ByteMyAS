package ch.forea.bytemyas {

  import flash.utils.ByteArray;

  public class ComplexByteArray extends ByteArray {

    public function ComplexByteArray() {
      super();
    }

    private function splice(bytes:ComplexByteArray, index:uint, deleteLength:uint):void{
      var temp:ComplexByteArray = new ComplexByteArray();
      position = index;
      temp.writeBytes(this, index + deleteLength);
      length = index;
      position = index;
      writeBytes(bytes);
      temp.position = 0;
      writeBytes(temp);
    }

    
    // Totally stolen from Tamarin's utils/abcdump.as
    /**
     * Reads a signed 24-bit integer from the byte stream.
     */
    public function readS24():int{
      var b:int = readUnsignedByte();
      b |= readUnsignedByte() << 8;
      b |= readByte() << 16;
      return b;
    }
    
    // Totally stolen from Tamarin's utils/abcdump.as
    /**
     * Reads an unsigned 30-bit/32-bit integer from the byte stream.
     */
    public function readU32():int{
      var result:int = readUnsignedByte();
      if (!(result & 0x00000080))
	return result;
      result = result & 0x0000007f | readUnsignedByte()<<7;
      if (!(result & 0x00004000))
	return result;
      result = result & 0x00003fff | readUnsignedByte()<<14;
      if (!(result & 0x00200000))
	return result;
      result = result & 0x001fffff | readUnsignedByte()<<21;
      if (!(result & 0x10000000))
	return result;
      return result & 0x0fffffff | readUnsignedByte()<<28;
    }

    
    public function readStringInfo(size:uint):String{
      //var size:uint = readU30(ba);
      var s:String = "";
      while(size){
	s += String.fromCharCode(readUnsignedByte());
	size--;
      }
      return s;
    }
    
    public function readString():String{
      var charCode:uint = readUnsignedByte();
      var s:String = "";
      while(charCode){
        s += String.fromCharCode(charCode);
        charCode = readUnsignedByte();
      }
      return s;
    }
    


    // XXX: I have no idea whether this will read a RECT from any other position than 8
    public function readRECT():Vector.<int>{
      var nbits:uint = this[position];
      var size:uint = nbits >> 3;
      var dimensions:Vector.<int> = new Vector.<int>();
      var neg_root:int = 1 << (size - 1);
      var bitOffset:int = (size % 8) ? (8 - (size % 8)) : 0;
      var byteOffset:int = (size + bitOffset) / 8;
      var ioffset:int;
      var ibuf:int = nbits % 8;
      for(var i:uint = 0; i < 4; i++){
	ioffset = position + byteOffset * i;
	for(var j:uint = 0; j < byteOffset; j++){
	  ibuf <<= 8;
	  ibuf += this[1 + ioffset + j];
	}
	dimensions[i] = (ibuf >> (3 + bitOffset + (i * bitOffset))) / 20;
	if(dimensions[i] >= neg_root){
	  dimensions[i] = (-1) * (neg_root - (dimensions[i] - neg_root));
	}
	var expn:int = 3 + bitOffset + (i * bitOffset);
	ibuf = ibuf % (1 << (expn - 1));
      }
      position = 1 + ioffset + j;
      return dimensions;
    }


    public function readFixed88():Number{
      return Number(readUnsignedShort() * Math.pow(2, -8));
    }

    public function writeFixed88(num:Number):void{
      writeShort(Math.round(num * Math.pow(2, 8)));
    }

    public static function formatBinaryByte(byte:uint):String {
      var formattedByte:String = byte.toString(2);
      while(formattedByte.length < 8)
        formattedByte = "0" + formattedByte;
      return formattedByte;
    }


  }

}
