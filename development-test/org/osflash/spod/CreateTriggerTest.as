package org.osflash.spod
{
	import org.osflash.spod.builders.expressions.where.GreaterThanExpression;
	import org.osflash.logger.logs.debug;
	import org.osflash.logger.logs.error;
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
		
		private function handleOpenSignal(database : SpodTriggerDatabase) : void
		{
			const now : Date = new Date();
			now.date -= 50;
			
			database.createTriggerSignal.add(handleCreateSignal);
			database.createTrigger(User).after().update().remove(new GreaterThanExpression('date', now));
		}
		
		private function handleCreateSignal(table : SpodTable) : void
		{
			debug('Table created!', table);
		}
		
		private function handleErrorSignal(event : SpodErrorEvent) : void
		{
			error(event.event.error);
		}
	}
}
