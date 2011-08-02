package org.osflash.spod.builders.trigger
{
	import org.osflash.spod.SpodStatement;
	import org.osflash.spod.builders.ISpodStatementBuilder;
	import org.osflash.spod.schema.ISpodColumnSchema;
	import org.osflash.spod.schema.ISpodSchema;
	import org.osflash.spod.schema.SpodTriggerSchema;
	import org.osflash.spod.schema.types.SpodSchemaType;

	import flash.errors.IllegalOperationError;
	import flash.utils.getQualifiedClassName;
	/**
	 * @author Simon Richardson - me@simonrichardson.info
	 */
	public class DeleteTriggerStatementBuilder implements ISpodStatementBuilder
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
		private var _ifExists : Boolean;

		public function DeleteTriggerStatementBuilder(	schema : ISpodSchema, 
														ifExists : Boolean = true
														)
		{
			if(null == schema) throw new ArgumentError('Schema can not be null');
			if(schema.schemaType != SpodSchemaType.TRIGGER) throw new ArgumentError('Schema ' + 
																	'should be a trigger schema');
																		
			_schema = schema;
			
			_buffer = new Vector.<String>();
			_ifExists = ifExists;
		}

		public function build() : SpodStatement
		{
			if(_schema is SpodTriggerSchema)
			{
				const triggerSchema : SpodTriggerSchema = SpodTriggerSchema(_schema);
				const columns : Vector.<ISpodColumnSchema> = triggerSchema.columns;
				const total : int = columns.length;
				
				if(total == 0) throw new IllegalOperationError('Invalid columns length');
				
				_buffer.length = 0;
				
				_buffer.push('DROP TRIGGER ');
				
				if(_ifExists) _buffer.push('IF EXISTS ');
				
				_buffer.push('`' + _schema.name + '`');
				
				const statement : SpodStatement = new SpodStatement(triggerSchema.type);
				
				// Make the query
				statement.query = _buffer.join('');
				
				return statement;
				
			} else throw new ArgumentError(getQualifiedClassName(_schema) + ' is not supported');
		}
	}
}
