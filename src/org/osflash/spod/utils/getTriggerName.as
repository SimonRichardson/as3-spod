package org.osflash.spod.utils
{
	import org.osflash.spod.schema.SpodSchemaTriggerIdentifier;
	/**
	 * @author Simon Richardson - me@simonrichardson.info
	 */
	public function getTriggerName(type : Class) : String
	{
		return SpodSchemaTriggerIdentifier.DEFAULT + getTableName(type);
	}
}
