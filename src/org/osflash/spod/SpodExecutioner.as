package org.osflash.spod
{
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
			
			if(!_running) execute();
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
		
		private function execute() : void
		{
			if(_running) return;
			
			const statement : SpodStatement = _statements.shift();
			if(statement.executing) 
				throw new IllegalOperationError('SpodStatement is already executing');
			
			statement.execute();
		}		
	}
}
