package org.osflash.spod.types
{
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public class SpodTypes
	{
		
		public static function getSQLName(type : Class) : String
		{
			switch(type)
			{
				case SpodInt: return SpodInt.SQL_NAME;
				case SpodString: return SpodString.SQL_NAME;
				case SpodDate: return SpodDate.SQL_NAME;
				default:
					throw new ArgumentError('Unknown type : ' + type);
			}
		}
	}
}
