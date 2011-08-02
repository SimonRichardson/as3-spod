package org.osflash.spod.utils
{
	/**
	 * @author Simon Richardson - me@simonrichardson.info
	 */
	public function getTriggerName(type : Class) : String
	{
		return 'Trigger' + getTableName(type);
	}
}
