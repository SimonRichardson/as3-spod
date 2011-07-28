package org.osflash.spod.factories
{
	import org.osflash.spod.SpodManager;
	import org.osflash.spod.SpodDatabase;
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public class SpodDatabaseFactory implements ISpodDatabaseFactory
	{
		
		public function create(name : String, manager : SpodManager) : SpodDatabase
		{
			return new SpodDatabase(name, manager);
		}
	}
}
