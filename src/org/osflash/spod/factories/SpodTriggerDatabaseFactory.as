package org.osflash.spod.factories
{
	import org.osflash.spod.SpodTriggerDatabase;
	import org.osflash.spod.SpodManager;
	import org.osflash.spod.SpodDatabase;
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public class SpodTriggerDatabaseFactory implements ISpodDatabaseFactory
	{

		public function create(name : String, manager : SpodManager) : SpodDatabase
		{
			return new SpodTriggerDatabase(name, manager);
		}
	}
}
