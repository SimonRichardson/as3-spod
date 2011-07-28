package org.osflash.spod.factories
{
	import org.osflash.spod.SpodDatabase;
	import org.osflash.spod.SpodManager;
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public interface ISpodDatabaseFactory
	{
		
		function create(name : String, manager : SpodManager) : SpodDatabase;
	}
}
