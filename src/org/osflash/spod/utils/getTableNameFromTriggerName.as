package org.osflash.spod.utils
{
	import org.osflash.spod.schema.SpodSchemaTriggerIdentifier;
	/**
	 * @author Simon Richardson - me@simonrichardson.info
	 */
	public function getTableNameFromTriggerName(name : String) : String
	{
		return name.substr(SpodSchemaTriggerIdentifier.DEFAULT.length);
	}
}
