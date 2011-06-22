package org.osflash.spod
{
	import org.osflash.spod.builders.ISQLStatementBuilder;
	import org.osflash.spod.builders.SQLCreateStatementBuilder;
	import org.osflash.spod.schema.SpodTableSchema;
	import org.osflash.spod.utils.getClassNameFromQname;

	import flash.data.SQLStatement;
	import flash.errors.IllegalOperationError;
	import flash.utils.Dictionary;
	import flash.utils.describeType;
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public class SpodDatabase
	{
		
		/**
		 * @private
		 */
		private var _name : String;
		
		/**
		 * @private
		 */
		private var _manager : SpodManager;
		
		/**
		 * @private
		 */
		private var _tables : Dictionary;
				
		public function SpodDatabase(name : String, manager : SpodManager)
		{
			if(null == name) throw new ArgumentError('Name can not be null');
			if(name.length < 1) throw new ArgumentError('Name can not be emtpy');
			if(null == manager) throw new ArgumentError('Manager can not be null');
			
			_name = name;
			_manager = manager;
			
			_tables = new Dictionary();
		}
		
		public function create(type : Class) : void
		{
			if(null == type) throw new ArgumentError('Type can not be null');
			
			if(!active(type))
			{
				createTable(type);
			}
			else throw new ArgumentError('Table already exists and is active, so you can not ' + 
																				'create it again');
		}
				
		public function active(type : Class) : Boolean
		{
			return null != _tables[type];
		}
		
		public function buildSchemaFromType(type : Class) : SpodTableSchema
		{
			if(null == type) throw new ArgumentError('Type can not be null');
			
			const description : XML = describeType(type);
			const tableName : String = getClassNameFromQname(description.@name);
			
			const schema : SpodTableSchema = new SpodTableSchema(type, tableName);
			
			for each(var variable : XML in description..variable)
			{
				const variableName : String = variable.@name;
				const variableType : String = variable.@type;
				
				schema.createByType(variableName, variableType);
			}
			
			if(schema.columns.length == 0) throw new IllegalOperationError('Schema has no columns');
			
			return schema;
		}
				
		private function createTable(type : Class) : void
		{
			const schema : SpodTableSchema = buildSchemaFromType(type);
			const builder : ISQLStatementBuilder = new SQLCreateStatementBuilder(schema);
			const query : SQLStatement = builder.build();
			
			_manager.executioner.add(query);
			
			_tables[type] = new SpodTable(schema);
		}
	}
}
