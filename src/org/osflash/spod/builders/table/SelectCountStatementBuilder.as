package org.osflash.spod.builders.table
{
	import flash.errors.IllegalOperationError;
	import flash.utils.getQualifiedClassName;
	import org.osflash.spod.SpodObjects;
	import org.osflash.spod.SpodStatement;
	import org.osflash.spod.builders.ISpodStatementBuilder;
	import org.osflash.spod.schema.SpodTableColumnSchema;
	import org.osflash.spod.schema.SpodTableSchema;
	import org.osflash.spod.schema.types.SpodSchemaType;

	/**
	 * @author Simon Richardson - me@simonrichardson.info
	 */
	public class SelectCountStatementBuilder implements ISpodStatementBuilder
	{

		/**
		 * @private
		 */
		private var _schema : SpodTableSchema;
		
		/**
		 * @private
		 */
		private var _buffer : Vector.<String>;

		public function SelectCountStatementBuilder(schema : SpodTableSchema)
		{
			if(null == schema) throw new ArgumentError('SpodTableSchema can not be null');
			if(_schema.schemaType != SpodSchemaType.TABLE) throw new ArgumentError('Schema ' + 
																		'should be a table schema');
			_schema = schema;
			
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
				
				_buffer.push('SELECT ');
				_buffer.push('COUNT(`' + _schema.identifier + '`) AS numObjects');				
				_buffer.push(' FROM ');
				_buffer.push('`' + _schema.name + '`');
				
				// We force a SpodObjects here so that we can map it to the numObjects on it.
				const statement : SpodStatement = new SpodStatement(SpodObjects);
				
				// Make the query
				statement.query = _buffer.join('');
				
				return statement;
				
			} else throw new ArgumentError(getQualifiedClassName(_schema) + ' is not supported');
		}
	}
}
