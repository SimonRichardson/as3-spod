package org.osflash.spod
{
	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;
	import org.osflash.signals.natives.NativeSignal;
	import org.osflash.spod.errors.SpodErrorEvent;

	import flash.data.SQLConnection;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	import flash.errors.IllegalOperationError;
	import flash.events.SQLErrorEvent;
	import flash.events.SQLEvent;
	/**
	 * @author Simon Richardson - me@simonrichardson.info
	 */
	public class SpodStatement
	{
		
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
		private var _statement : SQLStatement;
		
		/**
		 * @private
		 */
		private var _connection : SQLConnection;
		
		/**
		 * @privatea
		 */
		private var _result : SQLResult;
		
		/**
		 * @private
		 */
		private var _executed : Boolean;
		
		/**
		 * @private
		 */
		private var _completedSignal : ISignal;
		
		/**
		 * @private
		 */
		private var _errorSignal : ISignal;
		
		/**
		 * @private
		 */
		private var _nativeCompletedSignal : ISignal;
		
		/**
		 * @private
		 */
		private var _nativeErrorSignal : ISignal;
		
		public function SpodStatement(type : Class, object : SpodObject = null)
		{
			if(null == type) throw new ArgumentError('Type can not be null');
			_type = type;
			_object = object;
			
			_executed = false;
			
			_statement = new SQLStatement();
			// If we assign a type it restricts us to a limited api!
			// _statement.itemClass = type;
			
			_nativeCompletedSignal = new NativeSignal(_statement, SQLEvent.RESULT, SQLEvent);
			_nativeErrorSignal = new NativeSignal(_statement, SQLErrorEvent.ERROR, SQLErrorEvent);
		}
		
		public function execute() : void
		{
			if(null == _connection) throw new IllegalOperationError('No connection found');
			
			_executed = false;
			
			_nativeCompletedSignal.add(handleCompletedSignal);
			_nativeErrorSignal.add(handleErrorSignal);
			
			_statement.sqlConnection = _connection;
			_statement.execute();
		}
		
		private function handleCompletedSignal(event : SQLEvent) : void
		{
			_executed = true;
			
			const result : SQLResult = _statement.getResult();
			if(null == result)
			{	
				errorSignal.dispatch(this, new SpodErrorEvent('Result is null'));
				return;
			}
			else if(!result.complete) 
			{
				errorSignal.dispatch(this, new SpodErrorEvent('Result did not complete'));
				return;
			}
			
			_result = result;
			_completedSignal.dispatch(this);
		}
		
		private function handleErrorSignal(event : SQLErrorEvent) : void
		{
			event.stopImmediatePropagation();
			
			_executed = false;
			
			_errorSignal.dispatch(this, new SpodErrorEvent(event.text, event));
		}
		
		public function get type() : Class { return _type; }
		
		public function get object() : SpodObject { return _object; }
		
		public function get connection() : SQLConnection { return _connection; }
		public function set connection(value : SQLConnection) : void { _connection = value; }
		
		public function get query() : String { return _statement.text; }
		public function set query(value : String) : void { _statement.text = value; }
		
		public function get parameters() : Object { return _statement.parameters; }
		
		public function get executing() : Boolean { return _statement.executing; }
		
		public function get executed() : Boolean { return _executed; }
		
		public function get result() : SQLResult
		{
			if(null == _connection) throw new IllegalOperationError('No connection found');
			if(!_executed) throw new IllegalOperationError('SpodStatment not executed');
			
			return _result;
		}
		
		public function get completedSignal() : ISignal
		{
			if(null == _completedSignal) _completedSignal = new Signal(SpodStatement);
			return _completedSignal;
		}

		public function get errorSignal() : ISignal
		{
			if(null == _errorSignal) _errorSignal = new Signal(SpodStatement, SpodErrorEvent);
			return _errorSignal;
		}
	}
}
