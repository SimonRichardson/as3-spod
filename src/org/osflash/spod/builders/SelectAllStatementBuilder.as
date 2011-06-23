package org.osflash.spod.builders
{
	import org.osflash.spod.SpodStatement;
	import org.osflash.spod.schema.SpodTableColumnSchema;
	import org.osflash.spod.schema.SpodTableSchema;

	import flash.errors.IllegalOperationError;
	import flash.utils.getQualifiedClassName;
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public class SelectAllStatementBuilder implements ISpodStatementBuilder
	{

		/**
		 * @private
		 */
		private var _schema : SpodTableSchema;
		
		/**
		 * @private
		 */
		private var _buffer : String;

		public function SelectAllStatementBuilder(schema : SpodTableSchema)
		{
			if(null == schema) throw new ArgumentError('SpodTableSchema can not be null');
			
			_schema = schema;
			
			_buffer = '';
		}

		public function build() : SpodStatement
		{
			if(_schema is SpodTableSchema)
			{
				const tableSchema : SpodTableSchema = SpodTableSchema(_schema);
				const columns : Vector.<SpodTableColumnSchema> = tableSchema.columns.reverse();
				const total : int = columns.length;
				
				if(total == 0) throw new IllegalOperationError('Invalid columns length');
				
				_buffer = 'SELECT * FROM `' + _schema.name + '`';
				
				const statement : SpodStatement = new SpodStatement(tableSchema.type);
				
				// Make the query
				statement.query = _buffer;
				
				return statement;
				
			} else throw new ArgumentError(getQualifiedClassName(_schema) + ' is not supported');
		}
	}
}
