package org.osflash.spod.utils
{
	import org.osflash.spod.SpodObject;
	import org.osflash.spod.SpodTable;
	import org.osflash.spod.SpodTableRow;
	import org.osflash.spod.schema.ISpodColumnSchema;
	import org.osflash.spod.schema.SpodTableSchema;
	import org.osflash.spod.spod_namespace;
	import org.osflash.spod.types.SpodTypes;

	import flash.utils.Dictionary;
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public function describeTable(table : SpodTable) : XML
	{
		const result : XML = <table name={table.name} />;
		
		const schema : SpodTableSchema = table.schema;
		if(null == schema) throw new ArgumentError('Table is not initialised correctly');
		
		const columns : Vector.<ISpodColumnSchema> = schema.columns;
		if(columns.length == 0) throw new ArgumentError('Table has no columns');
		
		const schemaXML : XML = <schema />;
		
		const accessors : Vector.<String> = new Vector.<String>();
		
		var total : int = columns.length;
		for(var i : int = 0; i<total; i++)
		{
			const column : ISpodColumnSchema = columns[i];
			const sqlType : String = SpodTypes.getSQLName(column.type);
			const columnXML : XML = <column name={column.name} type={sqlType} />;
			
			accessors.push(column.name);
			
			schemaXML.appendChild(columnXML);
		}
		
		// We're dipping into something that shouldn't be visible to the outside		
		use namespace spod_namespace;
		
		const dataXML : XML = <sync-data />;
		const rows : Dictionary = table.rows;
		for each(var row : SpodTableRow in rows)
		{
			const object : SpodObject = row.object;
			
			const objectXML : XML = <row />;
			total = accessors.length;
			for(i=0; i<total; i++)
			{
				const key : String = accessors[i];
				objectXML[key] = object[key];
			}
			
			dataXML.appendChild(objectXML);
		}
		
		result.appendChild(schemaXML);
		result.appendChild(dataXML);
		
		return result;
	}
}
