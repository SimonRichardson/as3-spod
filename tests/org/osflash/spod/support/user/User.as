package org.osflash.spod.support.user
{
	import org.osflash.spod.SpodObject;
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public class User extends SpodObject
	{
		
		public var id : int;
		
		public var name : String;
		
		private var _date : Date;

		public function User(name : String = null, date : Date = null)
		{
			this.name = name;
			
			_date = date || new Date();
		}

		public function get date() : Date { return _date; }
		public function set date(value : Date) : void { _date = value; }
	}
}
