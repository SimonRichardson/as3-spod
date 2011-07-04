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
		
		public static function formatToSQLiteDateTime1(value : Date) : String
		{
			var result : String = '';
			
			result += value.fullYearUTC + '-' 
					+ pad(value.monthUTC + 1) + '-' 
					+ pad(value.dateUTC);
			result += ' ';
			result += pad(value.hoursUTC) + ':' 
					+ pad(value.minutesUTC) + ':' 
					+ pad(value.secondsUTC);
			
			return result; 
		}
				
		private static function pad(value : int) : String
		{
			return value < 10 ? '0' + value : '' + value;
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
