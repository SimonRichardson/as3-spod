package org.osflash.spod.schema
{
	import org.osflash.spod.utils.getTriggerName;
	import org.osflash.spod.errors.SpodError;
	import org.osflash.spod.schema.types.SpodSchemaType;
	import org.osflash.spod.types.SpodTypes;
	import org.osflash.spod.utils.getTableNameFromTriggerName;

	import flash.data.SQLSchema;
	import flash.data.SQLTriggerSchema;
	import flash.net.registerClassAlias;
	/**
	 * @author Simon Richardson - me@simonrichardson.info
	 */
	public class SpodTriggerSchema extends SpodSchema
	{
		
		/**
		 * @private
		 */
		private var _name : String;
		
		public function SpodTriggerSchema(type : Class, name : String)
		{
			super(type, name);
			
			_name = getTriggerName(type);
		}
		
		/**
		 * @inheritDoc
		 */	
		override public function validate(sql : SQLSchema) : void
		{
			if(sql is SQLTriggerSchema)
			{
				const sqlTrigger : SQLTriggerSchema = SQLTriggerSchema(sql);
				if(name != sqlTrigger.name)
				{
					throw new SpodError('Unexpected trigger name, expected ' + name + 
																	' got ' + sqlTrigger.name);
				}
				
				const tableName : String = getTableNameFromTriggerName(name);
				if(tableName != sqlTrigger.table)
				{
					throw new SpodError('Unexpected table name, expected ' + name + 
																	' got ' + sqlTrigger.name);
				}
			}
			else throw new ArgumentError('SQLSchema not supported ' + sql);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function createInt(name : String, altName : String) : void
		{
			if(null == name) throw new ArgumentError('Name can not be null');
			if(name.length < 1) throw new ArgumentError('Name can not be emtpy');
			if(null == altName) throw new ArgumentError('AltName can not be null');
			if(altName.length < 1) throw new ArgumentError('AltName can not be emtpy');
			
			columns.push(new SpodTriggerColumnSchema(name, altName, SpodTypes.INT));
		}
		
		/**
		 * @inheritDoc
		 */
		override public function createUInt(name : String, altName : String) : void
		{
			if(null == name) throw new ArgumentError('Name can not be null');
			if(name.length < 1) throw new ArgumentError('Name can not be emtpy');
			if(null == altName) throw new ArgumentError('AltName can not be null');
			if(altName.length < 1) throw new ArgumentError('AltName can not be emtpy');
			
			columns.push(new SpodTriggerColumnSchema(name, altName, SpodTypes.UINT));
		}
		
		/**
		 * @inheritDoc
		 */
		override public function createNumber(name : String, altName : String) : void
		{
			if(null == name) throw new ArgumentError('Name can not be null');
			if(name.length < 1) throw new ArgumentError('Name can not be emtpy');
			if(null == altName) throw new ArgumentError('AltName can not be null');
			if(altName.length < 1) throw new ArgumentError('AltName can not be emtpy');
			
			columns.push(new SpodTriggerColumnSchema(name, altName, SpodTypes.NUMBER));
		}
		
		/**
		 * @inheritDoc
		 */
		override public function createString(name : String, altName : String) : void
		{
			if(null == name) throw new ArgumentError('Name can not be null');
			if(name.length < 1) throw new ArgumentError('Name can not be emtpy');
			if(null == altName) throw new ArgumentError('AltName can not be null');
			if(altName.length < 1) throw new ArgumentError('AltName can not be emtpy');
			
			columns.push(new SpodTriggerColumnSchema(name, altName, SpodTypes.STRING));
		}
		
		/**
		 * @inheritDoc
		 */
		override public function createDate(name : String, altName : String) : void
		{
			if(null == name) throw new ArgumentError('Name can not be null');
			if(name.length < 1) throw new ArgumentError('Name can not be emtpy');
			if(null == altName) throw new ArgumentError('AltName can not be null');
			if(altName.length < 1) throw new ArgumentError('AltName can not be emtpy');
			
			columns.push(new SpodTriggerColumnSchema(name, altName, SpodTypes.DATE));
		}
		
		/**
		 * @inheritDoc
		 */
		override public function createBoolean(name : String, altName : String) : void
		{
			if(null == name) throw new ArgumentError('Name can not be null');
			if(name.length < 1) throw new ArgumentError('Name can not be emtpy');
			if(null == altName) throw new ArgumentError('AltName can not be null');
			if(altName.length < 1) throw new ArgumentError('AltName can not be emtpy');
			
			columns.push(new SpodTriggerColumnSchema(name, altName, SpodTypes.BOOLEAN));
		}
		
		/**
		 * @inheritDoc
		 */
		override public function createObject(name : String, altName : String) : void
		{
			if(null == name) throw new ArgumentError('Name can not be null');
			if(name.length < 1) throw new ArgumentError('Name can not be emtpy');
			if(null == altName) throw new ArgumentError('AltName can not be null');
			if(altName.length < 1) throw new ArgumentError('AltName can not be emtpy');
			
			// TODO : we should implement a custom class for this!
			registerClassAlias('Object', Object);
			
			columns.push(new SpodTriggerColumnSchema(name, altName, SpodTypes.OBJECT));
		}
		
		/**
		 * @inheritDoc
		 */
		override public function get name() : String { return _name; }
				
		/**
		 * @inheritDoc
		 */
		override public function get schemaType() : SpodSchemaType 
		{ 
			return SpodSchemaType.TRIGGER; 
		}
	}
}
