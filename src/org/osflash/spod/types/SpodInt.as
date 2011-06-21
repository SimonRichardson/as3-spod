package org.osflash.spod.types
{
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public class SpodInt implements ISpodType
	{

		public static const SQL_NAME : String = 'INTEGER';
		
		private var _value : int;
		
		public function SpodInt()
		{
			
		}
		
		public function get type() : String { return SQL_NAME; }
		
		public function get value() : String { return _value.toString(); }
	}
}
