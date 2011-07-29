package org.osflash.spod.builders.statements.trigger
{

	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public class SpodTriggerWhereBuilder extends SpodTriggerBaseBuilder 
											implements ISpodTriggerWhereBuilder
	{

		public function SpodTriggerWhereBuilder(type : Class)
		{
			super(type);
		}

		/**
		 * @inheritDoc
		 */
		public function where(...rest) : ISpodTriggerExecuteBuilder
		{
			const builder : ISpodTriggerExecuteBuilder = new SpodTriggerExecuteBuilder(type);
			builder.executeSignal.add(internalExecute);
			return builder;
		}
	}
}
