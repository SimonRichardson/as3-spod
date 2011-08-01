package org.osflash.spod.schema
{
	import org.osflash.spod.schema.types.SpodSchemaType;
	import org.osflash.spod.types.SpodTypes;

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
