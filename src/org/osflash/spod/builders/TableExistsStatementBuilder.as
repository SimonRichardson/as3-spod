package org.osflash.spod.builders
{
	import org.osflash.spod.SpodStatement;
	import org.osflash.spod.utils.getClassNameFromQname;

	import flash.utils.getQualifiedClassName;
	/**
	 * @author Simon Richardson - me@simonrichardson.info
	 */
	public class TableExistsStatementBuilder implements ISpodStatementBuilder
	{
		
		/**
		 * @private
		 */
		private var _type : Class;
		
		/**
		 * @private
		 */
		private var _buffer : String;

		public function TableExistsStatementBuilder(type : Class)
		{
			if(null == type) throw new ArgumentError('Type can not be null');
			_type = type;
			
			_buffer = '';
		}

		/**
		 * @inheritDoc
		 */
		public function build() : SpodStatement
		{
			_buffer = '';
			_buffer += 'SELECT name ';
			_buffer += 'FROM sqlite_master ';
			_buffer += 'WHERE type=`table` ';
			_buffer += 'AND name=`:name`';
			
			const qname : String = getQualifiedClassName(_type);
			
			const statement : SpodStatement = new SpodStatement(_type);
			statement.query = _buffer;
			statement.parameters[':name'] = getClassNameFromQname(qname);
			
			return statement;
		}
	}
}
