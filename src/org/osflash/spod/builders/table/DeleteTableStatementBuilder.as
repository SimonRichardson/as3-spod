package org.osflash.spod.builders.table
{
	import org.osflash.spod.SpodStatement;
	import org.osflash.spod.builders.ISpodStatementBuilder;
	import org.osflash.spod.schema.ISpodColumnSchema;
	import org.osflash.spod.schema.SpodTableSchema;
	import org.osflash.spod.schema.types.SpodSchemaType;

	import flash.errors.IllegalOperationError;
	import flash.utils.getQualifiedClassName;

	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public class DeleteTableStatementBuilder implements ISpodStatementBuilder
	{

		/**
		 * @private
		 */
		private var _schema : SpodTableSchema;
		
		/**
		 * @private
		 */
		private var _buffer : Vector.<String>;
		
		/**
		 * @private
		 */
		private var _ifExists : Boolean;

		public function DeleteTableStatementBuilder(	schema : SpodTableSchema, 
														ifExists : Boolean = true
														)
		{
			if(null == schema) throw new ArgumentError('SpodTableSchema can not be null');
			if(schema.schemaType != SpodSchemaType.TABLE) throw new ArgumentError('Schema ' + 
																		'should be a table schema');
																		
			_schema = schema;
			
			_buffer = new Vector.<String>();
			_ifExists = ifExists;
		}

		public function build() : SpodStatement
		{
			if(_schema is SpodTableSchema)
			{
				const tableSchema : SpodTableSchema = SpodTableSchema(_schema);
				const columns : Vector.<ISpodColumnSchema> = tableSchema.columns;
				const total : int = columns.length;
				
				if(total == 0) throw new IllegalOperationError('Invalid columns length');
				
				_buffer.length = 0;
				
				_buffer.push('DROP TABLE ');
				
				if(_ifExists) _buffer.push('IF EXISTS ');
				
				_buffer.push('`' + _schema.name + '`');
				
				const statement : SpodStatement = new SpodStatement(tableSchema.type);
				
				// Make the query
				statement.query = _buffer.join('');
				
				return statement;
				
			} else throw new ArgumentError(getQualifiedClassName(_schema) + ' is not supported');
		}
	}
}
