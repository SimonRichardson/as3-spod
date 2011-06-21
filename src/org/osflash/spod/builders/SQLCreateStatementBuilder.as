package org.osflash.spod.builders
{
	import org.osflash.spod.schema.ISpodSchema;
	import org.osflash.spod.schema.SpodTableColumnSchema;
	import org.osflash.spod.schema.SpodTableSchema;
	import org.osflash.spod.types.SpodInt;
	import org.osflash.spod.types.SpodTypes;

	import flash.errors.IllegalOperationError;
	import flash.utils.getQualifiedClassName;
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public class SQLCreateStatementBuilder implements ISQLStatementBuilder
	{
		
		private var _buffer : Vector.<String>;
		
		public function SQLCreateStatementBuilder()
		{
			_buffer = new Vector.<String>();
		}
		
		public function build(schema : ISpodSchema) : String
		{
			if(schema is SpodTableSchema)
			{
				const tableSchema : SpodTableSchema = SpodTableSchema(schema);
				const columns : Vector.<SpodTableColumnSchema> = tableSchema.columns;
				const total : int = columns.length;
				
				if(total == 0) throw new IllegalOperationError('Invalid columns length');
				
				_buffer.push('CREATE TABLE ');
				_buffer.push('`' + schema.name + '` ');
				_buffer.push('(');
				
				for(var i : int = 0; i<total; i++)
				{
					const column : SpodTableColumnSchema = columns[i];
					
					if(column.name == 'id' && column.type == SpodInt)
					{
						_buffer.push(column.name + ' ');
						_buffer.push('INTEGER ');
						_buffer.push('PRIMARY KEY ');
						_buffer.push('NOT NULL');
						_buffer.push(', ');
					}
					else
					{
						_buffer.push(column.name + ' ');
						_buffer.push(SpodTypes.getSQLName(column.type) + ' ');
						_buffer.push('NOT NULL');
						_buffer.push(', ');
					}
				}
				
				_buffer.pop();
				_buffer.push(')');
						
			} else throw new ArgumentError(getQualifiedClassName(schema) + ' is not supported');
			
			return sql;
		}

		public function get sql() : String { return _buffer.join(''); }
	}
}
