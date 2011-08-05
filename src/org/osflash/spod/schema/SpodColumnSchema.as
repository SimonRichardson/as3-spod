package org.osflash.spod.schema
{
	import org.osflash.spod.errors.SpodError;
	import org.osflash.spod.schema.types.SpodSchemaType;
	import org.osflash.spod.types.SpodTypes;
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public class SpodColumnSchema implements ISpodColumnSchema
	{
		/**
		 * @private
		 */
		private var _name : String;
		
		/**
		 * @private
		 */
		private var _type : int;
		
		/**
		 * @private
		 */
		private var _alternativeName : String;
		
		/**
		 * @private
		 */
		private var _customColumnName : Boolean;
		
		/**
		 * @private
		 */
		private var _autoIncrement : Boolean;

		public function SpodColumnSchema(name : String, altName : String, type : int)
		{
			if(null == name) throw new ArgumentError('Name can not be null');
			if(name.length < 1) throw new ArgumentError('Name can not be emtpy');
			if(null == altName) throw new ArgumentError('AltName can not be null');
			if(altName.length < 1) throw new ArgumentError('AltName can not be emtpy');
			if(isNaN(type)) throw new ArgumentError('Type can not be NaN');
			if(!SpodTypes.valid(type)) throw new ArgumentError('Type is not a valid type');
			
			_name = name;
			_alternativeName = altName;
			_type = type;
			
			_autoIncrement = false;
			
			_customColumnName = _name != _alternativeName;
		}
		
		/**
		 * @inheritDoc
		 */
		public function contains(name : String) : Boolean
		{
			throw new Error('Missing implementation');
		}
		
		/**
		 * @inheritDoc
		 */
		public function match(name : String, implementation : *) : Boolean
		{
			throw new Error('Missing implementation');
		}
		
		/**
		 * @inheritDoc
		 */
		public function get name() : String { return _name; }
		
		/**
		 * @inheritDoc
		 */
		public function get alternativeName() : String { return _alternativeName; }
		
		/**
		 * @inheritDoc
		 */
		public function get identifier() : String { return _name; }

		/**
		 * @inheritDoc
		 */
		public function get type() : int { return _type; }
		
		/**
		 * @inheritDoc
		 */
		public function get autoIncrement() : Boolean { return _autoIncrement; }
		
		/**
		 * @inheritDoc
		 */
		public function set autoIncrement(value : Boolean) : void 
		{ 
			// TODO : don't allow if the table has already been created, or if it has been provide
			// away to update the table.
			if(type == SpodTypes.INT || type == SpodTypes.UINT || type == SpodTypes.NUMBER)
				_autoIncrement = value;
			else throw new SpodError('Unable to autoIncrement on an invalid type');
		}
		
		/**
		 * @inheritDoc
		 */
		public function get customColumnName() : Boolean { return _customColumnName; }
		
		/**
		 * @inheritDoc
		 */
		public function get schemaType() : SpodSchemaType 
		{ 
			throw new Error('Abstract method error'); 
		}
	}
}
