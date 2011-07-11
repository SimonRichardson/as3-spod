package org.osflash.spod
{
	import org.osflash.signals.IPrioritySignal;
	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;
	import org.osflash.signals.natives.NativeSignal;
	import org.osflash.spod.builders.CreateTableStatementBuilder;
	import org.osflash.spod.builders.ISpodStatementBuilder;
	import org.osflash.spod.errors.SpodError;
	import org.osflash.spod.errors.SpodErrorEvent;
	import org.osflash.spod.schema.SpodTableColumnSchema;
	import org.osflash.spod.schema.SpodTableSchema;
	import org.osflash.spod.types.SpodTypes;
	import org.osflash.spod.utils.buildSchemaFromType;
	import org.osflash.spod.utils.getClassNameFromQname;

	import flash.data.SQLColumnSchema;
	import flash.data.SQLSchemaResult;
	import flash.data.SQLTableSchema;
	import flash.errors.IllegalOperationError;
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
				_nativeSQLErrorEventSignal.addWithPriority(	handleSQLErrorEventSignal, 
															int.MAX_VALUE
															).params = params;
				_nativeSQLEventSchemaSignal.addWithPriority(	handleSQLEventSchemaSignal
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
						handleSQLError(type, ignoreIfExists);
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
			
			if(active(type))
			{
				
			}
			else
			{
				
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
				throw new IllegalOperationError('SpodStatement can not be null');
			
			_tables[schema.type] = new SpodTable(schema, _manager);
			
			statement.completedSignal.add(handleCreateTableCompleteSignal);
			statement.errorSignal.add(handleCreateTableErrorSignal);
			
			_manager.executioner.add(statement);
		}
		
		/**
		 * @private
		 */
		private function handleSQLErrorEventSignal(	event : SQLErrorEvent, 
													type : Class,
													ignoreIfExists : Boolean
													) : void
		{
			// Catch the database not found error, if anything else we just let it slip through!
			if(event.errorID == 3115 && event.error.detailID == 1007)
			{
				event.stopImmediatePropagation();
				
				handleSQLError(type, ignoreIfExists);
			}
		}
		
		/**
		 * @private
		 */
		private function handleSQLError(type : Class, ignoreIfExists : Boolean) : void
		{
			_nativeSQLErrorEventSignal.remove(handleSQLErrorEventSignal);
			_nativeSQLEventSchemaSignal.remove(handleSQLEventSchemaSignal);
			
			if(null == type) throw new IllegalOperationError('Type can not be null');
			
			const schema : SpodTableSchema = buildSchemaFromType(type);
			if(null == schema) throw new IllegalOperationError('Schema can not be null');
			
			// Create it because it doesn't exist
			internalCreateTable(schema, ignoreIfExists);
		}
		
		/**
		 * @private
		 */
		private function handleSQLEventSchemaSignal(	event : SQLEvent, 
														type : Class, 
														ignoreIfExists : Boolean
														) : void
		{
			// This works out if there is a need to migrate a database or not!
			const schema : SpodTableSchema = buildSchemaFromType(type);
			if(null == schema) throw new IllegalOperationError('Schema can not be null');
			
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
					if(schema.name != sqlTable.name)
					{
						throw new SpodError('Unexpected table name, expected ' + schema.name + 
																		' got ' + sqlTable.name);
					}
					
					const numColumns : int = schema.columns.length; 
					
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
								column = schema.columns[index];
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
									column = schema.columns[index];
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
											schema.columns[i].name + ' and ' + 
											SpodTypes.getSQLName(schema.columns[i].type) + ' got ' +
											sqlColumnName + ' and ' + sqlDataType
											);
							}
						}
						
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
