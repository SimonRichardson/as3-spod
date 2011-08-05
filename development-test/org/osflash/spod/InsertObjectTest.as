package org.osflash.spod
{
	import org.osflash.logger.logs.debug;
	import org.osflash.logger.logs.error;
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
			table.insert(new User("Fred" + Math.random(), new Date(1981, 11, 17, 12, 12, 12, 12)));
		}
		
		protected function handleInsertSignal(object : SpodObject) : void
		{
			const user : User = object as User;
			debug(user.id);
			
			user.tableRow.table.selectSignal.add(handleSelectSignal);
			user.tableRow.table.select(4);
		}
		
		protected function handleSelectSignal(object : SpodObject) : void
		{
			const user : User = object as User;
			debug(user.id, user.date, user.name);
		}
		
		protected function handleErrorSignal(event : SpodErrorEvent) : void
		{
			error(event, event.error, event.event);
			error(event.event.error.getStackTrace());
		}
	}
}
