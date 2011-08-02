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
	import org.osflash.spod.errors.SpodError;
	import org.osflash.spod.errors.SpodErrorEvent;
	import org.osflash.spod.schema.SpodTriggerSchema;
	import org.osflash.spod.utils.getTableName;

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
		private var _removeTriggerSignal : ISignal;
				
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
			builder.executeSignal.add(internalBuildTrigger);
			return builder;
		}
		
		public function removeTrigger(	type : Class,
										ignoreIfExists : Boolean = true
										) : void
		{
			
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
			
			const name : String = getTableName(builder.type);
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
			
			statement.completedSignal.add(handleCreateTriggerCompleteSignal);
			statement.errorSignal.add(handleCreateTriggerErrorSignal);
			
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
			nativeSQLEventSchemaSignal.remove(handleTriggerSQLEventSchemaSignal);
			
			info('Handle trigger sql event', triggerBuilder);
		}
		
		/**
		 * @private
		 */
		private function handleCreateTriggerCompleteSignal(statement : SpodStatement) : void
		{
			statement.completedSignal.remove(handleCreateTriggerCompleteSignal);
			statement.errorSignal.remove(handleCreateTriggerErrorSignal);
			
			const trigger : SpodTrigger = _triggers[statement.type];
			if(null == trigger) throw new SpodError('SpodTable does not exist');
			
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
			statement.errorSignal.remove(handleCreateTriggerErrorSignal);
			
			_manager.errorSignal.dispatch(event);
		}
		
		public function get createTriggerSignal() : ISignal
		{
			if(null == _createTriggerSignal) _createTriggerSignal = new Signal(SpodTrigger);
			return _createTriggerSignal;
		}
		
		public function get removeTriggerSignal() : ISignal
		{
			if(null == _removeTriggerSignal) _removeTriggerSignal = new Signal();
			return _removeTriggerSignal;
		}
	}
}
