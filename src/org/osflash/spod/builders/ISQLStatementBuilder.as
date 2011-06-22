package org.osflash.spod.builders
{
	import flash.data.SQLStatement;
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public interface ISQLStatementBuilder
	{
		
		function build() : SQLStatement;
	}
}
