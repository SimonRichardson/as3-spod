package org.osflash.spod
{
	import org.osflash.logger.logs.debug;
	import org.osflash.logger.logs.error;
	import org.osflash.spod.errors.SpodErrorEvent;
	import org.osflash.spod.support.user.User;
	import org.osflash.spod.utils.describeTable;

	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.filesystem.File;
	import flash.utils.setTimeout;
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public class SyncObjectTest extends Sprite
	{
		
		private static const sessionName : String = "session.db"; 
		
		protected var resource : File;
		
		protected var user : User;
		
		public function SyncObjectTest()
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
			user = new User('Fred - ' + Math.random());
			
			table.insertSignal.add(handleInsertSignal);
			table.insert(user);
		}
		
		protected function handleInsertSignal(object : SpodObject) : void
		{
			debug(describeTable(object.tableRow.table).toXMLString());
			
			setTimeout(function() : void
			{			
				user.syncSignal.add(handleSyncSignal);
				user.sync();
			}, 5000);
		}
		
		protected function handleSyncSignal(object : SpodObject, updated : Boolean) : void
		{
			const table : SpodTable = object.tableRow.table; 
			
			debug('Updated : ', updated);
			debug(describeTable(table).toXMLString());
		}
			
		protected function handleErrorSignal(event : SpodErrorEvent) : void
		{
			error(event.event.error);
		}
	}
}
