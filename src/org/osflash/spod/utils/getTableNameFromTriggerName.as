package org.osflash.spod.utils
{
	/**
	 * @author Simon Richardson - me@simonrichardson.info
	 */
	public function getTableNameFromTriggerName(name : String) : String
	{
		return name.substr('Trigger'.length);
	}
}
