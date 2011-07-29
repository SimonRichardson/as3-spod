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

		public function SpodTriggerWithBuilder(type : Class, actionType : SpodTriggerActionType)
		{
			super(type);
			
			if(null == actionType) throw new ArgumentError('ActionType can not be null');
			
			_actionType = actionType;
		}
		
		public function insert() : void
		{
		}

		public function update() : void
		{
		}

		public function remove() : void
		{
		}
		
		public function get actionType() : SpodTriggerActionType { return _actionType; }
	}
}
