package ch.forea.bytemyas{

  import flash.utils.ByteArray;
  import flash.utils.Endian;

  /**
  * SWFArray
  *
  *
  */
  public class SWFArray extends ByteArray{
    
    public function SWFArray(swf:ByteArray = null){
      super();
      endian = Endian.LITTLE_ENDIAN;

      if(swf){
	swf.readBytes(this);
	if(this[0] == 0x43){
	  uncompress();
	}
	//trace(readTags(_swf));    
      }

    }
    
    public function validate():void{
      switch(this[0]|this[1]<<8|this[2]<<16|this[3]<<24){
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
    
    public override function compress():void{
      var compressedData:ByteArray = new ByteArray();
      compressedData.writeBytes(this, 8);
      compressedData.compress();
      length = 8;
      position = 8;
      writeBytes(compressedData);
      this[0] = 0x43;
    }

    public override function uncompress():void{
      var uncompressedData:ByteArray = new ByteArray();
      uncompressedData.writeBytes(this, 8);
      uncompressedData.uncompress();
      length = 8;
      position = 8;
      writeBytes(uncompressedData);
      this[0] = 0x46;
    }
    

    public static const DOABC:uint = 82;


    // this is a temp method to quickly skip to a specific tag
    public function getTag(swf:ByteArray, id:uint, index:int = -1):Array{
      swf.position = getHeaderLength(swf);
      var tags:Array = [];
      var tagHeaderPosition:uint;
      var tagHeader:uint;
      var tagID:uint;
      var tagLength:uint;
      var foundIndex:uint = 0;
      while(swf.position != swf.length){
        tagHeaderPosition = swf.position;
        tagHeader = swf.readUnsignedShort();
        tagID = tagHeader >> 6;
        tagLength = tagHeader & 63;
        if(tagLength == 63) tagLength = swf.readUnsignedInt();
        if(tagID == id){
	  if(index == -1){
	    tags[tags.length] = tagHeaderPosition;
	  }else if(foundIndex++ == index){
	    tags[tags.length] = tagHeaderPosition;
	    return tags;
	  }
        }
        swf.position += tagLength;
      }
      return tags;
    }

    public function readTag():Tag{
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
      
      var tagData:ByteArray = new ByteArray();
      tagData.endian = Endian.LITTLE_ENDIAN;
      tagData.writeBytes(this, tagHeaderPosition, tagLength + (tagLength < 63 ? 2 : 6));
      tagData.position = 0;
      
      this.position = tagHeaderPosition + tagLength + (tagLength < 63 ? 2 : 6);

      var c:Class = Tag.getClass(tagID);
      if(c){
	return new c(tagID, tagLength, tagData);
      }
      return new Tag(tagID, tagLength, tagData);
    }

    
    private function getHeaderLength(swf:ByteArray):uint{
      // Signature + Version + FileLength + FrameSize + FrameRate + FrameCount
      return 3 + 1 + 4 + (Math.ceil(((swf[8] >> 3) * 4 - 3) / 8) + 1) + 2 + 2;
    }
    
    private function splice(ba:ByteArray, index:uint, deleteLength:uint, value:ByteArray):void{
      var temp:ByteArray = new ByteArray();
      ba.position = index;
      temp.writeBytes(ba, index + deleteLength);
      ba.length = index;
      ba.position = index;
      ba.writeBytes(value);
      temp.position = 0;
      ba.writeBytes(temp);
    }
    
    // Totally stolen from Tamarin's utils/abcdump.as
    /**
     * Reads a signed 24-bit integer from the byte stream.
     */
    public function readS24(ba:ByteArray):int{
      var b:int = ba.readUnsignedByte();
      b |= ba.readUnsignedByte() << 8;
      b |= ba.readByte() << 16;
      return b;
    }
    
    // Totally stolen from Tamarin's utils/abcdump.as
    /**
     * Reads an unsigned 30-bit/32-bit integer from the byte stream.
     */
    public function readU32(ba:ByteArray):int{
      var result:int = ba.readUnsignedByte();
      if (!(result & 0x00000080))
	return result;
      result = result & 0x0000007f | ba.readUnsignedByte()<<7;
      if (!(result & 0x00004000))
	return result;
      result = result & 0x00003fff | ba.readUnsignedByte()<<14;
      if (!(result & 0x00200000))
	return result;
      result = result & 0x001fffff | ba.readUnsignedByte()<<21;
      if (!(result & 0x10000000))
	return result;
      return result & 0x0fffffff | ba.readUnsignedByte()<<28;
    }

    private function readStringInfo(ba:ByteArray, size:uint):String{
      //var size:uint = readU30(ba);
      var s:String = "";
      while(size){
	s += String.fromCharCode(ba.readUnsignedByte());
	size--;
      }
      return s;
    }

    private function readString(ba:ByteArray):String{
      var charCode:uint = ba.readUnsignedByte();
      var s:String = "";
      while(charCode){
        s += String.fromCharCode(charCode);
        charCode = ba.readUnsignedByte();
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

    
    public function createIndex(abc:ByteArray):Index{
      var index:Index = new Index();
      var currentPosition:uint;
      var newPosition:uint;
      var i:uint;
      var j:uint;
      var count:uint;
      var inner_count:uint;
      
      abc.position = 0;
      
      var tagHeader:uint = abc.readUnsignedShort();
      var tagID:uint = tagHeader >> 6;
      var tagLength:uint = tagHeader & 63;
      if(tagLength == 63) tagLength = abc.readUnsignedInt();
      
      abc.readUnsignedInt(); // flags
      readString(abc); // name
      
      index.minor_version = abc.position;
      abc.readUnsignedShort();
      
      index.major_version = abc.position;
      abc.readUnsignedShort();
      
      // 4.3 Constant Pool
      index.constant_pool.int_count = abc.position;
      count = readU32(abc);
      for(i = 1; i < count; i++){
	index.constant_pool.integer[i] = abc.position;
	readU32(abc);
      }
      
      index.constant_pool.uint_count = abc.position;
      count = readU32(abc);
      for(i = 1; i < count; i++){
	index.constant_pool.uinteger[i] = abc.position;
	readU32(abc);
      }
      
      index.constant_pool.double_count = abc.position;
      count = readU32(abc);
      for(i = 1; i < count; i++){
	index.constant_pool.double[i] = abc.position;
	abc.readDouble();
      }
      
      index.constant_pool.string_count = abc.position;
      count = readU32(abc);
      for(i = 1; i < count; i++){
	index.constant_pool.string[i] = abc.position;
	var string_size:uint = readU32(abc);
	readStringInfo(abc, string_size);
      }
      
      index.constant_pool.namespace_count = abc.position;
      count = readU32(abc);
      for(i = 1; i < count; i++){
	index.constant_pool.addNamespace();
	index.constant_pool.ns[i].kind = abc.position;
	abc.position++;
	index.constant_pool.ns[i].name = abc.position;
	readU32(abc);
      }
      
      index.constant_pool.ns_set_count = abc.position;
      count = readU32(abc);
      for(i = 1; i < count; i++){
	index.constant_pool.addNsSet();
	index.constant_pool.ns_set[i].count = abc.position;
	inner_count = readU32(abc);
	for(j = 0; j < inner_count; j++){
	  index.constant_pool.ns_set[i].ns[j] = abc.position;
	  readU32(abc);
	}
      }
      
      index.constant_pool.multiname_count = abc.position;
      count = readU32(abc);
      for(i = 1; i < count; i++){
	index.constant_pool.addMultiname();
	index.constant_pool.multiname[i].kind = abc.position;
	if(abc[abc.position] == 0x07 || abc[abc.position] == 0x0D){
	  abc.position++;
	  index.constant_pool.multiname[i].data.ns = abc.position;
	  readU32(abc);
	  index.constant_pool.multiname[i].data.name = abc.position;
	  readU32(abc);
	}else if(abc[abc.position] == 0x0F || abc[abc.position] == 0x10){
	  abc.position++;
	  index.constant_pool.multiname[i].data.name = abc.position;
	  readU32(abc);
	}else if(abc[abc.position] == 0x11 || abc[abc.position] == 0x12){
	  abc.position++;
	}else if(abc[abc.position] == 0x09 || abc[abc.position] == 0x0E){
	  abc.position++;
	  index.constant_pool.multiname[i].data.name = abc.position;
	  readU32(abc);
	  index.constant_pool.multiname[i].data.ns_set = abc.position;
	  readU32(abc);
	}else if(abc[abc.position] == 0x1B || abc[abc.position] == 0x1C){
	  abc.position++;
	  index.constant_pool.multiname[i].data.ns_set = abc.position;
	  readU32(abc);
	}
      }
      
      // 4.5 Method Signature
      index.method_count = abc.position;
      count = readU32(abc);
      for(i = 0; i < count; i++){
	index.addMethod();
	index.method[i].param_count = abc.position;
	var param_count:uint = readU32(abc);
	index.method[i].return_type = abc.position;
	readU32(abc);
	for(j = 0; j < param_count; j++){
	  index.method[i].param_type[j] = abc.position;
	  readU32(abc);
	}
	index.method[i].name = abc.position;
	readU32(abc);
	index.method[i].flags = abc.position;
	var method_flags:uint = abc.readUnsignedByte();
	if(method_flags >> 3 & 1){
	  index.method[i].options.option_count = abc.position;
	  inner_count = readU32(abc);
	  for(j = 0; j < inner_count; j++){
	    index.method[i].options.option[j].val = abc.position;
	    readU32(abc);
	    index.method[i].options.option[j].kind = abc.position;
	    abc.readUnsignedByte();
	  }
	}
	if(method_flags >> 7 & 1){
	  for(j = 0; j < param_count; j++){
	    index.method[i].param_names[j].param_name = abc.position;
	    readU32(abc);
	  }
	}
      }
      
      // 4.6 metadata_info
      index.metadata_count = abc.position;
      count = readU32(abc);
      for(i = 0; i < count; i++){
	index.addMetadata();
	index.metadata[i].name = abc.position;
	readU32(abc);
	index.metadata[i].item_count = abc.position;
	inner_count = readU32(abc);
	for(j = 0; j < inner_count; j++){
	  index.metadata[i].addItem();
	  index.metadata[i].item[j].key = abc.position;
	  readU32(abc);
	  index.metadata[i].item[j].value = abc.position;
	  readU32(abc);
	}
      }
      
      index.class_count = abc.position;
      var class_count:uint = readU32(abc);
      
      // 4.7 Instance
      for(i = 0; i < class_count; i++){
	index.addInstance();
	index.instance[i].name = abc.position;
	readU32(abc);
	index.instance[i].super_name = abc.position;
	readU32(abc);
	index.instance[i].flags = abc.position;
	var instance_flags:uint = abc.readUnsignedByte();
	if(instance_flags >> 3 & 1){
	  index.instance[i].protectedNs = abc.position;
	  readU32(abc);
	}
	index.instance[i].intrf_count = abc.position;
	inner_count = readU32(abc);
	for(j = 0; j < inner_count; j++){
	  index.instance[i].intrf[j] = abc.position;
	  readU32(abc);
	}
	index.instance[i].iinit = abc.position;
	readU32(abc);
	indexTraits(abc, index.instance[i]);
      }
      
      // 4.9 Class
      for(i = 0; i < class_count; i++){
	index.addClass();
	index.clss[i].cinit = abc.position;
	readU32(abc);
	indexTraits(abc, index.clss[i]);
      }
      
      // 4.10 Script
      index.script_count = abc.position;
      count = readU32(abc);
      for(i = 0; i < count; i++){
	index.addScript();
	index.script[i].init = abc.position;
	readU32(abc);
	indexTraits(abc, index.script[i]);
      }
      
      // 4.11 Method body
      index.method_body_count = abc.position;
      count = readU32(abc);
      for(i = 0; i < count; i++){
	index.addMethodBody();
	index.method_body[i].method = abc.position;
	readU32(abc);
	index.method_body[i].max_stack = abc.position;
	readU32(abc);
	index.method_body[i].local_count = abc.position;
	readU32(abc);
	index.method_body[i].init_scope_depth = abc.position;
	readU32(abc);
	index.method_body[i].max_scope_depth = abc.position;
	readU32(abc);
	index.method_body[i].code_length = abc.position;
	var code_length:uint = readU32(abc);
	abc.position += code_length;
	index.method_body[i].exception_count = abc.position;
	inner_count = readU32(abc);
	for(j = 0; j < inner_count; j ++){
	  index.method_body[i].addException();
	  index.method_body[i].exception[j].from = abc.position;
	  readU32(abc);
	  index.method_body[i].exception[j].to = abc.position;
	  readU32(abc);
	  index.method_body[i].exception[j].target = abc.position;
	  readU32(abc);
	  index.method_body[i].exception[j].exc_type = abc.position;
	  readU32(abc);
	  index.method_body[i].exception[j].var_name = abc.position;
	  readU32(abc);
	}
	indexTraits(abc, index.method_body[i]);
      }
      return index;
    }
    
    public static  function formatBinaryByte(byte:uint):String {
      var formattedByte:String = byte.toString(2);
      while(formattedByte.length < 8)
        formattedByte = "0" + formattedByte;
      return formattedByte;
    }

    private function indexTraits(abc:ByteArray, objectWithTraits:Trait):void{
      var i:uint;
      var count:uint;
      
      objectWithTraits.trait_count = abc.position;
      count = readU32(abc);
      for(i = 0; i < count; i++){
	objectWithTraits.addTrait();
	objectWithTraits.trait[i].name = abc.position;
	readU32(abc);
	objectWithTraits.trait[i].kind = abc.position;
	var trait_kind:uint = abc.readUnsignedByte();
	
	// 4.8.2 Slot and const traits
	if((trait_kind & 15) == 0 || (trait_kind & 15) == 6){
	  objectWithTraits.trait[i].data.slot_id = abc.position;
	  readU32(abc);
	  objectWithTraits.trait[i].data.type_name = abc.position;
	  readU32(abc);
	  objectWithTraits.trait[i].data.vindex = abc.position;
	  if(readU32(abc)){
	    objectWithTraits.trait[i].data.vkind = abc.position;
	    abc.readUnsignedByte();
	  }
	}
	
	// 4.8.3 Class traits
	if((trait_kind & 15) == 4){
	  objectWithTraits.trait[i].data.slot_id = abc.position;
	  readU32(abc);
	  objectWithTraits.trait[i].data.classi = abc.position;
	  readU32(abc);
	}
	
	// 4.8.4 Function traits
	if((trait_kind & 15) == 5){
	  objectWithTraits.trait[i].data.slot_id = abc.position;
	  readU32(abc);
	  objectWithTraits.trait[i].data.fun = abc.position;
	  readU32(abc);
	}
	
	// 4.8.5 Method, getter, and setter traits
	if((trait_kind & 15) == 1 || (trait_kind & 15) == 2 || (trait_kind & 15) == 3){
	  objectWithTraits.trait[i].data.disp_id = abc.position;
	  readU32(abc);
	  objectWithTraits.trait[i].data.method = abc.position;
	  readU32(abc);
	}
      }
    }
  }
}

internal class Index{
  public var minor_version:uint;
  public var major_version:uint;
  public var constant_pool:CPoolInfo = new CPoolInfo();
  public var method_count:uint;
  public var method:Vector.<MethodInfo> = new Vector.<MethodInfo>();
  public function addMethod():void{
    method.push(new MethodInfo());
  }
  public var metadata_count:uint;
  public var metadata:Vector.<MetadataInfo> = new Vector.<MetadataInfo>();
  public function addMetadata():void{
    metadata.push(new MetadataInfo());
  }
  public var class_count:uint;
  public var instance:Vector.<InstanceInfo> = new Vector.<InstanceInfo>();
  public function addInstance():void{
    instance.push(new InstanceInfo());
  }
  public var clss:Vector.<ClassInfo> = new Vector.<ClassInfo>();
  public function addClass():void{
    clss.push(new ClassInfo());
  }
  public var script_count:uint;
  public var script:Vector.<ScriptInfo> = new Vector.<ScriptInfo>();
  public function addScript():void{
    script.push(new ScriptInfo());
  }
  public var method_body_count:uint;
  public var method_body:Vector.<MethodBodyInfo> = new Vector.<MethodBodyInfo>();
  public function addMethodBody():void{
    method_body.push(new MethodBodyInfo());
  }
  public function invalidate(index:uint, difference:int):void{
    if(minor_version > index) minor_version += difference;
  }
}

internal class CPoolInfo{

  public var int_count:uint;
  public var integer:Vector.<uint> = Vector.<uint>([0]);
  public var uint_count:uint;
  public var uinteger:Vector.<uint> = Vector.<uint>([0]);
  public var double_count:uint;
  public var double:Vector.<uint> = Vector.<uint>([0]);
  public var string_count:uint;
  public var string:Vector.<uint> = Vector.<uint>([0]);
  public var namespace_count:uint;
  public var ns:Vector.<NamespaceInfo> = Vector.<NamespaceInfo>([new NamespaceInfo()]);
  public function addNamespace():void{
    ns.push(new NamespaceInfo());
  }
  public var ns_set_count:uint; 
  public var ns_set:Vector.<NsSetInfo> = Vector.<NsSetInfo>([new NsSetInfo()]);
  public function addNsSet():void{
    ns_set.push(new NsSetInfo());
  }
  public var multiname_count:uint;
  public var multiname:Vector.<MultinameInfo> = Vector.<MultinameInfo>([new MultinameInfo()]);
  public function addMultiname():void{
    multiname.push(new MultinameInfo());
  }

  public function toString():String{
    var val:String = "\tcpool_info{\n";
    val += "\t\tint_count = " + int_count + "\n";
    val += "\t\tinteger = " + integer + "\n";
    val += "\t\tuint_count = " + uint_count + "\n";
    val += "\t\tuinteger = " + uinteger + "\n";
    val += "\t\tdouble_count = " + double_count + "\n";
    val += "\t\tdouble = " + double + "\n";
    val += "\t\tstring_count = " + string_count + "\n";
    val += "\t\tstring = " + string + "\n";
    val += "\t\tnamespace_count = " + namespace_count + "\n";
    val += "\t\tns = " + ns + "\n";
    val += "\t\tns_set_count = " + ns_set_count + "\n";
    val += "\t\tns_set =" + ns_set + "\n";
    val += "\t\tmultiname_count = " + multiname_count + "\n";
    val += "\t\tmultiname = " + multiname + "\n";
    val += "}\n";
    return val;
  }

}

internal class NamespaceInfo{

  public var kind:uint; 
  public var name:uint;

  public function toString():String{
    var val:String = "\n\t\t\tNamespaceInfo{\n";
    val += "\t\t\t\tkind = " + kind + "\n";
    val += "\t\t\t\tname = " + name + "\n";
    val += "\t\t\t}";
    return val;
  }
}

internal class NsSetInfo{

  public var count:uint;
  public var ns:Vector.<uint> = new Vector.<uint>();
  
  public function toString():String{
    var val:String = "\n\t\t\tNsSetInfo{\n";
    val += "\t\t\t\tcount = " + count + "\n";
    val += "\t\t\t\tns = " + ns + "\n";
    val += "\t\t\t}";
    return val;
  }

}

internal class MultinameInfo{

  public var kind:uint;
  public var data:MultinameKind = new MultinameKind();

  public function toString():String{
    var val:String = "\n\t\t\tMultinameInfo{\n";
    val += "\t\t\t\tkind = " + kind + "\n";
    val += "\t\t\t\tdata = " + data + "\n";
    val += "\t\t\t}";
    return val;
  }

}

internal class MultinameKind{

  public var ns:uint;
  public var name:uint;
  public var ns_set:uint;

  public function toString():String{
    var val:String = "\n\t\t\t\tMultinameKind{\n";
    val += "\t\t\t\t\tns = " + ns + "\n";
    val += "\t\t\t\t\tname = " + name + "\n";
    val += "\t\t\t\t\tns_set = " + ns_set + "\n";
    val += "\t\t\t\t}";
    return val;
  }

}

internal class MethodInfo{

  public var param_count:uint;
  public var return_type:uint;
  public var param_type:Vector.<uint> = new Vector.<uint>();
  public var name:uint;
  public var flags:uint; 
  public var options:OptionInfo = new OptionInfo();
  public var param_names:ParamInfo = new ParamInfo();

}

internal class OptionInfo{

  public var option_count:uint;
  public var option:Vector.<OptionDetail> = new Vector.<OptionDetail>();

}

internal class OptionDetail{

  public var val:uint;
  public var kind:uint;

}

internal class ParamInfo{

  public var param_name:uint;

}

internal class MetadataInfo{

  public var name:uint;
  public var item_count:uint;
  public var item:Vector.<ItemInfo> = new Vector.<ItemInfo>();
  public function addItem():void{
    item.push(new ItemInfo());
  }

}

internal class ItemInfo{

  public var key:uint;
  public var value:uint;

}

internal class InstanceInfo implements Trait{

  public var name:uint;
  public var super_name:uint;
  public var flags:uint;
  public var protectedNs:uint; 
  public var intrf_count:uint;
  public var intrf:Vector.<uint> = new Vector.<uint>();
  public var iinit:uint;
  private var _trait_count:uint; 
  public function get trait_count():uint{
    return _trait_count;
  }
  public function set trait_count(count:uint):void{
    _trait_count = count;
  }
  private var _trait:Vector.<TraitsInfo> = new Vector.<TraitsInfo>();
  public function get trait():Vector.<TraitsInfo>{
    return _trait;
  }
  public function addTrait():void{
    trait.push(new TraitsInfo());
  }

  public function toString():String{
    var val:String = "\n\t\tInstanceInfo{\n";
    val += "\t\t\tname = " + name + "\n";
    val += "\t\t\tsuper_name = " + super_name + "\n";
    val += "\t\t\tflags = " + flags + "\n";
    val += "\t\t\tprotectedNs = " + protectedNs + "\n";
    val += "\t\t\tintrf_count = " + intrf_count + "\n";
    val += "\t\t}";
    return val;
  }

}

internal class ClassInfo implements Trait{

  public var cinit:uint;
  private var _trait_count:uint; 
  public function get trait_count():uint{
    return _trait_count;
  }
  public function set trait_count(count:uint):void{
    _trait_count = count;
  }
  private var _trait:Vector.<TraitsInfo> = new Vector.<TraitsInfo>();
  public function get trait():Vector.<TraitsInfo>{
    return _trait;
  }
  public function addTrait():void{
    trait.push(new TraitsInfo());
  }

  public function toString():String{
    var val:String = "\n\t\tClassInfo{\n";
    val += "\t\t\tcinit = " + cinit + "\n";
    val += "\t\t\ttrait_count = " + _trait_count + "\n";
    val += "\t\t}";
    return val;
  }

}

internal class ScriptInfo implements Trait{

  public var init:uint;
  private var _trait_count:uint; 
  public function get trait_count():uint{
    return _trait_count;
  }
  public function set trait_count(count:uint):void{
    _trait_count = count;
  }
  private var _trait:Vector.<TraitsInfo> = new Vector.<TraitsInfo>();
  public function get trait():Vector.<TraitsInfo>{
    return _trait;
  }
  public function addTrait():void{
    trait.push(new TraitsInfo());
  }

  public function toString():String{
    var val:String = "\n\t\tScriptInfo{\n";
    val += "\t\t\tinit = " + init + "\n";
    val += "\t\t\ttrait_count = " + _trait_count + "\n";
    val += "\t\t}";
    return val;
  }

}

internal class MethodBodyInfo implements Trait{

  public var method:uint;
  public var max_stack:uint;
  public var local_count:uint;
  public var init_scope_depth:uint;
  public var max_scope_depth:uint;
  public var code_length:uint;
  //public var code:Vector.<uint> = new Vector.<uint>();
  public var exception_count:uint;
  public var exception:Vector.<ExceptionInfo> = new Vector.<ExceptionInfo>();
  public function addException():void{
    exception.push(new ExceptionInfo());
  }
  private var _trait_count:uint; 
  public function get trait_count():uint{
    return _trait_count;
  }
  public function set trait_count(count:uint):void{
    _trait_count = count;
  }
  private var _trait:Vector.<TraitsInfo> = new Vector.<TraitsInfo>();
  public function get trait():Vector.<TraitsInfo>{
    return _trait;
  }
  public function addTrait():void{
    trait.push(new TraitsInfo());
  }

  public function toString():String{
    var val:String = "\n\t\tMethodBodyInfo{\n";
    val += "\t\t\tmethod = " + method + "\n";
    val += "\t\t\tmax_stack = " + max_stack + "\n";
    val += "\t\t\tlocal_count = " + local_count + "\n";
    val += "\t\t\tinit_scope_depth = " + init_scope_depth + "\n";
    val += "\t\t\tmax_scope_depth = " + max_scope_depth + "\n";
    val += "\t\t\tcode_length = " + code_length + "\n";
    val += "\t\t\texception_count = " + exception_count + "\n";
    val += "\t\t\texception = " + exception + "\n";
    val += "\t\t\ttrait_count = " + _trait_count + "\n";
    val += "\t\t}";
    return val;
  }

}

internal class ExceptionInfo{

  public var from:uint;
  public var to:uint;
  public var target:uint;
  public var exc_type:uint;
  public var var_name:uint;

}



internal interface Trait{

  function addTrait():void;
  function get trait_count():uint;
  function set trait_count(cout:uint):void;
  function get trait():Vector.<TraitsInfo>;
  
}

internal class TraitsInfo{

  public var name:uint;
  public var kind:uint;
  public var data:TraitKind = new TraitKind();
  public var metadata_count:uint;
  public var metadata:Vector.<uint> = new Vector.<uint>();
  
}

internal class TraitKind{

  public var slot_id:uint;
  public var type_name:uint;
  public var vindex:uint;
  public var vkind:uint;
  public var classi:uint;
  public var fun:uint;
  public var disp_id:uint;
  public var method:uint;

}