package org.osflash.spod.builders.statements.trigger
{
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public class SpodTriggerActionBuilder extends SpodTriggerBaseBuilder
	{
		
		private var _ignoreIfExists : Boolean;
		
		public function SpodTriggerActionBuilder(type : Class, ignoreIfExists : Boolean = true)
		{
			super(type);
			
			_ignoreIfExists = ignoreIfExists;
		}

		public function insert() : ISpodTriggerWhenBuilder
		{
			const builder : ISpodTriggerWhenBuilder = new SpodTriggerInsertBuilder(type);
			builder.executeSignal.add(internalExecute);
			return builder;
		}
		
		public function update() : ISpodTriggerWhenBuilder
		{
			const builder : ISpodTriggerWhenBuilder = new SpodTriggerUpdateBuilder(type);
			builder.executeSignal.add(internalExecute);
			return builder;
		}
		
		public function remove() : ISpodTriggerWhenBuilder
		{
			const builder : ISpodTriggerWhenBuilder = new SpodTriggerRemoveBuilder(type);
			builder.executeSignal.add(internalExecute);
			return builder;
		}
				
		public function get ignoreIfExists() : Boolean { return _ignoreIfExists; }
	}
}
