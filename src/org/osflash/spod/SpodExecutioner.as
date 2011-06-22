package org.osflash.spod
{
	import flash.errors.IllegalOperationError;
	import flash.data.SQLStatement;
	/**
	 * @author Simon Richardson - me@simonrichardson.info
	 */
	public class SpodExecutioner
	{
		
		/**
		 * @private
		 */
		private var _statements : Vector.<SQLStatement>;
		
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
			_statements = new Vector.<SQLStatement>();
		}
		
		public function add(statement : SQLStatement) : void
		{
			if(_statements.indexOf(statement) != -1) 
				throw new ArgumentError('SQLStatement already exists');
			
			_statements.push(statement);
			
			if(!_running) execute();
		}
		
		public function remove(statement : SQLStatement) : void
		{
			const index : int = _statements.indexOf(statement);
			if(index == -1)
				throw new ArgumentError('No such SQLStatement');
				
			_statements.splice(index, 1); 
		}
		
		private function execute() : void
		{
			if(_running) return;
			
			const statement : SQLStatement = _statements.shift();
			if(statement.executing) 
				throw new IllegalOperationError('SQLStatement is already executing');
			
			statement.sqlConnection = _manager.connection;
			statement.execute();
		}		
	}
}
