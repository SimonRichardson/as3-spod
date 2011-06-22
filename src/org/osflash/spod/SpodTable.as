package org.osflash.spod
{
	import org.osflash.spod.schema.SpodTableSchema;
	/**
	 * @author Simon Richardson - me@simonrichardson.info
	 */
	public class SpodTable
	{
		
		private var _exists : Boolean;
		
		private var _schema : SpodTableSchema;
		
		public function SpodTable(schema : SpodTableSchema)
		{
			if(null == schema) throw new ArgumentError('Schema can not be null');
			_schema = schema;
			_exists = false;
		}
		
		public function get exists() : Boolean { return _exists; }
		public function set exists(value : Boolean) : void { _exists = value; }

		public function get schema() : SpodTableSchema { return _schema; }
	}
}
