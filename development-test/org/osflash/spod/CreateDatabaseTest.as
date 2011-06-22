package org.osflash.spod
{
	import org.osflash.spod.support.user.User;

	import flash.display.Sprite;
	import flash.events.SQLErrorEvent;
	import flash.filesystem.File;
	[SWF(backgroundColor="#FFFFFF", frameRate="31", width="1280", height="720")]
	public class CreateDatabaseTest extends Sprite
	{
		
		private static const sessionName : String = "session" + (Math.random() * 9999) + ".db"; 
		
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
			database.create(User);
		}
		
		private function handleErrorSignal(event : SQLErrorEvent) : void
		{
			trace("******* FAILED " + event);
		}

	}
}
