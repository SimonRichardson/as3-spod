package org.osflash.spod
{
	import org.osflash.spod.errors.SpodErrorEvent;
	import flash.errors.IllegalOperationError;
	/**
	 * @author Simon Richardson - me@simonrichardson.info
	 */
	public class SpodExecutioner
	{
		
		/**
		 * @private
		 */
		private var _statements : Vector.<SpodStatement>;
		
		/**
		 * @private
		 */
		private var _manager : SpodManager;
		
		/**
		 * @private
		 */
		private var _running : Boolean;
				
		public function SpodExecutioner(manager : SpodManager)
		{
			if(null == manager) throw new ArgumentError('Manager can not be null');
			_manager = manager;
			
			_running = false;
			_statements = new Vector.<SpodStatement>();
		}
		
		public function add(statement : SpodStatement) : void
		{
			if(_statements.indexOf(statement) != -1) 
				throw new ArgumentError('SpodStatement already exists');
			
			statement.connection = _manager.connection;
			
			_statements.push(statement);
			
			if(!_running) advance();
		}
		
		public function remove(statement : SpodStatement) : void
		{
			const index : int = _statements.indexOf(statement);
			if(index == -1)
				throw new ArgumentError('No such SpodStatement');
				
			const removed : SpodStatement = _statements.splice(index, 1)[0];
			if(removed != statement)
				throw new IllegalOperationError('SpodStatement mismatch');
			
			statement.connection = null;
		}
		
		/**
		 * @private
		 */
		private function execute() : void
		{
			if(_running) return;
			if(_statements.length == 0)
			{
				_running = false;
				return;
			}
			
			_running = true;
			
			const statement : SpodStatement = _statements.shift();
			if(statement.executing) 
				throw new IllegalOperationError('SpodStatement is already executing');
			
			statement.completedSignal.add(handleCompletedSignal);
			statement.errorSignal.add(handleErrorSignal);
			statement.execute();
		}
		
		/**
		 * @private
		 */
		private function advance() : void
		{
			_running = false;
			execute();
		}
				
		/**
		 * @private
		 */
		private function handleCompletedSignal(statement : SpodStatement) : void
		{
			advance();
			
			statement;
		}
		
		/**
		 * @private
		 */
		private function handleErrorSignal(statement : SpodStatement, event : SpodErrorEvent) : void
		{
			advance();
			
			event;
			statement;
		}
	}
}
