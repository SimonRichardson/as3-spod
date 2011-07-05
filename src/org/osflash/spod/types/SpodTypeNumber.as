package org.osflash.spod.types
{
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public class SpodTypeNumber implements ISpodType
	{

		public static const SQL_NAME : String = 'REAL';
		
		public function SpodTypeNumber()
		{
		}
		
		/**
		 * @inheritDoc
		 */
		public function get type() : String { return SQL_NAME; }
		
		/**
		 * @inheritDoc
		 */
		public function get typeClass() : Class { return Number; }
	}
}
