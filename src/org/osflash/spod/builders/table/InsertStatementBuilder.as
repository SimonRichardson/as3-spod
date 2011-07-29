package org.osflash.spod.builders.table
{
	import flash.errors.IllegalOperationError;
	import flash.utils.getQualifiedClassName;
	import org.osflash.spod.SpodObject;
	import org.osflash.spod.SpodStatement;
	import org.osflash.spod.builders.ISpodStatementBuilder;
	import org.osflash.spod.schema.SpodTableColumnSchema;
	import org.osflash.spod.schema.SpodTableSchema;
	import org.osflash.spod.schema.types.SpodSchemaType;
	import org.osflash.spod.types.SpodTypes;

	/**
	 * @author Simon Richardson - me@simonrichardson.info
	 */
	public class InsertStatementBuilder implements ISpodStatementBuilder
	{

		/**
		 * @private
		 */
		private var _schema : SpodTableSchema;
		
		/**
		 * @private
		 */
		private var _object : SpodObject;

		/**
		 * @private
		 */
		private var _buffer : Vector.<String>;

		public function InsertStatementBuilder(schema : SpodTableSchema, object : SpodObject)
		{
			if(null == schema) throw new ArgumentError('SpodTableSchema can not be null');
			if(null == object) throw new ArgumentError('SpodObject can not be null');
			if(_schema.schemaType != SpodSchemaType.TABLE) throw new ArgumentError('Schema ' + 
																		'should be a table schema');
			_schema = schema;
			_object = object;
			
			_buffer = new Vector.<String>();
		}

		public function build() : SpodStatement
		{
			if(_schema is SpodTableSchema)
			{
				const tableSchema : SpodTableSchema = SpodTableSchema(_schema);
				const columns : Vector.<SpodTableColumnSchema> = tableSchema.columns.reverse();
				const total : int = columns.length;
				
				if(total == 0) throw new IllegalOperationError('Invalid columns length');
				
				_buffer.length = 0;
				
				_buffer.push('INSERT INTO ');
				_buffer.push('`' + _schema.name + '` ');
				
				var i : int;
				var column : SpodTableColumnSchema;
				var columnName : String;
				
				// Get the names
				_buffer.push('(');
				for(i=0; i<total; i++)
				{
					column = columns[i];
					columnName = column.name;
					
					if(	columnName == _schema.identifier && 
						column.type == SpodTypes.INT &&
						column.autoIncrement
						) 
						continue;
					
					_buffer.push('`' + columnName + '`');
					_buffer.push(', ');
				}
				
				_buffer.pop();
				_buffer.push(')');
				
				_buffer.push(' VALUES ');
				
				const statement : SpodStatement = new SpodStatement(tableSchema.type, _object);
				
				// Insert the values
				_buffer.push('(');
				for(i=0; i<total; i++)
				{
					column = columns[i];
					columnName = column.name;
					
					if(	columnName == _schema.identifier && 
						column.type == SpodTypes.INT &&
						column.autoIncrement
						) 
						continue;
										
					_buffer.push(':' + columnName + '');
					_buffer.push(', ');
					
					statement.parameters[':' + columnName] = _object[columnName];
				}
				
				_buffer.pop();
				_buffer.push(')');
				
				// Make the query
				statement.query = _buffer.join('');
								
				return statement;
				
			} else throw new ArgumentError(getQualifiedClassName(_schema) + ' is not supported');
		}
	}
}
