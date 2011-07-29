package org.osflash.spod.builders.statements.trigger
{
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public class SpodTriggerWhenBuilder extends SpodTriggerBaseBuilder 
										implements ISpodTriggerWhenBuilder
	{

		public function SpodTriggerWhenBuilder(type : Class)
		{
			super(type);
		}
		
		public function before() : ISpodTriggerWhereBuilder
		{
			const builder : ISpodTriggerWhereBuilder = new SpodTriggerWhereBuilder(type);
			builder.executeSignal.add(internalExecute);
			return builder;
		}

		public function after() : ISpodTriggerWhereBuilder
		{
			const builder : ISpodTriggerWhereBuilder = new SpodTriggerWhereBuilder(type);
			builder.executeSignal.add(internalExecute);
			return builder;
		}
	}
}
