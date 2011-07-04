package org.osflash.spod.select
{
	import asunit.asserts.assertEquals;
	import asunit.asserts.fail;
	import asunit.framework.IAsync;
	import flash.events.SQLErrorEvent;
	import org.osflash.spod.SpodDatabase;
	import org.osflash.spod.SpodManager;
	import org.osflash.spod.SpodTable;
	import org.osflash.spod.support.BaseTest;
	import org.osflash.spod.support.user.User;


	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public class SelectAllTest extends BaseTest
	{
		
		[Inject]
		public var insertAsync : IAsync;
		
		[Inject]
		public var selectAsync : IAsync;
		
		[Test]
		public function make_table_and_fill() : void
		{
			const manager : SpodManager = new SpodManager();
			manager.openSignal.add(openAsync.add(handleOpenSignal, 1000));
			manager.errorSignal.add(handleErrorSignal);
			manager.open(resource, true);
		}
				
		private function handleOpenSignal(database : SpodDatabase) : void
		{
			database.createTableSignal.add(createdAsync.add(handleCreateSignal, 1000));
			database.createTable(User);
		}
		
		private function handleCreateSignal(table : SpodTable) : void
		{
			const date : Date = new Date();
			
			const total : int = 3;
			for(var i : int = 0; i < total; i++)
			{
				const user : User = new User();
				user.name = 'Tim';
				user.date = date;
				
				if(i == total - 1)
				{
					user.insertSignal.add(insertAsync.add(match_user_valueOf_and_date_valueOf, 1000)).params = [date];
					user.insertSignal.add(insertAsync.add(select_all_users_validate_date, 1000)).params = [date, total];
				}
				table.insert(user);
			}
		}
		
		private function match_user_valueOf_and_date_valueOf(user : User, date : Date) : void
		{
			assertEquals('Date User should match date set', user.date.valueOf() == date.valueOf());
		}
		
		private function select_all_users_validate_date(user : User, date : Date, total : int) : void
		{
			const table : SpodTable = user.tableRow.table;
			table.selectAllSignal.add(selectAsync.add(match_users_valueOf_and_date_valueOf)).params = [date, total];
			table.selectAll();
		}
		
		private function match_users_valueOf_and_date_valueOf(users : Vector.<User>, date : Date, total : int) : void
		{
			assertEquals('Number of users should equal ' + total, users.length == total);
			
			for(var i : int = 0; i < total; i++)
			{
				const user : User = users[i];
				assertEquals('Date User should match date set', user.date.valueOf() == date.valueOf());
			}
		}
		
		private function handleErrorSignal(event : SQLErrorEvent) : void
		{
			fail('Failed on error', event.error);
		}
	}
}
