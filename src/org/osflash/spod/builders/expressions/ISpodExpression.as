package org.osflash.spod.builders.expressions
{
	/**
	 * @author Simon Richardson - me@simonrichardson.info
	 */
	public interface ISpodExpression
	{
		
		function build() : String;
		
		function get type() : int;
	}
}
