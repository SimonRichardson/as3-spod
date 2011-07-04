package org.osflash.spod.support
{
	import asunit.framework.IAsync;

	import flash.filesystem.File;
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public class BaseTest
	{
		
		private static const sessionName : String = "session.db"; 
		
		[Inject]
		public var openAsync : IAsync;
		
		[Inject]
		public var createdAsync : IAsync;
		
		protected var resource : File;
		
		[Before]
		public function setUp() : void
		{
			const storage : File = File.applicationStorageDirectory.resolvePath(sessionName);
			resource = storage;			
		}
		
		[After]
		public function tearDown() : void
		{
			if(resource.exists) resource.deleteFile();
			resource = null;
		}
	}
}
