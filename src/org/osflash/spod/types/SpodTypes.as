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
				case SpodTypeInt: return SpodTypeInt.SQL_NAME;
				case SpodTypeString: return SpodTypeString.SQL_NAME;
				case SpodTypeDate: return SpodTypeDate.SQL_NAME;
				case SpodTypeBoolean: return SpodTypeBoolean.SQL_NAME;
				case SpodTypeObject: return SpodTypeObject.SQL_NAME;
				default:
					throw new ArgumentError('Unknown type : ' + type);
			}
		}
	}
}
