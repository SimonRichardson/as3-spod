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
		private var _statements : Vector.<SpodStatement>;
		
		public function SpodStatementQueueIterator(statements : Vector.<SpodStatement>)
		{
			if(null == statements) throw new ArgumentError('Statements can not be null');
			
			_cursor = 0;
			_statements = statements;
		}
		
		public function get hasNext() : Boolean
		{
			return _cursor + 1 < _statements.length;
		}
		
		public function get next() : SpodStatement
		{
			if(_cursor >= _statements.length) throw new RangeError('Index out of range');
			
			const statement : SpodStatement = _statements[_cursor];
			
			_cursor++;
			
			return statement;
		}
	}
}
