package org.osflash.spod.builders.statements.trigger
{
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public class SpodTriggerActionBuilder extends SpodTriggerBaseBuilder
											implements ISpodTriggerActionBuilder
	{
		
		public function SpodTriggerActionBuilder(type : Class, head : ISpodTriggerBuilder)
		{
			super(type, head);
		}

		public function insert() : ISpodTriggerWithBuilder
		{
			const builder : ISpodTriggerWithBuilder = new SpodTriggerInsertBuilder(type, head);
			builder.executeSignal.add(internalExecute);
			return builder;
		}
		
		public function update() : ISpodTriggerWithBuilder
		{
			const builder : ISpodTriggerWithBuilder = new SpodTriggerUpdateBuilder(type, head);
			builder.executeSignal.add(internalExecute);
			return builder;
		}
		
		public function remove() : ISpodTriggerWithBuilder
		{
			const builder : ISpodTriggerWithBuilder = new SpodTriggerRemoveBuilder(type, head);
			builder.executeSignal.add(internalExecute);
			return builder;
		}
	}
}
