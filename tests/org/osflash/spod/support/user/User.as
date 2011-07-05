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
		
		public var object : Object;
		
		private var _date : Date;

		public function User(name : String = null, date : Date = null)
		{
			this.name = name;
			
			_date = date || new Date();
			
			object = {name: 'Name', age: 23};
		}

		public function get date() : Date { return _date; }
		public function set date(value : Date) : void { _date = value; }
	}
}
