package org.osflash.spod
{
	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;
	import org.osflash.signals.natives.NativeSignal;

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
			
			_nativeOpenSignal = new NativeSignal(_connection, SQLEvent.OPEN, SQLEvent);
			_nativeErrorSignal = new NativeSignal(_connection, SQLErrorEvent.ERROR, SQLErrorEvent);
			_nativeErrorSignal.add(handleNativeErrorSignal);
		}
		
		public function open(resource : File) : void
		{
			close();
			
			if(null == resource) throw new ArgumentError('Resource should not null');
			_resource = resource;
			
			_nativeOpenSignal.add(handleNativeOpenSignal);
			
			_connection.openAsync(_resource);
		}
		
		public function close() : void
		{
			if(_connection.inTransaction) throw new IllegalOperationError('SQLConnection in use');
			
			if(null != _resource)
			{
				_connection.close();
				_resource = null;
			}
		}
		
		/**
		 * @private
		 */
		private function handleNativeOpenSignal(event : SQLEvent) : void
		{
			_nativeOpenSignal.remove(handleNativeOpenSignal);
			
			_database = new SpodDatabase(this);
			
			openSignal.dispatch(_database);
		}
		
		/**
		 * @private
		 */
		private function handleNativeErrorSignal(event : SQLErrorEvent) : void
		{
			errorSignal.dispatch(event);
		}
		
		public function get connection() : SQLConnection { return _connection; }
		
		public function get isConnected() : Boolean { return null != _database; }
		
		public function get database() : SpodDatabase { return _database; }

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
