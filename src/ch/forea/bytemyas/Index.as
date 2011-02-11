package{

  public class Index{
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
    
    public function toString():String{
      var val:String = "index{\n";
      val += "\tminor_version = " + minor_version + "\n";
      val += "\tmajor_version = " + major_version + "\n";
      val += constant_pool;
      val += "\tmethod_count = " + method_count + "\n"; 
      val += "\tmethod = " + method + "\n";
      val += "\tmetadata_count = " + metadata_count + "\n"; 
      val += "\tmetadata = " + metadata + "\n";
      val += "\tclass_count = " + class_count + "\n"; 
      val += "\tinstance = " + instance + "\n";
      val += "\tclss = " + clss + "\n";
      val += "\tscript_count = " + script_count + "\n";
      val += "\tscript = " + script + "\n";
      val += "\tmethod_body_count = " + method_body_count + "\n";
      val += "\tmethod_body = " + method_body + "\n";
      val += "}\n";
      return val;
    }

    public function invalidate(index:uint, difference:int):void{
      if(minor_version > index) minor_version += difference;
    }

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




