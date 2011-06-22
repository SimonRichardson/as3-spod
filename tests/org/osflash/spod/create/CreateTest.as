package org.osflash.spod.create
{
	import asunit.framework.IAsync;

	import org.osflash.logger.utils.error;
	import org.osflash.spod.SpodDatabase;
	import org.osflash.spod.SpodManager;
	import org.osflash.spod.support.user.User;

	import flash.events.SQLErrorEvent;
	import flash.filesystem.File;
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public class CreateTest
	{
		
		private static const sessionName : String = "session" + (Math.random() * 9999) + ".db"; 
		
		[Inject]
		public var async : IAsync;
		
		protected var resource : File;
		
		[Before]
		public function setUp() : void
		{
			const storage : File = File.applicationStorageDirectory.resolvePath(sessionName);
			resource = storage;			
		}
		
		[After]
		public function tearDown() : void
		{
			resource = null;	
		}
		
		[Test]
		public function make_spod_and_create_db() : void
		{
			const manager : SpodManager = new SpodManager();
			manager.openSignal.add(async.add(handleOpenSignal, 1000));
			manager.errorSignal.add(handleErrorSignal);
			manager.open(resource);
		}
		
		[Test]
		public function make_spod_and_create_again_db() : void
		{
			const manager : SpodManager = new SpodManager();
			manager.openSignal.add(async.add(handleOpenSignal, 1000));
			manager.errorSignal.add(handleErrorSignal);
			manager.open(resource);
		}
		
		private function handleOpenSignal(database : SpodDatabase) : void
		{
			database.createTable(User);
		}
		
		private function handleErrorSignal(event : SQLErrorEvent) : void
		{
			error(event);
		}
	}
}
