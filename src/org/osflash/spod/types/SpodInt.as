package org.osflash.spod.types
{
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public class SpodInt implements ISpodType
	{

		public static const SQL_NAME : String = 'INTEGER';
		
		/**
		 * @private
		 */
		private var _value : int;
		
		public function SpodInt(value : int)
		{
			_value = value;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get type() : String { return SQL_NAME; }
		
		/**
		 * @inheritDoc
		 */
		public function get value() : String { return _value.toString(); }
	}
}
