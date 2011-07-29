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
		public function when(...rest) : ISpodTriggerExecuteBuilder
		{
			const builder : ISpodTriggerExecuteBuilder = new SpodTriggerExecuteBuilder(type);
			builder.executeSignal.add(internalExecute);
			return builder;
		}
		
		/**
		 * @inheritDoc
		 */
		public function execute(...rest) : void
		{
			const builder : ISpodTriggerExecuteBuilder = new SpodTriggerExecuteBuilder(type);
			builder.executeSignal.add(internalExecute);
			builder.execute.apply(null, rest);
		}
	}
}
