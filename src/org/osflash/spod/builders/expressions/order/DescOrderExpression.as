package org.osflash.spod.builders.expressions.order
{
	import flash.errors.IllegalOperationError;
	import org.osflash.spod.SpodStatement;
	import org.osflash.spod.builders.expressions.ISpodExpression;
	import org.osflash.spod.builders.expressions.SpodExpressionType;
	import org.osflash.spod.schema.SpodTableSchema;

	/**
	 * @author Simon Richardson - me@simonrichardson.info
	 */
	public class DescOrderExpression implements ISpodExpression
	{

		/**
		 * @private
		 */
		private var _key : String;

		public function DescOrderExpression(key : String)
		{
			if(null == key) throw new ArgumentError('Key can not be null');
			if(key.length < 1) throw new ArgumentError('Key can not be empty');
			
			_key = key;
		}
		
		/**
		 * @inheritDoc
		 */
		public function build(schema : SpodTableSchema, statement : SpodStatement) : String 
		{ 
			if(null == schema) throw new ArgumentError('Schema can not be null');
			if(null == statement) throw new ArgumentError('Statement can not be null');
			
			if(schema.contains(_key))
			{
				return '`' + _key + '` DESC';
				
			} else throw new IllegalOperationError('Invalid key');
		}
		

		/**
		 * @inheritDoc
		 */
		public function get type() : int { return SpodExpressionType.ORDER; }
	}
}
