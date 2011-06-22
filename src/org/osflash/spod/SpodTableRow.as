package org.osflash.spod
{
	/**
	 * @author Simon Richardson - me@simonrichardson.info
	 */
	public class SpodTableRow
	{
		
		/**
		 * @private
		 */
		private var _type : Class;
		
		/**
		 * @private
		 */
		private var _object : SpodObject;
		
		/**
		 * @private
		 */
		private var _manager : SpodManager;
		
		public function SpodTableRow(type : Class, object : SpodObject, manager : SpodManager)
		{
			if(null == type) throw new ArgumentError('Type can not be null');
			if(null == object) throw new ArgumentError('Object can not be null');
			if(null == manager) throw new ArgumentError('Manager can not be null');
			
			_type = type;
			_object = object;
			_manager = manager;
		}

		public function get object() : SpodObject { return _object; }
	}
}
