package org.osflash.spod.types
{
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public class SpodString implements ISpodType
	{
		
		public static const SQL_NAME : String = 'TEXT';
		
		public function SpodString()
		{
		}
		
		/**
		 * @inheritDoc
		 */
		public function get type() : String { return SQL_NAME; }
	}
}
