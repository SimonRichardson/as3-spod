package org.osflash.spod.schema
{
	import org.osflash.spod.types.SpodDate;
	import org.osflash.spod.types.SpodInt;
	import org.osflash.spod.types.SpodString;
	import org.osflash.spod.utils.validateString;
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public class SpodTableSchema implements ISpodSchema
	{
		
		/**
		 * @private
		 */
		private var _type : Class;
		
		/**
		 * @private
		 */
		private var _name : String;
				
		/**
		 * @private
		 */
		private var _columns : Vector.<SpodTableColumnSchema>;
		
		public function SpodTableSchema(type : Class, name : String)
		{
			if(null == type) throw new ArgumentError('Type can not be null');
			if(null == name) throw new ArgumentError('Name can not be null');
			if(name.length < 1) throw new ArgumentError('Name can not be emtpy');
			if(!validateString(name)) throw new ArgumentError('Invalid name');
			
			_type = type;
			_name = name;
			
			_columns = new Vector.<SpodTableColumnSchema>();
		}
		
		public function createByType(name : String, type : String) : void
		{
			if(null == name) throw new ArgumentError('Name can not be null');
			if(name.length < 1) throw new ArgumentError('Name can not be emtpy');
			if(null == type) throw new ArgumentError('Type can not be null');
			if(type.length < 1) throw new ArgumentError('Type can not be emtpy');
			
			switch(type.toLowerCase())
			{
				case 'int': createInt(name); break;
				case 'string': createString(name); break;
				case 'date': createDate(name); break;
				default:
					throw new ArgumentError('Unknown type');
			}
		}
		
		public function createInt(name : String) : void
		{
			if(null == name) throw new ArgumentError('Name can not be null');
			if(name.length < 1) throw new ArgumentError('Name can not be emtpy');
			
			_columns.push(new SpodTableColumnSchema(name, SpodInt));
		}
		
		public function createString(name : String) : void
		{
			if(null == name) throw new ArgumentError('Name can not be null');
			if(name.length < 1) throw new ArgumentError('Name can not be emtpy');
			
			_columns.push(new SpodTableColumnSchema(name, SpodString));
		}
		
		public function createDate(name : String) : void
		{
			if(null == name) throw new ArgumentError('Name can not be null');
			if(name.length < 1) throw new ArgumentError('Name can not be emtpy');
			
			_columns.push(new SpodTableColumnSchema(name, SpodDate));
		}
		
		public function get columns() : Vector.<SpodTableColumnSchema> { return _columns; }
		
		public function get type() : Class { return _type; }
		
		public function get name() : String { return _name; }
	}
}
