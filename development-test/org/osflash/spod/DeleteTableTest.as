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
	public class DeleteTableTest extends Sprite
	{

		private static const sessionName : String = "session.db";

		protected var resource : File;

		public function DeleteTableTest()
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

		private function handleOpenSignal(database : SpodDatabase) : void
		{
			database.deleteTableSignal.add(handleDeleteSignal);
			database.deleteTable(User);
		}

		private function handleDeleteSignal(table : SpodTable) : void
		{
			debug('Table deleted!', table);
		}

		private function handleErrorSignal(event : SpodErrorEvent) : void
		{
			error(event.event.error);
		}
	}
}
