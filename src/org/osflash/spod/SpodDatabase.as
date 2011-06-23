package org.osflash.spod
{
	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;
	import org.osflash.spod.builders.CreateStatementBuilder;
	import org.osflash.spod.builders.ISpodStatementBuilder;
	import org.osflash.spod.errors.SpodErrorEvent;
	import org.osflash.spod.schema.SpodTableSchema;
	import org.osflash.spod.utils.getClassNameFromQname;

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
		
		/**
		 * @private
		 */
		private var _createTableSignal : ISignal;
				
		public function SpodDatabase(name : String, manager : SpodManager)
		{
			if(null == name) throw new ArgumentError('Name can not be null');
			if(name.length < 1) throw new ArgumentError('Name can not be emtpy');
			if(null == manager) throw new ArgumentError('Manager can not be null');
			
			_name = name;
			_manager = manager;
			
			_tables = new Dictionary();
		}
		
		public function createTable(type : Class) : void
		{
			if(null == type) throw new ArgumentError('Type can not be null');
			
			if(!active(type))
			{
				const schema : SpodTableSchema = buildSchemaFromType(type);
				const builder : ISpodStatementBuilder = new CreateStatementBuilder(schema);
				const statement : SpodStatement = builder.build();
				
				if(null == statement) 
					throw new IllegalOperationError('SpodStatement can not be null');
				
				_tables[type] = new SpodTable(schema, _manager);
				
				statement.completedSignal.add(handleCreateTableCompleteSignal);
				statement.errorSignal.add(handleCreateTableErrorSignal);
				
				_manager.executioner.add(statement);
				
				// TODO : validate the schema of the table and the type.
				
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
		
		/**
		 * @private
		 */
		private function handleCreateTableCompleteSignal(statement : SpodStatement) : void
		{
			statement.completedSignal.remove(handleCreateTableCompleteSignal);
			statement.errorSignal.remove(handleCreateTableErrorSignal);
			
			const table : SpodTable = _tables[statement.type];
			if(null == table) throw new IllegalOperationError('SpodTable does not exist');
			
			createTableSignal.dispatch(table);
		}
		
		/**
		 * @private
		 */
		private function handleCreateTableErrorSignal(	statement : SpodStatement, 
													event : SpodErrorEvent
													) : void
		{
			statement.completedSignal.remove(handleCreateTableCompleteSignal);
			statement.errorSignal.remove(handleCreateTableErrorSignal);
			
			_manager.errorSignal.dispatch(event);
		}
		
		public function get createTableSignal() : ISignal
		{
			if(null == _createTableSignal) _createTableSignal = new Signal(SpodTable);
			return _createTableSignal;
		}
	}
}
