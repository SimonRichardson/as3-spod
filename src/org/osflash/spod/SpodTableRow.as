package org.osflash.spod
{
	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;
	import org.osflash.spod.builders.ISpodStatementBuilder;
	import org.osflash.spod.builders.UpdateStatementBuilder;
	import org.osflash.spod.errors.SpodErrorEvent;
	import org.osflash.spod.schema.SpodTableSchema;

	import flash.errors.IllegalOperationError;
	/**
	 * @author Simon Richardson - me@simonrichardson.info
	 */
	public class SpodTableRow
	{
		
		/**
		 * @private
		 */
		private var _table : SpodTable;
		
		/**
		 * @private
		 */
		private var _type : Class;
		
		/**
		 * @private
		 */
		private var _object : SpodObject;
		
		/**
		 * @private
		 */
		private var _manager : SpodManager;
		
		/**
		 * @private
		 */
		private var _updateSignal : ISignal;
		
		public function SpodTableRow(	table : SpodTable, 
										type : Class, 
										object : SpodObject, 
										manager : SpodManager
										)
		{
			if(null == table) throw new ArgumentError('Table can not be null');
			if(null == type) throw new ArgumentError('Type can not be null');
			if(null == object) throw new ArgumentError('Object can not be null');
			if(null == manager) throw new ArgumentError('Manager can not be null');
			
			_table = table;
			_type = type;
			_object = object;
			_manager = manager;
		}
		
		public function update() : void
		{
			const schema : SpodTableSchema = _table.schema;
			const builder : ISpodStatementBuilder = new UpdateStatementBuilder(schema, object);
			const statement : SpodStatement = builder.build();
			
			statement.completedSignal.add(handleUpdateCompletedSignal);
			statement.errorSignal.add(handleUpdateErrorSignal);
			
			_manager.executioner.add(statement);
		}
		
		/**
		 * @private
		 */
		private function handleUpdateCompletedSignal(statement : SpodStatement) : void
		{
			statement.completedSignal.remove(handleUpdateCompletedSignal);
			statement.errorSignal.remove(handleUpdateErrorSignal);
			
			if(object != statement.object) throw new IllegalOperationError('SpodObject mismatch');
			
			updateSignal.dispatch(_object);
		}
		
		/**
		 * @private
		 */
		private function handleUpdateErrorSignal(	statement : SpodStatement, 
													event : SpodErrorEvent
													) : void
		{
			statement.completedSignal.remove(handleUpdateCompletedSignal);
			statement.errorSignal.remove(handleUpdateErrorSignal);
			
			_manager.errorSignal.dispatch(event);
		}

		public function get object() : SpodObject { return _object; }
		
		public function get table() : SpodTable { return _table; }
		
		public function get updateSignal() : ISignal
		{
			if(null == _updateSignal) _updateSignal = new Signal(SpodObject);
			return _updateSignal;
		}
	}
}
