package org.osflash.spod
{
	import org.osflash.logger.logs.info;
	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;
	import org.osflash.spod.builders.statements.trigger.ISpodTriggerBuilder;
	import org.osflash.spod.builders.statements.trigger.SpodTriggerActionBuilder;
	import org.osflash.spod.errors.SpodError;
	import org.osflash.spod.schema.SpodTriggerSchema;
	import org.osflash.spod.utils.buildTriggerSchemaFromType;
	import org.osflash.spod.utils.getClassNameFromQname;

	import flash.data.SQLTriggerSchema;
	import flash.errors.SQLError;
	import flash.events.SQLErrorEvent;
	import flash.events.SQLEvent;
	import flash.utils.getQualifiedClassName;
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public class SpodTriggerDatabase extends SpodDatabase
	{
		
		use namespace spod_namespace;
				
		/**
		 * @private
		 */
		private var _manager : SpodManager;
		
		/**
		 * @private
		 */
		private var _createTriggerSignal : ISignal;
				
		public function SpodTriggerDatabase(name : String, manager : SpodManager)
		{
			super(name, manager);
			
			_manager = manager;
		}
		
		public function createTrigger(	type : Class, 
										ignoreIfExists : Boolean = true
										) : SpodTriggerActionBuilder
		{
			const builder : SpodTriggerActionBuilder = new SpodTriggerActionBuilder(type, 
																					ignoreIfExists
																					);
			builder.executeSignal.add(internalBuildTrigger);
			return builder;
		}
		
		private function internalBuildTrigger(builder : ISpodTriggerBuilder) : void
		{
			const params : Array = [builder];
			nativeSQLErrorEventSignal.addOnceWithPriority(	handleTriggerSQLErrorEventSignal, 
															int.MAX_VALUE
															).params = params;
			nativeSQLEventSchemaSignal.addOnceWithPriority(	handleTriggerSQLEventSchemaSignal
															).params = params;
			
			const name : String = getClassNameFromQname(getQualifiedClassName(builder.type));
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
												builder : ISpodTriggerBuilder
												) : void
		{
			if(null == schema) throw new ArgumentError('Schema can not be null');
			
			info('Create trigger table', schema, builder);
		}
		
		/**
		 * @private
		 */
		private function handleTriggerSQLError(builder : ISpodTriggerBuilder) : void
		{
			nativeSQLErrorEventSignal.remove(handleTriggerSQLErrorEventSignal);
			nativeSQLEventSchemaSignal.remove(handleTriggerSQLEventSchemaSignal);
			
			const type : Class = builder.type;
			if(null == type) throw new SpodError('Type can not be null');
			
			const schema : SpodTriggerSchema = buildTriggerSchemaFromType(type);
			if(null == schema) throw new SpodError('Schema can not be null');
			
			// Create it because it doesn't exist
			internalCreateTrigger(schema, builder);
		}
		
		/**
		 * @private
		 */
		private function handleTriggerSQLErrorEventSignal(	event : SQLErrorEvent, 
															builder : ISpodTriggerBuilder
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
															type : Class, 
															ignoreIfExists : Boolean
															) : void
		{
			nativeSQLErrorEventSignal.remove(handleTriggerSQLErrorEventSignal);
			nativeSQLEventSchemaSignal.remove(handleTriggerSQLEventSchemaSignal);
			
			info('Handle trigger sql event', ignoreIfExists );
		}
		
		public function get createTriggerSignal() : ISignal
		{
			if(null == _createTriggerSignal) _createTriggerSignal = new Signal();
			return _createTriggerSignal;
		}
	}
}
