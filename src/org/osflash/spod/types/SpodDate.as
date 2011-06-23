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
		
		public static function write(value : Date) : String 
		{
			var buffer : String = '';

			buffer += value.fullYear + '-' + pad(value.month) + '-' + pad(value.date);
			buffer += pad(value.hours) + ':' + pad(value.minutes) + ':' + pad(value.seconds);
			
			return buffer; 
		}
		
		public static function read(value : String) : Date
		{
			const date : Date = new Date();
			date.setTime(Date.parse(value));
			return date;
		}
		
		/**
		 * @private
		 */
		private static function pad(value : int) : String
		{
			return value < 10 ? '0' + value : '' + value;
		}

		/**
		 * @inheritDoc
		 */		
		public function get type() : String { return SQL_NAME; }
	}
}
