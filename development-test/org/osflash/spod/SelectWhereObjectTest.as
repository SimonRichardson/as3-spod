package org.osflash.spod
{
	import org.osflash.logger.utils.debug;
	import org.osflash.logger.utils.error;
	import org.osflash.spod.builders.expressions.DescOrderExpression;
	import org.osflash.spod.builders.expressions.LessThanExpression;
	import org.osflash.spod.errors.SpodErrorEvent;
	import org.osflash.spod.support.user.User;
	import org.osflash.spod.utils.describeTable;

	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.filesystem.File;
	
	[SWF(backgroundColor="#FFFFFF", frameRate="31", width="1280", height="720")]
	public class SelectWhereObjectTest extends Sprite
	{
		
		private static const sessionName : String = "session.db"; 
		
		protected var resource : File;
		
		public function SelectWhereObjectTest()
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
			const date : Date = new Date();
			
			object.tableRow.table.selectWhereSignal.add(handleSelectWhereSignal);
			object.tableRow.table.selectWhere(	new LessThanExpression('date', date), 
												new DescOrderExpression('date')
												);
		}
		
		protected function handleSelectWhereSignal(objects : Vector.<SpodObject>) : void
		{
			if(null == objects || objects.length == 0) debug('Nothing found');
			else
			{
				const total : int = objects.length;
				for(var i : int = 0; i < total; i++)
				{
					const object : SpodObject = objects[i]; 
					const user : User = object as User;
					debug('User id :', user.id, user.date);
				}
				debug(describeTable(user.tableRow.table));
			}
		}
			
		protected function handleErrorSignal(event : SpodErrorEvent) : void
		{
			error(event.event.error);
		}
	}
}
