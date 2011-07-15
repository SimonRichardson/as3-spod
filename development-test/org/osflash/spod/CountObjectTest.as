package org.osflash.spod
{
	import org.osflash.logger.logs.debug;
	import org.osflash.logger.logs.error;
	import org.osflash.spod.errors.SpodErrorEvent;
	import org.osflash.spod.support.user.User;
	import org.osflash.spod.utils.getClassNameFromQname;

	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.filesystem.File;
	import flash.utils.getQualifiedClassName;
	import flash.utils.getTimer;
	
	[SWF(backgroundColor="#FFFFFF", frameRate="31", width="1280", height="720")]
	public class CountObjectTest extends Sprite
	{
		
		private static const sessionName : String = "session.db"; 
		
		protected var resource : File;
		
		private var _timer : int;
		
		public function CountObjectTest()
		{
			debug(getQualifiedClassName(this));
			
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
			debug("Begin");
			
			_timer = getTimer();
			
			// flood the database with rows
			table.begin();
			
			const total : int = 1000;
			for(var i : int = 0; i < total; i++)
			{
				const user : User = new User("User - " + i);
				if(i == total - 1) user.insertSignal.add(handleInsertSignal);
				table.insert(user);
			}
			
			debug("Commit");
			
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
			
			debug(getTimer() - _timer, 'ms');
		}
			
		protected function handleErrorSignal(event : SpodErrorEvent) : void
		{
			error(event.event.error);
		}
	}
}
