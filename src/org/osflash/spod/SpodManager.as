package org.osflash.spod
{
	import org.osflash.spod.errors.SpodErrorEvent;
	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;
	import org.osflash.signals.natives.NativeSignal;
	import org.osflash.spod.utils.getDatabaseName;

	import flash.data.SQLConnection;
	import flash.errors.IllegalOperationError;
	import flash.events.SQLErrorEvent;
	import flash.events.SQLEvent;
	import flash.filesystem.File;
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public class SpodManager
	{
		
		/**
		 * @private
		 */
		private var _resource : File;
		
		/**
		 * @private
		 */
		private var _connection : SQLConnection;
		
		/**
		 * @private
		 */
		private var _database : SpodDatabase;
		
		/**
		 * @private
		 */
		private var _async : Boolean;
		
		/**
		 * @private
		 */
		private var _executioner : SpodExecutioner;
		
		/**
		 * @private
		 */
		private var _savepointName : String;
		
		/**
		 * @private
		 */
		private var _nativeOpenSignal : ISignal;
		
		/**
		 * @private
		 */
		private var _nativeErrorSignal : ISignal;
		
		/**
		 * @private
		 */
		private var _openSignal : ISignal;
		
		/**
		 * @private
		 */
		private var _errorSignal : ISignal;
		
		public function SpodManager()
		{
			_connection = new SQLConnection();
			_executioner = new SpodExecutioner(this);
			
			_nativeOpenSignal = new NativeSignal(_connection, SQLEvent.OPEN, SQLEvent);
			_nativeErrorSignal = new NativeSignal(_connection, SQLErrorEvent.ERROR, SQLErrorEvent);
			_nativeErrorSignal.add(handleNativeErrorSignal);
		}
		
		public function open(resource : File, async : Boolean = false) : void
		{
			close();
			
			if(null == resource) throw new ArgumentError('Resource should not null');
			_resource = resource;
			
			_nativeOpenSignal.add(handleNativeOpenSignal);
			
			_async = async;
			
			if(async) _connection.openAsync(_resource);
			else 
			{	
				_connection.open(_resource);
			
				opened();
			}
		}
		
		public function close() : void
		{
			if(_connection.inTransaction) throw new IllegalOperationError('SQLConnection in use');
			
			if(null != _resource)
			{
				_connection.close();
				_resource = null;
			}
			
			_async = false;
		}
		
		public function addSavepoint() : void
		{
			_savepointName = "Savepoint" + new Date().time;
			_connection.setSavepoint(_savepointName);
		}
		
		public function commitSavepoint() : void
		{
			_connection.releaseSavepoint(_savepointName);
		}
		
		public function revertSavepoint() : void
		{
			_connection.rollbackToSavepoint(_savepointName);
		}
		
		/**
		 * @private
		 */
		private function handleNativeOpenSignal(event : SQLEvent) : void
		{
			_nativeOpenSignal.remove(handleNativeOpenSignal);
			
			opened();
		}
		
		/**
		 * @private
		 */
		private function handleNativeErrorSignal(event : SQLErrorEvent) : void
		{
			errorSignal.dispatch(new SpodErrorEvent(event.text, event));
		}
		
		private function opened() : void
		{
			_database = new SpodDatabase(getDatabaseName(_resource), this);
			
			openSignal.dispatch(_database);
		}
		
		public function get connection() : SQLConnection { return _connection; }
		
		public function get connected() : Boolean 
		{ 
			return _connection.connected && null != _database; 
		}
		
		public function get async() : Boolean { return _async; }
		
		public function get database() : SpodDatabase { return _database; }
		
		public function get executioner() : SpodExecutioner { return _executioner; }

		public function get openSignal() : ISignal
		{
			if(null == _openSignal) _openSignal = new Signal(SpodDatabase);
			return _openSignal;
		}

		public function get errorSignal() : ISignal
		{
			if(null == _errorSignal) _errorSignal = new Signal(SpodErrorEvent);
			return _errorSignal;
		}
	}
}
