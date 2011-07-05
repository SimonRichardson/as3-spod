package org.osflash.spod.types
{
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public class SpodTypeString implements ISpodType
	{
		
		public static const SQL_NAME : String = 'TEXT';
		
		public function SpodTypeString()
		{
		}
		
		/**
		 * @inheritDoc
		 */
		public function get type() : String { return SQL_NAME; }
		
		/**
		 * @inheritDoc
		 */
		public function get typeClass() : Class { return String; }
	}
}
