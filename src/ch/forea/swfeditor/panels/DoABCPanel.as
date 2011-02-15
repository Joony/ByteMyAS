package ch.forea.swfeditor.panels {

  import ch.forea.bytemyas.tags.DoABC;
  import ch.forea.bytemyas.ComplexByteArray;
  import ch.forea.swfeditor.TagPanel

  public class DoABCPanel extends TagPanel {

    private var index:*;
    private var data:ComplexByteArray;

    private var stringConstants:Vector.<String> = Vector.<String>(['*']);
    private var namespaces:Vector.<String> = Vector.<String>(['*']);
    private var namespaceSets:Vector.<Vector.<String>> = new Vector.<Vector.<String>>();
    private var multinames:Vector.<Multiname> = Vector.<Multiname>([new Multiname()]);

    public function DoABCPanel(tag:DoABC) {
      super(tag);
      trace('DoABCPanel');
      
      index = (tag as DoABC).createIndex();
      data = tag.data;

      var i:uint;
      // cache string constants
      for(i = 0; i < index.constant_pool.string.length; i++) {
	data.position = index.constant_pool.string[i];
	stringConstants.push(data.readStringInfo(data.readU32()));
      }

      // cache namspaces
      for(i = 0; i < index.constant_pool.ns.length; i++) {
	data.position = index.constant_pool.ns[i].name;
	namespaces.push(stringConstants[data.readU32()]);
      }

      // cache namespace sets
      namespaceSets.push(Vector.<String>(['*']));
      var j:uint;
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

	var kind:uint = data[index.constant_pool.multiname[i].kind];
	switch(kind) {
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
        }
	multinames.push(multiname);
      }
      
      trace('stringConstants = ' + stringConstants);
      trace('namespaces = ' + namespaces);
      trace('namespaceSets = ' + namespaceSets);
      trace('multinames = ' + multinames);

    }
    

  }

}

internal class Multiname {
  public var ns:String = '*';
  public var name:String = '*';
  public var ns_set:Vector.<String>;
  public function toString():String {
    if(ns_set)
      return '[Multiname ' + ns_set + ':' + name + ']';
    return '[Multiname ' + ns + ':' + name + ']';
  }
}
