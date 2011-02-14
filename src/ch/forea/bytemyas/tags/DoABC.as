package ch.forea.bytemyas.tags {

  import ch.forea.bytemyas.ComplexByteArray;
  import ch.forea.bytemyas.Tag;
    
  public class DoABC extends Tag{

    private static const K_DO_ABC_LAZY_INITIALIZE:uint = 0x1; // 1

    public function DoABC(id:uint, length:uint, data:ComplexByteArray){
      super(id, length, data, ['kDoAbcLazyInitialize', 'doAbcName']);
      try {
	trace(createIndex());
      } catch(e:Error) {
	trace(e.message);
      }
    }

    public function get kDoAbcLazyInitialize():Boolean {
      var tempData:ComplexByteArray = data;
      tempData.position = length < 0x3F ? 2 : 6;
      return (tempData.readUnsignedInt() & K_DO_ABC_LAZY_INITIALIZE) == K_DO_ABC_LAZY_INITIALIZE;
    }
    public function set kDoAbcLazyInitialize(b:Boolean):void {
      updateBitFlag(K_DO_ABC_LAZY_INITIALIZE, b);
    }

    private function updateBitFlag(flag:uint, value:Boolean):void {
      var tempData:ComplexByteArray = data;
      tempData.position = length < 0x3F ? 2 : 6;
      var flags:uint = tempData.readUnsignedByte();
      if((value && flags & flag) || (!value && !(flags & flag)))
        return;
      tempData.position = length < 0x3F ? 2 : 6;
      tempData.writeByte(value ? flags | flag : flags ^ flag);
      data = tempData;
    }

    public function get doAbcName():String {
      var tempData:ComplexByteArray = data;
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


    private var stringConstantArray:Array = [];
    private var multinameArray:Array = [];
    public function createIndex():ABCIndex{
      var tempData:ComplexByteArray = data;
      var index:ABCIndex = new ABCIndex();
      var currentPosition:uint;
      var newPosition:uint;
      var i:uint;
      var j:uint;
      var count:uint;
      var inner_count:uint;
      
      tempData.position = 0;
      
      var tagHeader:uint = tempData.readUnsignedShort();
      var tagID:uint = tagHeader >> 6;
      var tagLength:uint = tagHeader & 63;
      if(tagLength == 63) tagLength = tempData.readUnsignedInt();
      
      tempData.readUnsignedInt(); // flags

      trace('DoABC');

      trace('name = ' + tempData.readString()); // name
      
      index.minor_version = tempData.position;
      trace('minor_version = ' + tempData.readUnsignedShort());
      
      index.major_version = tempData.position;
      trace('major_version = ' + tempData.readUnsignedShort());
      
      trace('constant_pool');
      // 4.3 Constant Pool
      index.constant_pool.int_count = tempData.position;
      count = tempData.readU32();
      trace('int_count = ' + count);
      for(i = 1; i < count; i++){
	index.constant_pool.integer[i - 1] = tempData.position;
	trace(tempData.readU32());
      }
      
      index.constant_pool.uint_count = tempData.position;
      count = tempData.readU32();
      trace('uint_count = ' + count);
      for(i = 1; i < count; i++){
	index.constant_pool.uinteger[i - 1] = tempData.position;
	trace(tempData.readU32());
      }
      
      index.constant_pool.double_count = tempData.position;
      count = tempData.readU32();
      trace('double_count = ' + count);
      for(i = 1; i < count; i++){
	index.constant_pool.double[i - 1] = tempData.position;
	trace(tempData.readDouble());
      }
      
      index.constant_pool.string_count = tempData.position;
      count = tempData.readU32();
      trace('string_count = ' + count);

      stringConstantArray = [];

      for(i = 1; i < count; i++){
	index.constant_pool.string[i - 1] = tempData.position;
	var string_size:uint = tempData.readU32();
	stringConstantArray.push(tempData.readStringInfo(string_size));
      }
      trace(stringConstantArray);

      index.constant_pool.namespace_count = tempData.position;
      count = tempData.readU32();
      trace('namespace_count = ' + count);
      var tempNamespaceArray:Array = [];
      for(i = 1; i < count; i++){
	index.constant_pool.addNamespace();
	index.constant_pool.ns[i - 1].kind = tempData.position;
	tempData.position++;
	index.constant_pool.ns[i - 1].name = tempData.position;

	var tempNameIndex:uint = tempData.readU32();

	tempNamespaceArray.push(stringConstantArray[tempNameIndex - 1]);
      }
      trace(tempNamespaceArray);
      

      index.constant_pool.ns_set_count = tempData.position;
      count = tempData.readU32();
      trace('ns_set_count = ' + count);
      for(i = 1; i < count; i++){
	index.constant_pool.addNsSet();
	index.constant_pool.ns_set[i - 1].count = tempData.position;
	inner_count = tempData.readU32();
	trace('inner_count = ' + inner_count);
	for(j = 0; j < inner_count; j++){
	  index.constant_pool.ns_set[i - 1].ns[j] = tempData.position;
	  trace('ns_set[' + (i - 1) + '].ns[' + j + '] = ' + tempNamespaceArray[tempData.readU32() - 1]);
	}
      }
      
      index.constant_pool.multiname_count = tempData.position;
      count = tempData.readU32();
      trace('multiname_count = ' + count);
      
      multinameArray = [];
      
      for(i = 1; i < count; i++){
	index.constant_pool.addMultiname();
	index.constant_pool.multiname[i - 1].kind = tempData.position;
	
	switch(tempData[tempData.position]){
	  case 0x07:
	    trace('QName');
	    break;
	  case 0x0D:
	    trace('QNameA');
	    break;
	  case 0x0F:
	    trace('RTQName');
	    break;
	  case 0x10:
	    trace('RTQNameA');
	    break;
	  case 0x11:
	    trace('RTQNameL');
	    break;
	  case 0x12:
	    trace('RTQNameLA');
	    break;
	  case 0x09:
	    trace('Multiname');
	    break;
	  case 0x0E:
	    trace('MultinameA');
	    break;
	  case 0x1B:
	    trace('MultinameL');
	    break;
	  case 0x1C:
	    trace('MultinameLA');
	    break;
	  case 0x13:
	  case 0x14:
	    trace('UNKNOWN (NameL?)');
	    break;
	  case 0x1D:
	    trace('???');
	    break;
	  default:
	    trace('ERROR, unknown code: 0x' + tempData[tempData.position].toString(16));
        }
	if(tempData[tempData.position] == 0x07 || tempData[tempData.position] == 0x0D){
	  tempData.position++;
	  index.constant_pool.multiname[i - 1].data.ns = tempData.position;

	  var tempNS:uint = tempData.readU32();
	  trace('ns = ' + tempNamespaceArray[tempNS - 1]);

	  index.constant_pool.multiname[i - 1].data.name = tempData.position;

	  var tempName:uint = tempData.readU32();
	  trace('name = ' + stringConstantArray[tempName - 1]);

	  multinameArray.push(stringConstantArray[tempName - 1]);

	}else if(tempData[tempData.position] == 0x0F || tempData[tempData.position] == 0x10){
	  tempData.position++;
	  index.constant_pool.multiname[i - 1].data.name = tempData.position;

	  multinameArray.push(stringConstantArray[tempData.readU32() - 1]);

	}else if(tempData[tempData.position] == 0x11 || tempData[tempData.position] == 0x12){
	  tempData.position++;
	}else if(tempData[tempData.position] == 0x09 || tempData[tempData.position] == 0x0E){
	  tempData.position++;
	  index.constant_pool.multiname[i - 1].data.name = tempData.position;

	  multinameArray.push(stringConstantArray[tempData.readU32() - 1]);

	  index.constant_pool.multiname[i - 1].data.ns_set = tempData.position;
	  tempData.readU32();
	}else if(tempData[tempData.position] == 0x1B || tempData[tempData.position] == 0x1C){
	  tempData.position++;
	  index.constant_pool.multiname[i - 1].data.ns_set = tempData.position;
	  tempData.readU32();

	  multinameArray.push('');

	}else if(tempData[tempData.position] == 0x1D){
	  // WARNING: undocumented
	  tempData.position++;
	  var nameIndex:uint = tempData.readU32();

	  multinameArray.push(stringConstantArray[nameIndex - 1]);

	  inner_count = tempData.readU32();
	  for(j = 0; j < inner_count; j++) {
	    var typeIndex:uint = tempData.readU32();
	  }
	  
// here is the implementation of 0x1D from AbcPrinter.java
/*
int nameIndex = (int)readU32();
MultiName mn = multiNameConstants[nameIndex];
int count = (int)readU32();
MultiName types[] = new MultiName[count];
for (int t = 0; t < count; t++){
  int typeIndex = (int)readU32();
  types[t] = multiNameConstants[typeIndex];
}
multiNameConstants[i].typeName = mn;
multiNameConstants[i].types = types;
*/

	}

      }
      
      trace('method signature');

      // 4.5 Method Signature
      index.method_count = tempData.position;
      count = tempData.readU32();
      trace('method_count = ' + count); 
      for(i = 0; i < count; i++){
	index.addMethod();
	index.method[i].param_count = tempData.position;
	var param_count:uint = tempData.readU32();
	trace('param_count = ' + param_count);
	index.method[i].return_type = tempData.position;
	trace('return type = ' + multinameArray[tempData.readU32() - 1]);
	for(j = 0; j < param_count; j++){
	  index.method[i].param_type[j] = tempData.position;
	  trace('param type = ' + multinameArray[tempData.readU32() - 1]);
	}
	index.method[i].name = tempData.position;
	trace('method name = ' + stringConstantArray[tempData.readU32() - 1]);
	index.method[i].flags = tempData.position;
	var method_flags:uint = tempData.readUnsignedByte();
	if(method_flags >> 3 & 1){
	  index.method[i].options.option_count = tempData.position;
	  inner_count = tempData.readU32();
	  for(j = 0; j < inner_count; j++){
	    index.method[i].options.addOption();
	    index.method[i].options.option[j].val = tempData.position;
	    tempData.readU32();
	    index.method[i].options.option[j].kind = tempData.position;
	    tempData.readUnsignedByte();
	  }
	}
	if(method_flags >> 7 & 1){
	  for(j = 0; j < param_count; j++){
	    index.method[i].addParamName();
	    index.method[i].param_names[j].param_name = tempData.position;
	    tempData.readU32();
	  }
	}
      }
      
      trace('metadata_info');

      // 4.6 metadata_info
      index.metadata_count = tempData.position;
      count = tempData.readU32();
      for(i = 0; i < count; i++){
	index.addMetadata();
	index.metadata[i].name = tempData.position;

	trace('name = ' + stringConstantArray[tempData.readU32() - 1]);

	index.metadata[i].item_count = tempData.position;
	inner_count = tempData.readU32();
	for(j = 0; j < inner_count; j++){
	  index.metadata[i].addItem();
	  index.metadata[i].item[j].key = tempData.position;
	  tempData.readU32();
	  index.metadata[i].item[j].value = tempData.position;
	  tempData.readU32();
	}
      }
      

      trace('instance');

      index.class_count = tempData.position;
      var class_count:uint = tempData.readU32();
      trace('instance_count = ' + count);
      // 4.7 Instance
      for(i = 0; i < class_count; i++){
	index.addInstance();
	index.instance[i].name = tempData.position;

	trace('name = ' + multinameArray[tempData.readU32() - 1]);

	index.instance[i].super_name = tempData.position;

	trace('super_name = ' + multinameArray[tempData.readU32() - 1]);


	index.instance[i].flags = tempData.position;
	var instance_flags:uint = tempData.readUnsignedByte();
	if(instance_flags >> 3 & 1){
	  index.instance[i].protectedNs = tempData.position;
	  tempData.readU32();
	}
	index.instance[i].intrf_count = tempData.position;
	inner_count = tempData.readU32();
	trace('intrf__count = ' + inner_count);
	for(j = 0; j < inner_count; j++){
	  index.instance[i].intrf[j] = tempData.position;
	  tempData.readU32();
	}
	index.instance[i].iinit = tempData.position;
	trace('iinit = ' + tempData.readU32());
	indexTraits(tempData, index.instance[i]);
      }
      

      trace('class');

      // 4.9 Class
      for(i = 0; i < class_count; i++){
	index.addClass();
	index.clss[i].cinit = tempData.position;
	trace('cinit = ' + tempData.readU32());
	indexTraits(tempData, index.clss[i]);
      }
      
      trace('script');

      // 4.10 Script
      index.script_count = tempData.position;
      count = tempData.readU32();
      for(i = 0; i < count; i++){
	index.addScript();
	index.script[i].init = tempData.position;
	tempData.readU32();
	indexTraits(tempData, index.script[i]);
      }
      
      trace('method body');

      // 4.11 Method body
      index.method_body_count = tempData.position;
      count = tempData.readU32();
      for(i = 0; i < count; i++){
	index.addMethodBody();
	index.method_body[i].method = tempData.position;
	tempData.readU32();
	index.method_body[i].max_stack = tempData.position;
	tempData.readU32();
	index.method_body[i].local_count = tempData.position;
	tempData.readU32();
	index.method_body[i].init_scope_depth = tempData.position;
	tempData.readU32();
	index.method_body[i].max_scope_depth = tempData.position;
	tempData.readU32();
	index.method_body[i].code_length = tempData.position;
	var code_length:uint = tempData.readU32();
	tempData.position += code_length;
	index.method_body[i].exception_count = tempData.position;
	inner_count = tempData.readU32();
	for(j = 0; j < inner_count; j ++){
	  index.method_body[i].addException();
	  index.method_body[i].exception[j].from = tempData.position;
	  tempData.readU32();
	  index.method_body[i].exception[j].to = tempData.position;
	  tempData.readU32();
	  index.method_body[i].exception[j].target = tempData.position;
	  tempData.readU32();
	  index.method_body[i].exception[j].exc_type = tempData.position;
	  tempData.readU32();
	  index.method_body[i].exception[j].var_name = tempData.position;
	  tempData.readU32();
	}
	indexTraits(tempData, index.method_body[i]);
      }

      return index;
    }

    

    private function indexTraits(tempData:ComplexByteArray, objectWithTraits:Trait):void{
      var i:uint;
      var count:uint;

      trace('trait');
      objectWithTraits.trait_count = tempData.position;
      count = tempData.readU32();
      trace('trait_count = ' + count);
      for(i = 0; i < count; i++) {
	objectWithTraits.addTrait();
	objectWithTraits.trait[i].name = tempData.position;

	trace('name = ' + multinameArray[tempData.readU32() - 1]);

	objectWithTraits.trait[i].kind = tempData.position;
	var trait_kind:uint = tempData.readUnsignedByte();

	switch(trait_kind & 15){
	  case 0:
	    trace('kind = slot');
	    break;
          case 1:
	    trace('kind = method');
	    break;
          case 2:
	    trace('kind = getter');
	    break;
          case 3:
	    trace('kind = setter');
	    break;
          case 4:
	    trace('kind = class');
	    break;
          case 5:
	    trace('kind = function');
	    break;
          case 6:
	    trace('kind = const');
	    break;
	  default:
	    trace('ERROR, unknown type: ' + (trait_kind & 15));
	}

	
	if((trait_kind & 15) == 0 || (trait_kind & 15) == 6) {
	  // 4.8.2 Slot and const traits
	  objectWithTraits.trait[i].data.slot_id = tempData.position;
	  tempData.readU32();
	  objectWithTraits.trait[i].data.type_name = tempData.position;
	  
	  trace('type_name = ' + multinameArray[tempData.readU32() - 1]);

	  objectWithTraits.trait[i].data.vindex = tempData.position;
	  
	  var vindex:int = tempData.readU32();
	  trace('vindex = ' + vindex);

	  if(vindex != 0) {
	    objectWithTraits.trait[i].data.vkind = tempData.position;
	    tempData.position++;
	  }
	}else if((trait_kind & 15) == 4) {
	  // 4.8.3 Class traits
	  objectWithTraits.trait[i].data.slot_id = tempData.position;
	  tempData.readU32();
	  objectWithTraits.trait[i].data.classi = tempData.position;
	  tempData.readU32();
	}else if((trait_kind & 15) == 5) {
	  // 4.8.4 Function traits
	  objectWithTraits.trait[i].data.slot_id = tempData.position;
	  tempData.readU32();
	  objectWithTraits.trait[i].data.fun = tempData.position;
	  tempData.readU32();
	}else if((trait_kind & 15) == 1 || (trait_kind & 15) == 2 || (trait_kind & 15) == 3) {
	  // 4.8.5 Method, getter, and setter traits
	  objectWithTraits.trait[i].data.disp_id = tempData.position;
	  tempData.readU32();
	  objectWithTraits.trait[i].data.method = tempData.position;
	  tempData.readU32();
	}

	// XXX: NO METADATA!!!!!!

	trace('metadata? ' + (trait_kind >> 4));
	switch(trait_kind >> 4){
	  case 0x1:
	    trace('trait attribute = final');
	    break;
	  case 0x2:
	    trace('trait attribute = override');
	    break;
	  case 0x4:
	    trace('trait attribute = metadata');
	    break;
	}
	if(trait_kind >> 4){
	  var inner_count:uint = tempData.readU32();
	  for(var j:uint = 0; j < inner_count; j++){
	    tempData.readU32();
	  }
	}



      }
    }
    
  }

}


internal class ABCIndex{
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

  public function toString():String{
    var val:String = 'minor_version = ' + minor_version + "\n";
    val += 'major_version = ' + major_version + "\n";
    val += 'constant_pool = ' + constant_pool + "\n";
    val += 'method_count = ' + method_count + "\n";
    return val;
  }
}

internal class CPoolInfo{

  public var int_count:uint;
  public var integer:Vector.<uint> = new Vector.<uint>();
  public var uint_count:uint;
  public var uinteger:Vector.<uint> = new Vector.<uint>();
  public var double_count:uint;
  public var double:Vector.<uint> = new Vector.<uint>();
  public var string_count:uint;
  public var string:Vector.<uint> = new Vector.<uint>();
  public var namespace_count:uint;
  public var ns:Vector.<NamespaceInfo> = new Vector.<NamespaceInfo>();
  public function addNamespace():void{
    ns.push(new NamespaceInfo());
  }
  public var ns_set_count:uint; 
  public var ns_set:Vector.<NsSetInfo> = new Vector.<NsSetInfo>();
  public function addNsSet():void{
    ns_set.push(new NsSetInfo());
  }
  public var multiname_count:uint;
  public var multiname:Vector.<MultinameInfo> = new Vector.<MultinameInfo>();
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
  public var param_names:Vector.<ParamInfo> = new Vector.<ParamInfo>();
  public function addParamName():void{
    param_names.push(new ParamInfo());
  }

}

internal class OptionInfo{

  public var option_count:uint;
  public var option:Vector.<OptionDetail> = new Vector.<OptionDetail>();
  public function addOption():void{
    option.push(new OptionDetail());
  }

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
