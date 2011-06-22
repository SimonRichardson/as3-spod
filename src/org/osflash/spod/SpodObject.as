package org.osflash.spod
{
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public class SpodObject
	{
		
		/**
		 * @private
		 */
		private var _table : SpodTable;
		
		public function update() : void
		{
			
		}
		
		public function remove() : void
		{
			
		}
		
		public function sync() : void
		{
			
		}

		spod_namespace function get table() : SpodTable { return _table; }
		spod_namespace function set table(value : SpodTable) : void { _table = value; }
	}
}
