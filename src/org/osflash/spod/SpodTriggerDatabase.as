package org.osflash.spod
{
	import org.osflash.logger.logs.info;
	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;
	import org.osflash.spod.builders.ISpodStatementBuilder;
	import org.osflash.spod.builders.schemas.TriggerSchemaBuilder;
	import org.osflash.spod.builders.statements.trigger.ISpodTriggerWhenBuilder;
	import org.osflash.spod.builders.statements.trigger.SpodTriggerWhenBuilder;
	import org.osflash.spod.builders.trigger.CreateTriggerStatementBuilder;
	import org.osflash.spod.builders.trigger.DeleteTriggerStatementBuilder;
	import org.osflash.spod.errors.SpodError;
	import org.osflash.spod.errors.SpodErrorEvent;
	import org.osflash.spod.schema.SpodTriggerSchema;
	import org.osflash.spod.utils.getTriggerName;

	import flash.data.SQLSchemaResult;
	import flash.data.SQLTriggerSchema;
	import flash.errors.SQLError;
	import flash.events.SQLErrorEvent;
	import flash.events.SQLEvent;
	import flash.utils.Dictionary;
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public class SpodTriggerDatabase extends SpodDatabase
	{
		
		use namespace spod_namespace;
		
		/**
		 * @private
		 */
		private var _schemaBuilder : TriggerSchemaBuilder;
		
		/**
		 * @private
		 */
		private var _triggers : Dictionary;
		
		/**
		 * @private
		 */
		private var _manager : SpodManager;
		
		/**
		 * @private
		 */
		private var _createTriggerSignal : ISignal;
		
		/**
		 * @private
		 */
		private var _deleteTriggerSignal : ISignal;
				
		public function SpodTriggerDatabase(name : String, manager : SpodManager)
		{
			super(name, manager);
			
			_manager = manager;
			
			_schemaBuilder = new TriggerSchemaBuilder();
			
			_triggers = new Dictionary();
		}
		
		public function createTrigger(	type : Class, 
										ignoreIfExists : Boolean = true
										) : ISpodTriggerWhenBuilder
		{
			const builder : ISpodTriggerWhenBuilder = new SpodTriggerWhenBuilder(	type, 
																					ignoreIfExists
																					);
			builder.executeSignal.addOnce(internalBuildTrigger);
			return builder;
		}
		
		public function deleteTrigger(	type : Class,
										ifExists : Boolean = true
										) : void
		{
			if(null == type) throw new ArgumentError('Type can not be null');
			if(!activeTrigger(type))
			{
				const params : Array = [type];
				nativeSQLErrorEventSignal.addOnceWithPriority(	handleDeleteSQLErrorEventSignal, 
																int.MAX_VALUE
																).params = params;
				nativeSQLEventSchemaSignal.addOnceWithPriority(	handleDeleteSQLEventSchemaSignal
																	).params = params;
				
				const name : String = getTriggerName(type);
				try
				{
					_manager.connection.loadSchema(SQLTriggerSchema, name);
				}
				catch(error : SQLError)
				{
					deleteTriggerSignal.dispatch(null);
				}
			}
			else
			{
				const trigger : SpodTrigger = getTrigger(type);
				const schema : SpodTriggerSchema = trigger.schema;
				
				if(null == schema) throw new SpodError('SpodTriggerSchema can not be null');
				
				const builder : ISpodStatementBuilder = new DeleteTriggerStatementBuilder(
																				schema, ifExists);
				const statement : SpodStatement = builder.build();
				
				if(null == statement) 
					throw new SpodError('SpodStatement can not be null');
								
				statement.completedSignal.addOnce(handleDeleteTriggerCompleteSignal);
				statement.errorSignal.addOnce(handleDeleteTriggerErrorSignal);
				
				if(_manager.queuing) _manager.queue.add(statement);
				else _manager.executioner.add(new SpodStatementQueue(statement));
			}
		}
		
		
		/**
		 * Work out if the trigger with the type of class is active or not. Active being in memory,
		 * this doesn't check the database. Consider calling createTrigger for now to load it into
		 * memory.
		 * 
		 * @param type of Class to work out if it's active
		 * @return Boolean state of the trigger memory
		 */
		public function activeTrigger(type : Class) : Boolean
		{
			return null != _triggers[type];
		}
		
		/**
		 * Return the trigger of type of class. 
		 * 
		 * @param type of Class to work out if it's active
		 * @return the trigger as a SpodTrigger.
		 */
		public function getTrigger(type : Class) : SpodTrigger
		{
			return activeTable(type) ? _triggers[type] : null; 
		}
		
		/**
		 * @private
		 */
		private function internalBuildTrigger(builder : ISpodTriggerWhenBuilder) : void
		{
			const params : Array = [builder];
			nativeSQLErrorEventSignal.addOnceWithPriority(	handleTriggerSQLErrorEventSignal, 
															int.MAX_VALUE
															).params = params;
			nativeSQLEventSchemaSignal.addOnceWithPriority(	handleTriggerSQLEventSchemaSignal
															).params = params;
			
			const name : String = getTriggerName(builder.type);
			try
			{
				_manager.connection.loadSchema(SQLTriggerSchema, name);
			}
			catch(error : SQLError)
			{
				// supress the error
				if(error.errorID == 3115 && error.detailID == 1007 && !_manager.async)
					handleTriggerSQLError(builder);
			}
		}
				
		/**
		 * @private
		 */
		private function internalCreateTrigger(	schema : SpodTriggerSchema, 
												triggerBuilder : ISpodTriggerWhenBuilder
												) : void
		{
			if(null == schema) throw new ArgumentError('Schema can not be null');
			
			const builder : ISpodStatementBuilder = new CreateTriggerStatementBuilder(
																			schema, triggerBuilder);
			const statement : SpodStatement = builder.build();
			
			if(null == statement) 
				throw new SpodError('SpodStatement can not be null');
			
			_triggers[schema.type] = new SpodTrigger(schema, _manager);
			
			statement.completedSignal.addOnce(handleCreateTriggerCompleteSignal);
			statement.errorSignal.addOnce(handleCreateTriggerErrorSignal);
			
			if(_manager.queuing) _manager.queue.add(statement);
			else _manager.executioner.add(new SpodStatementQueue(statement));
		}
		
		/**
		 * @private
		 */
		private function handleTriggerSQLError(builder : ISpodTriggerWhenBuilder) : void
		{
			nativeSQLErrorEventSignal.remove(handleTriggerSQLErrorEventSignal);
			nativeSQLEventSchemaSignal.remove(handleTriggerSQLEventSchemaSignal);
			
			const type : Class = builder.type;
			if(null == type) throw new SpodError('Type can not be null');
			
			const schema : SpodTriggerSchema = _schemaBuilder.buildTrigger(type);
			if(null == schema) throw new SpodError('Schema can not be null');
			
			// Create it because it doesn't exist
			internalCreateTrigger(schema, builder);
		}
		
		/**
		 * @private
		 */
		private function handleTriggerSQLErrorEventSignal(	event : SQLErrorEvent, 
															builder : ISpodTriggerWhenBuilder
															) : void
		{
			// Catch the database not found error, if anything else we just let it slip through!
			if(event.errorID == 3115 && event.error.detailID == 1007)
			{
				event.stopImmediatePropagation();
				
				handleTriggerSQLError(builder);
			}
		}
		
		/**
		 * @private
		 */
		private function handleTriggerSQLEventSchemaSignal(	event : SQLEvent, 
															triggerBuilder : ISpodTriggerWhenBuilder
															) : void
		{
			nativeSQLErrorEventSignal.remove(handleTriggerSQLErrorEventSignal);
			
			info('Handle trigger sql event', triggerBuilder);
		}
		
		/**
		 * @private
		 */
		private function handleCreateTriggerCompleteSignal(statement : SpodStatement) : void
		{
			statement.errorSignal.remove(handleCreateTriggerErrorSignal);
			
			const trigger : SpodTrigger = _triggers[statement.type];
			if(null == trigger) throw new SpodError('SpodTrigger does not exist');
			
			createTriggerSignal.dispatch(trigger);
		}
		
		/**
		 * @private
		 */
		private function handleCreateTriggerErrorSignal(	statement : SpodStatement, 
															event : SpodErrorEvent
															) : void
		{
			statement.completedSignal.remove(handleCreateTriggerCompleteSignal);
			
			_manager.errorSignal.dispatch(event);
		}
		
		
		/**
		 * @private
		 */
		private function handleDeleteSQLErrorEventSignal(	event : SQLErrorEvent, 
															type : Class
															) : void
		{
			// Catch the database not found error, if anything else we just let it slip through!
			if(event.errorID == 3115 && event.error.detailID == 1007)
			{
				event.stopImmediatePropagation();
				
				// we should state no spod trigger exists.
				deleteTriggerSignal.dispatch(null);
			}
		}
		
		/**
		 * @private
		 */
		private function handleDeleteSQLEventSchemaSignal(	event : SQLEvent, 
															type : Class
															) : void
		{
			nativeSQLErrorEventSignal.remove(handleDeleteSQLErrorEventSignal);
			
			// This works out if there is a need to migrate a database or not!
			const schema : SpodTriggerSchema = _schemaBuilder.buildTrigger(type);
			if(null == schema) throw new SpodError('Schema can not be null');
			
			const result : SQLSchemaResult = _manager.connection.getSchemaResult();
			if(null == result || null == result.triggers) deleteTriggerSignal.dispatch(null);
			else
			{
				const triggers : Array = result.triggers;
				const total : int = triggers.length;
				
				if(total == 0) deleteTriggerSignal.dispatch(null);
				else if(total == 1)
				{
					 const sqlTrigger : SQLTriggerSchema = result.triggers[0];
					
					// This throws a lot of errors, we should wrap it up in try...catch... and 
					// broadcast it to the error message
					try { schema.validate(sqlTrigger); }
					catch(error : SpodError)
					{
						_manager.errorSignal.dispatch(new SpodErrorEvent(error.message, error));
					}
										
					if(null != schema)
					{
						// We don't need to make a new trigger as we've already got one!
						const trigger : SpodTrigger = new SpodTrigger(schema, _manager);
						
						_triggers[type] = trigger;
						
						deleteTrigger(type);
					}
				}
				else throw new SpodError('Invalid trigger count, expected 1 got ' + total);
			}
		}
		
		/**
		 * @private
		 */
		private function handleDeleteTriggerCompleteSignal(statement : SpodStatement) : void
		{
			statement.errorSignal.remove(handleDeleteTriggerErrorSignal);
			
			const trigger : SpodTrigger = _triggers[statement.type];
			
			_triggers[statement.type] = null;
			delete _triggers[statement.type];
			
			deleteTriggerSignal.dispatch(trigger);
		}
		
		/**
		 * @private
		 */
		private function handleDeleteTriggerErrorSignal(	statement : SpodStatement, 
															event : SpodErrorEvent
															) : void
		{
			statement.completedSignal.remove(handleDeleteTriggerCompleteSignal);
			
			_manager.errorSignal.dispatch(event);
		}
		
		public function get createTriggerSignal() : ISignal
		{
			if(null == _createTriggerSignal) _createTriggerSignal = new Signal(SpodTrigger);
			return _createTriggerSignal;
		}
		
		public function get deleteTriggerSignal() : ISignal
		{
			if(null == _deleteTriggerSignal) _deleteTriggerSignal = new Signal(SpodTrigger);
			return _deleteTriggerSignal;
		}
	}
}
