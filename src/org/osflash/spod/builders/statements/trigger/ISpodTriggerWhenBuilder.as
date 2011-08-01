package org.osflash.spod.builders.statements.trigger
{
	import org.osflash.spod.schema.types.SpodTriggerWhenType;
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public interface ISpodTriggerWhenBuilder extends ISpodTriggerBuilder
	{
		
		function before() : ISpodTriggerActionBuilder;
		
		function after() : ISpodTriggerActionBuilder;
		
		function get whenType() : SpodTriggerWhenType;
		
		function get actionBuilder() : ISpodTriggerActionBuilder;
		
		function get ignoreIfExists() : Boolean;
	}
}
