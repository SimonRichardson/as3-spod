package org.osflash.spod.builders.expressions
{
	import org.osflash.spod.SpodStatement;
	import org.osflash.spod.schema.ISpodSchema;
	/**
	 * @author Simon Richardson - me@simonrichardson.info
	 */
	public interface ISpodExpression
	{
		
		function build(schema : ISpodSchema, statement : SpodStatement) : String;
		
		function get type() : int;
		
		function get operator() : SpodExpressionOperatorType;
	}
}
