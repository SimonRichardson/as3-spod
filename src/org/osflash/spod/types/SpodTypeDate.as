package org.osflash.spod.types
{
	/**
	 * @author Simon Richardson - me@simonrichardson.info
	 */
	public class SpodTypeDate implements ISpodType
	{
		
		public static const SQL_NAME : String = 'DATETIME';
		
		public function SpodTypeDate()
		{
		}

		/**
		 * @inheritDoc
		 */		
		public function get type() : String { return SQL_NAME; }
		
		/**
		 * @inheritDoc
		 */
		public function get typeClass() : Class { return Date; }
	}
}
