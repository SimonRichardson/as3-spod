package org.osflash.spod.builders.schemas
{
	import org.osflash.spod.schema.SpodTableSchema;
	import org.osflash.spod.factories.SpodTableSchemaFactory;
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public class TableSchemaBuilder extends SchemaBuilder
	{

		public function TableSchemaBuilder()
		{
			super(new SpodTableSchemaFactory());
		}
		
		public function buildTable(type : Class) : SpodTableSchema
		{
			return SpodTableSchema(build(type));
		}
	}
}
