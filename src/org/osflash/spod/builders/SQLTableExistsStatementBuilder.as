package org.osflash.spod.builders
{
	import flash.utils.getQualifiedClassName;
	import org.osflash.spod.utils.getClassNameFromQname;
	import flash.data.SQLStatement;
	/**
	 * @author Simon Richardson - me@simonrichardson.info
	 */
	public class SQLTableExistsStatementBuilder implements ISQLStatementBuilder
	{
		
		/**
		 * @private
		 */
		private var _type : Class;
		
		/**
		 * @private
		 */
		private var _buffer : String;

		public function SQLTableExistsStatementBuilder(type : Class)
		{
			if(null == type) throw new ArgumentError('Type can not be null');
			_type = type;
			
			_buffer = '';
		}

		/**
		 * @inheritDoc
		 */
		public function build() : SQLStatement
		{
			_buffer = '';
			_buffer += 'SELECT name ';
			_buffer += 'FROM sqlite_master ';
			_buffer += 'WHERE type=`table` ';
			_buffer += 'AND name=`:name`';
			
			const qname : String = getQualifiedClassName(_type);
			
			const statement : SQLStatement = new SQLStatement();
			statement.text = _buffer;
			statement.itemClass = _type;
			statement.parameters[':name'] = getClassNameFromQname(qname);
			
			return statement;
		}
	}
}
