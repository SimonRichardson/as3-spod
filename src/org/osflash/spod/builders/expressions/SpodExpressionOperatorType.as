package org.osflash.spod.builders.expressions
{
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public final class SpodExpressionOperatorType
	{
		
		public static const AND : SpodExpressionOperatorType = 
															new SpodExpressionOperatorType('and');
		
		public static const OR : SpodExpressionOperatorType = 
															new SpodExpressionOperatorType('or');
		
		public static const LIKE : SpodExpressionOperatorType = 
															new SpodExpressionOperatorType('like');
		
		/**
		 * @inheritDoc
		 */
		private var _type : String;

		public function SpodExpressionOperatorType(type : String)
		{
			if(null == type) throw new ArgumentError('Type can not be null');
			
			_type = type;
		}
		
		public function get type() : String { return _type; }
		
		public function get name() : String { return type.toUpperCase(); }
	}
}
