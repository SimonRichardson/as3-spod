package org.osflash.spod.builders
{
	import org.osflash.spod.SpodStatement;
	import org.osflash.spod.schema.ISpodSchema;
	import org.osflash.spod.schema.SpodTableColumnSchema;
	import org.osflash.spod.schema.SpodTableSchema;
	import org.osflash.spod.types.SpodTypes;

	import flash.errors.IllegalOperationError;
	import flash.utils.getQualifiedClassName;
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public class CreateTableStatementBuilder implements ISpodStatementBuilder
	{
		
		/**
		 * @private
		 */
		private var _schema : ISpodSchema;
		
		/**
		 * @private
		 */
		private var _buffer : Vector.<String>;
		
		/**
		 * @private
		 */
		private var _ignoreIfExists : Boolean;
		
		public function CreateTableStatementBuilder(schema : ISpodSchema)
		{
			if(null == schema) throw new ArgumentError('Schema can not be null');
			_schema = schema;
			
			_buffer = new Vector.<String>();
			_ignoreIfExists = true; // TODO : make sure we can inject this.
		}
		
		/**
		 * @inheritDoc
		 */
		public function build() : SpodStatement
		{
			if(_schema is SpodTableSchema)
			{
				const tableSchema : SpodTableSchema = SpodTableSchema(_schema);
				const columns : Vector.<SpodTableColumnSchema> = tableSchema.columns.reverse();
				const total : int = columns.length;
				
				if(total == 0) throw new IllegalOperationError('Invalid columns length');
				
				_buffer.length = 0;
				
				_buffer.push('CREATE TABLE ');
				
				if(_ignoreIfExists) _buffer.push('IF NOT EXISTS ');
				
				_buffer.push('`' + _schema.name + '` ');
				_buffer.push('(');
				
				for(var i : int = 0; i<total; i++)
				{
					const column : SpodTableColumnSchema = columns[i];
					
					if(column.name == 'id' && column.type == SpodTypes.INT)
					{
						_buffer.push('`' + column.name + '` ');
						_buffer.push('INTEGER ');
						_buffer.push('PRIMARY KEY ');
						_buffer.push('NOT NULL');
						_buffer.push(', ');
					}
					else
					{
						_buffer.push('`' + column.name + '` ');
						_buffer.push(SpodTypes.getSQLName(column.type) + ' ');
						_buffer.push('NOT NULL');
						_buffer.push(', ');
					}
				}
				
				_buffer.pop();
				_buffer.push(')');
						
				const statement : SpodStatement = new SpodStatement(tableSchema.type);
				statement.query = _buffer.join('');
				
				return statement;
				
			} else throw new ArgumentError(getQualifiedClassName(_schema) + ' is not supported');
		}
	}
}
