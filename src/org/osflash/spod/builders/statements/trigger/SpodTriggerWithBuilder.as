package org.osflash.spod.builders.statements.trigger
{
	import org.osflash.spod.schema.types.SpodTriggerActionType;
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public class SpodTriggerWithBuilder extends SpodTriggerBaseBuilder 
													implements ISpodTriggerWithBuilder
	{

		/**
		 * @private
		 */
		private var _actionType : SpodTriggerActionType;

		public function SpodTriggerWithBuilder(	type : Class, 
												head : ISpodTriggerBuilder, 
												actionType : SpodTriggerActionType
												)
		{
			super(type, head);
			
			if(null == actionType) throw new ArgumentError('ActionType can not be null');
			
			_actionType = actionType;
		}
		
		/**
		 * @inheritDoc
		 */
		public function insert(...rest) : void
		{
			internalExecute(head);
		}

		/**
		 * @inheritDoc
		 */
		public function update(...rest) : void
		{
			internalExecute(head);
		}

		/**
		 * @inheritDoc
		 */
		public function remove(...rest) : void
		{
			internalExecute(head);
		}
		
		public function get actionType() : SpodTriggerActionType { return _actionType; }
	}
}
