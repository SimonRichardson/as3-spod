package org.osflash.spod.builders.trigger
{
	import org.osflash.spod.builders.expressions.limit.LimitExpression;
	import org.osflash.spod.SpodStatement;
	import org.osflash.spod.builders.ISpodStatementBuilder;
	import org.osflash.spod.builders.expressions.ISpodExpression;
	import org.osflash.spod.builders.statements.trigger.ISpodTriggerActionBuilder;
	import org.osflash.spod.builders.statements.trigger.ISpodTriggerWhenBuilder;
	import org.osflash.spod.builders.statements.trigger.ISpodTriggerWithBuilder;
	import org.osflash.spod.builders.table.DeleteWhereStatementBuilder;
	import org.osflash.spod.builders.table.SelectWhereStatementBuilder;
	import org.osflash.spod.errors.SpodError;
	import org.osflash.spod.schema.ISpodColumnSchema;
	import org.osflash.spod.schema.ISpodSchema;
	import org.osflash.spod.schema.SpodTriggerSchema;
	import org.osflash.spod.schema.types.SpodSchemaType;
	import org.osflash.spod.schema.types.SpodTriggerActionType;
	import org.osflash.spod.schema.types.SpodTriggerWhenType;
	import org.osflash.spod.schema.types.SpodTriggerWithType;
	import org.osflash.spod.spod_namespace;
	import org.osflash.spod.utils.getTableNameFromTriggerName;

	import flash.utils.getQualifiedClassName;
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public class CreateTriggerStatementBuilder implements ISpodStatementBuilder
	{
		
		use namespace spod_namespace;
		
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
		private var _triggerBuilder : ISpodTriggerWhenBuilder;
		
		/**
		 * @private
		 */
		private var _ignoreIfExists : Boolean;
		
		public function CreateTriggerStatementBuilder(	schema : ISpodSchema, 
														triggerBuilder : ISpodTriggerWhenBuilder
														)
		{
			if(null == schema) throw new ArgumentError('Schema can not be null');
			if(null == triggerBuilder) throw new ArgumentError('TriggerBuilder can not be null');
			if(schema.schemaType != SpodSchemaType.TRIGGER) throw new ArgumentError('Schema ' + 
																		'should be a index schema');
			_schema = schema;
			
			_buffer = new Vector.<String>();
			
			_triggerBuilder = triggerBuilder;
			_ignoreIfExists = _triggerBuilder.ignoreIfExists;
		}
		
		/**
		 * @inheritDoc
		 */
		public function build() : SpodStatement
		{
			if(_schema is SpodTriggerSchema)
			{
				const triggerSchema : SpodTriggerSchema = SpodTriggerSchema(_schema);
				const columns : Vector.<ISpodColumnSchema> = triggerSchema.columns;
				const total : int = columns.length;
				
				if(total == 0) throw new SpodError('Invalid columns length');
				
				_buffer.length = 0;
				
				_buffer.push('CREATE TRIGGER ');
				
				if(_ignoreIfExists) _buffer.push('IF NOT EXISTS ');
				
				const whenType : SpodTriggerWhenType = _triggerBuilder.whenType;
				
				_buffer.push(triggerSchema.name);
				_buffer.push(' ');
				_buffer.push(whenType.name);
				_buffer.push(' ');
				
				const actionBuilder : ISpodTriggerActionBuilder = _triggerBuilder.actionBuilder;
				const actionType : SpodTriggerActionType = actionBuilder.actionType;
				
				const tableName : String = getTableNameFromTriggerName(triggerSchema.name);
				
				_buffer.push(actionType.name);
				_buffer.push(' ON ');
				_buffer.push(tableName);
				_buffer.push(' BEGIN ');
				
				const statement : SpodStatement = new SpodStatement(triggerSchema.type);
				
				// implement the update, insert, delete statements
				const withBuilder : ISpodTriggerWithBuilder = actionBuilder.withBuilder;
				const withType : SpodTriggerWithType = withBuilder.withType;
				
				const expressions : Vector.<ISpodExpression> = withBuilder.withExpressions;
				
				var whereBuilder : ISpodStatementBuilder;
				var whereStatement : SpodStatement;
				switch(withType)
				{
					case SpodTriggerWithType.SELECT:
						whereBuilder = new SelectWhereStatementBuilder(triggerSchema, expressions);
						whereStatement = whereBuilder.build();
						break;
					case SpodTriggerWithType.DELETE:
						whereBuilder = new DeleteWhereStatementBuilder(triggerSchema, expressions);
						whereStatement = whereBuilder.build();
						break;
					case SpodTriggerWithType.LIMIT:
						expressions.unshift(new LimitExpression(withBuilder.withLimitTotal));
						
						whereBuilder = new LimitDeleteStatementBuilder(triggerSchema, expressions);
						whereStatement = whereBuilder.build();
						break;
					default:
						throw new SpodError('Unknown with type ' + withType);
				}
				
				var whereQuery : String = whereStatement.query;
				for(var key : String in whereStatement.parameters)
				{
					const pattern : RegExp = new RegExp(key, 'g');
					if(whereQuery.match(pattern))
					{
						var replacement : String;
						if(whereStatement.parameters[key] is Date)
						{
							const date  : Date = whereStatement.parameters[key];
							replacement = "strftime('%J', '" + toSqlDate(date) + "')";
						}
						else replacement = "'" + whereStatement.parameters[key] + "'";
						
						whereQuery = whereQuery.replace(pattern, replacement);
					}
				}
				
				_buffer.push(whereQuery);				
				_buffer.push(';');
				_buffer.push(' END ');
				
				statement.query = _buffer.join('');
				
				return statement;
				
			} else throw new ArgumentError(getQualifiedClassName(_schema) + ' is not supported');
		}
		
		/**
		 * @private
		 */
		private function lpad(original : Object, length : int, pad : String) : String
		{
			var padded : String = null == original ? "" : String(original);
			while (padded.length < length) 
				padded = pad + padded;
			return padded;
		}
		
		/**
		 * @private
		 */
		private function toSqlDate(dateVal : Date) : String
		{
			return dateVal == null ? null : dateVal.fullYear
									+ "-" + lpad(dateVal.month + 1, 2, '0')
									+ "-" + lpad(dateVal.date, 2, '0')
									+ " " + lpad(dateVal.hours, 2, '0')
									+ ":" + lpad(dateVal.minutes, 2, '0')
									+ ":" + lpad(dateVal.seconds, 2, '0');
		}
	}
}
