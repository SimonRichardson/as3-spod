package org.osflash.spod
{
	import org.osflash.logger.utils.debug;
	import org.osflash.logger.utils.error;
	import org.osflash.spod.errors.SpodErrorEvent;
	import org.osflash.spod.support.user.User;
	import org.osflash.spod.utils.getClassNameFromQname;

	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.filesystem.File;
	import flash.utils.getQualifiedClassName;
	
	[SWF(backgroundColor="#FFFFFF", frameRate="31", width="1280", height="720")]
	public class CountObjectTest extends Sprite
	{
		
		private static const sessionName : String = "session.db"; 
		
		protected var resource : File;
		
		public function CountObjectTest()
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
			table.begin();
			
			const total : int = 3;
			for(var i : int = 0; i < total; i++)
			{
				const user : User = new User("User - " + i);
				if(i == total - 1) user.insertSignal.add(handleInsertSignal);
				table.insert(user);
			}
			
			table.commit();
		}
		
		protected function handleInsertSignal(object : SpodObject) : void
		{
			object.tableRow.table.countSignal.add(handleCountSignal);
			object.tableRow.table.count();
		}
		
		protected function handleCountSignal(table : SpodTable, total : int) : void
		{
			const name : String = getClassNameFromQname(getQualifiedClassName(table.schema.type));
			debug(total + " " + name + "s in table " + name);
		}
			
		protected function handleErrorSignal(event : SpodErrorEvent) : void
		{
			error(event.event.error);
		}
	}
}
