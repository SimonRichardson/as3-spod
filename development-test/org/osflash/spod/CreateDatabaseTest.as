package org.osflash.spod
{
	import org.osflash.logger.utils.debug;
	import org.osflash.spod.errors.SpodErrorEvent;
	import org.osflash.spod.support.user.User;

	import flash.display.Sprite;
	import flash.filesystem.File;
	
	[SWF(backgroundColor="#FFFFFF", frameRate="31", width="1280", height="720")]
	public class CreateDatabaseTest extends Sprite
	{
		
		private static const sessionName : String = "session.db"; 
		
		protected var resource : File;

		public function CreateDatabaseTest()
		{
			trace("******* START");
			
			const storage : File = File.applicationStorageDirectory.resolvePath(sessionName);
			resource = storage;
			
			const manager : SpodManager = new SpodManager();
			manager.openSignal.add(handleOpenSignal);
			manager.errorSignal.add(handleErrorSignal);
			manager.open(resource, true);
			
			trace("******* HELLO");
		}
		
		private function handleOpenSignal(database : SpodDatabase) : void
		{
			database.createdSignal.add(handleCreatedSignal);
			database.create(User);
		}
		
		private function handleCreatedSignal(table : SpodTable) : void
		{
			
		}
		
		private function handleErrorSignal(event : SpodErrorEvent) : void
		{
			trace("******* FAILED " + event);
		}

	}
}
