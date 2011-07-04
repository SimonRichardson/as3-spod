package org.osflash.spod.create
{
	import asunit.asserts.assertNotNull;
	import asunit.asserts.fail;
	import flash.events.SQLErrorEvent;
	import org.osflash.spod.SpodDatabase;
	import org.osflash.spod.SpodManager;
	import org.osflash.spod.SpodTable;
	import org.osflash.spod.support.BaseTest;
	import org.osflash.spod.support.user.User;


	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public class CreateTest extends BaseTest
	{
		
		[Test]
		public function make_spod_and_create_db() : void
		{
			const manager : SpodManager = new SpodManager();
			manager.openSignal.add(openAsync.add(handleOpenSignal, 1000));
			manager.errorSignal.add(handleErrorSignal);
			manager.open(resource);
		}
		
		[Test]
		public function make_spod_and_create_again_db() : void
		{
			const manager : SpodManager = new SpodManager();
			manager.openSignal.add(openAsync.add(handleOpenSignal, 1000));
			manager.errorSignal.add(handleErrorSignal);
			manager.open(resource);
		}
		
		private function handleOpenSignal(database : SpodDatabase) : void
		{
			database.createTableSignal.add(createdAsync.add(handleCreatedSignal, 1000));
			database.createTable(User);
		}
		
		private function handleCreatedSignal(table : SpodTable) : void
		{
			assertNotNull(table);
		}
		
		private function handleErrorSignal(event : SQLErrorEvent) : void
		{
			fail('Failed on error', event.error);
		}
	}
}
