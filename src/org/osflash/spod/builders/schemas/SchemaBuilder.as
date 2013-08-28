package org.osflash.spod.builders.schemas
{
	import org.osflash.spod.types.SpodTypes;
	import org.osflash.spod.SpodObject;
	import org.osflash.spod.errors.SpodError;
	import org.osflash.spod.factories.ISpodSchemaFactory;
	import org.osflash.spod.schema.ISpodColumnSchema;
	import org.osflash.spod.schema.SpodSchema;
	import org.osflash.spod.schema.SpodSchemaIdentifier;
	import org.osflash.spod.utils.getTableName;

	import flash.utils.describeType;
	import flash.utils.getQualifiedClassName;

	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public class SchemaBuilder
	{

		/**
		 * @private
		 */
		private var _factory : ISpodSchemaFactory;

		public function SchemaBuilder(factory : ISpodSchemaFactory)
		{
			if (null == factory) throw new ArgumentError('Factory can not be null');

			_factory = factory;
		}
		
		public function build(type : Class) : SpodSchema
		{
			if (null == type) throw new ArgumentError('Type can not be null');

			const description : XML = describeType(type);

			const tableName : String = getTableName(type);
			const schema : SpodSchema = _factory.createSchema(type, tableName);
			
			const defaultId : String = SpodSchemaIdentifier.DEFAULT;

			for each (var parameter : XML in description..constructor.parameter)
			{
				if (parameter.@optional != 'true')
					throw new ArgumentError('Type constructor parameters need to be optional');
			}

			var identifier : String = defaultId;
			var identifierFound : Boolean = false;
			var identifierAutoIncrement : Boolean = true;

			for each (var variable : XML in description..variable)
			{
				const variableName : String = variable.@name;
				const variableType : String = variable.@type;
				
				var variableAltName : String = variableName;

				const variableMetadata : XMLList = variable..metadata.(@name == 'Type');
				if (null != variableMetadata && variableMetadata.length() > 0)
				{
					const variableArg : XMLList = variableMetadata.arg.(	@key == 'identifier' 
																			&& 
																			@value == 'true'
																			);
					
					if (null != variableArg && variableArg.length() > 0)
					{
						identifier = variableName;
						identifierFound = true;
					}
					else if (variableName == defaultId) identifierFound = true;
					
					// Checking if the identifier should be auto incremented.
					const autoIncrementArg : XMLList = variableMetadata.arg.(	@key == 'autoIncrement' 
																				&& 
																				@value == 'false'
																				);
					
					if (null != autoIncrementArg && autoIncrementArg.length() > 0)
					{
						identifierAutoIncrement = false;
					}
					
					const variableAltNameArg : XMLList = variableMetadata.arg.(@key == 'name');
					if(null != variableAltNameArg && variableAltNameArg.length() > 0)
					{
						variableAltName = variableAltNameArg.(@key == 'name').@value;
						
						// We need to patch the identifier name with alternative name!
						if(identifier == variableName)
						{
							identifier = variableAltName;
							identifierFound = true;
						}
					}
				}
				else if (variableName == defaultId) identifierFound = true;
				
				schema.createByType(variableName, variableAltName, variableType);
			}

			const spodObjectQName : String = getQualifiedClassName(SpodObject);
			for each (var accessor : XML in description.factory.accessor)
			{
				const accessorName : String = accessor.@name;
				const accessorType : String = accessor.@type;
				
				var accessorAltName : String = accessorName;
				
				if (accessor.@declaredBy == spodObjectQName) continue;
				if (accessor.@access != 'readwrite')
				{
					throw new ArgumentError('Accessor (getter & setter) needs to be \'readwrite\'' +
																	 ' to work with SQLStatement');
				}
				
				const accessorMetadata : XMLList = accessor..metadata.(@name == 'Type');
				if (null != accessorMetadata && accessorMetadata.length() > 0)
				{
					const accessorArg : XMLList = accessorMetadata.arg.(	@key == 'identifier' 
																			&& 
																			@value == 'true'
																			);

					if (identifierFound) throw new SpodError('Identifier already exists, only ' + 
																	'one can be used at one time.');

					if (null != accessorArg && accessorArg.length() > 0)
					{
						identifier = accessorName;
						identifierFound = true;
					}
					else if (accessorName == defaultId) identifierFound = true;
					
					const accessorAltNameArg : XMLList = accessorMetadata.arg.(@key == 'name');
					if(null != accessorAltNameArg && accessorAltNameArg.length() > 0)
					{
						accessorAltName = accessorAltNameArg.(@key == 'name').@value;
						
						// We need to patch the identifier name with alternative name!
						if(identifier == accessorName)
						{
							identifier = accessorAltName;
							identifierFound = true;
						}
					}
				}
				else if (accessorName == defaultId) identifierFound = true;

				if (!schema.contains(accessorName)) 
					schema.createByType(accessorName, accessorAltName, accessorType);
			}

			if (!identifierFound) throw new ArgumentError('Type needs identifier variable to work');
			if (schema.columns.length == 0) throw new SpodError('Schema has no columns');

			schema.identifier = identifier;

			if (schema.contains(identifier))
			{
				const identifierColumn : ISpodColumnSchema = schema.getColumnByName(identifier);

				if (null != identifierColumn) 
				{
					const identifierType : int = identifierColumn.type;
					identifierColumn.autoIncrement = SpodTypes.validIdentifier(identifierType) 
													 && 
													 identifierAutoIncrement;
				}
				else throw new SpodError('Invalid table column schema identifier');
			}
			else throw new SpodError('Invalid table schema identifier');

			return schema;
		}
	}
}
