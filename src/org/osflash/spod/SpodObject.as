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
		
		/**
		 * @private
		 */
		private var _tableRow : SpodTableRow;
		
		public function update() : void
		{
			_tableRow.update();
		}
		
		public function remove() : void
		{
			
		}
		
		public function sync() : void
		{
			
		}

		spod_namespace function get table() : SpodTable { return _table; }
		spod_namespace function set table(value : SpodTable) : void { _table = value; }
		
		spod_namespace function get tableRow() : SpodTableRow { return _tableRow; }
		spod_namespace function set tableRow(value : SpodTableRow) : void { _tableRow = value; }
	}
}
