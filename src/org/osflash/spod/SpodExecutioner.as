package org.osflash.spod
{
	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;
	import org.osflash.spod.errors.SpodError;
	import org.osflash.spod.errors.SpodErrorEvent;

	import flash.errors.IllegalOperationError;
	/**
	 * @author Simon Richardson - me@simonrichardson.info
	 */
	public class SpodExecutioner
	{
		
		use namespace spod_namespace;
		
		/**
		 * @private
		 */
		private var _queues : Vector.<SpodStatementQueue>;
		
		/**
		 * @private
		 */
		private var _queue : SpodStatementQueueIterator;
		
		/**
		 * @private
		 */
		private var _manager : SpodManager;
		
		/**
		 * @private
		 */
		private var _running : Boolean;
		
		/**
		 * @private
		 */
		private var _executedSignal : ISignal;
				
		public function SpodExecutioner(manager : SpodManager)
		{
			if(null == manager) throw new ArgumentError('Manager can not be null');
			_manager = manager;
			
			_running = false;
			_queues = new Vector.<SpodStatementQueue>();
		}
		
		public function add(queue : SpodStatementQueue) : void
		{
			if(_queues.indexOf(queue) != -1) 
				throw new ArgumentError('SpodStatementQueue already exists');
			
			_queues.push(queue);
			
			if(!_running) advance();
		}
		
		public function remove(queue : SpodStatementQueue) : void
		{
			const index : int = _queues.indexOf(queue);
			if(index == -1)
				throw new ArgumentError('No such SpodStatementQueue');
				
			const removed : SpodStatementQueue = _queues.splice(index, 1)[0];
			if(removed != queue)
				throw new IllegalOperationError('SpodStatementQueue mismatch');
		}
				
		/**
		 * @private
		 */
		private function execute() : void
		{
			if(_running) return;
			if(null == _queue || !_queue.hasNext)
			{
				_running = false;
				return;
			}
			
			_running = true;
			
			const statement : SpodStatement = _queue.next;
			statement.connection = _manager.connection;
			
			if(statement.executing) 
				throw new IllegalOperationError('SpodStatement is already executing');
			
			statement.completedSignal.add(handleCompletedSignal);
			statement.errorSignal.add(handleErrorSignal);
			statement.execute();
		}
		
		/**
		 * @private
		 */
		spod_namespace function advance() : void
		{
			_running = false;
			
			if(null != _queue && _queue.hasNext) execute();
			else
			{
				 if(_queues.length == 0) 
				 {
					if(null != _queue) _queue.queue.active = false;
					
					_queue = null;
				 }
				 else 
				 {
					if(_queues.length > 0) 
					{
						if(null != _queue) _queue.queue.active = false;
						
						const queue : SpodStatementQueue = _queues.shift();
						_queue = queue.iterator;
						_queue.queue.active = true;
					}
					else throw new SpodError('Unable to begin statement queue');
					
					if(_queue.length > 1)
					{
						_manager.beginSignal.addOnce(handleBeginSignal);
						_manager.begin();
					}
					else handleBeginSignal();
				 }
			}
		}
		
		/**
		 * @private
		 */
		private function handleBeginSignal() : void
		{
			execute();
		}
		
		/**
		 * @private
		 */
		private function handleCommitSignal() : void
		{
			executedSignal.dispatch();
			
			advance();
		}
		
		/**
		 * @private
		 */
		private function handleRollbackSignal() : void
		{
			advance();
		}
		
		/**
		 * @private
		 */
		private function handleCompletedSignal(statement : SpodStatement) : void
		{
			if(!_queue.hasNext) 
			{
				if(_queue.length > 1)
				{
					_manager.commitSignal.addOnce(handleCommitSignal);
					_manager.commit();
				} else handleCommitSignal();
			}
			else advance();
			
			statement;
		}
		
		/**
		 * @private
		 */
		private function handleErrorSignal(statement : SpodStatement, event : SpodErrorEvent) : void
		{
			const transaction : Boolean = statement.connection.inTransaction;
			if(transaction)
			{
				_manager.rollbackSignal.addOnce(handleRollbackSignal);
				_manager.rollback();
			}
			else advance();
			
			event;
		}
		
		public function get executedSignal() : ISignal
		{
			if(null == _executedSignal) _executedSignal = new Signal();
			return _executedSignal;
		}
	}
}
