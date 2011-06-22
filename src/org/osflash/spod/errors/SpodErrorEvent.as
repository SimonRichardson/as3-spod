package org.osflash.spod.errors
{
	import flash.events.SQLErrorEvent;
	/**
	 * @author Simon Richardson - me@simonrichardson.info
	 */
	public class SpodErrorEvent extends Error
	{
		
		/**
		 * @private
		 */
		private var _event : SQLErrorEvent;

		public function SpodErrorEvent(message : String, event : SQLErrorEvent = null)
		{
			super(message);
			
			_event = event;
		}

		public function get event() : SQLErrorEvent { return _event; }
	}
}
