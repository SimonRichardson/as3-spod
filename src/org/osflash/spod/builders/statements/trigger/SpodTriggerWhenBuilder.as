package org.osflash.spod.builders.statements.trigger
{
	import org.osflash.spod.schema.types.SpodTriggerWhenType;
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public class SpodTriggerWhenBuilder extends SpodTriggerBaseBuilder 
										implements ISpodTriggerWhenBuilder
	{
		
		/**
		 * @private
		 */
		private var _builder : ISpodTriggerActionBuilder;
		
		/**
		 * @inheritDoc
		 */
		private var _ignoreIfExists : Boolean;

		public function SpodTriggerWhenBuilder(type : Class, ignoreIfExists : Boolean = true)
		{
			super(type, this);
			
			_ignoreIfExists = ignoreIfExists;
		}
		
		/**
		 * @inheritDoc
		 */
		public function before() : ISpodTriggerActionBuilder
		{
			if(null != _builder)
			{
				_builder.executeSignal.remove(internalExecute);
				_builder = null;
			}
			
			_builder = new SpodTriggerBeforeBuilder(type, this);
			_builder.executeSignal.add(internalExecute);
			return _builder;
		}

		/**
		 * @inheritDoc
		 */
		public function after() : ISpodTriggerActionBuilder
		{
			if(null != _builder)
			{
				_builder.executeSignal.remove(internalExecute);
				_builder = null;
			}
			
			_builder = new SpodTriggerAfterBuilder(type, this);
			_builder.executeSignal.add(internalExecute);
			return _builder;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get whenType() : SpodTriggerWhenType { return _builder.whenType; }
		
		/**
		 * @inheritDoc
		 */
		public function get actionBuilder() : ISpodTriggerActionBuilder { return _builder; }
		
		/**
		 * @inheritDoc
		 */
		public function get ignoreIfExists() : Boolean { return _ignoreIfExists; }
	}
}
