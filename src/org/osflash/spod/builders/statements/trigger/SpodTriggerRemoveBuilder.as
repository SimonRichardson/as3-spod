package org.osflash.spod.builders.statements.trigger
{
	import org.osflash.spod.schema.types.SpodTriggerActionType;
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public class SpodTriggerRemoveBuilder extends SpodTriggerWhenBuilder
	{

		public function SpodTriggerRemoveBuilder(type : Class)
		{
			super(type, SpodTriggerActionType.DELETE);
		}
	}
}
