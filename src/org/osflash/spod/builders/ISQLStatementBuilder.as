package org.osflash.spod.builders
{
	import org.osflash.spod.schema.ISpodSchema;
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public interface ISQLStatementBuilder
	{
		
		function build(schema : ISpodSchema) : String;
	}
}
