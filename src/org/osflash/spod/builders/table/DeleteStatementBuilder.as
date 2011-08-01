package org.osflash.spod.builders.table
{
	import org.osflash.spod.SpodObject;
	import org.osflash.spod.SpodStatement;
	import org.osflash.spod.builders.ISpodStatementBuilder;
	import org.osflash.spod.schema.ISpodColumnSchema;
	import org.osflash.spod.schema.ISpodSchema;
	import org.osflash.spod.schema.SpodTableSchema;
	import org.osflash.spod.schema.types.SpodSchemaType;
	import org.osflash.spod.utils.getIdentifierValueFromObject;

	import flash.errors.IllegalOperationError;
	import flash.utils.getQualifiedClassName;

	/**
	 * @author Simon Richardson - me@simonrichardson.info
	 */
	public class DeleteStatementBuilder implements ISpodStatementBuilder
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

		public function DeleteStatementBuilder(schema : ISpodSchema, object : SpodObject)
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
				
				if(total == 0) throw new IllegalOperationError('Invalid columns length');
				
				_buffer.length = 0;
				
				_buffer.push('DELETE FROM ');
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
