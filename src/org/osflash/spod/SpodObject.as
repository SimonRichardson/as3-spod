package org.osflash.spod
{
	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;
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
		
		/**
		 * @private
		 */
		private var _updateSignal : ISignal;
		
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
		
		private function handleUpdateSignal(object : SpodObject) : void
		{
			if(object != this) return;
			
			updateSignal.dispatch(this);
		}
		
		
		public function get updateSignal() : ISignal
		{
			if(null == _updateSignal) _updateSignal = new Signal(SpodObject); 
			return _updateSignal;
		}

		spod_namespace function get table() : SpodTable { return _table; }
		spod_namespace function set table(value : SpodTable) : void { _table = value; }
		
		spod_namespace function get tableRow() : SpodTableRow { return _tableRow; }
		spod_namespace function set tableRow(value : SpodTableRow) : void 
		{ 
			if(null != _tableRow)
				_tableRow.updateSignal.remove(handleUpdateSignal);
			
			_tableRow = value; 
			_tableRow.updateSignal.add(handleUpdateSignal);
		}
	}
}
