package org.osflash.spod.utils
{
	import org.osflash.logger.utils.debug;
	import org.osflash.spod.SpodObject;
	import org.osflash.spod.schema.SpodTableSchema;

	import flash.errors.IllegalOperationError;
	import flash.utils.describeType;
	import flash.utils.getQualifiedClassName;
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public function buildSchemaFromType(type : Class) : SpodTableSchema
	{
		if(null == type) throw new ArgumentError('Type can not be null');
		
		const description : XML = describeType(type);
		const tableName : String = getClassNameFromQname(description.@name);
		
		const schema : SpodTableSchema = new SpodTableSchema(type, tableName);
		const defaultId : String = SpodTableSchema.DEFAULT_UNIQUE_IDENTIFIER;
		
		for each(var parameter : XML in description..constructor.parameter)
		{
			if(parameter.@optional != 'true') 
				throw new ArgumentError('Type constructor parameters need to be optional');
		}
		
		var identifier : String = defaultId;
		var identifierFound : Boolean = false;
		for each(var variable : XML in description..variable)
		{
			const variableName : String = variable.@name;
			const variableType : String = variable.@type;
			
			const variableMetadata : XMLList = variable..metadata.(@name == 'Type');
			if(null != variableMetadata && variableMetadata.length() > 0)
			{
				const variableArg : XMLList = variableMetadata.arg.(	@key == 'identifier' 
																		&& @value == 'true'
																		);
				if(null != variableArg && variableArg.length() > 0)
				{
					identifier = variableName;
					identifierFound = true;
				}
				else if(variableName == defaultId) identifierFound = true;
			}
			else if(variableName == defaultId) identifierFound = true;

			schema.createByType(variableName, variableType);
		}
		
		const spodObjectQName : String = getQualifiedClassName(SpodObject);
		for each(var accessor : XML in description.factory.accessor)
		{
			const accessorName : String = accessor.@name;
			const accessorType : String = accessor.@type;
			
			if(accessor.@declaredBy == spodObjectQName) continue;
			if(accessor.@access != 'readwrite') 
			{
				throw new ArgumentError('Accessor (getter & setter) needs to be \'readwrite\'' +
																' to work with SQLStatement');
			}
			
			const accessorMetadata : XMLList = accessor..metadata.(@name == 'Type');
			if(null != accessorMetadata && accessorMetadata.length() > 0)
			{
				const accessorArg : XMLList = accessorMetadata.arg.(	@key == 'identifier' 
																		&& 
																		@value == 'true'
																		);
				if(null != accessorArg && accessorArg.length() > 0)
				{
					identifier = accessorName;
					identifierFound = true;
				}
				else if(accessorName == defaultId) identifierFound = true;
			}
			else if(accessorName == defaultId) identifierFound = true;
			
			if(!schema.contains(accessorName)) schema.createByType(accessorName, accessorType);
		}
		
		if(!identifierFound) throw new ArgumentError('Type needs identifier variable to work');
		if(schema.columns.length == 0) throw new IllegalOperationError('Schema has no columns');
		
		schema.identifier = identifier;
		
		return schema;
	}
}
