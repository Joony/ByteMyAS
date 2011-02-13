package ch.forea.bytemyas.tags {

  import ch.forea.bytemyas.ComplexByteArray;
  import ch.forea.bytemyas.Tag;
    
  public class ProductInfo extends Tag{

    public function ProductInfo(id:uint, length:uint, data:ComplexByteArray){
      super(id, length, data, ['productID', 'edition', 'version', 'compilationDate']);
    }

    // XXX: Maybe this should just return the int
    public function get productID():String {
      var tempData:ComplexByteArray = data;
      tempData.position = 2;
      switch(tempData.readUnsignedInt()) {
        case 0:
	  return 'Unknown';
	case 1:
	  return 'Macromedia Flex for J2EE';
	case 2:
	  return 'Macromedia Flex for .NET';
	case 3:
	  return 'Adobe Flex';
      }
      return null;
    }
    public function set productID(id:String):void {
      var tempData:ComplexByteArray = data;
      tempData.position = 2;
      tempData.writeInt(parseInt(id));
      data = tempData;
    }

    // XXX: Maybe this should just return the int
    public function get edition():String {
      var tempData:ComplexByteArray = data;
      tempData.position = 6;
      switch(tempData.readUnsignedInt()) {
        case 0:
	  return 'Developer Edition';
	case 1:
	  return 'Full Commercial Edition';
	case 2:
	  return 'Non Commercial Edition';
	case 3:
	  return 'Educational Edition';
	case 4:
	  return 'Not For Resale (NFR) Edition';
	case 5:
	  return 'Trial Edition';
        case 6:
	  return 'None';
      }
      return null;
    }
    public function set edition(id:String):void {
      var tempData:ComplexByteArray = data;
      tempData.position = 6;
      tempData.writeInt(parseInt(id));
      data = tempData;
    }
    
    // XXX: Maybe this should be split up
    public function get version():String {
      var tempData:ComplexByteArray = data;
      tempData.position = 10;
      var majorVersion:uint = tempData.readUnsignedByte();
      var minorVersion:uint = tempData.readUnsignedByte();
      var buildLow:uint = tempData.readUnsignedInt();
      var buildHigh:uint = tempData.readUnsignedInt();
      return majorVersion + '.' + minorVersion + '.' + buildHigh + '.' + buildLow;
    }

    public function get compilationDate():Date {
      var tempData:ComplexByteArray = data;
      tempData.position = 20;
      var milli:Number = tempData.readUnsignedInt();
      var date:Date = new Date();
      date.setTime(milli + tempData.readUnsignedInt() * 0x100000000);
      return date;
    }


  }

}
