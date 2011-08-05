package org.osflash.spod
{
	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;
	import org.osflash.signals.natives.NativeSignal;
	import org.osflash.spod.errors.SpodError;
	import org.osflash.spod.errors.SpodErrorEvent;

	import flash.data.SQLConnection;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
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
		private var _prefetch : int;
		
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
		private var _nextSignal : ISignal;
		
		/**
		 * @private
		 */
		private var _errorSignal : ISignal;
		
		/**
		 * @private
		 */
		private var _queryUpdateSignal : ISignal;
		
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
			_prefetch = -1;
			
			_executed = false;
			
			_statement = new SQLStatement();
			_statement.itemClass = type;
			
			_nativeCompletedSignal = new NativeSignal(_statement, SQLEvent.RESULT, SQLEvent);
			_nativeErrorSignal = new NativeSignal(_statement, SQLErrorEvent.ERROR, SQLErrorEvent);
		}
		
		public function execute(prefetch : int = -1) : void
		{
			if(null == _connection) throw new SpodError('No connection found');
			if(prefetch < -1 || prefetch == 0) throw new SpodError('Invalid prefetch value');
			
			_prefetch = prefetch;
			
			_executed = false;
			
			_nativeCompletedSignal.addOnce(handleCompletedSignal);
			_nativeErrorSignal.addOnce(handleErrorSignal);
			
			_statement.sqlConnection = _connection;
			_statement.execute(prefetch);
		}
		
		public function next() : void
		{
			if(null == _connection) throw new SpodError('No connection found');
			
			if(_executed)
			{
				_nativeCompletedSignal.addOnce(handleNextSignal);
				_nativeErrorSignal.addOnce(handleErrorSignal);

				_statement.next(prefetch);
			}
			else throw new SpodError('Transaction in process');
		}
		
		/**
		 * @private
		 */
		private function handleCompletedSignal(event : SQLEvent) : void
		{
			_executed = true;
			
			const result : SQLResult = _statement.getResult();
			if(null == result)
			{	
				errorSignal.dispatch(this, new SpodErrorEvent('Result is null'));
				return;
			}
			
			_result = result;
			_completedSignal.dispatch(this);
		}
		
		/**
		 * @private
		 */
		private function handleNextSignal(event : SQLEvent) : void
		{
			_executed = true;
			
			const result : SQLResult = _statement.getResult();
			if(null == result)
			{	
				errorSignal.dispatch(this, new SpodErrorEvent('Result is null'));
				return;
			}
			
			_result = result;
			_nextSignal.dispatch(this);
		}
		
		/**
		 * @private
		 */
		private function handleErrorSignal(event : SQLErrorEvent) : void
		{
			event.stopImmediatePropagation();
			
			_executed = false;
			
			const error : SpodError = new SpodError('Native SQLStatement Error');
			_errorSignal.dispatch(this, new SpodErrorEvent(event.text, error, event));
		}
		
		public function get type() : Class { return _type; }
		
		public function get object() : SpodObject { return _object; }
		
		public function get prefetch() : int { return _prefetch; }
		public function set prefetch(value : int) : void 
		{
			if(prefetch < -1 || prefetch == 0) throw new ArgumentError('Invalid prefetch value');
			
			_prefetch = value;
		}
		
		public function get connection() : SQLConnection { return _connection; }
		public function set connection(value : SQLConnection) : void { _connection = value; }
		
		public function get query() : String { return _statement.text; }
		public function set query(value : String) : void 
		{ 
			if(null == value || value.length < 1) throw new ArgumentError('Invalid query');
			_statement.text = value;
			
			if(null != _queryUpdateSignal) queryUpdateSignal.dispatch(value);
		}
		
		public function get parameters() : Object { return _statement.parameters; }
		
		public function get executing() : Boolean { return _statement.executing; }
		
		public function get executed() : Boolean { return _executed; }
		
		public function get result() : SQLResult
		{
			if(null == _connection) throw new SpodError('No connection found');
			if(!_executed) throw new SpodError('SpodStatment not executed');
			
			return _result;
		}
		
		public function get completedSignal() : ISignal
		{
			if(null == _completedSignal) _completedSignal = new Signal(SpodStatement);
			return _completedSignal;
		}
		
		public function get nextSignal() : ISignal
		{
			if(null == _nextSignal) _nextSignal = new Signal(SpodStatement);
			return _nextSignal;
		}

		public function get errorSignal() : ISignal
		{
			if(null == _errorSignal) _errorSignal = new Signal(SpodStatement, SpodErrorEvent);
			return _errorSignal;
		}
		
		public function get queryUpdateSignal() : ISignal
		{
			if(null == _queryUpdateSignal) _queryUpdateSignal = new Signal(String);
			return _queryUpdateSignal;
		}
	}
}
