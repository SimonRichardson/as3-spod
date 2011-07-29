package org.osflash.spod.builders.statements.trigger
{
	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public class SpodTriggerBaseBuilder implements ISpodTriggerBuilder
	{
		/**
		 * @private
		 */
		private var _type : Class;
		
		/**
		 * @private
		 */
		private var _executeSignal : ISignal;

		public function SpodTriggerBaseBuilder(type : Class)
		{
			if(null == type) throw new ArgumentError('Type can not be null');
			
			_type = type;
		}
		
		/**
		 * @private
		 */
		protected function internalExecute() : void
		{
			executeSignal.dispatch(this);
		}
		
		public function get type() : Class { return _type; }
		
		public function get executeSignal() : ISignal
		{
			if(null == _executeSignal) _executeSignal = new Signal(ISpodTriggerBuilder);
			return _executeSignal;
		}
	}
}
