package org.osflash.spod.types
{
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public class SpodString implements ISpodType
	{
		
		public static const SQL_NAME : String = 'TEXT';
		
		/**
		 * @private
		 */
		private var _value : String;
		
		public function SpodString(value : String)
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
		public function get value() : String { return _value; }
	}
}
