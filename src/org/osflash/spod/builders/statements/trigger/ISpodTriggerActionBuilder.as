package org.osflash.spod.builders.statements.trigger
{
	import org.osflash.spod.schema.types.SpodTriggerActionType;
	import org.osflash.spod.schema.types.SpodTriggerWhenType;
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public interface ISpodTriggerActionBuilder extends ISpodTriggerBuilder
	{
		
		function insert() : ISpodTriggerWithBuilder;
		
		function update() : ISpodTriggerWithBuilder;
		
		function remove() : ISpodTriggerWithBuilder;
		
		function get whenType() : SpodTriggerWhenType;
		
		function get actionType() : SpodTriggerActionType;
		
		function get withBuilder() : ISpodTriggerWithBuilder;
	}
}
