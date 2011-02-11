package ch.forea.bytemyas {

  import flash.utils.Proxy;
  import flash.utils.flash_proxy;
  import flash.utils.describeType;

  public dynamic class DataObject extends Proxy{

    private var propertyList:Array = [];

    public function getPropertyType(propertyName:String):String {
      return describeType(this)..accessor.(@name == propertyName).@type;
    }

    public function DataObject(propertyOrder:Array = null) {
      if(propertyOrder && propertyOrder.length){
        propertyList = propertyList.concat(propertyOrder);
      }else{
        for each(var propertyName:String in describeType(this)..accessor.(@type == 'readonly' || @type == 'readwrite').@name){
	  propertyList.push(propertyName);
        }
      }
      propertyList.push('data');
    }

    // we shouldn't need these, as you should implement your own getters/setters for your properties in a subclass of Tag
    /*
    flash_proxy override function getProperty(name:*):* {
      trace("Tag.getProperty(" + name + ") this = " + this);
      throw new Error("property " + name + " hasn't been implemented in " + this); 
      return null;
    }
    flash_proxy override function setProperty(name:*, value:*):void {
      trace("Tag.setProperty(" + name + ", " + value + ") this = " + this);
      throw new Error("property " + name + " hasn't been implemented in " + this); 
    }
    */


    flash_proxy override function nextNameIndex(index:int):int{
      if(propertyList && index < propertyList.length)
        return index + 1;
      return 0;
    }

    flash_proxy override function nextName(index:int):String{
      return propertyList[index - 1];
    }

    flash_proxy override function nextValue(index:int):*{
      return this[propertyList[index - 1]];
    }

    /*
    flash_proxy override function callProperty(name:*, ...rest):*{
      if(name == 'toString')
        return '[object ' + flash.utils.getQualifiedClassName(this) + ']';
    }
    */

    public function toString():String {
      var description:String = '[DataObject]';
      for(var propertyName:String in this) {
  	  description += ', ' + propertyName + ':' + getPropertyType(propertyName) + ' = ' + this[propertyName];
      }
      return description;
    }

  }

}
