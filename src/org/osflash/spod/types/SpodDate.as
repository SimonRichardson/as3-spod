package org.osflash.spod.types
{
	/**
	 * @author Simon Richardson - me@simonrichardson.info
	 */
	public class SpodDate implements ISpodType
	{
		
		public static const SQL_NAME : String = 'DATETIME';
		
		public function SpodDate()
		{
		}

		/**
		 * @inheritDoc
		 */		
		public function get type() : String { return SQL_NAME; }
	}
}
