package org.osflash.spod.builders.expressions.order
{
	import org.osflash.spod.SpodStatement;
	import org.osflash.spod.builders.expressions.ISpodExpression;
	import org.osflash.spod.builders.expressions.SpodExpressionOperatorType;
	import org.osflash.spod.builders.expressions.SpodExpressionType;
	import org.osflash.spod.errors.SpodError;
	import org.osflash.spod.schema.ISpodSchema;

	import flash.errors.IllegalOperationError;

	/**
	 * @author Simon Richardson - me@simonrichardson.info
	 */
	public class AscOrderExpression implements ISpodExpression
	{

		/**
		 * @private
		 */
		private var _key : String;
		
		/**
		 * @private
		 */
		private var _strict : Boolean;

		public function AscOrderExpression(key : String, strict : Boolean = true)
		{
			if(null == key) throw new ArgumentError('Key can not be null');
			if(key.length < 1) throw new ArgumentError('Key can not be empty');
			
			_key = key;
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
				return '`' + _key + '` ASC';
			}
			else
			{
				if(schema.contains(_key))
				{
					return '`' + _key + '` ASC';
					
				} else throw new IllegalOperationError('Invalid key');
			}
		}

		/**
		 * @inheritDoc
		 */
		public function get type() : int { return SpodExpressionType.ORDER; }
		
		/**
		 * @inheritDoc
		 */
		public function get operator() : SpodExpressionOperatorType 
		{ 
			throw new SpodError('Missing implementation');
		}
	}
}
