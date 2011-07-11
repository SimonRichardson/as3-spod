package org.osflash.spod.utils
{
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
		
		for each(var parameter : XML in description..constructor.parameter)
		{
			if(parameter.@optional != 'true') 
				throw new ArgumentError('Type constructor parameters need to be optional');
		}
		
		var identifierFound : Boolean = false;
		for each(var variable : XML in description..variable)
		{
			const variableName : String = variable.@name;
			const variableType : String = variable.@type;
			
			if(variableName == 'id') identifierFound = true;
			
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
			
			if(accessorName == 'id') identifierFound = true;
			
			if(!schema.contains(accessorName)) schema.createByType(accessorName, accessorType);
		}
		
		if(!identifierFound) throw new ArgumentError('Type needs id variable to work');
		if(schema.columns.length == 0) throw new IllegalOperationError('Schema has no columns');
		
		return schema;
	}
}
