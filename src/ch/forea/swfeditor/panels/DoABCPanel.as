package ch.forea.swfeditor.panels {

  import ch.forea.bytemyas.tags.DoABC;
  import ch.forea.bytemyas.ComplexByteArray;
  import ch.forea.swfeditor.TagPanel

  public class DoABCPanel extends TagPanel {

    private var index:*;
    private var data:ComplexByteArray;

    private var stringConstants:Vector.<String> = Vector.<String>(['*']);
    private var namespaces:Vector.<NS> = Vector.<NS>([new NS()]);
    private var namespaceSets:Vector.<Vector.<String>> = new Vector.<Vector.<String>>();
    private var multinames:Vector.<Multiname> = Vector.<Multiname>([new Multiname()]);

    private var instances:Vector.<Instance> = new Vector.<Instance>();

    public function DoABCPanel(tag:DoABC) {
      super(tag);
      trace('DoABCPanel');
      
      index = (tag as DoABC).createIndex();
      data = tag.data;

      var i:uint;
      var j:uint;

      // cache string constants
      for(i = 0; i < index.constant_pool.string.length; i++) {
	data.position = index.constant_pool.string[i];
	stringConstants.push(data.readStringInfo(data.readU32()));
      }

      // cache namspaces
      var ns:NS;
      for(i = 0; i < index.constant_pool.ns.length; i++) {
	ns = new NS();
	ns.kind = data[index.constant_pool.ns[i].kind];
	data.position = index.constant_pool.ns[i].name;
	ns.name = stringConstants[data.readU32()];
	namespaces.push(ns);
      }

      // cache namespace sets
      namespaceSets.push(Vector.<String>(['*']));
      var nsSet:Vector.<String>;
      for(i = 0; i < index.constant_pool.ns_set.length; i++) {
	nsSet = new Vector.<String>();
        for(j = 0; j < index.constant_pool.ns_set[i].ns.length; j++) {
          data.position = index.constant_pool.ns_set[i].ns[j];
	  nsSet.push(stringConstants[data.readU32()]);
        }
	namespaceSets.push(nsSet);
      }

      // cache multinames
      var multiname:Multiname;
      for(i = 0; i < index.constant_pool.multiname.length; i++) {
	multiname = new Multiname();

	switch(data[index.constant_pool.multiname[i].kind]) {
          case 0x07:
	  case 0x0D:
	    data.position = index.constant_pool.multiname[i].data.ns;
	    multiname.ns = namespaces[data.readU32()];
	    data.position = index.constant_pool.multiname[i].data.name;
	    multiname.name = stringConstants[data.readU32()];
	    break;
	  case 0x0F:
	  case 0x10:
	    data.position = index.constant_pool.multiname[i].data.name;
	    multiname.name = stringConstants[data.readU32()];
	    break;
	  case 0x09:
	  case 0x0E:
	    data.position = index.constant_pool.multiname[i].data.name;
	    multiname.name = stringConstants[data.readU32()];
	    data.position = index.constant_pool.multiname[i].data.ns_set;
	    multiname.ns_set = namespaceSets[data.readU32()];
	    break;
	  case 0x1B:
	  case 0x1C:
	    data.position = index.constant_pool.multiname[i].data.ns_set;
	    multiname.ns_set = namespaceSets[data.readU32()];
	    break;
	  case 0x1D:
	    data.position = index.constant_pool.multiname[i].data.name;
	    // XXX: this just bodges together the Vector type
	    // TODO: store the types of the Vector so they can be retrieved later for import statements
	    multiname.name = multinames[data.readU32()].name;
	    for(j = 0; j < index.constant_pool.multiname[i].data.type.length; j++) {
              data.position = index.constant_pool.multiname[i].data.type[j];
              multiname.types.push(multinames[data.readU32()]);
            }
        }
	multinames.push(multiname);
      }
      
      // trace('stringConstants = ' + stringConstants);
      // trace('namespaces = ' + namespaces);
      // trace('namespaceSets = ' + namespaceSets);
      // trace('multinames = ' + multinames);

      
      // instance info
      var instance:Instance;
      var instanceMultiname:Multiname;
      var methodID:uint;
      for(i = 0; i < index.instance.length; i++) {
	instance = new Instance();
	// multiname
	data.position = index.instance[i].name;
	instanceMultiname = multinames[data.readU32()];
	instance.name = instanceMultiname.name;
	instance.ns = instanceMultiname.ns;
	// super
	data.position = index.instance[i].super_name;
	instanceMultiname = multinames[data.readU32()];
	instance.superClass = instanceMultiname.name;
	// XXX: probably have to take in to account the kind of namespace (should be package namespace)
	instance.addImport(instanceMultiname);
	// flags - Dynamic, Final, Interface
	var flags:uint = data[index.instance[i].flags];
	instance.isSealed = (flags & 0x01) == 0x01;
	instance.isFinal = (flags & 0x02) == 0x02;
	instance.isInterface = (flags & 0x04) == 0x04;
	if((flags & 0x08) == 0x08) {
	  data.position = index.instance[i].protectedNs;
	  instance.protectedNs = namespaces[data.readU32()];
        }
	// constructor
	if(index.instance[i].iinit) {
	  
	  instance.constructor = new Method();
	  data.position = index.instance[i].iinit;
	  methodID = data.readU32();
	  data.position = index.method[methodID].name;
	  var tempMultiname:Multiname = new Multiname();
	  tempMultiname.name = stringConstants[data.readU32()].replace(instance.ns.name + ':' + instance.name + '/', '');
	  instance.constructor.signature.name = tempMultiname;

	  var paramLength:uint = index.method[methodID].param_type.length;
 	  var optionalParamLength:uint = index.method[methodID].options.option.length;
	  var parameter:Parameter;
	  for(j = 0; j < paramLength; j++) {
	    parameter = new Parameter();
	    data.position = index.method[methodID].param_type[j];
	    parameter.type = multinames[data.readU32()];
	    instance.addImport(parameter.type);
	    data.position = index.method[methodID].param_names[j].param_name;
	    parameter.name = stringConstants[data.readU32()];
	    
	    if(optionalParamLength && j >= paramLength - optionalParamLength) {
	      data.position = index.method[methodID].options.option[j - (paramLength - optionalParamLength)].val;
	      switch(data[index.method[methodID].options.option[j - (paramLength - optionalParamLength)].kind]) {
                case 0x03: // integer
		  // TODO: cache integer constants
		  parameter.value = 'unknown - integer';
		  break;
		case 0x04: // unsigned integer
		  // TODO: cache unsigned integer constants
		  parameter.value = 'unknown - unsigned int';
		  break;
		case 0x06: // double
		  // TODO: cache double constants
		  parameter.value = 'unknown - double';
		  break;
		case 0x01: // string
		  parameter.value = '"' + stringConstants[data.readU32()] + '"';
		  break;
		case 0x0B: // true
		  parameter.value = 'true';
		  break;
		case 0x0A: // false
		  parameter.value = 'false';
		  break;
		case 0x0C: // null
		  parameter.value = 'null';
		  break;
		case 0x00: // undefined
		  parameter.value = 'undefined';
		  break;
              }
	    }

	    instance.constructor.signature.parameters.push(parameter);
	  }
	  
	  
        }
	// traits - instance variables, methods, getters & setters
	var traitKind:uint;
	var traitAttributes:uint;
	for(j = 0; j < index.instance[i].trait.length; j++) {
	  traitKind = data[index.instance[i].trait[j].kind];
          switch(traitKind & 0x0F) {
	    case 0x00: // slot/instance variable
	      var slot:Slot = new Slot();
	      data.position = index.instance[i].trait[j].name;
	      slot.name = multinames[data.readU32()];
	      data.position = index.instance[i].trait[j].data.type_name;
	      slot.type = multinames[data.readU32()];
              instance.addImport(slot.type);

	      // Vector types
	      for(var k:uint = 0; k < slot.type.types.length; k++) {
                instance.addImport(slot.type.types[k]);
              }

	      data.position = index.instance[i].trait[j].data.vindex;
	      var vindex:uint = data.readU32();
	      if(vindex) {
		data.position = index.instance[i].trait[j].data.vkind;
	        switch(data.readU32()) {
		  case 0x03: // integer
		    // TODO: cache integer constants
		    slot.value = 'unknown - integer';
		    break;
		  case 0x04: // unsigned integer
		    // TODO: cache unsigned integer constants
		    slot.value = 'unknown - unsigned int';
		    break;
		  case 0x06: // double
		    // TODO: cache double constants
		    slot.value = 'unknown - double';
		    break;
		  case 0x01: // string
		    slot.value = '"' + stringConstants[vindex] + '"';
		    break;
		  case 0x0B: // true
		    slot.value = 'true';
		    break;
		  case 0x0A: // false
		    slot.value = 'false';
		    break;
		  case 0x0C: // null
		    slot.value = 'null';
		    break;
		  case 0x00: // undefined
		    slot.value = 'undefined';
		    break;
		}
              }

	      instance.slots.push(slot);
	      break;
	    case 0x01: // method
	    case 0x02: // getter
	    case 0x03: // setter
	      var method:Method = new Method();
	      method.kind = traitKind;
	      data.position = index.instance[i].trait[j].name;
	      method.signature.name = multinames[data.readU32()];
	      
	      data.position = index.instance[i].trait[j].data.method;
	      methodID = data.readU32();
	      data.position = index.method[methodID].return_type;
	      method.signature.returnType = multinames[data.readU32()];
	      instance.addImport(method.signature.returnType);

	      var paramLength:uint = index.method[methodID].param_type.length;
 	      var optionalParamLength:uint = index.method[methodID].options.option.length;
	      var parameter:Parameter;
	      for(k = 0; k < paramLength; k++) {
		parameter = new Parameter();
		data.position = index.method[methodID].param_type[k];
		parameter.type = multinames[data.readU32()];
		instance.addImport(parameter.type);
		data.position = index.method[methodID].param_names[k].param_name;
		parameter.name = stringConstants[data.readU32()];
	    
		if(optionalParamLength && k >= paramLength - optionalParamLength) {
		  data.position = index.method[methodID].options.option[k - (paramLength - optionalParamLength)].val;
		  switch(data[index.method[methodID].options.option[k - (paramLength - optionalParamLength)].kind]) {
                    case 0x03: // integer
		      // TODO: cache integer constants
		      parameter.value = 'unknown - integer';
		      break;
		    case 0x04: // unsigned integer
		      // TODO: cache unsigned integer constants
		      parameter.value = 'unknown - unsigned int';
		      break;
		    case 0x06: // double
		      // TODO: cache double constants
		      parameter.value = 'unknown - double';
		      break;
		    case 0x01: // string
		      parameter.value = '"' + stringConstants[data.readU32()] + '"';
		      break;
		    case 0x0B: // true
		      parameter.value = 'true';
		      break;
		    case 0x0A: // false
		      parameter.value = 'false';
		      break;
		    case 0x0C: // null
		      parameter.value = 'null';
		      break;
		    case 0x00: // undefined
		      parameter.value = 'undefined';
		      break;
		  }
	        }
		method.signature.parameters.push(parameter);
	      }
	      instance.methods.push(method);
	      break;
	    case 0x04: // class
	      break;
	    case 0x05: // function
	      break;
	    case 0x06: // constant
	      break;
          }
        }

	instances.push(instance);
      }


      trace('instances = \n' + instances);
    }
    

  }

}

internal class NS {
  public var kind:uint;
  public var name:String = '*';
  public function toString():String {
    var kind:Vector.<String> = new Vector.<String>;
    if((this.kind & 0x08) == 0x08)
      kind.push('namespace');
    if((this.kind & 0x16) == 0x16)
      kind.push('package namespace');
    if((this.kind & 0x17) == 0x17)
      kind.push('package internal namespace');
    if((this.kind & 0x18) == 0x18)
      kind.push('protected namespace');
    if((this.kind & 0x19) == 0x19)
      kind.push('explicit namespace');
    if((this.kind & 0x1A) == 0x1A)
      kind.push('static protected namespace');
    if((this.kind & 0x05) == 0x05)
      kind.push('private namespace');
    return '[Namespace name = ' + name + ', kind = ' + kind + ']';
  }
}

internal class Multiname {
  public var ns:NS;
  public var name:String = '*';
  public var ns_set:Vector.<String>;
  public var types:Vector.<Multiname> = new Vector.<Multiname>;

  public function toString():String {
    if(ns_set)
      return '[Multiname ' + ns_set + ':' + name + ']';
    return '[Multiname ' + ns + ':' + name + ']';
  }
}

internal class Slot {
  public var name:Multiname;
  public var type:Multiname;
  public var value:String;
}

internal class Method {
  public var kind:uint;
  public var signature:MethodSignature = new MethodSignature();
}

internal class MethodSignature {
  public var name:Multiname;
  public var returnType:Multiname;
  public var parameters:Vector.<Parameter> = new Vector.<Parameter>();
}

internal class Parameter {
  public var name:String;
  public var type:Multiname;
  public var value:*;
}

internal class Instance {
  public var imports:Vector.<String> = new Vector.<String>();
  public function addImport(multiname:Multiname):void {
    var importStatement:String;
    if(multiname.ns && multiname.ns.name != '' && (multiname.ns.kind & 0x05) != 0x05 && multiname.ns.name != ns.name)
      importStatement = multiname.ns.name + '.' + multiname.name;      
    else
      return;
    for(var i:uint = 0; i < imports.length; i++) {
      if(imports[i] == importStatement)
        return;
    }
    imports.push(importStatement);
  }
  public var ns:NS;
  public var superClass:String;
  public var name:String;
  public var interfaces:Vector.<String>;
  public var isSealed:Boolean;
  public var isFinal:Boolean;
  public var isInterface:Boolean;
  public var protectedNs:NS;
  public var slots:Vector.<Slot> = new Vector.<Slot>();
  public var constructor:Method;
  public var methods:Vector.<Method> = new Vector.<Method>();
  public function toString():String {
    var description:String = '';
    var tabs:String = '';
    var scope:String;
    var i:uint;
    var j:uint;

    // package
    if((ns.kind & 0x05) != 0x05) {
      description += 'package' + (ns ? ' ' + ns.name : '') + ' {\n';
      tabs += '\t';
    }

    // imports
    for(i = 0; i < imports.length; i++) {
      description += tabs + 'import ' + imports[i] + ';\n';
    }

    // class declaration
    description += tabs + (isFinal ? 'final ' : '') + ((ns.kind & 0x05) == 0x05 ? 'internal ' : 'public ') + (isSealed ? '' : 'dynamic ') + (isInterface ? 'interface ' : 'class ') + name + (superClass && superClass != 'Object' && superClass != '*' ? ' extends ' + superClass : '') + ' {\n';
    tabs += '\t';
    
    // instance variables
    for(i = 0; i < slots.length; i++) {
      scope = 'public ';
      if((slots[i].name.ns.kind & 0x05) == 0x05)
        scope = 'private ';
      else if((slots[i].name.ns.kind & 0x18) == 0x18)
        scope = 'protected ';
      var vectorType:String = '';
      for(j = 0; j < slots[i].type.types.length; j++) {
	vectorType += '.<' + slots[i].type.types[j].name + '>';
      }
      description += tabs + scope + 'var ' + slots[i].name.name + ':' + slots[i].type.name + vectorType + (slots[i].value ? ' = ' + slots[i].value : '') + ';\n';
    }

    // constructor
    var parameters:Array
    if(constructor) {
      parameters = [];
      for(i = 0; i < constructor.signature.parameters.length; i++) {
	  parameters.push(constructor.signature.parameters[i].name + ':' + constructor.signature.parameters[i].type.name + (constructor.signature.parameters[i].value ? ' = ' + constructor.signature.parameters[i].value : ''));
      }
      description += tabs + 'public function ' + constructor.signature.name.name + '(' + parameters.join(', ') + ') {}\n';
    }

    // methods
    for(i = 0; i < methods.length; i++) {
      scope = 'public ';
      if((methods[i].signature.name.ns.kind & 0x05) == 0x05)
        scope = 'private ';
      else if((methods[i].signature.name.ns.kind & 0x18) == 0x18)
        scope = 'protected ';
      parameters = [];
      for(j = 0; j < methods[i].signature.parameters.length; j++) {
	  parameters.push(methods[i].signature.parameters[j].name + ':' + methods[i].signature.parameters[j].type.name + (methods[i].signature.parameters[j].value ? ' = ' + methods[i].signature.parameters[j].value : ''));
      }
      var attributes:uint = methods[i].kind >> 4;
      description += tabs + ((attributes & 0x2) == 0x02 ? 'override ' : '') + scope + ((attributes & 0x1) == 0x01 ? 'final ' : '') + 'function ' + ((methods[i].kind & 0x02) == 0x02 ? 'get ' : ((methods[i].kind & 0x03) == 0x03 ? 'set ' : '')) + methods[i].signature.name.name + '(' + parameters.join(', ') + '):' + methods[i].signature.returnType.name + ' {}\n';
    }

    tabs = tabs.slice(0, tabs.length -1);
    description += tabs + '}\n';
    tabs = tabs.slice(0, tabs.length -1);
    if((ns.kind & 0x05) != 0x05) {
      description += '}\n';
    }
    return description;
  }
}