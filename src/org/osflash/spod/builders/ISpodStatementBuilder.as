package org.osflash.spod.builders
{
	import org.osflash.spod.SpodStatement;
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public interface ISpodStatementBuilder
	{
		
		function build() : SpodStatement;
	}
}
