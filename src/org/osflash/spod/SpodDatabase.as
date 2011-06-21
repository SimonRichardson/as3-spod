package org.osflash.spod
{
	import flash.data.SQLStatement;
	import org.osflash.spod.builders.ISQLStatementBuilder;
	import org.osflash.spod.builders.SQLCreateStatementBuilder;
	import org.osflash.spod.schema.SpodTableSchema;
	import org.osflash.spod.utils.getDatabaseNameFromClassName;

	import flash.utils.describeType;
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public class SpodDatabase
	{
		
		/**
		 * @private
		 */
		private var _manager : SpodManager;
		
		/**
		 * @private
		 */
		private var _schema : SpodTableSchema;
		
		public function SpodDatabase(manager : SpodManager)
		{
			if(null == manager) throw new ArgumentError('Manager can not be null');
			_manager = manager;	
		}
		
		public function create(type : Class) : void
		{
			if(null == type) throw new ArgumentError('Type can not be null');
			
			const description : XML = describeType(type);
			const tableName : String = getDatabaseNameFromClassName(description.@name);
					
			// TODO : Check if the table already exists, if it does then load it.
			// TODO : Validate the current database against the class
			
			_schema = new SpodTableSchema(tableName);
			
			for each(var variable : XML in description..variable)
			{
				const variableName : String = variable.@name;
				const variableType : String = variable.@type;
				
				_schema.createByType(variableName, variableType);
			}
			
			const builder : ISQLStatementBuilder = new SQLCreateStatementBuilder();
			const sql : String = builder.build(_schema);
			
			// TODO : push into a queue
			const query : SQLStatement = new SQLStatement();
			query.sqlConnection = _manager.connection;
			query.text = sql;
			query.itemClass = type;
			query.execute();
		}
	}
}
