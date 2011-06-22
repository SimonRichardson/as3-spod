package org.osflash.spod.utils
{
	import flash.filesystem.File;
	/**
	 * @author Simon Richardson - me@simonrichardson.info
	 */
	public function getDatabaseName(resource : File) : String
	{
		// Work out the database name
		const extension : String = resource.extension;
		return resource.name.substr(0, -(extension.length + 1));
	}
}
