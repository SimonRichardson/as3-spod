package org.osflash.spod.schema.types
{
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public final class SpodTriggerActionType
	{
		
		public static const INSERT : SpodTriggerActionType = new SpodTriggerActionType('insert');
		
		public static const UPDATE : SpodTriggerActionType = new SpodTriggerActionType('update');
		
		public static const DELETE : SpodTriggerActionType = new SpodTriggerActionType('delete');
		
		private var _type : String;

		public function SpodTriggerActionType(type : String)
		{
			if(null == type) throw new ArgumentError('Type can not be null');
			
			_type = type;
		}

		public function get type() : String { return _type; }
	}
}
