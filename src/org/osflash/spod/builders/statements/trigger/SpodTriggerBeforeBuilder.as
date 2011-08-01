package org.osflash.spod.builders.statements.trigger
{
	import org.osflash.spod.schema.types.SpodTriggerWhenType;

	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public class SpodTriggerBeforeBuilder extends SpodTriggerActionBuilder
	{

		public function SpodTriggerBeforeBuilder(type : Class, head : ISpodTriggerBuilder)
		{
			super(type, head);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function get whenType() : SpodTriggerWhenType
		{
			return SpodTriggerWhenType.BEFORE;
		}
	}
}
