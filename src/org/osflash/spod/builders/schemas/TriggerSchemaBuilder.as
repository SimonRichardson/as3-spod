package org.osflash.spod.builders.schemas
{
	import org.osflash.spod.factories.SpodTriggerSchemaFactory;
	import org.osflash.spod.schema.SpodTriggerSchema;
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public class TriggerSchemaBuilder extends SchemaBuilder
	{

		public function TriggerSchemaBuilder()
		{
			super(new SpodTriggerSchemaFactory());
		}
		
		public function buildTrigger(type : Class) : SpodTriggerSchema
		{
			return SpodTriggerSchema(build(type));
		}
	}
}
