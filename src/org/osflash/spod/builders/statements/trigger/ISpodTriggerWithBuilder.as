package org.osflash.spod.builders.statements.trigger
{
	import org.osflash.spod.schema.types.SpodTriggerActionType;
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public interface ISpodTriggerWithBuilder extends ISpodTriggerBuilder
	{
		
		function insert(...rest) : void;
		
		function update(...rest) : void;
		
		function remove(...rest) : void;
		
		function get actionType() : SpodTriggerActionType;
	}
}
