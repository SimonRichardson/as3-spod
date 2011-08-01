package org.osflash.spod.schema
{
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public interface ISpodColumnSchema extends ISpodSchema
	{
		
		function get type() : int;
		
		function get autoIncrement() : Boolean;
		
		function set autoIncrement(value : Boolean) : void;
	}
}
