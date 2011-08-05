package org.osflash.spod.builders.expressions.limit
{
	import org.osflash.spod.errors.SpodError;
	import org.osflash.spod.builders.expressions.SpodExpressionOperatorType;
	import org.osflash.spod.SpodStatement;
	import org.osflash.spod.builders.expressions.ISpodExpression;
	import org.osflash.spod.builders.expressions.SpodExpressionType;
	import org.osflash.spod.schema.ISpodSchema;
	/**
	 * @author Simon Richardson - me@simonrichardson.info
	 */
	public class LimitExpression implements ISpodExpression
	{

		/**
		 * @private
		 */
		private var _amount : int;

		public function LimitExpression(amount : int)
		{
			if(isNaN(amount)) throw new ArgumentError('Amount can not be null');
			if(amount < 0) throw new ArgumentError('Amount can not be less than 0');
			
			_amount = amount;
		}

		/**
		 * @inheritDoc
		 */
		public function build(schema : ISpodSchema, statement : SpodStatement) : String 
		{ 
			if(null == schema) throw new ArgumentError('Schema can not be null');
			if(null == statement) throw new ArgumentError('Statement can not be null');
			
			return '' + _amount;
		}

		/**
		 * @inheritDoc
		 */
		public function get type() : int { return SpodExpressionType.LIMIT; }
		
		/**
		 * Get the amount to limit the expression by
		 * @return int
		 */
		public function get amount() : int { return _amount; }
		
		/**
		 * @inheritDoc
		 */
		public function get operator() : SpodExpressionOperatorType 
		{ 
			throw new SpodError('Missing implementation');
		}
	}
}
