package org.osflash.spod.builders.statements.trigger
{
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public class SpodTriggerWhenBuilder extends SpodTriggerBaseBuilder 
										implements ISpodTriggerWhenBuilder
	{

		/**
		 * @inheritDoc
		 */
		private var _ignoreIfExists : Boolean;

		public function SpodTriggerWhenBuilder(type : Class, ignoreIfExists : Boolean = true)
		{
			super(type, this);
			
			_ignoreIfExists = ignoreIfExists;
		}
		
		public function before() : ISpodTriggerActionBuilder
		{
			const builder : ISpodTriggerActionBuilder = new SpodTriggerActionBuilder(type, this);
			builder.executeSignal.add(internalExecute);
			return builder;
		}

		public function after() : ISpodTriggerActionBuilder
		{
			const builder : ISpodTriggerActionBuilder = new SpodTriggerActionBuilder(type, this);
			builder.executeSignal.add(internalExecute);
			return builder;
		}
		
		public function get ignoreIfExists() : Boolean { return _ignoreIfExists; }
	}
}
