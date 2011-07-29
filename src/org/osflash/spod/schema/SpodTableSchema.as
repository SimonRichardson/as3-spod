package org.osflash.spod.schema
{
	import org.osflash.spod.schema.types.SpodSchemaType;
	import org.osflash.spod.errors.SpodError;
	import org.osflash.spod.types.SpodTypes;
	import org.osflash.spod.utils.validateString;

	import flash.data.SQLColumnSchema;
	import flash.data.SQLTableSchema;
	import flash.errors.IllegalOperationError;
	import flash.net.registerClassAlias;
	import flash.utils.getQualifiedClassName;
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public class SpodTableSchema implements ISpodSchema
	{
				
		/**
		 * @private
		 */
		private var _type : Class;
		
		/**
		 * @private
		 */
		private var _name : String;
		
		/**
		 * @private
		 */
		private var _identifier : String;
			
		/**
		 * @private
		 */
		private var _columns : Vector.<SpodTableColumnSchema>;
		
		public function SpodTableSchema(type : Class, name : String)
		{
			if(null == type) throw new ArgumentError('Type can not be null');
			if(null == name) throw new ArgumentError('Name can not be null');
			if(name.length < 1) throw new ArgumentError('Name can not be emtpy');
			if(!validateString(name)) throw new ArgumentError('Invalid name');
			
			_type = type;
			_name = name;
			_identifier = SpodSchemaIdentifier.DEFAULT;
			
			_columns = new Vector.<SpodTableColumnSchema>();
		}
		
		public function contains(name : String) : Boolean
		{
			var index : int = _columns.length;
			while(--index > -1)
			{
				const column : SpodTableColumnSchema = _columns[index];
				if(column.name == name) return true;
			}
			
			return false;
		}
		
		public function match(name : String, implementation : *) : Boolean
		{
			const type : String = getQualifiedClassName(implementation).toLowerCase();
			
			var index : int = _columns.length;
			while(--index > -1)
			{
				const column : SpodTableColumnSchema = _columns[index];
				if(column.name == name)
				{
					if(type == 'int' && column.type == SpodTypes.INT) return true;
					else if(type == 'uint' && column.type == SpodTypes.UINT) return true;
					else if(type == 'number' && column.type == SpodTypes.NUMBER) return true;
					else if(type == 'string' && column.type == SpodTypes.STRING) return true;
					else if(type == 'date' && column.type == SpodTypes.DATE) return true;
					else if(type == 'boolean' && column.type == SpodTypes.BOOLEAN) return true;
					else if(type == 'object' && column.type == SpodTypes.OBJECT) return true;
					else
						throw new IllegalOperationError('Unknown column type : ' + type);
				}
			}
			
			return false;
		}
		
		/**
		 * Validate the current schema against the current SQLTableSchema from the database.
		 * 
		 * @param sqlTable SQLTableSchema from the current database
		 * @throws SpodError if mismatch is found.
		 */
		public function validate(sqlTable : SQLTableSchema) : void
		{
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
				var column : SpodTableColumnSchema;
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
		
		public function createByType(name : String, type : String) : void
		{
			if(null == name) throw new ArgumentError('Name can not be null');
			if(name.length < 1) throw new ArgumentError('Name can not be emtpy');
			if(null == type) throw new ArgumentError('Type can not be null');
			if(type.length < 1) throw new ArgumentError('Type can not be emtpy');
			
			switch(type.toLowerCase())
			{
				case 'int': createInt(name); break;
				case 'uint': createUInt(name); break;
				case 'number': createNumber(name); break;
				case 'string': createString(name); break;
				case 'date': createDate(name); break;
				case 'boolean': createBoolean(name); break;
				case 'object': createObject(name); break;
				default:
					throw new ArgumentError('Unknown type');
			}
		}
		
		public function createInt(name : String) : void
		{
			if(null == name) throw new ArgumentError('Name can not be null');
			if(name.length < 1) throw new ArgumentError('Name can not be emtpy');
			
			_columns.push(new SpodTableColumnSchema(name, SpodTypes.INT));
		}
		
		public function createUInt(name : String) : void
		{
			if(null == name) throw new ArgumentError('Name can not be null');
			if(name.length < 1) throw new ArgumentError('Name can not be emtpy');
			
			_columns.push(new SpodTableColumnSchema(name, SpodTypes.UINT));
		}
		
		public function createNumber(name : String) : void
		{
			if(null == name) throw new ArgumentError('Name can not be null');
			if(name.length < 1) throw new ArgumentError('Name can not be emtpy');
			
			_columns.push(new SpodTableColumnSchema(name, SpodTypes.NUMBER));
		}
		
		public function createString(name : String) : void
		{
			if(null == name) throw new ArgumentError('Name can not be null');
			if(name.length < 1) throw new ArgumentError('Name can not be emtpy');
			
			_columns.push(new SpodTableColumnSchema(name, SpodTypes.STRING));
		}
		
		public function createDate(name : String) : void
		{
			if(null == name) throw new ArgumentError('Name can not be null');
			if(name.length < 1) throw new ArgumentError('Name can not be emtpy');
			
			_columns.push(new SpodTableColumnSchema(name, SpodTypes.DATE));
		}
		
		public function createBoolean(name : String) : void
		{
			if(null == name) throw new ArgumentError('Name can not be null');
			if(name.length < 1) throw new ArgumentError('Name can not be emtpy');
			
			_columns.push(new SpodTableColumnSchema(name, SpodTypes.BOOLEAN));
		}
		
		public function createObject(name : String) : void
		{
			if(null == name) throw new ArgumentError('Name can not be null');
			if(name.length < 1) throw new ArgumentError('Name can not be emtpy');
			
			// TODO : we should implement a custom class for this!
			registerClassAlias('Object', Object);
			
			_columns.push(new SpodTableColumnSchema(name, SpodTypes.OBJECT));
		}
		
		public function getColumnByName(value : String) : SpodTableColumnSchema
		{
			var index : int = _columns.length;
			while(--index > -1)
			{
				const column : SpodTableColumnSchema = _columns[index];
				if(column.name == value) return column;
			}
			
			return null;
		}
		
		public function isValidSelectIdentifier() : Boolean
		{
			const column : SpodTableColumnSchema = getColumnByName(_identifier);
			if(null == column) throw new SpodError('Invalid column identifier');
			return column.type == SpodTypes.INT || column.type == SpodTypes.UINT;
		}
		
		public function get columns() : Vector.<SpodTableColumnSchema> { return _columns; }
		
		public function get type() : Class { return _type; }
		
		public function get name() : String { return _name; }
		
		public function get identifier() : String { return _identifier; }
		public function set identifier(value : String) : void 
		{ 
			if(_identifier != value)
			{
				var index : int = _columns.length;
				while(--index > -1)
				{
					const column : SpodTableColumnSchema = _columns[index];
					if(column.name == value)
					{
						_identifier = value;
						return;
					}
				}
				
				throw new SpodError('Invalid identifier');
			}
		}

		public function get schemaType() : SpodSchemaType { return SpodSchemaType.TABLE; }
	}
}
