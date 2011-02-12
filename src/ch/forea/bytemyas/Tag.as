package ch.forea.bytemyas {

  import flash.utils.ByteArray;
  import flash.utils.Endian;
  import flash.utils.Proxy;
  import flash.utils.flash_proxy;
  import flash.utils.describeType;

  import ch.forea.bytemyas.tags.*;

  public dynamic class Tag extends DataObject {

    private var _id:uint;
    public function get id():uint {
      return _id;
    }
    private var _length:uint;
    public function get length():uint {
      return _length;
    }
    private var _data:ByteArray;
    public function get data():ByteArray {
      var temp:ByteArray = new ByteArray();
      temp.endian = Endian.LITTLE_ENDIAN;
      _data.position = 0;
      _data.readBytes(temp, 0, _length + (_length < 63 ? 2 : 6));
      return temp;
    }
    public function set data(newData:ByteArray):void{
      _data = newData;
    }

    public function get name():String{
      switch(_id){
	case 0:
	  return "End";
	case 1:
	  return "ShowFrame";
        case 2:
	  return "DefineShape";
        case 4:
	  return "PlaceObject";
        case 5:
	  return "RemoveObject";
        case 6:
	  return "DefineBits";
        case 7:
	  return "DefineButton";
        case 8:
	  return "JPEGTables";
        case 9:
	  return "SetBackgroundColor";
        case 10:
	  return "DefineFont";
        case 11:
	  return "DefineText";
        case 12:
	  return "DoAction";
        case 13:
	  return "DefineFontInfo";
        case 14:
	  return "DefineSound";
        case 15:
	  return "StartSound";
        case 17:
	  return "DefineSoundButton";
        case 18:
	  return "SoundStreamHead";
        case 19:
	  return "SoundStreamBlock";
        case 20:
	  return "DefineBitsLossless";
        case 21:
	  return "DefineBitsJPEG2";
        case 22:
	  return "DefineShape2";
        case 23:
	  return "DefineButtonCxform";
        case 24:
	  return "Protect";
        case 26:
	  return "PlaceObject2";
        case 28:
	  return "RemoveObject2";
        case 32:
	  return "DefineShape3";
        case 33:
	  return "DefineText2";
        case 34:
	  return "DefineButton2";
        case 35:
	  return "DefineBitsJPEG3";
        case 36:
	  return "DefineBitsLossless2";
        case 37:
	  return "DefineEditText";
        case 39:
	  return "DefineSprite";
	case 41:
	  return "ProductInfo"; // Undocumented
        case 43:
	  return "FrameLabel";
        case 45:
	  return "SoundStreamHead2";
        case 46:
	  return "DefineMorphShape";
        case 48:
	  return "DefineFont2";
        case 56:
	  return "ExportAssets";
        case 57:
	  return "ImportAssets";
        case 58:
	  return "EnableDebugger";
        case 59:
	  return "DoInitAction";
        case 60:
	  return "DefineVideoStream";
        case 61:
	  return "VideoFrame";
        case 62:
	  return "DefineFontInfo2";
	case 63:
	  return "DebugID"; // Undocumented
        case 64:
	  return "EnableDebugger2";
        case 65:
	  return "ScriptLimits";
        case 66:
	  return "SetTabIndex";
	case 69:
	  return "FileAttributes";
        case 70:
	  return "PlaceObject3";
        case 71:
	  return "ImportAssets2";
        case 73:
	  return "DefineFontAlignZones";
        case 74:
	  return "CSMTextSettings";
        case 75:
	  return "DefineFont3";
        case 76:
	  return "SymbolClass";
	case 77:
	  return "Metadata";
        case 78:
	  return "DefineScalingGrid";
        case 82:
	  return "DoABC";
        case 83:
	  return "DefineShape4";
        case 84:
	  return "DefineMorphShape2";
        case 86:
	  return "DefineSceneAndFrameLabelData";
        case 87:
	  return "DefineBinaryData";
        case 88:
	  return "DefineFontName";
        case 89:
	  return "StartSound2";
        case 90:
	  return "DefineBitsJPEG4";
        case 91:
	  return "DefineFont4";
      }
      return "Unknown";
    }

    public static function getClass(id:uint):Class{
      switch(id){
        case 9:
	  return SetBackgroundColor;
	case 41:
	  return ProductInfo;
	case 43:
	  return FrameLabel;
	case 64:
	  return EnableDebugger2;
	case 65:
	  return ScriptLimits;
	case 69:
	  return FileAttributes;
	case 76:
	  return SymbolClass;
	case 77:
	  return Metadata;
	case 82:
	  return DoABC;
	case 88:
	  return DefineFontName;
      }
      return null;
    }



    public function Tag(id:uint, length:uint, data:ByteArray, propertyOrder:Array = null) {
      _id = id;
      _length = length;
      _data = data;

      var propertyList:Array = ['name', 'id', 'length'];

      if(propertyOrder) {
	propertyList = propertyList.concat(propertyOrder);	
      } else {
	for each(var propertyName:String in describeType(this)..accessor.(@type == 'readonly' || @type == 'readwrite').@name){
	  if(propertyName != 'name' && propertyName != 'id' && propertyName != 'length' && propertyName != 'data'){
	    propertyList.push(propertyName);
          }
        }
      }

      propertyList.push('data');

      super(propertyList);
    }

    public override function toString():String {
      var description:String = '[' + name + ':' + id + ']';
      for(var propertyName:String in this) {
        if(propertyName != 'data' && propertyName != 'id' && propertyName != 'name')
  	  description += ', ' + propertyName + ':' + getPropertyType(propertyName) + ' = ' + this[propertyName];
      }
      return description;
    }


  }

}
