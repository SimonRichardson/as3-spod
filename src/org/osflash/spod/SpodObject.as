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
		
		/**
		 * @private
		 */
		private var _syncSignal : ISignal;
		
		/**
		 * @private
		 */
		private var _removeSignal : ISignal;
		
		public function update() : void
		{
			_tableRow.update();
		}
		
		public function remove() : void
		{
			_tableRow.remove();
		}
		
		public function sync() : void
		{
			_tableRow.sync();
		}
		
		/**
		 * @private
		 */
		private function handleUpdateSignal(object : SpodObject) : void
		{
			if(object != this) return;
			
			updateSignal.dispatch(this);
		}
		
		/**
		 * @private
		 */
		private function handleSyncSignal(object : SpodObject) : void
		{
			if(object != this) return;
			
			syncSignal.dispatch(this);
		}
		
		/**
		 * @private
		 */
		private function handleRemoveSignal(object : SpodObject) : void
		{
			if(object != this) return;
			
			removeSignal.dispatch(this);
		}
		
		public function get updateSignal() : ISignal
		{
			if(null == _updateSignal) _updateSignal = new Signal(SpodObject); 
			return _updateSignal;
		}
		
		public function get syncSignal() : ISignal
		{
			if(null == _syncSignal) _syncSignal = new Signal(SpodObject); 
			return _syncSignal;
		}
		
		public function get removeSignal() : ISignal
		{
			if(null == _removeSignal) _removeSignal = new Signal(SpodObject); 
			return _removeSignal;
		}

		spod_namespace function get table() : SpodTable { return _table; }
		spod_namespace function set table(value : SpodTable) : void { _table = value; }
		
		spod_namespace function get tableRow() : SpodTableRow { return _tableRow; }
		spod_namespace function set tableRow(value : SpodTableRow) : void 
		{ 
			if(null != _tableRow)
			{
				_tableRow.updateSignal.remove(handleUpdateSignal);
				_tableRow.syncSignal.remove(handleSyncSignal);
				_tableRow.removeSignal.remove(handleRemoveSignal);
			}
			
			_tableRow = value;
			
			if(null != value)
			{ 
				_tableRow.updateSignal.add(handleUpdateSignal);
				_tableRow.syncSignal.add(handleSyncSignal);
				_tableRow.removeSignal.add(handleRemoveSignal);
			}
		}
	}
}
