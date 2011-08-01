package org.osflash.spod.factories
{
	import org.osflash.spod.schema.SpodSchema;
	import org.osflash.spod.schema.SpodTriggerSchema;
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public class SpodTriggerSchemaFactory implements ISpodSchemaFactory
	{
		
		/**
		 * @inheritDoc
		 */
		public function createSchema(type : Class, name : String) : SpodSchema
		{
			return new SpodTriggerSchema(type, name);
		}
	}
}
