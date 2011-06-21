package org.osflash.spod.schema
{
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public class SpodTableColumnSchema
	{
		
		/**
		 * @private
		 */
		private var _name : String;
		
		/**
		 * @private
		 */
		private var _type : Class;

		public function SpodTableColumnSchema(name : String, type : Class)
		{
			if(null == name) throw new ArgumentError('Name can not be null');
			if(name.length < 1) throw new ArgumentError('Name can not be emtpy');
			if(null == type) throw new ArgumentError('Type can not be null');
			
			_name = name;
			_type = type;
		}

		public function get name() : String { return _name; }

		public function get type() : Class { return _type; }
	}
}
