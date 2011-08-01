package org.osflash.spod.builders.statements.trigger
{
	import org.osflash.spod.schema.types.SpodTriggerActionType;
	import org.osflash.spod.schema.types.SpodTriggerWhenType;
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public class SpodTriggerActionBuilder extends SpodTriggerBaseBuilder
											implements ISpodTriggerActionBuilder
	{
		
		/**
		 * @private
		 */
		private var _builder : ISpodTriggerWithBuilder;
		
		public function SpodTriggerActionBuilder(type : Class, head : ISpodTriggerBuilder)
		{
			super(type, head);
		}

		/**
		 * @inheritDoc
		 */
		public function insert() : ISpodTriggerWithBuilder
		{
			if(null != _builder)
			{
				_builder.executeSignal.remove(internalExecute);
				_builder = null;
			}
			
			_builder = new SpodTriggerInsertBuilder(type, head);
			_builder.executeSignal.add(internalExecute);
			return _builder;
		}
		
		/**
		 * @inheritDoc
		 */
		public function update() : ISpodTriggerWithBuilder
		{
			if(null != _builder)
			{
				_builder.executeSignal.remove(internalExecute);
				_builder = null;
			}
			
			_builder = new SpodTriggerUpdateBuilder(type, head);
			_builder.executeSignal.add(internalExecute);
			return _builder;
		}
		
		/**
		 * @inheritDoc
		 */
		public function remove() : ISpodTriggerWithBuilder
		{
			if(null != _builder)
			{
				_builder.executeSignal.remove(internalExecute);
				_builder = null;
			}
			
			_builder = new SpodTriggerRemoveBuilder(type, head);
			_builder.executeSignal.add(internalExecute);
			return _builder;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get whenType() : SpodTriggerWhenType
		{
			throw new Error('Abstract method error');
		}
		
		/**
		 * @inheritDoc
		 */
		public function get actionType() : SpodTriggerActionType { return _builder.actionType; }
		
		public function get withBuilder() : ISpodTriggerWithBuilder { return _builder; }
	}
}
