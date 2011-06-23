package org.osflash.spod
{
	import org.osflash.spod.utils.describeTable;
	import org.osflash.logger.utils.debug;
	import org.osflash.logger.utils.error;
	import org.osflash.spod.errors.SpodErrorEvent;
	import org.osflash.spod.support.user.User;

	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.filesystem.File;
	[SWF(backgroundColor="#FFFFFF", frameRate="31", width="1280", height="720")]
	public class SelectAllObjectTest extends Sprite
	{
		
		private static const sessionName : String = "session.db"; 
		
		protected var resource : File;
		
		public function SelectAllObjectTest()
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
			// flood the database with rows
			const total : int = 20;
			for(var i : int = 0; i < total; i++)
			{
				const user : User = new User("User - " + i);
				if(i == total - 1) user.insertSignal.add(handleInsertSignal);
				table.insert(user);
			}
		}
		
		protected function handleInsertSignal(object : SpodObject) : void
		{
			object.tableRow.table.selectAllSignal.add(handleSelectSignal);
			object.tableRow.table.selectAll();
		}
		
		protected function handleSelectSignal(objects : Vector.<SpodObject>) : void
		{
			if(objects.length == 0) debug('Nothing found');
			else
			{
				debug(describeTable(objects[0].tableRow.table).toXMLString());
			}
		}
			
		protected function handleErrorSignal(event : SpodErrorEvent) : void
		{
			error(event.event.error);
		}
	}
}
