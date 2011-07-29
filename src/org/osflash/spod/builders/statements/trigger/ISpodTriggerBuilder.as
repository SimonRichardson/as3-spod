package org.osflash.spod.builders.statements.trigger
{
	import org.osflash.signals.ISignal;
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public interface ISpodTriggerBuilder
	{
		
		function get type() : Class;
		
		function get executeSignal() : ISignal;
	}
}
