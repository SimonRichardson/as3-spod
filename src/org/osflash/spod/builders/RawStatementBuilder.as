package org.osflash.spod.builders
{
	import org.osflash.spod.SpodStatement;
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public class RawStatementBuilder implements ISpodStatementBuilder
	{
		
		/**
		 * @private
		 */
		private var _query : String;
		
		/**
		 * @private
		 */
		private var _parameters : Object;
		
		public function RawStatementBuilder(query : String, parameters : Object)
		{
			if(null == query) throw new ArgumentError('Query can not be null');
			_query = query;
			_parameters = parameters;
		}

		/**
		 * @inheritDoc
		 */
		public function build() : SpodStatement
		{			
			const statement : SpodStatement = new SpodStatement(Object);
			statement.query = _query;
			
			for(var i : String in _parameters)
			{
				statement.parameters[i] = _parameters[i];
			}
			
			return statement;
		}
	}
}
