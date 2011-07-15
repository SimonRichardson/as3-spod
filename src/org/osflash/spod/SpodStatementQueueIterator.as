package org.osflash.spod
{
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public class SpodStatementQueueIterator
	{
		
		/**
		 * @private
		 */
		private var _cursor : int;
		
		/**
		 * @private
		 */
		private var _queue : SpodStatementQueue;
		
		/**
		 * @private
		 */
		private var _statements : Vector.<SpodStatement>;
		
		public function SpodStatementQueueIterator(	queue : SpodStatementQueue,
													statements : Vector.<SpodStatement>
													)
		{
			if(null == queue) throw new ArgumentError('Queue can not be null');
			if(null == statements) throw new ArgumentError('Statements can not be null');
			
			_cursor = 0;
			
			_queue = queue;
			_queue.active = true;
			
			_statements = statements;
		}
		
		public function get hasNext() : Boolean
		{
			return _cursor < _statements.length;
		}
		
		public function get next() : SpodStatement
		{
			if(_cursor >= _statements.length) throw new RangeError('Index out of range');
			
			const statement : SpodStatement = _statements[_cursor];
			
			_cursor++;
			
			return statement;
		}
		
		spod_namespace function get queue() : SpodStatementQueue { return _queue; }
	}
}
