package org.osflash.spod.builders.statements.trigger
{
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public interface ISpodTriggerWhereBuilder extends ISpodTriggerBuilder
	{
		
		function when(...rest) : ISpodTriggerExecuteBuilder;
		
		function execute(...rest) : void;
	}
}
