package org.osflash.spod.builders.table
{
	import org.osflash.spod.SpodObject;
	import org.osflash.spod.SpodStatement;
	import org.osflash.spod.builders.ISpodStatementBuilder;
	import org.osflash.spod.errors.SpodError;
	import org.osflash.spod.schema.ISpodColumnSchema;
	import org.osflash.spod.schema.ISpodSchema;
	import org.osflash.spod.schema.SpodTableSchema;
	import org.osflash.spod.schema.types.SpodSchemaType;
	import org.osflash.spod.utils.getIdentifierValueFromObject;

	import flash.utils.getQualifiedClassName;

	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public class SelectStatementBuilder implements ISpodStatementBuilder
	{

		/**
		 * @private
		 */
		private var _schema : ISpodSchema;
		
		/**
		 * @private
		 */
		private var _object : SpodObject;

		/**
		 * @private
		 */
		private var _buffer : Vector.<String>;

		public function SelectStatementBuilder(schema : ISpodSchema, object : SpodObject)
		{
			if(null == schema) throw new ArgumentError('Schema can not be null');
			if(null == object) throw new ArgumentError('Object can not be null');
			if(schema.schemaType != SpodSchemaType.TABLE) throw new ArgumentError('Schema ' + 
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
				const columns : Vector.<ISpodColumnSchema> = tableSchema.columns;
				const total : int = columns.length;
				
				if(total == 0) throw new SpodError('Invalid columns length');
				
				_buffer.length = 0;
				
				_buffer.push('SELECT ');
				
				for(var i : int = 0; i<total; i++)
				{
					const column : ISpodColumnSchema = columns[i];
					const columnName : String = column.name;
					
					_buffer.push('`' + columnName + '`');
					_buffer.push(', ');
				}
				
				_buffer.pop();
				
				_buffer.push(' FROM ');
				_buffer.push('`' + _schema.name + '`');
				_buffer.push(' WHERE ');
				_buffer.push('`' + _schema.identifier + '`=:id');
				
				const statement : SpodStatement = new SpodStatement(tableSchema.type, _object);
				statement.parameters[':id'] = getIdentifierValueFromObject(	_object, 
																			_schema.identifier
																			);
								
				// Make the query
				statement.query = _buffer.join('');
				
				return statement;
				
			} else throw new ArgumentError(getQualifiedClassName(_schema) + ' is not supported');
		}
	}
}
