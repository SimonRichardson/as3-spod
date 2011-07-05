package org.osflash.spod.types
{
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public class SpodTypes
	{
		
		public static const INT : int = 0;
		
		public static const UINT : int = 1;
		
		public static const NUMBER : int = 2;
		
		public static const STRING : int = 3;
		
		public static const DATE : int = 4;
		
		public static const BOOLEAN : int = 5;
		
		public static const OBJECT : int = 6;
		
		public static function valid(type : int) : Boolean
		{
			return 	type == INT || 
					type == UINT ||
					type == NUMBER ||
					type == STRING || 
					type == DATE || 
					type == BOOLEAN || 
					type == OBJECT;
		}
		
		public static function getSQLName(type : int) : String
		{
			switch(type)
			{
				case INT: return SpodTypeInt.SQL_NAME;
				case UINT: return SpodTypeUInt.SQL_NAME;
				case NUMBER: return SpodTypeNumber.SQL_NAME;
				case STRING: return SpodTypeString.SQL_NAME;
				case DATE: return SpodTypeDate.SQL_NAME;
				case BOOLEAN: return SpodTypeBoolean.SQL_NAME;
				case OBJECT: return SpodTypeObject.SQL_NAME;
				default:
					throw new ArgumentError('Unknown type : ' + type);
			}
		}
	}
}
