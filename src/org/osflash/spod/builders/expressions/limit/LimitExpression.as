package org.osflash.spod.builders.expressions.limit
{
	import org.osflash.spod.SpodStatement;
	import org.osflash.spod.builders.expressions.ISpodExpression;
	import org.osflash.spod.builders.expressions.SpodExpressionType;
	import org.osflash.spod.schema.SpodTableSchema;
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
			
			_amount = amount;
		}

		/**
		 * @inheritDoc
		 */
		public function build(schema : SpodTableSchema, statement : SpodStatement) : String 
		{ 
			if(null == schema) throw new ArgumentError('Schema can not be null');
			if(null == statement) throw new ArgumentError('Statement can not be null');
			
			return '' + _amount;
		}

		/**
		 * @inheritDoc
		 */
		public function get type() : int { return SpodExpressionType.LIMIT; }
	}
}
