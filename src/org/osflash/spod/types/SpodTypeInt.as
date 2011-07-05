package org.osflash.spod.types
{
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public class SpodTypeInt implements ISpodType
	{

		public static const SQL_NAME : String = 'INTEGER';
		
		public function SpodTypeInt()
		{
		}
		
		/**
		 * @inheritDoc
		 */
		public function get type() : String { return SQL_NAME; }
		
		/**
		 * @inheritDoc
		 */
		public function get typeClass() : Class { return int; }
	}
}
