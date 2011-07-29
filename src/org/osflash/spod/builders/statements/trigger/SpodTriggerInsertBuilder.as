package org.osflash.spod.builders.statements.trigger
{
	import org.osflash.spod.schema.types.SpodTriggerActionType;
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public class SpodTriggerInsertBuilder extends SpodTriggerWhenBuilder
	{

		public function SpodTriggerInsertBuilder(type : Class)
		{
			super(type, SpodTriggerActionType.INSERT);
		}

	}
}
