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

		/**
		 * @private
		 */
		private var _error : SpodError;

		public function SpodErrorEvent(	message : String, 
										error : SpodError = null,
										event : SQLErrorEvent = null
										)
		{
			super(message);
			
			_error = error;
			_event = event;
		}

		public function get error() : SpodError { return _error; }

		public function get event() : SQLErrorEvent { return _event; }
	}
}
