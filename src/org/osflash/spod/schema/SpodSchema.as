package org.osflash.spod.schema
{
	import org.osflash.spod.errors.SpodError;
	import org.osflash.spod.schema.types.SpodSchemaType;
	import org.osflash.spod.types.SpodTypes;
	import org.osflash.spod.utils.validateString;

	import flash.data.SQLSchema;
	import flash.errors.IllegalOperationError;
	import flash.utils.getQualifiedClassName;
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public class SpodSchema implements ISpodSchema
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
		private var _customColumnNames : Boolean;
			
		/**
		 * @private
		 */
		private var _columns : Vector.<ISpodColumnSchema>;
		
		public function SpodSchema(type : Class, name : String)
		{
			if(null == type) throw new ArgumentError('Type can not be null');
			if(null == name) throw new ArgumentError('Name can not be null');
			if(name.length < 1) throw new ArgumentError('Name can not be emtpy');
			if(!validateString(name)) throw new ArgumentError('Invalid name');
			
			_type = type;
			_name = name;
			_identifier = SpodSchemaIdentifier.DEFAULT;
			
			_columns = new Vector.<ISpodColumnSchema>();
			
			_customColumnNames = false;
		}
		
		public function contains(name : String) : Boolean
		{
			var index : int = _columns.length;
			while(--index > -1)
			{
				const column : ISpodColumnSchema = _columns[index];
				const customName : Boolean = column.customColumnName;
				const columnName : String = customName ? column.alternativeName : column.name; 
				if(columnName == name) return true;
			}
			return false;
		}
		
		public function match(name : String, implementation : *) : Boolean
		{
			const type : String = getQualifiedClassName(implementation).toLowerCase();
			
			var index : int = _columns.length;
			while(--index > -1)
			{
				const column : ISpodColumnSchema = _columns[index];
				const customName : Boolean = column.customColumnName;
				const columnName : String = customName ? column.alternativeName : column.name; 
				if(columnName == name)
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
		public function validate(sqlTable : SQLSchema) : void
		{  
			throw new Error('Abstract method error');
		}
		
		public function createByType(name : String, altName : String, type : String) : void
		{
			if(null == name) throw new ArgumentError('Name can not be null');
			if(name.length < 1) throw new ArgumentError('Name can not be emtpy');
			if(null == altName) throw new ArgumentError('Alternative name can not be null');
			if(altName.length < 1) throw new ArgumentError('Alternative name can not be emtpy');
			if(null == type) throw new ArgumentError('Type can not be null');
			if(type.length < 1) throw new ArgumentError('Type can not be emtpy');
			
			if(name != altName) _customColumnNames = true;
			
			switch(type.toLowerCase())
			{
				case 'int': createInt(name, altName); break;
				case 'uint': createUInt(name, altName); break;
				case 'number': createNumber(name, altName); break;
				case 'string': createString(name, altName); break;
				case 'date': createDate(name, altName); break;
				case 'boolean': createBoolean(name, altName); break;
				case 'object': createObject(name, altName); break;
				default:
					throw new ArgumentError('Unknown type');
			}
		}
		
		public function createInt(name : String, altName : String) : void
		{
			throw new Error('Abstract method error'); 
		}
		
		public function createUInt(name : String, altName : String) : void
		{
			throw new Error('Abstract method error'); 
		}
		
		public function createNumber(name : String, altName : String) : void
		{
			throw new Error('Abstract method error'); 
		}
		
		public function createString(name : String, altName : String) : void
		{
			throw new Error('Abstract method error'); 
		}
		
		public function createDate(name : String, altName : String) : void
		{
			throw new Error('Abstract method error'); 
		}
		
		public function createBoolean(name : String, altName : String) : void
		{
			throw new Error('Abstract method error'); 
		}
		
		public function createObject(name : String, altName : String) : void
		{
			throw new Error('Abstract method error'); 
		}
		
		public function getColumnByName(value : String) : ISpodColumnSchema
		{
			var index : int = _columns.length;
			while(--index > -1)
			{
				const column : ISpodColumnSchema = _columns[index];
				const customName : Boolean = column.customColumnName;
				const columnName : String = customName ? column.alternativeName : column.name;
				if(columnName == value) return column;
			}
			
			return null;
		}
				
		public function isValidSelectIdentifier() : Boolean
		{
			const column : ISpodColumnSchema = getColumnByName(_identifier);
			if(null == column) throw new SpodError('Invalid column identifier');
			return 	column.type == SpodTypes.INT || 
					column.type == SpodTypes.UINT || 
					column.type == SpodTypes.NUMBER;
		}
		
		public function get columns() : Vector.<ISpodColumnSchema> { return _columns; }
		
		public function get customColumnNames() : Boolean { return _customColumnNames; }
		
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
					const column : ISpodColumnSchema = _columns[index];
					const customName : Boolean = column.customColumnName;
					const columnName : String = customName ? column.alternativeName : column.name;
					if(columnName == value)
					{
						_identifier = value;
						return;
					}
				}
				
				throw new SpodError('Invalid identifier');
			}
		}
		
		public function get schemaType() : SpodSchemaType 
		{
			throw new Error('Abstract method error'); 
 		}
	}
}
