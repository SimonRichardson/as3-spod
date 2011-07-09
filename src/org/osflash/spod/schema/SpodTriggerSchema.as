package org.osflash.spod.schema
{
	import org.osflash.spod.utils.validateString;
	/**
	 * @author Simon Richardson - me@simonrichardson.info
	 */
	public class SpodTriggerSchema implements ISpodSchema
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
		
		public function SpodTriggerSchema(type : Class, name : String)
		{
			if(null == type) throw new ArgumentError('Type can not be null');
			if(null == name) throw new ArgumentError('Name can not be null');
			if(name.length < 1) throw new ArgumentError('Name can not be emtpy');
			if(!validateString(name)) throw new ArgumentError('Invalid name');
			
			_type = type;
			_name = name;
			
			_columns = new Vector.<SpodTableColumnSchema>();
		}
		
		public function get columns() : Vector.<SpodTableColumnSchema> { return _columns; }
		
		public function get type() : Class { return _type; }
		
		public function get name() : String { return _name; }
	}
}
