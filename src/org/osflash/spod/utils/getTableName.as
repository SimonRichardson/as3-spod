package org.osflash.spod.utils
{
	import flash.utils.describeType;
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public function getTableName(type : Class) : String
	{
		const description : XML = describeType(type);
		const metaTableName : XMLList = description.factory.metadata.(@name == 'Type');
		if(null != metaTableName && metaTableName.length() > 0)
		{
			const metaTableNameArg : XMLList = metaTableName.arg.(@key == 'name');
			const metaTableNameValue : String = metaTableNameArg.@value;
			if(null != metaTableNameValue && metaTableNameValue.length > 1)
				return metaTableNameValue;
		}
		
		return getClassNameFromQname(description.@name);
	}
}
