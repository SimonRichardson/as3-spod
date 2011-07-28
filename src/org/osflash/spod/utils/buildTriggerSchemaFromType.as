package org.osflash.spod.utils
{
	import org.osflash.spod.schema.SpodTriggerSchema;
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public function buildTriggerSchemaFromType(type : Class) : SpodTriggerSchema
	{
		return new SpodTriggerSchema(type, 'stuff');
	}
}
