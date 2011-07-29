package org.osflash.spod.builders.statements.trigger
{
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public class SpodTriggerActionBuilder extends SpodTriggerBaseBuilder
											implements ISpodTriggerActionBuilder
	{
		
		public function SpodTriggerActionBuilder(type : Class)
		{
			super(type);
		}

		public function insert() : ISpodTriggerWithBuilder
		{
			const builder : ISpodTriggerWithBuilder = new SpodTriggerInsertBuilder(type);
			builder.executeSignal.add(internalExecute);
			return builder;
		}
		
		public function update() : ISpodTriggerWithBuilder
		{
			const builder : ISpodTriggerWithBuilder = new SpodTriggerUpdateBuilder(type);
			builder.executeSignal.add(internalExecute);
			return builder;
		}
		
		public function remove() : ISpodTriggerWithBuilder
		{
			const builder : ISpodTriggerWithBuilder = new SpodTriggerRemoveBuilder(type);
			builder.executeSignal.add(internalExecute);
			return builder;
		}
	}
}
