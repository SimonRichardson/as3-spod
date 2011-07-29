package org.osflash.spod.builders.statements.trigger
{
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public interface ISpodTriggerWhenBuilder extends ISpodTriggerBuilder
	{
		
		function before() : ISpodTriggerWhereBuilder;
		
		function after() : ISpodTriggerWhereBuilder;
	}
}
