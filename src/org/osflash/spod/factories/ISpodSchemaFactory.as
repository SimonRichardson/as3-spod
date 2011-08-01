package org.osflash.spod.factories
{
	import org.osflash.spod.schema.SpodSchema;
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public interface ISpodSchemaFactory
	{

		function createSchema(type : Class, tableName : String) : SpodSchema;
	}
}
