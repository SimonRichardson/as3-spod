package org.osflash.spod
{
	import org.osflash.spod.errors.SpodError;
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public class SpodStatementQueue
	{
		
		/**
		 * @private
		 */
		private var _active : Boolean;
		
		/**
		 * @private
		 */
		private var _statements : Vector.<SpodStatement>;

		public function SpodStatementQueue(initialStatement : SpodStatement = null)
		{
			_active = false;
			_statements = new Vector.<SpodStatement>();
			
			if(null != initialStatement) add(initialStatement);
		}
		
		public function add(statement : SpodStatement) : void
		{
			if(_active) throw new SpodError('Unable to add whilst active');
			
			if(_statements.indexOf(statement) != -1) 
				throw new ArgumentError('SpodStatement already exists');
						
			_statements.push(statement);
		}
		
		public function remove(statement : SpodStatement) : void
		{
			if(_active) throw new SpodError('Unable to remove whilst active');
			
			const index : int = _statements.indexOf(statement);
			if(index == -1)
				throw new ArgumentError('No such SpodStatement');
				
			const removed : SpodStatement = _statements.splice(index, 1)[0];
			if(removed != statement)
				throw new SpodError('SpodStatement mismatch');
		}
		
		public function getAtIndex(index : int) : SpodStatement
		{
			if(index < 0 || index >= _statements.length) throw new RangeError('Index out of range');
			
			return _statements[index];
		}
		
		public function get iterator() : SpodStatementQueueIterator
		{
			return new SpodStatementQueueIterator(this, _statements);
		}
		
		public function get length() : int { return _statements.length; }
		
		public function get active() : Boolean { return _active; }
		public function set active(value : Boolean) : void { _active = value; }
	}
}
