package org.osflash.spod
{
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
		private var _isAsync : Boolean;
		
		/**
		 * @private
		 */
		private var _executioner : SpodExecutioner;
		
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
			
			_isAsync = async;
			
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
			
			_isAsync = false;
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
			errorSignal.dispatch(event);
		}
		
		private function opened() : void
		{
			_database = new SpodDatabase(getDatabaseName(_resource), this);
			
			openSignal.dispatch(_database);
		}
		
		public function get connection() : SQLConnection { return _connection; }
		
		public function get isConnected() : Boolean 
		{ 
			return _connection.connected && null != _database; 
		}
		
		public function get isAsync() : Boolean { return _isAsync; }
		
		public function get database() : SpodDatabase { return _database; }
		
		public function get executioner() : SpodExecutioner { return _executioner; }

		public function get openSignal() : ISignal
		{
			if(null == _openSignal) _openSignal = new Signal(SpodDatabase);
			return _openSignal;
		}

		public function get errorSignal() : ISignal
		{
			if(null == _errorSignal) _errorSignal = new Signal(SQLErrorEvent);
			return _errorSignal;
		}
	}
}
