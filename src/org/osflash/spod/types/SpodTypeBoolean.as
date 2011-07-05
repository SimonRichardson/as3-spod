package org.osflash.spod.types
{
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public class SpodTypeBoolean implements ISpodType
	{
		
		public static const SQL_NAME : String = 'BOOLEAN';
		
		public function SpodTypeBoolean()
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
