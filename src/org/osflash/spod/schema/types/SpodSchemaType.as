package org.osflash.spod.schema.types
{
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public final class SpodSchemaType
	{
		
		public static const TABLE : SpodSchemaType = new SpodSchemaType('table');
		
		public static const TRIGGER : SpodSchemaType = new SpodSchemaType('trigger');
		
		public static const INDEX : SpodSchemaType = new SpodSchemaType('index');

		public static const TABLE_COLUMN : SpodSchemaType = new SpodSchemaType('table_column');
		
		private var _type : String;

		public function SpodSchemaType(type : String)
		{
			if(null == type) throw new ArgumentError('Type can not be null');
			
			_type = type;
		}

		public function get type() : String { return _type; }
	}
}
