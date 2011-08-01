package org.osflash.spod.builders.statements.trigger
{
	import org.osflash.spod.builders.expressions.ISpodExpression;
	import org.osflash.spod.schema.types.SpodTriggerWithType;
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
		private var _withType : SpodTriggerWithType;
		
		/**
		 * @private
		 */
		private var _withExpressions : Vector.<ISpodExpression>;
		
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
			_withExpressions = new Vector.<ISpodExpression>();
		}
		
		/**
		 * @inheritDoc
		 */
		public function select(...rest) : void
		{
			_withType = SpodTriggerWithType.SELECT;
			
			var index : int = rest.length;
			if(index == 0) throw new ArgumentError('Arguments can not be empty');
			while(--index > -1)
			{
				_withExpressions.push(rest[index]);
			}
			
			internalExecute(head);
		}
		
		/**
		 * @inheritDoc
		 */
		public function insert(...rest) : void
		{
			_withType = SpodTriggerWithType.INSERT;
			
			var index : int = rest.length;
			if(index == 0) throw new ArgumentError('Arguments can not be empty');
			while(--index > -1)
			{
				_withExpressions.push(rest[index]);
			}
			
			internalExecute(head);
		}

		/**
		 * @inheritDoc
		 */
		public function update(...rest) : void
		{
			_withType = SpodTriggerWithType.UPDATE;
			
			var index : int = rest.length;
			if(index == 0) throw new ArgumentError('Arguments can not be empty');
			while(--index > -1)
			{
				_withExpressions.push(rest[index]);
			}
			
			internalExecute(head);
		}

		/**
		 * @inheritDoc
		 */
		public function remove(...rest) : void
		{
			_withType = SpodTriggerWithType.DELETE;
			
			var index : int = rest.length;
			if(index == 0) throw new ArgumentError('Arguments can not be empty');
			while(--index > -1)
			{
				_withExpressions.push(rest[index]);
			}
			
			internalExecute(head);
		}
		
		/**
		 * @inheritDoc
		 */
		public function get actionType() : SpodTriggerActionType { return _actionType; }
		
		/**
		 * @inheritDoc
		 */
		public function get withType() : SpodTriggerWithType { return _withType; }
		
		/**
		 * @inheritDoc
		 */
		public function get withExpressions() : Vector.<ISpodExpression> 
		{ 
			return _withExpressions; 
		}
	}
}
