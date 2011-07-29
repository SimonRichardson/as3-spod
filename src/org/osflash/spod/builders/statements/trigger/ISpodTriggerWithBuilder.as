package org.osflash.spod.builders.statements.trigger
{
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public interface ISpodTriggerWithBuilder extends ISpodTriggerBuilder
	{
		
		function insert(...rest) : void;
		
		function update(...rest) : void;
		
		function remove(...rest) : void;
	}
}
