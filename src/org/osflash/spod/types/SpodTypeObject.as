package org.osflash.spod.types
{
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public class SpodTypeObject implements ISpodType
	{
		
		public static const SQL_NAME : String = 'OBJECT';
		
		public function SpodTypeObject()
		{
		}
		
		/**
		 * @inheritDoc
		 */
		public function get type() : String { return SQL_NAME; }
		
		/**
		 * @inheritDoc
		 */
		public function get typeClass() : Class { return Object; }
	}
}
