package ch.forea.bytemyas {

  import flash.utils.ByteArray;
  import flash.utils.Endian;


// TODO: Move most of the read/write functions out so DataObject can enjoy them too
  /**
  * SWFArray
  *
  *
  */
  public class SWFArray extends ComplexByteArray {
    
    public function SWFArray(swf:ByteArray = null) {
      super();
      endian = Endian.LITTLE_ENDIAN;

      if(swf) {
	swf.readBytes(this);
	if(this[0] == 0x43) {
	  uncompress();
	}
	//trace(readTags(_swf));    
      }

    }
    
    public function validate():void {
      switch(this[0]|this[1]<<8|this[2]<<16|this[3]<<24) {
	// compressed
      case 67|87<<8|83<<16|10<<24: // version 10
      case 67|87<<8|83<<16|9<<24: // version 9
	// uncompressed
      case 70|87<<8|83<<16|10<<24: // version 10
      case 70|87<<8|83<<16|9<<24: // version 9
	return;
      default:
	throw new Error("Not a valid SWF file");
      }
    }
    
    public override function compress():void {
      var compressedData:ComplexByteArray = new ComplexByteArray();
      compressedData.writeBytes(this, 8);
      compressedData.compress();
      length = 8;
      position = 8;
      writeBytes(compressedData);
      this[0] = 0x43;
    }

    public override function uncompress():void {
      var uncompressedData:ComplexByteArray = new ComplexByteArray();
      uncompressedData.writeBytes(this, 8);
      uncompressedData.uncompress();
      length = 8;
      position = 8;
      writeBytes(uncompressedData);
      this[0] = 0x46;
    }

    // this is a temp method to quickly skip to a specific tag
    public function getTag(id:uint, index:int = -1):Array {
      position = getHeaderLength();
      var tags:Array = [];
      var tagHeaderPosition:uint;
      var tagHeader:uint;
      var tagID:uint;
      var tagLength:uint;
      var foundIndex:uint = 0;
      while(position != length) {
        tagHeaderPosition = position;
        tagHeader = readUnsignedShort();
        tagID = tagHeader >> 6;
        tagLength = tagHeader & 63;
        if(tagLength == 63)
	  tagLength = readUnsignedInt();
        if(tagID == id) {
	  if(index == -1) {
	    tags[tags.length] = tagHeaderPosition;
	  }else if(foundIndex++ == index) {
	    tags[tags.length] = tagHeaderPosition;
	    return tags;
	  }
        }
        position += tagLength;
      }
      return tags;
    }

    public function readTag():Tag {
      var tagHeaderPosition:uint;
      var tagHeader:uint;
      var tagID:uint;
      var tagLength:uint;
      tagHeaderPosition = this.position;
      tagHeader = this.readUnsignedShort();
      tagID = tagHeader >> 6;
      tagLength = tagHeader & 63;
      if(tagLength == 63)
        tagLength = this.readInt();
      
      var tagData:ComplexByteArray = new ComplexByteArray();
      tagData.endian = Endian.LITTLE_ENDIAN;
      tagData.writeBytes(this, tagHeaderPosition, tagLength + (tagLength < 63 ? 2 : 6));
      tagData.position = 0;
      
      this.position = tagHeaderPosition + tagLength + (tagLength < 63 ? 2 : 6);

      var c:Class = Tag.getClass(tagID);
      if(c) {
	return new c(tagID, tagLength, tagData);
      }
      return new Tag(tagID, tagLength, tagData);
    }

    private function getHeaderLength():uint {
      // Signature + Version + FileLength + FrameSize + FrameRate + FrameCount
      return 3 + 1 + 4 + (Math.ceil(((this[8] >> 3) * 4 - 3) / 8) + 1) + 2 + 2;
    }
    
  }
}
