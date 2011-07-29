package org.osflash.spod.builders.statements.trigger
{
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public interface ISpodTriggerExecuteBuilder extends ISpodTriggerBuilder
	{
		
		function execute(...rest) : void; 
	}
}
