package org.osflash.spod
{
	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;
	import org.osflash.spod.builders.ISpodStatementBuilder;
	import org.osflash.spod.builders.RawStatementBuilder;
	import org.osflash.spod.builders.expressions.ISpodExpression;
	import org.osflash.spod.builders.table.DeleteWhereStatementBuilder;
	import org.osflash.spod.builders.table.InsertStatementBuilder;
	import org.osflash.spod.builders.table.SelectAllStatementBuilder;
	import org.osflash.spod.builders.table.SelectByIdStatementBuilder;
	import org.osflash.spod.builders.table.SelectCountStatementBuilder;
	import org.osflash.spod.builders.table.SelectWhereStatementBuilder;
	import org.osflash.spod.errors.SpodError;
	import org.osflash.spod.errors.SpodErrorEvent;
	import org.osflash.spod.schema.ISpodColumnSchema;
	import org.osflash.spod.schema.SpodTableSchema;

	import flash.data.SQLResult;
	import flash.errors.IllegalOperationError;
	import flash.utils.Dictionary;

	/**
	 * @author Simon Richardson - me@simonrichardson.info
	 */
	public class SpodTable
	{
		
		use namespace spod_namespace;
		
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
		
		/**
		 * @private
		 */
		private var _selectSignal : ISignal;
		
		/**
		 * @private
		 */
		private var _selectWhereSignal : ISignal;
		
		/**
		 * @private
		 */
		private var _selectAllSignal : ISignal;
		
		/**
		 * @private
		 */
		private var _countSignal : ISignal;
		
		/**
		 * @private
		 */
		private var _removeWhereSignal : ISignal;
				
		public function SpodTable(schema : SpodTableSchema, manager : SpodManager)
		{
			if(null == schema) throw new ArgumentError('Schema can not be null');
			if(null == manager) throw new ArgumentError('SpodManager can not be null');
			
			_schema = schema;
			_manager = manager;
			
			_exists = false;
			
			_rows = new Dictionary();
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
		
		public function insert(object : SpodObject) : void
		{
			if(null == object) throw new ArgumentError('SpodObject can not be null');
			if(!(object is _schema.type)) throw new ArgumentError('SpodObejct mistmatch');
			
			const builder : ISpodStatementBuilder = new InsertStatementBuilder(_schema, object);
			const statement : SpodStatement = builder.build();
			
			statement.completedSignal.addOnce(handleInsertCompletedSignal);
			statement.errorSignal.addOnce(handleInsertErrorSignal);
			
			if(_manager.queuing) _manager.queue.add(statement);
			else _manager.executioner.add(new SpodStatementQueue(statement));
		}
		
		public function select(id : int) : void
		{
			if(isNaN(id)) throw new ArgumentError('id can not be NaN');
			if(!_schema.isValidSelectIdentifier()) throw new SpodError('Unable to select by id, ' + 
										'where a custom identifier is used and is not type of int');
			
			const builder : ISpodStatementBuilder = new SelectByIdStatementBuilder(_schema, id);
			const statement : SpodStatement = builder.build();
			
			statement.completedSignal.addOnce(handleSelectCompletedSignal);
			statement.errorSignal.addOnce(handleSelectErrorSignal);
			
			if(_manager.queuing) _manager.queue.add(statement);
			else _manager.executioner.add(new SpodStatementQueue(statement));
		}
		
		public function selectWhere(...rest) : void
		{
			if(null == rest) throw new ArgumentError('Rest can not be null');
			
			var prefetch : int;
			var expressions : Vector.<ISpodExpression>;
			if(rest[0] is int)
			{
				prefetch = rest[0];
				if(rest[1] is Vector) expressions = Vector.<ISpodExpression>(rest[1]);
				else expressions = Vector.<ISpodExpression>(rest);
			}
			else if(rest[0] is Vector)
			{
				prefetch = -1;
				if(rest[0] is Vector) expressions = Vector.<ISpodExpression>(rest[0]);
				else expressions = Vector.<ISpodExpression>(rest);
			}
			else expressions = Vector.<ISpodExpression>(rest);
			
			
			const builder : ISpodStatementBuilder = new SelectWhereStatementBuilder(	_schema, 
																						expressions
																						);
			const statement : SpodStatement = builder.build();
			statement.prefetch = prefetch;
			
			statement.completedSignal.addOnce(handleSelectWhereCompletedSignal);
			statement.errorSignal.addOnce(handleSelectWhereErrorSignal);
			
			if(_manager.queuing) _manager.queue.add(statement);
			else _manager.executioner.add(new SpodStatementQueue(statement));
		}
		
		public function selectAll(prefetch : int = -1) : void
		{
			const builder : ISpodStatementBuilder = new SelectAllStatementBuilder(_schema);
			const statement : SpodStatement = builder.build();
			statement.prefetch = prefetch;
			
			statement.completedSignal.addOnce(handleSelectAllCompletedSignal);
			statement.errorSignal.addOnce(handleSelectAllErrorSignal);
			
			if(_manager.queuing) _manager.queue.add(statement);
			else _manager.executioner.add(new SpodStatementQueue(statement));
		}
		
		public function count() : void
		{
			const builder : ISpodStatementBuilder = new SelectCountStatementBuilder(_schema);
			const statement : SpodStatement = builder.build();
			
			statement.completedSignal.addOnce(handleCountCompletedSignal);
			statement.errorSignal.addOnce(handleCountErrorSignal);
			
			if(_manager.queuing) _manager.queue.add(statement);
			else _manager.executioner.add(new SpodStatementQueue(statement));
		}
		
		public function removeWhere(...rest) : void
		{
			if(null == rest) throw new ArgumentError('Rest can not be null');
			
			const expressions : Vector.<ISpodExpression> = (rest[0] is Vector) ? 
															rest[0] 
															: 
															Vector.<ISpodExpression>(rest);
															
			const builder : ISpodStatementBuilder = new DeleteWhereStatementBuilder(	_schema, 
																						expressions
																						);
			const statement : SpodStatement = builder.build();
			
			statement.completedSignal.addOnce(handleRemoveWhereCompletedSignal);
			statement.errorSignal.addOnce(handleRemoveWhereErrorSignal);
			
			if(_manager.queuing) _manager.queue.add(statement);
			else _manager.executioner.add(new SpodStatementQueue(statement));
		}
		
		/**
		 * @private
		 */
		spod_namespace function executeQuery(string : String, params : Object = null) : void
		{
			const parameters : Object = params || {};
			
			const builder : ISpodStatementBuilder = new RawStatementBuilder(string, parameters);
			const statement : SpodStatement = builder.build();
			
			statement.completedSignal.addOnce(handleQueryCompletedSignal);
			statement.errorSignal.addOnce(handleQueryErrorSignal);
			
			if(_manager.queuing) _manager.queue.add(statement);
			else _manager.executioner.add(new SpodStatementQueue(statement));
		}
		
		/**
		 * @private
		 */
		spod_namespace function removeRow(value : SpodTableRow) : void
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
		private function parseSelectStatementResult(result : SQLResult) : Vector.<SpodObject>
		{
			if(null == _schema) throw new IllegalOperationError('No valid schema');
			
			const type : Class = _schema.type;
			if(null == type) throw new IllegalOperationError('No valid type');
			
			const objects : Vector.<SpodObject> = new Vector.<SpodObject>();
			
			const total : int = result.data.length;
			for(var i : int = 0; i<total; i++)
			{
				var object : SpodObject;
				if(_schema.customColumnNames)
				{
					const rawObject : Object = result.data[i];
					
					object = new type();
					for(var j : String in rawObject)
					{
						if(j in object) object[j] = rawObject[j];
						else 
						{
							// This is what maps back to the original name!
							const columnSchema : ISpodColumnSchema = _schema.getColumnByName(j);
							if(null != columnSchema)
							{
								const columnName : String = columnSchema.name;
								if(columnName in object) object[columnName] = rawObject[j];
							}
						}
					}
				}
				else object = result.data[i] as SpodObject;
				
				if(null == object) throw new IllegalOperationError('Invalid SpodObject');
				if(!(object is type)) throw new IllegalOperationError('Invalid type');
				
				const identifierColumn : ISpodColumnSchema = _schema.getColumnByName(_schema.identifier);
				const identifierName : String = identifierColumn.name;
				const id : int = object[identifierName];
				if(isNaN(id)) throw new IllegalOperationError('Invalid identifier');
				
				const row : SpodTableRow = new SpodTableRow(this, type, object, _manager);
				if(null != _rows[id])
				{
					const prev : SpodTableRow = _rows[id];
					prev.removeSignal.dispatch(prev.object);
				}
				
				// Create the correct inject references
				object.tableRow = row;
				
				_rows[id] = row;
				
				objects.push(object);
			}
			
			return objects;
		}
		
		/**
		 * @private
		 */
		private function handleInsertCompletedSignal(statement : SpodStatement) : void
		{
			statement.errorSignal.remove(handleInsertErrorSignal);
			
			const rowId : int = statement.result.lastInsertRowID;
			if(isNaN(rowId)) throw new IllegalOperationError('Invalid row id');
			
			const object : SpodObject = statement.object;
			if(null == object) throw new IllegalOperationError('Invalid statement object');
			
			const row : SpodTableRow = new SpodTableRow(this, _schema.type, object, _manager);
			
			// Inject the correct identifier
			const identifierAltName : String = _schema.identifier;
			const identifierColumn : ISpodColumnSchema = _schema.getColumnByName(identifierAltName);
			const identifierName : String = identifierColumn.name;
			
			if(_schema.isValidSelectIdentifier() && identifierName in object)
				object[identifierName] = rowId;
			
			// Create the correct inject references
			object.tableRow = row;
			
			// Push in to the row
			_rows[rowId] = row;
			
			insertSignal.dispatch(object);
			row.insertSignal.dispatch(object);
		}
		
		/**
		 * @private
		 */
		private function handleInsertErrorSignal(	statement : SpodStatement, 
													event : SpodErrorEvent
													) : void
		{
			statement.completedSignal.remove(handleInsertCompletedSignal);
			
			_manager.errorSignal.dispatch(event);
		}
		
		/**
		 * @private
		 */
		private function handleSelectCompletedSignal(statement : SpodStatement) : void
		{
			statement.errorSignal.remove(handleSelectErrorSignal);
			
			const result : SQLResult = statement.result;
			if(	null == result || 
				null == result.data || 
				result.data.length == 0
				)
			{
				selectSignal.dispatch(null);	
			}
			else
			{
				const objects :  Vector.<SpodObject> = parseSelectStatementResult(result);
				if(objects.length > 1) throw new SpodError('Unexpected objects found, expected ' +
																	'1 got ' + objects.length);
				selectSignal.dispatch(objects[0]);
			}
		}
		
		/**
		 * @private
		 */
		private function handleSelectErrorSignal(	statement : SpodStatement, 
													event : SpodErrorEvent
													) : void
		{
			statement.completedSignal.remove(handleSelectCompletedSignal);
			
			_manager.errorSignal.dispatch(event);
		}
		
		/**
		 * @private
		 */
		private function handleSelectWhereCompletedSignal(	statement : SpodStatement, 
															prefetched : Vector.<SpodObject> = null
															) : void
		{
			statement.errorSignal.remove(handleSelectWhereErrorSignal);
			
			const result : SQLResult = statement.result;
			if(	null == result || 
				null == result.data 
				)
			{
				selectWhereSignal.dispatch(new Vector.<SpodObject>());	
			}
			else if(result.data.length == 0) selectWhereSignal.dispatch(prefetched);
			else
			{
				const objects : Vector.<SpodObject> = parseSelectStatementResult(result);
				if(!result.complete)
				{
					const params : Vector.<SpodObject> = prefetched.concat(objects);
					statement.nextSignal.addOnce(handleSelectWhereCompletedSignal).params = [params];
					statement.errorSignal.addOnce(handleSelectWhereErrorSignal);
					statement.next();
				}
				else
				{
					selectWhereSignal.dispatch(objects);
				}
			}
		}
		
		/**
		 * @private
		 */
		private function handleSelectWhereErrorSignal(	statement : SpodStatement, 
														event : SpodErrorEvent
														) : void
		{
			statement.completedSignal.remove(handleSelectWhereCompletedSignal);
			
			_manager.errorSignal.dispatch(event);
		}
		
		/**
		 * @private
		 */
		private function handleSelectAllCompletedSignal(	statement : SpodStatement, 
															prefetched : Vector.<SpodObject> = null
															) : void
		{
			statement.errorSignal.remove(handleSelectAllErrorSignal);
			
			const result : SQLResult = statement.result;
			if(	null == result || 
				null == result.data
				)
			{
				selectAllSignal.dispatch(new Vector.<SpodObject>());	
			}
			else if(result.data.length == 0) selectAllSignal.dispatch(prefetched);
			else
			{
				const objects : Vector.<SpodObject> = parseSelectStatementResult(result);
				if(!result.complete)
				{
					const params : Vector.<SpodObject> = prefetched.concat(objects);
					statement.nextSignal.addOnce(handleSelectAllCompletedSignal).params = [params];
					statement.errorSignal.addOnce(handleSelectAllErrorSignal);
					statement.next();
				}
				else
				{
					selectAllSignal.dispatch(objects);
				}
			}
		}
		
		/**
		 * @private
		 */
		private function handleSelectAllErrorSignal(	statement : SpodStatement, 
														event : SpodErrorEvent
														) : void
		{
			statement.completedSignal.remove(handleSelectAllCompletedSignal);
			
			_manager.errorSignal.dispatch(event);
		}
		
		/**
		 * @private
		 */
		private function handleCountCompletedSignal(	statement : SpodStatement) : void
		{
			statement.errorSignal.remove(handleCountErrorSignal);
			
			const result : SQLResult = statement.result;
			if(	null == result || 
				null == result.data || 
				result.data.length == 0
				)
			{
				countSignal.dispatch(this, 0);	
			}
			else
			{
				if(statement.result.data.length > 1) 
					throw new IllegalOperationError('Count result mismatch');
				
				const spodObjects : SpodObjects = statement.result.data[0] as SpodObjects;
				if(null == spodObjects) throw new IllegalOperationError('Invalid Object');
				
				countSignal.dispatch(this, spodObjects.numObjects);
			}
		}
		
		/**
		 * @private
		 */
		private function handleCountErrorSignal(	statement : SpodStatement, 
													event : SpodErrorEvent
													) : void
		{
			statement.completedSignal.remove(handleCountCompletedSignal);
			
			_manager.errorSignal.dispatch(event);
		}
		
		/**
		 * @private
		 */
		private function handleRemoveWhereCompletedSignal(statement : SpodStatement) : void
		{
			statement.errorSignal.remove(handleRemoveWhereErrorSignal);
			
			const result : SQLResult = statement.result;
			removeWhereSignal.dispatch(result.rowsAffected);	
		}
		
		/**
		 * @private
		 */
		private function handleRemoveWhereErrorSignal(	statement : SpodStatement, 
														event : SpodErrorEvent
														) : void
		{
			statement.completedSignal.remove(handleRemoveWhereCompletedSignal);
			
			_manager.errorSignal.dispatch(event);
		}
		
		/**
		 * @private
		 */
		private function handleQueryCompletedSignal(statement : SpodStatement) : void
		{
			statement.errorSignal.remove(handleQueryErrorSignal);
			
			throw new Error('Missing Implementation');	
		}
		
		/**
		 * @private
		 */
		private function handleQueryErrorSignal(	statement : SpodStatement, 
													event : SpodErrorEvent
													) : void
		{
			statement.completedSignal.remove(handleQueryCompletedSignal);
			
			_manager.errorSignal.dispatch(event);
		}
		
		public function get exists() : Boolean { return _exists; }
		public function set exists(value : Boolean) : void { _exists = value; }

		public function get schema() : SpodTableSchema { return _schema; }
		
		public function get name() : String { return _schema.name; }
		
		public function get manager() : SpodManager { return _manager; }

		spod_namespace function get rows() : Dictionary { return _rows; }
		
		public function get insertSignal() : ISignal
		{
			if(null == _insertSignal) _insertSignal = new Signal(SpodObject);
			return _insertSignal;
		}
		
		public function get selectSignal() : ISignal
		{
			if(null == _selectSignal) _selectSignal = new Signal(SpodObject);
			return _selectSignal;
		}
		
		public function get selectWhereSignal() : ISignal
		{
			if(null == _selectWhereSignal) _selectWhereSignal = new Signal(Vector.<SpodObject>);
			return _selectWhereSignal;
		}
		
		public function get selectAllSignal() : ISignal
		{
			if(null == _selectAllSignal) _selectAllSignal = new Signal(Vector.<SpodObject>);
			return _selectAllSignal;
		}
		
		public function get countSignal() : ISignal
		{
			if(null == _countSignal) _countSignal = new Signal(SpodTable, int);
			return _countSignal;
		}
		
		public function get removeWhereSignal() : ISignal
		{
			if(null == _removeWhereSignal) _removeWhereSignal = new Signal(int);
			return _removeWhereSignal;
		}
	}
}
