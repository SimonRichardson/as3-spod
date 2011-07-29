package org.osflash.spod.schema.types
{
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public final class SpodTriggerWhenType
	{
		
		public static const BEFORE : SpodTriggerWhenType = new SpodTriggerWhenType('before');
		
		public static const AFTER : SpodTriggerWhenType = new SpodTriggerWhenType('after');
		
		private var _type : String;

		public function SpodTriggerWhenType(type : String)
		{
			if(null == type) throw new ArgumentError('Type can not be null');
			
			_type = type;
		}

		public function get type() : String { return _type; }
	}
}
