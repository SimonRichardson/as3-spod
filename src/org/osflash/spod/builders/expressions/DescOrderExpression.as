package org.osflash.spod.builders.expressions
{
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
		public function build() : String { return '`' + _key + '` DESC'; }

		/**
		 * @inheritDoc
		 */
		public function get type() : int { return SpodExpressionType.ORDER; }
	}
}
