package org.osflash.spod.builders.trigger
{
	import org.osflash.spod.SpodStatement;
	import org.osflash.spod.builders.ISpodStatementBuilder;
	import org.osflash.spod.builders.expressions.ISpodExpression;
	import org.osflash.spod.builders.expressions.SpodExpressionType;
	import org.osflash.spod.builders.expressions.limit.LimitExpression;
	import org.osflash.spod.schema.ISpodColumnSchema;
	import org.osflash.spod.schema.ISpodSchema;
	import org.osflash.spod.schema.SpodTableSchema;
	import org.osflash.spod.schema.SpodTriggerSchema;
	import org.osflash.spod.schema.types.SpodSchemaType;
	import org.osflash.spod.utils.getTableNameFromTriggerName;

	import flash.errors.IllegalOperationError;
	import flash.utils.getQualifiedClassName;
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public class LimitDeleteStatementBuilder implements ISpodStatementBuilder
	{
		
		public static const DEFAULT_LIMIT_NUMBER : int = 999999;

		/**
		 * @private
		 */
		private var _schema : ISpodSchema;
		
		/**
		 * @private
		 */
		private var _expressions : Vector.<ISpodExpression>;
		
		/**
		 * @private
		 */
		private var _limitedExpression : Boolean;

		/**
		 * @private
		 */
		private var _buffer : Vector.<String>;

		public function LimitDeleteStatementBuilder(	schema : ISpodSchema, 
														expressions : Vector.<ISpodExpression>
														)
		{
			if(null == schema) throw new ArgumentError('Schema can not be null');
			if(null == expressions) throw new ArgumentError('Expressions can not be null');
			if(expressions.length == 0) throw new ArgumentError('Expressions can not be empty');
			
			if(	!(schema.schemaType == SpodSchemaType.TABLE || 
				schema.schemaType == SpodSchemaType.TRIGGER)
				) 
			{
				throw new ArgumentError('Schema should be a table or trigger schema');
			}
			
			_schema = schema;
			_expressions = expressions;
			_limitedExpression = _expressions[0] is LimitExpression;
			
			if(!_limitedExpression) throw new ArgumentError('Invalid limit found');
			
			_buffer = new Vector.<String>();
		}

		public function build() : SpodStatement
		{
			var schemaType : Class;
			var schemaName : String;
			var schemaColumns : Vector.<ISpodColumnSchema>;
			if(_schema is SpodTableSchema)
			{
				const tableSchema : SpodTableSchema = SpodTableSchema(_schema);
				schemaType = tableSchema.type;
				schemaName = tableSchema.name;
				schemaColumns = tableSchema.columns;
			}
			else if(_schema is SpodTriggerSchema)
			{
				const triggerSchema : SpodTriggerSchema = SpodTriggerSchema(_schema);
				schemaType = triggerSchema.type;
				schemaName = getTableNameFromTriggerName(triggerSchema.name);
				schemaColumns = triggerSchema.columns;
			}
			else throw new ArgumentError(getQualifiedClassName(_schema) + ' is not supported');
			
			const total : int = schemaColumns.length;
			
			if(total == 0) throw new IllegalOperationError('Invalid columns length');
			
			_buffer.length = 0;
			
			_buffer.push('DELETE FROM ');
			_buffer.push('`' + schemaName + '` ');
			
			const statement : SpodStatement = new SpodStatement(schemaType);
			
			const limitExpression : LimitExpression = _expressions.shift();
			const amount : int = limitExpression.amount;
			
			_buffer.push('WHERE ');
			_buffer.push('`' + _schema.identifier + '` ');
			_buffer.push('IN ');
			
			// BEGIN INNER SELECT
			_buffer.push('(');
			_buffer.push('SELECT ');
			_buffer.push('`' + _schema.identifier + '` ');
			_buffer.push('FROM ');
			_buffer.push('`' + schemaName + '` ');
			
			const orderBuffer : Array = [];
			
			const numExpressions : int = _expressions.length;				
			for(var i : int = 0; i<numExpressions; i++)
			{
				const expression : ISpodExpression = _expressions[i];
				if(expression.type == SpodExpressionType.ORDER)
				{
					if(orderBuffer.length > 0) orderBuffer.push(' AND ');
					orderBuffer.push(expression.build(_schema, statement));
				}
				else throw new IllegalOperationError('Unknown expression type');
			}
			
			if(orderBuffer.length > 0)
			{
				_buffer.push('ORDER BY ');
				_buffer.push.apply(null, orderBuffer);
			}
			
			_buffer.push(' LIMIT ' + DEFAULT_LIMIT_NUMBER + ' ');
			_buffer.push('OFFSET ' + amount);
			_buffer.push(')');
			// END INNER SELECT
			
			// Make the query
			statement.query = _buffer.join('');
			
			return statement;
		}
	}
}
