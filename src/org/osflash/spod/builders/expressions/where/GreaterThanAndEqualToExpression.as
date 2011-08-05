package org.osflash.spod.builders.expressions.where
{
	import org.osflash.spod.SpodStatement;
	import org.osflash.spod.builders.expressions.ISpodExpression;
	import org.osflash.spod.builders.expressions.SpodExpressionOperatorType;
	import org.osflash.spod.builders.expressions.SpodExpressionType;
	import org.osflash.spod.schema.ISpodSchema;

	import flash.errors.IllegalOperationError;
	/**
	 * @author Simon Richardson - me@simonrichardson.info
	 */
	public class GreaterThanAndEqualToExpression implements ISpodExpression
	{
		
		/**
		 * @private
		 */
		private var _key : String;
		
		/**
		 * @private
		 */
		private var _value : *; 
		
		/**
		 * @private
		 */
		private var _operator : SpodExpressionOperatorType;

		/**
		 * @private
		 */
		private var _strict : Boolean;
		
		public function GreaterThanAndEqualToExpression(	key : String, 
															value : *,
															operator : SpodExpressionOperatorType = 
																	null,
															strict : Boolean = true
															)
		{
			if(null == key) throw new ArgumentError('Key can not be null');
			if(key.length < 1) throw new ArgumentError('Key can not be empty');
			
			_key = key;
			_value = value;
			_operator = operator || SpodExpressionOperatorType.AND;
			_strict = strict;
		}
		
		/**
		 * @inheritDoc
		 */
		public function build(schema : ISpodSchema, statement : SpodStatement) : String 
		{ 
			if(null == schema) throw new ArgumentError('Schema can not be null');
			if(null == statement) throw new ArgumentError('Statement can not be null');
			
			if(!_strict)
			{
				statement.parameters[':' + _key] = _value;
				return '`' + _key + '` >= :' + _key + ''; 
			}
			else
			{
				if(schema.match(_key, _value))
				{
					statement.parameters[':' + _key] = _value;
					return '`' + _key + '` >= :' + _key + ''; 
				} else throw new IllegalOperationError('Invalid key');
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function get type() : int { return SpodExpressionType.WHERE; }
		
		/**
		 * @inheritDoc
		 */
		public function get operator() : SpodExpressionOperatorType { return _operator; }
	}
}
