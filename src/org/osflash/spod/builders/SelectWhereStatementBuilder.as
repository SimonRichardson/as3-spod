package org.osflash.spod.builders
{
	import org.osflash.spod.SpodStatement;
	import org.osflash.spod.builders.expressions.ISpodExpression;
	import org.osflash.spod.builders.expressions.SpodExpressionType;
	import org.osflash.spod.schema.SpodTableColumnSchema;
	import org.osflash.spod.schema.SpodTableSchema;

	import flash.errors.IllegalOperationError;
	import flash.utils.getQualifiedClassName;
	/**
	 * @author Simon Richardson - me@simonrichardson.info
	 */
	public class SelectWhereStatementBuilder implements ISpodStatementBuilder
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

		public function SelectWhereStatementBuilder(	schema : SpodTableSchema, 
														expressions : Vector.<ISpodExpression>
														)
		{
			if(null == schema) throw new ArgumentError('SpodTableSchema can not be null');
			if(null == expressions) throw new ArgumentError('Expressions can not be null');
			if(expressions.length == 0) throw new ArgumentError('Expressions can not be empty');
			
			_schema = schema;
			_expressions = expressions;
			
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
				
				for(var i : int = 0; i<total; i++)
				{
					const column : SpodTableColumnSchema = columns[i];
					const columnName : String = column.name;
					
					_buffer.push('`' + columnName + '`');
					_buffer.push(', ');
				}
				
				_buffer.pop();
				
				_buffer.push(' FROM ');
				_buffer.push('`' + _schema.name + '`');
				
				const statement : SpodStatement = new SpodStatement(tableSchema.type);
				
				const whereBuffer : Vector.<String> = new Vector.<String>();
				const orderBuffer : Vector.<String> = new Vector.<String>();
				
				const numExpressions : int = _expressions.length;				
				for(i=0; i<numExpressions; i++)
				{
					const expression : ISpodExpression = _expressions[i];
					if(expression.type == SpodExpressionType.WHERE)
					{
						if(whereBuffer.length > 0) whereBuffer.push(' AND ');
						whereBuffer.push(expression.build());
					}
					else if(expression.type == SpodExpressionType.ORDER)
					{
						if(orderBuffer.length > 0) orderBuffer.push(' AND ');
						orderBuffer.push(expression.build());
					}
					else throw new IllegalOperationError('Unknown expression type');
				}
				
				if(whereBuffer.length > 0)
				{
					_buffer.push(' WHERE ');
					_buffer.push.apply(null, whereBuffer);
				}
				
				if(orderBuffer.length > 0)
				{
					_buffer.push(' ORDER BY ');
					_buffer.push.apply(null, orderBuffer);
				}
				
				// Make the query
				statement.query = _buffer.join('');
				
				return statement;
				
			} else throw new ArgumentError(getQualifiedClassName(_schema) + ' is not supported');
		}
	}
}
