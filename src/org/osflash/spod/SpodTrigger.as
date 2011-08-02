package org.osflash.spod
{
	import org.osflash.spod.schema.SpodTriggerSchema;
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public class SpodTrigger
	{
		
		use namespace spod_namespace;
		
		/**
		 * @private
		 */
		private var _exists : Boolean;
		
		/**
		 * @private
		 */
		private var _schema : SpodTriggerSchema;
		
		/**
		 * @private
		 */
		private var _manager : SpodManager;

		public function SpodTrigger(schema : SpodTriggerSchema, manager : SpodManager)
		{
			if(null == schema) throw new ArgumentError('Schema can not be null');
			if(null == manager) throw new ArgumentError('SpodManager can not be null');
			
			_schema = schema;
			_manager = manager;
			
			_exists = false;
		}
		
		public function get exists() : Boolean { return _exists; }
		public function set exists(value : Boolean) : void { _exists = value; }

		public function get schema() : SpodTriggerSchema { return _schema; }
		
		public function get name() : String { return _schema.name; }
		
		public function get manager() : SpodManager { return _manager; }
	}
}
