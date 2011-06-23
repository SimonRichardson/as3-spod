package org.osflash.spod.types
{
	/**
	 * @author Simon Richardson - me@simonrichardson.info
	 */
	public class SpodDate implements ISpodType
	{
		
		public static const SQL_NAME : String = 'DATETIME';
		
		/**
		 * @private
		 */
		private var _value : Date;
		
		public function SpodDate(value : Date)
		{
			_value = value;
		}
		
		/**
		 * @private
		 */
		private function pad(value : int) : String
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
		public function get value() : String 
		{
			var buffer : String = '';

			buffer += _value.fullYear + '-' + pad(_value.month) + '-' + pad(_value.date);
			buffer += pad(_value.hours) + ':' + pad(_value.minutes) + ':' + pad(_value.seconds);
			
			return buffer; 
		}
	}
}
