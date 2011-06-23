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
		private var _insertSignal : ISignal;
		
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
		private function handleInsertSignal(object : SpodObject) : void
		{
			if(object != this) return;
			
			insertSignal.dispatch(this);
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
		private function handleSyncSignal(object : SpodObject, updated : Boolean) : void
		{
			if(object != this) return;
			
			syncSignal.dispatch(this, updated);
		}
		
		/**
		 * @private
		 */
		private function handleRemoveSignal(object : SpodObject) : void
		{
			if(object != this) return;
			
			removeSignal.dispatch(this);
		}
		
		public function get insertSignal() : ISignal
		{
			if(null == _insertSignal) _insertSignal = new Signal(SpodObject); 
			return _insertSignal;
		}
		
		public function get updateSignal() : ISignal
		{
			if(null == _updateSignal) _updateSignal = new Signal(SpodObject); 
			return _updateSignal;
		}
		
		public function get syncSignal() : ISignal
		{
			if(null == _syncSignal) _syncSignal = new Signal(SpodObject, Boolean); 
			return _syncSignal;
		}
		
		public function get removeSignal() : ISignal
		{
			if(null == _removeSignal) _removeSignal = new Signal(SpodObject); 
			return _removeSignal;
		}

		spod_namespace function get table() : SpodTable { return _table; }
		spod_namespace function set table(value : SpodTable) : void { _table = value; }
		
		public function get tableRow() : SpodTableRow { return _tableRow; }
		public function set tableRow(value : SpodTableRow) : void 
		{ 
			if(null != _tableRow)
			{
				_tableRow.insertSignal.remove(handleInsertSignal);
				_tableRow.updateSignal.remove(handleUpdateSignal);
				_tableRow.syncSignal.remove(handleSyncSignal);
				_tableRow.removeSignal.remove(handleRemoveSignal);
			}
			
			_tableRow = value;
			
			if(null != value)
			{ 
				_tableRow.insertSignal.add(handleInsertSignal);
				_tableRow.updateSignal.add(handleUpdateSignal);
				_tableRow.syncSignal.add(handleSyncSignal);
				_tableRow.removeSignal.add(handleRemoveSignal);
			}
		}
	}
}
