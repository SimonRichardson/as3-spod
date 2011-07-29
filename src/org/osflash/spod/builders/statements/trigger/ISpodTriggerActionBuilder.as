package org.osflash.spod.builders.statements.trigger
{
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public interface ISpodTriggerActionBuilder extends ISpodTriggerBuilder
	{
		
		function insert() : ISpodTriggerWithBuilder;
		
		function update() : ISpodTriggerWithBuilder;
		
		function remove() : ISpodTriggerWithBuilder;
	}
}
