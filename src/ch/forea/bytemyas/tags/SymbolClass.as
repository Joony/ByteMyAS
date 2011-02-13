package ch.forea.bytemyas.tags {

  import flash.utils.Endian;

  import ch.forea.bytemyas.ComplexByteArray;
  import ch.forea.bytemyas.Tag;
  import ch.forea.bytemyas.tags.symbolclass.Symbol;
    
  public class SymbolClass extends Tag{

    private var _symbols:Array = [];

    public function SymbolClass(id:uint, length:uint, data:ComplexByteArray){      
      super(id, length, data, ['symbols']);
      var tempData:ComplexByteArray = data;
      tempData.position = length < 0x3F ? 2 : 6;
      var numberOfSymbols:uint = tempData.readUnsignedShort();
      var symbol:Symbol;
      var symbolStartPosition:uint;
      var symbolData:ComplexByteArray;
      var stringLength:uint;
      for(var i:uint = 0; i < numberOfSymbols; i++) {
	symbolStartPosition = tempData.position;
	tempData.position += 2;
	
	stringLength = 0;
        while(tempData.position < 2 + length) {
	  stringLength++;
	  if(tempData.readByte() == 0)
	    break;
        }

	symbolData = new ComplexByteArray();
	symbolData.endian = Endian.LITTLE_ENDIAN;
	symbolData.writeBytes(tempData, symbolStartPosition, tempData.position - symbolStartPosition);

	symbol = new Symbol(symbolData)
	_symbols.push(symbol);
      }      
    }

    public function get symbols():Array {
      return _symbols;
    }
    


  }

}
