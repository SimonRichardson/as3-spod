package org.osflash.spod
{
	import org.osflash.signals.IPrioritySignal;
	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;
	import org.osflash.signals.natives.NativeSignal;
	import org.osflash.spod.builders.CreateTableStatementBuilder;
	import org.osflash.spod.builders.DeleteTableStatementBuilder;
	import org.osflash.spod.builders.ISpodStatementBuilder;
	import org.osflash.spod.errors.SpodError;
	import org.osflash.spod.errors.SpodErrorEvent;
	import org.osflash.spod.schema.SpodTableSchema;
	import org.osflash.spod.utils.buildSchemaFromType;
	import org.osflash.spod.utils.getClassNameFromQname;

	import flash.data.SQLSchemaResult;
	import flash.data.SQLTableSchema;
	import flash.errors.SQLError;
	import flash.events.SQLErrorEvent;
	import flash.events.SQLEvent;
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public class SpodDatabase
	{
		
		use namespace spod_namespace;
		
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
		
		/**
		 * @private
		 */
		private var _loadTableSignal : ISignal;
		
		/**
		 * @private
		 */
		private var _deleteTableSignal : ISignal;
		
		/**
		 * @private
		 */
		private var _nativeSQLErrorEventSignal : IPrioritySignal;
		
		/**
		 * @private
		 */
		private var _nativeSQLEventSchemaSignal : IPrioritySignal;
				
		public function SpodDatabase(name : String, manager : SpodManager)
		{
			if(null == name) throw new ArgumentError('Name can not be null');
			if(name.length < 1) throw new ArgumentError('Name can not be emtpy');
			if(null == manager) throw new ArgumentError('Manager can not be null');
			
			_name = name;
			_manager = manager;
			
			if(null == manager.connection) throw new ArgumentError('SpodConnection required');
			_nativeSQLErrorEventSignal = new NativeSignal(	_manager.connection, 
															SQLErrorEvent.ERROR, 
															SQLErrorEvent
															);
			_nativeSQLErrorEventSignal.strict = false;
			_nativeSQLEventSchemaSignal = new NativeSignal(	_manager.connection,
															SQLEvent.SCHEMA,
															SQLEvent
															);
			_nativeSQLEventSchemaSignal.strict = false;
			
			_tables = new Dictionary();
		}
		
		public function begin() : void
		{
			_manager.beginQueue();
		}
		
		public function release() : void
		{
			_manager.releaseQueue();
		}
		
		public function commit() : void
		{
			_manager.commitQueue();
		}
		
		/**
		 * Create a table with the type of class. This is a 1 to 1 relationship and can be considered
		 * as strongly typed. If the table doesn't match the type of class here then an TypeError 
		 * will be thrown because it can't convert the Class to a table row.
		 * 
		 * @param type of Class to use for the database table.
		 * @param ignoreIfExists Boolean if you want to ignore the table if it already exists. This
		 * 						 prevents a SQLError from being thrown if the table already exists.
		 * @throws ArgumentError if the type is null
		 * @throws ArgumentError if the table already exists in the active memory 						 
		 */
		public function createTable(type : Class, ignoreIfExists : Boolean = true) : void
		{
			if(null == type) throw new ArgumentError('Type can not be null');
			
			if(!active(type))
			{
				const params : Array = [type, ignoreIfExists];
				_nativeSQLErrorEventSignal.addOnceWithPriority(	handleCreateSQLErrorEventSignal, 
																int.MAX_VALUE
																).params = params;
				_nativeSQLEventSchemaSignal.addOnceWithPriority(	handleCreateSQLEventSchemaSignal
																	).params = params;
				
				const name : String = getClassNameFromQname(getQualifiedClassName(type));
				try
				{
					_manager.connection.loadSchema(SQLTableSchema, name);
				}
				catch(error : SQLError)
				{
					// supress the error
					if(error.errorID == 3115 && error.detailID == 1007 && !_manager.async)
						handleCreateSQLError(type, ignoreIfExists);
				}
			}
			else throw new ArgumentError('Table already exists and is active, so you can not ' + 
																				'create it again');
		}
		
		/**
		 * Load a table with the type of class. This is a 1 to 1 relationship and can be considered
		 * as strongly typed. If the table doesn't match the type of class here then an TypeError 
		 * will be thrown because it can't convert the Class to a table row.
		 * 
		 * @param type of Class to use for the database table.
		 * @param ignoreIfExists Boolean if you want to ignore the table if it already exists. This
		 * 						 prevents a SQLError from being thrown if the table already exists.
		 * @throws ArgumentError if the type is null
		 * @throws ArgumentError if the table already exists in the active memory 	
		 */
		public function loadTable(type : Class) : void
		{
			if(null == type) throw new ArgumentError('Type can not be null');
			
			if(active(type)) loadTableSignal.dispatch(getTable(type));
			else
			{
				const params : Array = [type];
				_nativeSQLErrorEventSignal.addOnceWithPriority(	handleLoadSQLErrorEventSignal, 
																int.MAX_VALUE
																).params = params;
				_nativeSQLEventSchemaSignal.addOnceWithPriority(	handleLoadSQLEventSchemaSignal
																	).params = params;
				
				const name : String = getClassNameFromQname(getQualifiedClassName(type));
				try
				{
					_manager.connection.loadSchema(SQLTableSchema, name);
				}
				catch(error : SQLError)
				{
					loadTableSignal.dispatch(null);
				}
			}
		}
		
		/**
		 * Delete a table with the type of class.  This is a 1 to 1 relationship and can be considered
		 * as strongly typed. If the table doesn't match the type of class here then an TypeError 
		 * will be thrown because it can't convert the Class to a table row.
		 * 
		 * @param type of Class to use for the database table.
		 */
		public function deleteTable(type : Class, ifExists : Boolean = true) : void
		{
			if(null == type) throw new ArgumentError('Type can not be null');
			if(!active(type))
			{
				const params : Array = [type];
				_nativeSQLErrorEventSignal.addOnceWithPriority(	handleDeleteSQLErrorEventSignal, 
																int.MAX_VALUE
																).params = params;
				_nativeSQLEventSchemaSignal.addOnceWithPriority(	handleDeleteSQLEventSchemaSignal
																	).params = params;
				
				const name : String = getClassNameFromQname(getQualifiedClassName(type));
				try
				{
					_manager.connection.loadSchema(SQLTableSchema, name);
				}
				catch(error : SQLError)
				{
					deleteTableSignal.dispatch(null);
				}
			}
			else
			{
				const table : SpodTable = getTable(type);
				const schema : SpodTableSchema = table.schema;
				
				if(null == schema) throw new SpodError('SpodTableSchema can not be null');
				
				const builder : ISpodStatementBuilder = new DeleteTableStatementBuilder(
																				schema, ifExists);
				const statement : SpodStatement = builder.build();
				
				if(null == statement) 
					throw new SpodError('SpodStatement can not be null');
								
				statement.completedSignal.add(handleDeleteTableCompleteSignal);
				statement.errorSignal.add(handleDeleteTableErrorSignal);
				
				if(_manager.queuing) _manager.queue.add(statement);
				else _manager.executioner.add(new SpodStatementQueue(statement));
			}
		}
		
		/**
		 * Work out if the table with the type of class is active or not. Active being in memory,
		 * this doesn't check the database. Consider calling createTable for now to load it into
		 * memory.
		 * 
		 * @param type of Class to work out if it's active
		 * @return Boolean state of the table memory
		 */
		public function active(type : Class) : Boolean
		{
			return null != _tables[type];
		}
		
		/**
		 * Return the table of type of class. 
		 * 
		 * @param type of Class to work out if it's active
		 * @return the table as a SpodTable.
		 */
		public function getTable(type : Class) : SpodTable
		{
			return active(type) ? _tables[type] : null; 
		}
				
		/**
		 * @private
		 */
		private function internalCreateTable(	schema : SpodTableSchema, 
												ignoreIfExists : Boolean
												) : void
		{
			if(null == schema) throw new ArgumentError('Schema can not be null');
			
			const builder : ISpodStatementBuilder = new CreateTableStatementBuilder(
																			schema, ignoreIfExists);
			const statement : SpodStatement = builder.build();
			
			if(null == statement) 
				throw new SpodError('SpodStatement can not be null');
			
			_tables[schema.type] = new SpodTable(schema, _manager);
			
			statement.completedSignal.add(handleCreateTableCompleteSignal);
			statement.errorSignal.add(handleCreateTableErrorSignal);
			
			if(_manager.queuing) _manager.queue.add(statement);
			else _manager.executioner.add(new SpodStatementQueue(statement));
		}
		
		/**
		 * @private
		 */
		private function handleCreateSQLErrorEventSignal(	event : SQLErrorEvent, 
															type : Class,
															ignoreIfExists : Boolean
															) : void
		{
			// Catch the database not found error, if anything else we just let it slip through!
			if(event.errorID == 3115 && event.error.detailID == 1007)
			{
				event.stopImmediatePropagation();
				
				handleCreateSQLError(type, ignoreIfExists);
			}
		}
		
		/**
		 * @private
		 */
		private function handleLoadSQLErrorEventSignal(event : SQLErrorEvent, type : Class) : void
		{
			// Catch the database not found error, if anything else we just let it slip through!
			if(event.errorID == 3115 && event.error.detailID == 1007)
			{
				event.stopImmediatePropagation();
				
				// we should state no spod table exists.
				loadTableSignal.dispatch(null);
			}
		}
		
		/**
		 * @private
		 */
		private function handleDeleteSQLErrorEventSignal(event : SQLErrorEvent, type : Class) : void
		{
			// Catch the database not found error, if anything else we just let it slip through!
			if(event.errorID == 3115 && event.error.detailID == 1007)
			{
				event.stopImmediatePropagation();
				
				// we should state no spod table exists.
				deleteTableSignal.dispatch(null);
			}
		}
				
		/**
		 * @private
		 */
		private function handleCreateSQLError(type : Class, ignoreIfExists : Boolean) : void
		{
			_nativeSQLErrorEventSignal.remove(handleCreateSQLErrorEventSignal);
			_nativeSQLEventSchemaSignal.remove(handleCreateSQLEventSchemaSignal);
			
			if(null == type) throw new SpodError('Type can not be null');
			
			const schema : SpodTableSchema = buildSchemaFromType(type);
			if(null == schema) throw new SpodError('Schema can not be null');
			
			// Create it because it doesn't exist
			internalCreateTable(schema, ignoreIfExists);
		}
		
		/**
		 * @private
		 */
		private function handleCreateSQLEventSchemaSignal(	event : SQLEvent, 
															type : Class, 
															ignoreIfExists : Boolean
															) : void
		{
			_nativeSQLErrorEventSignal.remove(handleCreateSQLErrorEventSignal);
			_nativeSQLEventSchemaSignal.remove(handleCreateSQLEventSchemaSignal);
			
			// This works out if there is a need to migrate a database or not!
			const schema : SpodTableSchema = buildSchemaFromType(type);
			if(null == schema) throw new SpodError('Schema can not be null');
			
			const result : SQLSchemaResult = _manager.connection.getSchemaResult();
			if(null == result || null == result.tables) internalCreateTable(schema, ignoreIfExists);
			else
			{
				const tables : Array = result.tables;
				const total : int = tables.length;
				 
				if(total == 0) internalCreateTable(schema, ignoreIfExists);
				else if(total == 1)
				{
					const sqlTable : SQLTableSchema = result.tables[0];
					
					// This throws a lot of errors, we should wrap it up in try...catch... and 
					// broadcast it to the error message
					try { schema.validate(sqlTable); }
					catch(error : SpodError)
					{
						_manager.errorSignal.dispatch(new SpodErrorEvent(error.message, error));
					}
										
					if(null != schema)
					{
						// We don't need to make a new table as we've already got one!
						const table : SpodTable = new SpodTable(schema, _manager);
						
						_tables[type] = table;
						
						createTableSignal.dispatch(table);
					}
				}
				else throw new SpodError('Invalid table count, expected 1 got ' + total);
			}
		}
		
		/**
		 * @private
		 */
		private function handleLoadSQLEventSchemaSignal(	event : SQLEvent, 
															type : Class
															) : void
		{
			_nativeSQLErrorEventSignal.remove(handleLoadSQLErrorEventSignal);
			_nativeSQLEventSchemaSignal.remove(handleLoadSQLEventSchemaSignal);
			
			// This works out if there is a need to migrate a database or not!
			const schema : SpodTableSchema = buildSchemaFromType(type);
			if(null == schema) throw new SpodError('Schema can not be null');
			
			const result : SQLSchemaResult = _manager.connection.getSchemaResult();
			if(null == result || null == result.tables) loadTableSignal.dispatch(null);
			else
			{
				const tables : Array = result.tables;
				const total : int = tables.length;
				
				if(total == 0) loadTableSignal.dispatch(null);
				else if(total == 1)
				{
					 const sqlTable : SQLTableSchema = result.tables[0];
					
					// This throws a lot of errors, we should wrap it up in try...catch... and 
					// broadcast it to the error message
					try { schema.validate(sqlTable); }
					catch(error : SpodError)
					{
						_manager.errorSignal.dispatch(new SpodErrorEvent(error.message, error));
					}
										
					if(null != schema)
					{
						// We don't need to make a new table as we've already got one!
						const table : SpodTable = new SpodTable(schema, _manager);
						
						_tables[type] = table;
						
						loadTableSignal.dispatch(table);
					}
				}
				else throw new SpodError('Invalid table count, expected 1 got ' + total);
			}
		}
		
		/**
		 * @private
		 */
		private function handleDeleteSQLEventSchemaSignal(	event : SQLEvent, 
															type : Class
															) : void
		{
			_nativeSQLErrorEventSignal.remove(handleDeleteSQLErrorEventSignal);
			_nativeSQLEventSchemaSignal.remove(handleDeleteSQLEventSchemaSignal);
			
			// This works out if there is a need to migrate a database or not!
			const schema : SpodTableSchema = buildSchemaFromType(type);
			if(null == schema) throw new SpodError('Schema can not be null');
			
			const result : SQLSchemaResult = _manager.connection.getSchemaResult();
			if(null == result || null == result.tables) deleteTableSignal.dispatch(null);
			else
			{
				const tables : Array = result.tables;
				const total : int = tables.length;
				
				if(total == 0) deleteTableSignal.dispatch(null);
				else if(total == 1)
				{
					 const sqlTable : SQLTableSchema = result.tables[0];
					
					// This throws a lot of errors, we should wrap it up in try...catch... and 
					// broadcast it to the error message
					try { schema.validate(sqlTable); }
					catch(error : SpodError)
					{
						_manager.errorSignal.dispatch(new SpodErrorEvent(error.message, error));
					}
										
					if(null != schema)
					{
						// We don't need to make a new table as we've already got one!
						const table : SpodTable = new SpodTable(schema, _manager);
						
						_tables[type] = table;
						
						deleteTable(type);
					}
				}
				else throw new SpodError('Invalid table count, expected 1 got ' + total);
			}
		}
		
		/**
		 * @private
		 */
		private function handleCreateTableCompleteSignal(statement : SpodStatement) : void
		{
			statement.completedSignal.remove(handleCreateTableCompleteSignal);
			statement.errorSignal.remove(handleCreateTableErrorSignal);
			
			const table : SpodTable = _tables[statement.type];
			if(null == table) throw new SpodError('SpodTable does not exist');
			
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
		
		/**
		 * @private
		 */
		private function handleDeleteTableCompleteSignal(statement : SpodStatement) : void
		{
			statement.completedSignal.remove(handleDeleteTableCompleteSignal);
			statement.errorSignal.remove(handleDeleteTableErrorSignal);
			
			const table : SpodTable = _tables[statement.type];
			
			_tables[statement.type] = null;
			delete _tables[statement.type];
			
			deleteTableSignal.dispatch(table);
		}
		
		/**
		 * @private
		 */
		private function handleDeleteTableErrorSignal(	statement : SpodStatement, 
														event : SpodErrorEvent
														) : void
		{
			statement.completedSignal.remove(handleDeleteTableCompleteSignal);
			statement.errorSignal.remove(handleDeleteTableErrorSignal);
			
			_manager.errorSignal.dispatch(event);
		}
		
		public function get createTableSignal() : ISignal
		{
			if(null == _createTableSignal) _createTableSignal = new Signal(SpodTable);
			return _createTableSignal;
		}
		
		public function get loadTableSignal() : ISignal
		{
			if(null == _loadTableSignal) _loadTableSignal = new Signal(SpodTable);
			return _loadTableSignal;
		}
		
		public function get deleteTableSignal() : ISignal
		{
			if(null == _deleteTableSignal) _deleteTableSignal = new Signal(SpodTable);
			return _deleteTableSignal;
		}
	}
}
