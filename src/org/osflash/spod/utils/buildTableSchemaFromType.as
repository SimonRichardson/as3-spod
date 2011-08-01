package org.osflash.spod.utils
{
	import org.osflash.spod.SpodObject;
	import org.osflash.spod.errors.SpodError;
	import org.osflash.spod.schema.SpodColumnSchema;
	import org.osflash.spod.schema.SpodSchemaIdentifier;
	import org.osflash.spod.schema.SpodTableSchema;

	import flash.utils.describeType;
	import flash.utils.getQualifiedClassName;
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public function buildTableSchemaFromType(type : Class) : SpodTableSchema
	{
		if(null == type) throw new ArgumentError('Type can not be null');
		
		const description : XML = describeType(type);
		
		const tableName : String = getTableName(type);
		const schema : SpodTableSchema = new SpodTableSchema(type, tableName);
		const defaultId : String = SpodSchemaIdentifier.DEFAULT;
		
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
																		&& 
																		@value == 'true'
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
				
				if(identifierFound) throw new SpodError('Identifier already exists, only one ' + 
																		'can be used at one time.');
																		
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
		if(schema.columns.length == 0) throw new SpodError('Schema has no columns');
		
		schema.identifier = identifier;
		
		if(schema.contains(identifier))
		{
			const identifierColumn : SpodColumnSchema = schema.getColumnByName(identifier);
			
			if(null != identifierColumn) identifierColumn.autoIncrement = true;
			else throw new SpodError('Invalid table column schema identifier');
		}
		else throw new SpodError('Invalid table schema identifier');
				
		return schema;
	}
}
