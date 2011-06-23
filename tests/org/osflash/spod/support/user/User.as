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
		
		public var date : Date;

		public function User(name : String = null)
		{
			this.name = name;
			this.date = new Date();
		}	
	}
}
