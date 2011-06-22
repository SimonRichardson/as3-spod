package org.osflash.spod.utils
{
	import org.osflash.logger.utils.debug;
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public function getClassNameFromQname(name : String) : String
	{
		debug(name);
		
		const index : int = name.lastIndexOf(":");
		if(index == -1) throw new ArgumentError('Name is not a type of Class');
		return name.substr(index + 1);
	}
}
