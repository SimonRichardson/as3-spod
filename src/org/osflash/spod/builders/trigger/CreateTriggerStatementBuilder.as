package org.osflash.spod.builders.trigger
{
	import org.osflash.logger.logs.info;
	import org.osflash.spod.SpodStatement;
	import org.osflash.spod.builders.ISpodStatementBuilder;
	import org.osflash.spod.errors.SpodError;
	import org.osflash.spod.schema.ISpodSchema;
	import org.osflash.spod.schema.SpodTableColumnSchema;
	import org.osflash.spod.schema.SpodTableSchema;
	import org.osflash.spod.schema.SpodTriggerSchema;
	import org.osflash.spod.schema.types.SpodSchemaType;

	import flash.utils.getQualifiedClassName;
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public class CreateTriggerStatementBuilder implements ISpodStatementBuilder
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
		
		public function CreateTriggerStatementBuilder(	schema : ISpodSchema, 
														ignoreIfExists : Boolean = true
														)
		{
			if(null == schema) throw new ArgumentError('Schema can not be null');
			if(_schema.schemaType != SpodSchemaType.TRIGGER) throw new ArgumentError('Schema ' + 
																		'should be a index schema');
			_schema = schema;
			
			_buffer = new Vector.<String>();
			_ignoreIfExists = ignoreIfExists;
		}
		
		/**
		 * @inheritDoc
		 */
		public function build() : SpodStatement
		{
			if(_schema is SpodTriggerSchema)
			{
				const tableSchema : SpodTableSchema = SpodTableSchema(_schema);
				const columns : Vector.<SpodTableColumnSchema> = tableSchema.columns.reverse();
				const total : int = columns.length;
				
				if(total == 0) throw new SpodError('Invalid columns length');
				
				_buffer.length = 0;
				
				_buffer.push('CREATE TRIGGER ');
				
				if(_ignoreIfExists) _buffer.push('IF NOT EXISTS ');
				
				
				
				if(length == _buffer.length) throw new SpodError('No identifier found.');
						
				const statement : SpodStatement = new SpodStatement(tableSchema.type);
				statement.query = _buffer.join('');
				
				info(statement.query);
				
				return statement;
				
			} else throw new ArgumentError(getQualifiedClassName(_schema) + ' is not supported');
		}
	}
}
