package org.osflash.spod.factories
{
	import org.osflash.spod.schema.SpodSchema;
	import org.osflash.spod.schema.SpodTableSchema;
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public class SpodTableSchemaFactory implements ISpodSchemaFactory
	{
		
		/**
		 * @inheritDoc
		 */
		public function createSchema(type : Class, name : String) : SpodSchema
		{
			return new SpodTableSchema(type, name);
		}
	}
}
