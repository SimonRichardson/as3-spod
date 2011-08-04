package org.osflash.spod.schema.types
{
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public final class SpodTriggerWithType
	{
		
		public static const SELECT : SpodTriggerWithType = new SpodTriggerWithType('select');
		
		public static const INSERT : SpodTriggerWithType = new SpodTriggerWithType('insert');
		
		public static const UPDATE : SpodTriggerWithType = new SpodTriggerWithType('update');
		
		public static const DELETE : SpodTriggerWithType = new SpodTriggerWithType('delete');
		
		public static const LIMIT : SpodTriggerWithType = new SpodTriggerWithType('limit');
		
		private var _type : String;

		public function SpodTriggerWithType(type : String)
		{
			if(null == type) throw new ArgumentError('Type can not be null');
			
			_type = type;
		}

		public function get type() : String { return _type; }
		
		public function get name() : String { return type.toUpperCase(); }
	}
}
