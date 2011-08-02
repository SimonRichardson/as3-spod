package org.osflash.spod.schema
{
	import org.osflash.spod.errors.SpodError;
	import org.osflash.spod.schema.types.SpodSchemaType;
	import org.osflash.spod.types.SpodTypes;

	import flash.data.SQLColumnSchema;
	import flash.data.SQLSchema;
	import flash.data.SQLTableSchema;
	import flash.net.registerClassAlias;
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public class SpodTableSchema extends SpodSchema
	{

		public function SpodTableSchema(type : Class, name : String)
		{
			super(type, name);
		}
		
		/**
		 * @inheritDoc
		 */	
		override public function validate(sql : SQLSchema) : void
		{
			if(sql is SQLTableSchema)
			{
				const sqlTable : SQLTableSchema = SQLTableSchema(sql);
				if(name != sqlTable.name)
				{
					throw new SpodError('Unexpected table name, expected ' + name + 
																	' got ' + sqlTable.name);
				}
				
				const numColumns : int = columns.length; 
				if(sqlTable.columns.length != numColumns)
				{
					throw new SpodError('Invalid column count, expected ' + numColumns + 
															' got ' + sqlTable.columns.length);
				}
				else
				{
					var column : ISpodColumnSchema;
					var columnName : String;
					var dataType : String;
					
					// This validates the schema of the database and the class!
					for(var i : int = 0; i<numColumns; i++)
					{
						const sqlColumnSchema : SQLColumnSchema = sqlTable.columns[i];
						const sqlColumnName : String = sqlColumnSchema.name;
						const sqlDataType : String = sqlColumnSchema.dataType;
						
						var match : Boolean = false;
						
						var index : int = numColumns;
						while(--index > -1)
						{
							column = columns[index];
							columnName = column.name;
							dataType = SpodTypes.getSQLName(column.type);
							
							if(sqlColumnName == columnName && sqlDataType == dataType)
							{
								match = true;
							}
						}
						
						if(!match) 
						{
							// Try and work out if it's just a data change.
							index = numColumns;
							while(--index > -1)
							{
								column = columns[index];
								columnName = column.name;
								dataType = SpodTypes.getSQLName(column.type);
								
								if(sqlColumnName == columnName && sqlDataType != dataType)
								{
									throw new SpodError('Invalid data type in table schema, ' +
										'expected ' + dataType + ' got ' + sqlDataType + 
										' for ' + columnName 
										);
									
									// Exit it out as no further action is required.
									return;
								}
							}
							
							// Database has really changed
							throw new SpodError('Invalid table schema, expected ' + 
										columns[i].name + ' and ' + 
										SpodTypes.getSQLName(columns[i].type) + ' got ' +
										sqlColumnName + ' and ' + sqlDataType
										);
						}
					}
				}
			}
			else throw new ArgumentError('SQLSchema not supported ' + sql);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function createInt(name : String) : void
		{
			if(null == name) throw new ArgumentError('Name can not be null');
			if(name.length < 1) throw new ArgumentError('Name can not be emtpy');
			
			columns.push(new SpodTableColumnSchema(name, SpodTypes.INT));
		}
		
		/**
		 * @inheritDoc
		 */
		override public function createUInt(name : String) : void
		{
			if(null == name) throw new ArgumentError('Name can not be null');
			if(name.length < 1) throw new ArgumentError('Name can not be emtpy');
			
			columns.push(new SpodTableColumnSchema(name, SpodTypes.UINT));
		}
		
		/**
		 * @inheritDoc
		 */
		override public function createNumber(name : String) : void
		{
			if(null == name) throw new ArgumentError('Name can not be null');
			if(name.length < 1) throw new ArgumentError('Name can not be emtpy');
			
			columns.push(new SpodTableColumnSchema(name, SpodTypes.NUMBER));
		}
		
		/**
		 * @inheritDoc
		 */
		override public function createString(name : String) : void
		{
			if(null == name) throw new ArgumentError('Name can not be null');
			if(name.length < 1) throw new ArgumentError('Name can not be emtpy');
			
			columns.push(new SpodTableColumnSchema(name, SpodTypes.STRING));
		}
		
		/**
		 * @inheritDoc
		 */
		override public function createDate(name : String) : void
		{
			if(null == name) throw new ArgumentError('Name can not be null');
			if(name.length < 1) throw new ArgumentError('Name can not be emtpy');
			
			columns.push(new SpodTableColumnSchema(name, SpodTypes.DATE));
		}
		
		/**
		 * @inheritDoc
		 */
		override public function createBoolean(name : String) : void
		{
			if(null == name) throw new ArgumentError('Name can not be null');
			if(name.length < 1) throw new ArgumentError('Name can not be emtpy');
			
			columns.push(new SpodTableColumnSchema(name, SpodTypes.BOOLEAN));
		}
		
		/**
		 * @inheritDoc
		 */
		override public function createObject(name : String) : void
		{
			if(null == name) throw new ArgumentError('Name can not be null');
			if(name.length < 1) throw new ArgumentError('Name can not be emtpy');
			
			// TODO : we should implement a custom class for this!
			registerClassAlias('Object', Object);
			
			columns.push(new SpodTableColumnSchema(name, SpodTypes.OBJECT));
		}
		
		/**
		 * @inheritDoc
		 */
		override public function get schemaType() : SpodSchemaType { return SpodSchemaType.TABLE; }
	}
}
