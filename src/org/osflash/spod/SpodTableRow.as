package org.osflash.spod
{
	import org.osflash.spod.types.SpodDate;
	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;
	import org.osflash.spod.builders.DeleteStatementBuilder;
	import org.osflash.spod.builders.ISpodStatementBuilder;
	import org.osflash.spod.builders.SelectStatementBuilder;
	import org.osflash.spod.builders.UpdateStatementBuilder;
	import org.osflash.spod.errors.SpodErrorEvent;
	import org.osflash.spod.schema.SpodTableColumnSchema;
	import org.osflash.spod.schema.SpodTableSchema;
	import org.osflash.spod.types.SpodInt;

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
		private var _insertSignal : ISignal;
		
		/**
		 * @private
		 */
		private var _updateSignal : ISignal;
		
		/**
		 * @private
		 */
		private var _syncSignal : ISignal;
		
		/**
		 * @private
		 */
		private var _removeSignal : ISignal;
		
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
		
		public function sync() : void
		{
			const schema : SpodTableSchema = _table.schema;
			const builder : ISpodStatementBuilder = new SelectStatementBuilder(schema, object);
			const statement : SpodStatement = builder.build();
			
			statement.completedSignal.add(handleSyncCompletedSignal);
			statement.errorSignal.add(handleSyncErrorSignal);
			
			_manager.executioner.add(statement);
		}
		
		public function remove() : void
		{
			const schema : SpodTableSchema = _table.schema;
			const builder : ISpodStatementBuilder = new DeleteStatementBuilder(schema, object);
			const statement : SpodStatement = builder.build();
			
			statement.completedSignal.add(handleRemoveCompletedSignal);
			statement.errorSignal.add(handleRemoveErrorSignal);
			
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
				
		/**
		 * @private
		 */
		private function handleSyncCompletedSignal(statement : SpodStatement) : void
		{
			statement.completedSignal.remove(handleSyncCompletedSignal);
			statement.errorSignal.remove(handleSyncErrorSignal);
			
			if(null == statement.result) throw new IllegalOperationError('Result is null');
			
			const data : Array = statement.result.data;
			if(null == data || data.length != 1) throw new IllegalOperationError('Result mismatch');
			
			if(null == table) throw new IllegalOperationError('Invalid table');
			const schema : SpodTableSchema = table.schema;
			if(null == schema) throw new IllegalOperationError('Invalid table schema');
			
			const object : SpodObject = data[0] as SpodObject;
			if(null == object) throw new IllegalOperationError('Object mismatch');
			
			var updated : Boolean = false;
			
			const total : int = schema.columns.length;
			if(total == 0) throw new IllegalOperationError('Invalid number of columns');
			for(var i : int = 0; i<total; i++)
			{
				const column : SpodTableColumnSchema = schema.columns[i];
				const columnName : String = column.name;
				if(columnName == 'id' && column.type == SpodInt)
				{
					if(_object['id'] != object['id']) 
						throw new IllegalOperationError('Object id mismatch');
				}
				else
				{
					if(column.type == SpodDate)
					{
						// Work out how to do a date update
						const spodDate : Date = _object[columnName];
						const objectDate : Date = object[columnName];
						if(null == spodDate && null == objectDate) 
						{
							// both are null, continue 
							continue;
						}
						else if(null == spodDate && null != objectDate)
							_object[columnName] = object[columnName];
						else if(null != spodDate && null == objectDate)
							_object[columnName] = null;
						else if(spodDate.valueOf() != objectDate.valueOf()) 
							spodDate.setTime(objectDate.valueOf());
						else 
						{
							// Nothing has been updated so we'll move on.
							continue;
						}
						
						updated = true;
					}
					else
					{
						// We're just any time, do a overwrite
						if(_object[columnName] != object[columnName]) 
						{
							_object[columnName] = object[columnName];
							updated = true;
						}
					}
				}
			}
			
			syncSignal.dispatch(_object, updated);
		}
		
		/**
		 * @private
		 */
		private function handleSyncErrorSignal(	statement : SpodStatement, 
												event : SpodErrorEvent
												) : void
		{
			statement.completedSignal.remove(handleSyncCompletedSignal);
			statement.errorSignal.remove(handleSyncErrorSignal);
			
			_manager.errorSignal.dispatch(event);
		}
		
		/**
		 * @private
		 */
		private function handleRemoveCompletedSignal(statement : SpodStatement) : void
		{
			statement.completedSignal.remove(handleRemoveCompletedSignal);
			statement.errorSignal.remove(handleRemoveErrorSignal);
			
			if(object != statement.object) throw new IllegalOperationError('SpodObject mismatch');

			use namespace spod_namespace;
			
			_table.removeRow(this);
			
			removeSignal.dispatch(_object);
		}
		
		/**
		 * @private
		 */
		private function handleRemoveErrorSignal(	statement : SpodStatement, 
													event : SpodErrorEvent
													) : void
		{
			statement.completedSignal.remove(handleRemoveCompletedSignal);
			statement.errorSignal.remove(handleRemoveErrorSignal);
			
			_manager.errorSignal.dispatch(event);
		}

		public function get object() : SpodObject { return _object; }
		
		public function get table() : SpodTable { return _table; }
		
		public function get insertSignal() : ISignal
		{
			if(null == _insertSignal) _insertSignal = new Signal(SpodObject);
			return _insertSignal;
		}
		
		public function get updateSignal() : ISignal
		{
			if(null == _updateSignal) _updateSignal = new Signal(SpodObject);
			return _updateSignal;
		}
		
		public function get syncSignal() : ISignal
		{
			if(null == _syncSignal) _syncSignal = new Signal(SpodObject);
			return _syncSignal;
		}
		
		public function get removeSignal() : ISignal
		{
			if(null == _removeSignal) _removeSignal = new Signal(SpodObject);
			return _removeSignal;
		}
	}
}
