package org.osflash.spod.utils
{
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public function validateString(value : String) : Boolean
	{
		const pattern : RegExp = /\A[a-zA-Z][a-zA-Z]+/;
		return pattern.exec(value) != null;
	}
}
