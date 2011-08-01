package org.osflash.spod.builders.table
{
	import org.osflash.spod.SpodStatement;
	import org.osflash.spod.builders.ISpodStatementBuilder;
	import org.osflash.spod.builders.expressions.ISpodExpression;
	import org.osflash.spod.builders.expressions.SpodExpressionType;
	import org.osflash.spod.schema.ISpodColumnSchema;
	import org.osflash.spod.schema.SpodTableSchema;
	import org.osflash.spod.schema.types.SpodSchemaType;

	import flash.errors.IllegalOperationError;
	import flash.utils.getQualifiedClassName;

	/**
	 * @author Simon Richardson - me@simonrichardson.info
	 */
	public class DeleteWhereStatementBuilder implements ISpodStatementBuilder
	{

		/**
		 * @private
		 */
		private var _schema : SpodTableSchema;
		
		/**
		 * @private
		 */
		private var _expressions : Vector.<ISpodExpression>;

		/**
		 * @private
		 */
		private var _buffer : Vector.<String>;

		public function DeleteWhereStatementBuilder(	schema : SpodTableSchema, 
														expressions : Vector.<ISpodExpression>
														)
		{
			if(null == schema) throw new ArgumentError('SpodTableSchema can not be null');
			if(null == expressions) throw new ArgumentError('Expressions can not be null');
			if(expressions.length == 0) throw new ArgumentError('Expressions can not be empty');
			if(schema.schemaType != SpodSchemaType.TABLE) throw new ArgumentError('Schema ' + 
																		'should be a table schema');
			_schema = schema;
			_expressions = expressions;
			
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
				
				const statement : SpodStatement = new SpodStatement(tableSchema.type);
				
				const whereBuffer : Array = [];
				
				const numExpressions : int = _expressions.length;				
				for(var i : int = 0; i<numExpressions; i++)
				{
					const expression : ISpodExpression = _expressions[i];
					if(expression.type == SpodExpressionType.WHERE)
					{
						if(whereBuffer.length > 0) whereBuffer.push(' AND ');
						whereBuffer.push(expression.build(_schema, statement));
					}
					else throw new IllegalOperationError('Unknown expression type');
				}
				
				if(whereBuffer.length > 0)
				{
					_buffer.push(' WHERE ');
					_buffer.push.apply(null, whereBuffer);
				}
				
				// Make the query
				statement.query = _buffer.join('');
				
				return statement;
				
			} else throw new ArgumentError(getQualifiedClassName(_schema) + ' is not supported');
		}
	}
}
