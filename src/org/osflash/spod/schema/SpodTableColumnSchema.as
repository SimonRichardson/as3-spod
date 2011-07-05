package org.osflash.spod.schema
{
	import org.osflash.spod.types.SpodTypes;
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
		private var _type : int;

		public function SpodTableColumnSchema(name : String, type : int)
		{
			if(null == name) throw new ArgumentError('Name can not be null');
			if(name.length < 1) throw new ArgumentError('Name can not be emtpy');
			if(isNaN(type)) throw new ArgumentError('Type can not be NaN');
			if(!SpodTypes.valid(type)) throw new ArgumentError('Type is not a valid type');
			
			_name = name;
			_type = type;
		}

		public function get name() : String { return _name; }

		public function get type() : int { return _type; }
	}
}
