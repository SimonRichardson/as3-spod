package org.osflash.spod
{
	import org.osflash.logger.logs.debug;
	import org.osflash.logger.logs.error;
	import org.osflash.spod.builders.expressions.order.AscOrderExpression;
	import org.osflash.spod.errors.SpodErrorEvent;
	import org.osflash.spod.factories.ISpodDatabaseFactory;
	import org.osflash.spod.factories.SpodTriggerDatabaseFactory;
	import org.osflash.spod.support.user.User;

	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.filesystem.File;
	[SWF(backgroundColor="#FFFFFF", frameRate="31", width="1280", height="720")]
	public class CreateTriggerTest extends Sprite
	{
		
		private static const sessionName : String = "session.db"; 
		
		protected var resource : File;

		public function CreateTriggerTest()
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
						
			const storage : File = File.applicationStorageDirectory.resolvePath(sessionName);
			resource = storage;
			
			const factory : ISpodDatabaseFactory = new SpodTriggerDatabaseFactory();
			const manager : SpodManager = new SpodManager(factory);
			manager.openSignal.add(handleOpenSignal);
			manager.errorSignal.add(handleErrorSignal);
			manager.open(resource, true);
		}
		
		private function handleOpenSignal(database : SpodDatabase) : void
		{
			database.createTableSignal.add(handleTableCreateSignal);
			database.createTable(User);
		}
		
		private function handleTableCreateSignal(table : SpodTable) : void
		{
			debug('Table created!', table);
			
			const database : SpodTriggerDatabase = SpodTriggerDatabase(table.manager.database);
			
			database.deleteTriggerSignal.add(handleTriggerDeleteSignal).params = [database];
			database.deleteTrigger(User);
		}
		
		private function handleTriggerDeleteSignal(trigger : SpodTrigger, database : SpodTriggerDatabase) : void
		{
			debug('Trigger removed!');
			
			database.createTriggerSignal.add(handleTriggerCreateSignal).params = [database];
			database.createTrigger(User)
							.after()
							.insert()
							.limit(5, new AscOrderExpression('date'));
			
			trigger;
		}
		
		private function handleTriggerCreateSignal(trigger : SpodTrigger, database : SpodTriggerDatabase) : void
		{
			debug('Trigger created!', trigger);
			
			const table : SpodTable = database.getTable(User);
			
			// flood the database with rows
			const total : int = 10;
			for(var i : int = 0; i < total; i++)
			{
				const user : User = new User("User - " + i);
				if(i < 5) user.date = new Date(2012, 1, 1);
				else 
				{
					user.date = new Date();
					user.date.minutes -= 1;
				}
				
				if(i == total - 1) user.insertSignal.add(handleInsertSignal);
				table.insert(user);
			}
		}
		
		private function handleInsertSignal(object : SpodObject) : void
		{
			debug('User created');
			
			object;
		}
		
		private function handleErrorSignal(event : SpodErrorEvent) : void
		{
			error(event.event);
		}
	}
}
