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
		private var _createdSignal : ISignal;
				
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
			
		/**
		 * @private
		 */	
		private function createTable(type : Class) : void
		{
			const schema : SpodTableSchema = buildSchemaFromType(type);
			const builder : ISpodStatementBuilder = new CreateStatementBuilder(schema);
			const statement : SpodStatement = builder.build();
			
			statement.completedSignal.add(handleCreatedCompleteSignal);
			statement.errorSignal.add(handleCreatedErrorSignal);
			
			_manager.executioner.add(statement);
			
			_tables[type] = new SpodTable(schema);
		}
		
		/**
		 * @private
		 */
		private function handleCreatedCompleteSignal(statement : SpodStatement) : void
		{
			statement.completedSignal.remove(handleCreatedCompleteSignal);
			statement.errorSignal.remove(handleCreatedErrorSignal);
			
			const table : SpodTable = _tables[statement.type];
			if(null == table) throw new IllegalOperationError('SpodTable does not exist');
			
			createdSignal.dispatch(table);
		}
		
		/**
		 * @private
		 */
		private function handleCreatedErrorSignal(	statement : SpodStatement, 
													event : SpodErrorEvent
													) : void
		{
			statement.completedSignal.remove(handleCreatedCompleteSignal);
			statement.errorSignal.remove(handleCreatedErrorSignal);
			
			_manager.errorSignal.dispatch(event);
		}
		
		public function get createdSignal() : ISignal
		{
			if(null == _createdSignal) _createdSignal = new Signal(SpodTable);
			return _createdSignal;
		}
	}
}
