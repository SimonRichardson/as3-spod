package org.osflash.spod.schema
{
	import org.osflash.spod.schema.types.SpodSchemaType;

	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public class SpodTriggerColumnSchema extends SpodColumnSchema
	{

		public function SpodTriggerColumnSchema(name : String, altName : String, type : int)
		{
			super(name, altName, type);
		}

		/**
		 * @inheritDoc
		 */
		override public function get schemaType() : SpodSchemaType
		{
			return SpodSchemaType.TRIGGER_COLUMN;
		}
	}
}
