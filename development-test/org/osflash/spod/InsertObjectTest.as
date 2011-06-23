package org.osflash.spod
{
	import org.osflash.logger.utils.debug;
	import org.osflash.logger.utils.error;
	import org.osflash.spod.errors.SpodErrorEvent;
	import org.osflash.spod.support.user.User;

	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.filesystem.File;
	
	[SWF(backgroundColor="#FFFFFF", frameRate="31", width="1280", height="720")]
	public class InsertObjectTest extends Sprite
	{
		
		private static const sessionName : String = "session.db"; 
		
		protected var resource : File;
		
		public function InsertObjectTest()
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
						
			const storage : File = File.applicationStorageDirectory.resolvePath(sessionName);
			resource = storage;
			
			const manager : SpodManager = new SpodManager();
			manager.openSignal.add(handleOpenSignal);
			manager.errorSignal.add(handleErrorSignal);
			manager.open(resource, true);
		}
		
		protected function handleOpenSignal(database : SpodDatabase) : void
		{
			database.createTableSignal.add(handleCreatedSignal);
			database.createTable(User);
		}
		
		protected function handleCreatedSignal(table : SpodTable) : void
		{
			table.insertSignal.add(handleInsertSignal);
			table.insert(new User("Fred" + Math.random()));
		}
		
		protected function handleInsertSignal(object : SpodObject) : void
		{
			const user : User = object as User;
			debug(user.id);
		}
			
		protected function handleErrorSignal(event : SpodErrorEvent) : void
		{
			error(event.event.error);
		}
	}
}
