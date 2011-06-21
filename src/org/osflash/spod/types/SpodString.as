package org.osflash.spod.types
{
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public class SpodString implements ISpodType
	{
		
		public static const SQL_NAME : String = 'CHAR(255)';
		
		private var _value : String;
		
		public function SpodString()
		{
		}
		
		public function get type() : String { return SQL_NAME; }

		public function get value() : String { return _value; }
	}
}
