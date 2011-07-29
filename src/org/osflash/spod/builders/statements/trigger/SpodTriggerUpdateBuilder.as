package org.osflash.spod.builders.statements.trigger
{
	import org.osflash.spod.schema.types.SpodTriggerActionType;
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public class SpodTriggerUpdateBuilder extends SpodTriggerWhenBuilder
	{
		public function SpodTriggerUpdateBuilder(type : Class)
		{
			super(type, SpodTriggerActionType.UPDATE);
		}
	}
}
