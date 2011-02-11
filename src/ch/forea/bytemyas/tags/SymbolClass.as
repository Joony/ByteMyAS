package ch.forea.bytemyas.tags {

  import flash.utils.ByteArray;

  import ch.forea.bytemyas.Tag;
    
  public class SymbolClass extends Tag{

    public function SymbolClass(id:uint, length:uint, data:ByteArray){
      super(id, length, data, ['symbols']);
    }

    public function get symbols():Array {
      var tempData:ByteArray = data;
      tempData.position = length < 0x3F ? 2 : 6;
      var numberOfSymbols:uint = tempData.readUnsignedShort();
      var symbols:Array = [];
      var symbol:Object;
      var nameStartPosition:uint;
      var stringLength:uint;
      for(var i:uint = 0; i < numberOfSymbols; i++) {
        symbol = {tag: tempData.readUnsignedShort()};
	nameStartPosition = tempData.position;
	stringLength = 0;
        while(tempData.position < 2 + length) {
	  stringLength++;
	  if(tempData.readByte() == 0)
	    break;
        }
        tempData.position = nameStartPosition;
        symbol.name = tempData.readUTFBytes(stringLength);
	symbol.toString = function():String {
	  return '[tag = ' + this.tag + ', name = ' + this.name + ']';
	}
	symbols.push(symbol);
      }
      return symbols;
    }
    


  }

}
