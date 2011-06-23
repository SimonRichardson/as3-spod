package org.osflash.spod
{
	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;
	import org.osflash.spod.builders.ISpodStatementBuilder;
	import org.osflash.spod.builders.InsertStatementBuilder;
	import org.osflash.spod.errors.SpodErrorEvent;
	import org.osflash.spod.schema.SpodTableSchema;

	import flash.errors.IllegalOperationError;
	import flash.utils.Dictionary;
	/**
	 * @author Simon Richardson - me@simonrichardson.info
	 */
	public class SpodTable
	{
		
		/**
		 * @private
		 */
		private var _exists : Boolean;
		
		/**
		 * @private
		 */
		private var _schema : SpodTableSchema;
		
		/**
		 * @private
		 */
		private var _manager : SpodManager;
		
		/**
		 * @private
		 */
		private var _rows : Dictionary;
		
		/**
		 * @private
		 */
		private var _insertSignal : ISignal;
		
		public function SpodTable(schema : SpodTableSchema, manager : SpodManager)
		{
			if(null == schema) throw new ArgumentError('Schema can not be null');
			if(null == manager) throw new ArgumentError('SpodManager can not be null');
			
			_schema = schema;
			_manager = manager;
			
			_exists = false;
			
			_rows = new Dictionary();
		}
		
		public function insert(object : SpodObject) : void
		{
			if(null == object) throw new ArgumentError('SpodObject can not be null');
			if(!(object is _schema.type)) throw new ArgumentError('SpodObejct mistmatch');
			
			const builder : ISpodStatementBuilder = new InsertStatementBuilder(_schema, object);
			const statement : SpodStatement = builder.build();
			
			statement.completedSignal.add(handleInsertCompletedSignal);
			statement.errorSignal.add(handleInsertErrorSignal);
			
			_manager.executioner.add(statement);
		}
		
		/**
		 * @private
		 */
		internal function removeRow(value : SpodTableRow) : void
		{
			for(var id : String in _rows)
			{
				if(_rows[id] == value)
				{
					_rows[id] = null;
					delete _rows[id];
					
					return;
				}
			}
			
			throw new Error('SpodTableRow does not exist');
		}
		
		/**
		 * @private
		 */
		private function handleInsertCompletedSignal(statement : SpodStatement) : void
		{
			statement.completedSignal.remove(handleInsertCompletedSignal);
			statement.errorSignal.remove(handleInsertErrorSignal);
			
			const rowId : int = statement.result.lastInsertRowID;
			if(isNaN(rowId)) throw new IllegalOperationError('Invalid row id');
			
			const object : SpodObject = statement.object;
			if(null == object) throw new IllegalOperationError('Invalid statement object');

			const row : SpodTableRow = new SpodTableRow(this, _schema.type, object, _manager);
			
			// Inject the correct id
			if('id' in object) object['id'] = rowId;
			
			// Create the correct inject references
			use namespace spod_namespace;
			object.table = this;
			object.tableRow = row;
			
			// Push in to the row
			_rows[rowId] = row;
			
			insertSignal.dispatch(row);
		}
		
		/**
		 * @private
		 */
		private function handleInsertErrorSignal(	statement : SpodStatement, 
													event : SpodErrorEvent
													) : void
		{
			statement.completedSignal.remove(handleInsertCompletedSignal);
			statement.errorSignal.remove(handleInsertErrorSignal);
			
			_manager.errorSignal.dispatch(event);
		}
		
		public function get exists() : Boolean { return _exists; }
		public function set exists(value : Boolean) : void { _exists = value; }

		public function get schema() : SpodTableSchema { return _schema; }
		
		public function get name() : String { return _schema.name; }

		spod_namespace function get rows() : Dictionary { return _rows; }
		
		public function get insertSignal() : ISignal
		{
			if(null == _insertSignal) _insertSignal = new Signal(SpodTableRow);
			return _insertSignal;
		}
	}
}
