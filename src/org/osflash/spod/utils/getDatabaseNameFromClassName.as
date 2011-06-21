package org.osflash.spod.utils
{
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public function getDatabaseNameFromClassName(name : String) : String
	{
		const index : int = name.lastIndexOf(":");
		if(index == -1) throw new ArgumentError('Name is not a type of Class');
		return name.substr(index + 1);
	}
}
