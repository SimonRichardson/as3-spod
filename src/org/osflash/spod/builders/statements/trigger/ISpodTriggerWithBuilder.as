package org.osflash.spod.builders.statements.trigger
{
	import org.osflash.spod.builders.expressions.ISpodExpression;
	import org.osflash.spod.schema.types.SpodTriggerActionType;
	import org.osflash.spod.schema.types.SpodTriggerWithType;
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public interface ISpodTriggerWithBuilder extends ISpodTriggerBuilder
	{
		
		function select(...rest) : void;
		
		function insert(...rest) : void;
		
		function update(...rest) : void;
		
		function remove(...rest) : void;
		
		function get actionType() : SpodTriggerActionType;
		
		function get withType() : SpodTriggerWithType;
		
		function get withExpressions() : Vector.<ISpodExpression>;
	}
}
