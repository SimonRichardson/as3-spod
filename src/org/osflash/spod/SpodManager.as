package org.osflash.spod
{
	import org.osflash.spod.factories.SpodTableDatabaseFactory;
	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;
	import org.osflash.signals.natives.NativeSignal;
	import org.osflash.spod.errors.SpodError;
	import org.osflash.spod.errors.SpodErrorEvent;
	import org.osflash.spod.factories.ISpodDatabaseFactory;
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
		
		use namespace spod_namespace;
		
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
		private var _nativeOpenSignal : ISignal;
		
		/**
		 * @private
		 */
		private var _nativeErrorSignal : ISignal;
		
		/**
		 * @private
		 */
		private var _nativeBeginSignal : ISignal;
		
		/**
		 * @private
		 */
		private var _nativeCommitSignal : ISignal;
		
		/**
		 * @private
		 */
		private var _nativeRollbackSignal : ISignal;
		
		/**
		 * @private
		 */
		private var _openSignal : ISignal;
		
		/**
		 * @private
		 */
		private var _errorSignal : ISignal;
		
		/**
		 * @private
		 */
		private var _beginSignal : ISignal;
		
		/**
		 * @private
		 */
		private var _commitSignal : ISignal;
		
		/**
		 * @private
		 */
		private var _rollbackSignal : ISignal;
		
		/**
		 * @private
		 */
		private var _queuing : Boolean;
		
		/**
		 * @private
		 */
		private var _queue : SpodStatementQueue;
		
		/**
		 * @private
		 */
		private var _databaseFactory : ISpodDatabaseFactory;
		
		public function SpodManager(databaseFactory : ISpodDatabaseFactory = null)
		{
			_queuing = false;
			
			_connection = new SQLConnection();
			_executioner = new SpodExecutioner(this);
			
			_databaseFactory = databaseFactory || new SpodTableDatabaseFactory();
			
			_nativeOpenSignal = new NativeSignal(_connection, SQLEvent.OPEN, SQLEvent);
			_nativeErrorSignal = new NativeSignal(_connection, SQLErrorEvent.ERROR, SQLErrorEvent);
			_nativeErrorSignal.add(handleNativeErrorSignal);
			
			_nativeBeginSignal = new NativeSignal(_connection, SQLEvent.BEGIN, SQLEvent);
			_nativeCommitSignal = new NativeSignal(_connection, SQLEvent.COMMIT, SQLEvent);
			_nativeRollbackSignal = new NativeSignal(_connection, SQLEvent.ROLLBACK, SQLEvent);
		}
		
		public function open(resource : File, async : Boolean = false) : void
		{
			close();
			
			if(null == resource) throw new ArgumentError('Resource should not null');
			_resource = resource;
			
			_nativeOpenSignal.addOnce(handleNativeOpenSignal);
			
			_async = async;
			
			if(async) _connection.openAsync(_resource);
			else _connection.open(_resource);
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
		
		public function begin() : void
		{
			_nativeBeginSignal.addOnce(handleNativeBeginSignal);
			
			_connection.begin();
		}
		
		public function commit() : void
		{
			_nativeCommitSignal.addOnce(handleNativeCommitSignal);
			
			_connection.commit();
		}
		
		public function rollback() : void
		{
			_nativeRollbackSignal.addOnce(handleNativeRollbackSignal);
			
			_connection.rollback();
		}
		
		spod_namespace function beginQueue() : void
		{
			if(!_async) throw new SpodError('Unable to run queueing in sync mode, try Async mode');
			if(_queuing) throw new SpodError('Unable to begin as already in begin state');
			
			_queuing = true;
			_queue = new SpodStatementQueue();
		}
		
		spod_namespace function releaseQueue() : void
		{
			if(!_async) throw new SpodError('Unable to run queueing in sync mode, try Async mode');
			if(_queuing) throw new SpodError('Unable to release as not in begin state');
			if(_queue.active) throw new SpodError(	'Unable to release queue as ' + 
																'already active'
																);
			_executioner.remove(_queue);
			
			_queue = null;
			_queuing = false;
		}
		
		spod_namespace function commitQueue() : void
		{
			if(!_async) throw new SpodError('Unable to run queueing in sync mode, try Async mode');
			if(!_queuing) throw new SpodError(	'Unable to commit as there is nothing to commit, ' + 
												'try calling begin()'
												);
			if(null == _queue) throw new SpodError('Invalid queue found');
			if(_queue.length == 0) throw new SpodError('Queue can not be 0');
			
			_executioner.executedSignal.addOnce(handleExecutedSignal);
			_executioner.add(_queue);
			
			_queuing = false;
		}
		
		spod_namespace function get queue() : SpodStatementQueue { return _queue; }

		spod_namespace function get queuing() : Boolean { return _queuing; }
		
		/**
		 * @private
		 */
		private function handleExecutedSignal() : void
		{
			const queued : Boolean = _queuing;
			
			_queue = null;
			_queuing = false;
			
			if(queued) _executioner.advance();
		}
				
		/**
		 * @private
		 */
		private function handleNativeOpenSignal(event : SQLEvent) : void
		{
			opened();
		}
		
		/**
		 * @private
		 */
		private function handleNativeErrorSignal(event : SQLErrorEvent) : void
		{
			const error : SpodError = new SpodError('Native SQLError');
			errorSignal.dispatch(new SpodErrorEvent(event.text, error, event));
		}
		
		/**
		 * @private
		 */
		private function handleNativeBeginSignal(event : SQLEvent) : void
		{
			_beginSignal.dispatch();
		}
		
		/**
		 * @private
		 */
		private function handleNativeCommitSignal(event : SQLEvent) : void
		{
			_commitSignal.dispatch();
		}
		
		/**
		 * @private
		 */
		private function handleNativeRollbackSignal(event : SQLEvent) : void
		{
			_rollbackSignal.dispatch();
		}
		
		/**
		 * @private
		 */
		private function opened() : void
		{
			if(null == _databaseFactory) throw new SpodError('Invalid Database Factory');
			
			const name : String = getDatabaseName(_resource);
			_database = _databaseFactory.create(name, this);
					
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

		public function get beginSignal() : ISignal
		{
			if(null == _beginSignal) _beginSignal = new Signal();
			return _beginSignal;
		}
		
		public function get commitSignal() : ISignal
		{
			if(null == _commitSignal) _commitSignal = new Signal();
			return _commitSignal;
		}
		
		public function get rollbackSignal() : ISignal
		{
			if(null == _rollbackSignal) _rollbackSignal = new Signal();
			return _rollbackSignal;
		}
	}
}
