package ch.forea.bytemyas.tags {

  import flash.utils.Endian;

  import ch.forea.bytemyas.ComplexByteArray;
  import ch.forea.bytemyas.Tag;
  import ch.forea.bytemyas.tags.exportassets.Asset;
    
  public class ExportAssets extends Tag{

    private var _assets:Array = [];

    public function ExportAssets(id:uint, length:uint, data:ComplexByteArray){      
      super(id, length, data, ['assets']);
      var tempData:ComplexByteArray = data;
      tempData.position = length < 0x3F ? 2 : 6;
      var numberOfAssets:uint = tempData.readUnsignedShort();
      var asset:Asset;
      var assetStartPosition:uint;
      var assetData:ComplexByteArray;
      var stringLength:uint;
      for(var i:uint = 0; i < numberOfAssets; i++) {
	assetStartPosition = tempData.position;
	tempData.position += 2;
	
	stringLength = 0;
        while(tempData.position < 2 + length) {
	  stringLength++;
	  if(tempData.readByte() == 0)
	    break;
        }

	assetData = new ComplexByteArray();
	assetData.endian = Endian.LITTLE_ENDIAN;
	assetData.writeBytes(tempData, assetStartPosition, tempData.position - assetStartPosition);

	asset = new Asset(assetData);
	_assets.push(asset);
      }      
    }

    public function get assets():Array {
      return _assets;
    }
    


  }

}
