package org.osflash.spod.builders.expressions
{
	/**
	 * @author Simon Richardson - me@simonrichardson.info
	 */
	public class LessThanExpression implements ISpodExpression
	{
		
		/**
		 * @private
		 */
		private var _key : String;
		
		/**
		 * @private
		 */
		private var _value : *; 

		public function LessThanExpression(key : String, value : *)
		{
			if(null == key) throw new ArgumentError('Key can not be null');
			if(key.length < 1) throw new ArgumentError('Key can not be empty');
			
			_key = key;
			_value = value;
		}
		
		/**
		 * @inheritDoc
		 */
		public function build() : String 
		{ 
			var value : String;
			if(_value is int || _value is uint || _value is Number) value = '' + _value + '';
			else value = '\'' + _value + '\''; 
			
			return '`' + _key + '` < ' + value; 
		}
		
		/**
		 * @inheritDoc
		 */
		public function get type() : int { return SpodExpressionType.WHERE; }
	}
}
