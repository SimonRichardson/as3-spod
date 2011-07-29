package org.osflash.spod.builders.statements.trigger
{
	import org.osflash.spod.schema.types.SpodTriggerActionType;
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public class SpodTriggerWhenBuilder extends SpodTriggerBaseBuilder 
										implements ISpodTriggerWhenBuilder
	{

		/**
		 * @inheritDoc
		 */
		private var _action : SpodTriggerActionType;

		public function SpodTriggerWhenBuilder(type : Class, action : SpodTriggerActionType)
		{
			super(type);
			
			if(null == action) throw new ArgumentError('Action can not be null');
			_action = action;
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

		public function get action() : SpodTriggerActionType { return _action; }
	}
}
