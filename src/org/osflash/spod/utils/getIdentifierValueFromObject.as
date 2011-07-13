package org.osflash.spod.utils
{
	import org.osflash.spod.SpodObject;
	import org.osflash.spod.errors.SpodError;

	import flash.utils.getQualifiedClassName;
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public function getIdentifierValueFromObject(object : SpodObject, identifier : String) : *
	{
		if(identifier in object)
		{
			// Check the new identifier
			const type : String = getQualifiedClassName(object[identifier]);
			if(type == 'int' || type == 'uint' || type == 'Number')
			{
				if(isNaN(object[identifier])) 
					throw new SpodError('Given object identifier value is NaN');
			}
			else if(type == 'String')
			{
				if(	null == object[identifier])
					throw new SpodError('Given object identifier value is null');
				else if(String(object[identifier]).length == 0 || String(object[identifier]) == '')
					throw new SpodError('Given object identifier value is empty');
			}
			else
			{
				if(	null == object[identifier])
					throw new SpodError('Given object identifier value is null');
			}
			
			// We've passed the verification
			return object[identifier];
		}
		else throw new SpodError('Unable to locate identifier in object');
	}
}
