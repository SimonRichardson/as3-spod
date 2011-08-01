package org.osflash.spod.schema
{
	import org.osflash.spod.schema.types.SpodSchemaType;
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public interface ISpodSchema
	{
		
		function contains(key : String) : Boolean;
		
		function match(name : String, implementation : *) : Boolean;
		
		function get name() : String;
				
		function get identifier() : String;
		
		function get schemaType() : SpodSchemaType;
	}
}
