package org.osflash.spod.builders.statements.trigger
{
	import org.osflash.spod.builders.statements.trigger.ISpodTriggerExecuteBuilder;

	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public class SpodTriggerExecuteBuilder extends SpodTriggerBaseBuilder 
											implements ISpodTriggerExecuteBuilder
	{

		public function SpodTriggerExecuteBuilder(type : Class)
		{
			super(type);
		}

		/**
		 * @inheritDoc
		 */
		public function execute(...rest) : void
		{
			
		}
	}
}
