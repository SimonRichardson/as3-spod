package org.osflash.spod.schema
{
	import org.osflash.spod.errors.SpodError;
	import org.osflash.spod.utils.validateString;
	/**
	 * @author Simon Richardson - me@simonrichardson.info
	 */
	public class SpodIndexSchema implements ISpodSchema
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
		private var _identifier : String;
				
		/**
		 * @private
		 */
		private var _columns : Vector.<SpodTableColumnSchema>;
		
		public function SpodIndexSchema(type : Class, name : String)
		{
			if(null == type) throw new ArgumentError('Type can not be null');
			if(null == name) throw new ArgumentError('Name can not be null');
			if(name.length < 1) throw new ArgumentError('Name can not be emtpy');
			if(!validateString(name)) throw new ArgumentError('Invalid name');
			
			_type = type;
			_name = name;
			_identifier = SpodSchemaIdentifier.DEFAULT;
			
			_columns = new Vector.<SpodTableColumnSchema>();
		}
		
		public function get columns() : Vector.<SpodTableColumnSchema> { return _columns; }
		
		public function get type() : Class { return _type; }
		
		public function get name() : String { return _name; }
		
		public function get identifier() : String { return _identifier; }
		public function set identifier(value : String) : void 
		{ 
			if(_identifier != value)
			{
				var index : int = _columns.length;
				while(--index > -1)
				{
					const column : SpodTableColumnSchema = _columns[index];
					if(column.name == value)
					{
						_identifier = value;
						return;
					}
				}
				
				throw new SpodError('Invalid index identifier');
			}
		}
	}
}
