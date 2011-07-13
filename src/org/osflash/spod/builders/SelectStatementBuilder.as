package org.osflash.spod.builders
{
	import org.osflash.spod.SpodObject;
	import org.osflash.spod.SpodStatement;
	import org.osflash.spod.errors.SpodError;
	import org.osflash.spod.schema.SpodTableColumnSchema;
	import org.osflash.spod.schema.SpodTableSchema;

	import flash.utils.getQualifiedClassName;
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public class SelectStatementBuilder implements ISpodStatementBuilder
	{

		/**
		 * @private
		 */
		private var _schema : SpodTableSchema;
		
		/**
		 * @private
		 */
		private var _object : SpodObject;

		/**
		 * @private
		 */
		private var _buffer : Vector.<String>;

		public function SelectStatementBuilder(schema : SpodTableSchema, object : SpodObject)
		{
			if(null == schema) throw new ArgumentError('SpodTableSchema can not be null');
			if(null == object) throw new ArgumentError('SpodObject can not be null');
			
			_schema = schema;
			_object = object;
			
			_buffer = new Vector.<String>();
		}

		public function build() : SpodStatement
		{
			if(_schema is SpodTableSchema)
			{
				const tableSchema : SpodTableSchema = SpodTableSchema(_schema);
				const columns : Vector.<SpodTableColumnSchema> = tableSchema.columns.reverse();
				const total : int = columns.length;
				
				if(total == 0) throw new SpodError('Invalid columns length');
				
				_buffer.length = 0;
				
				_buffer.push('SELECT ');
				
				for(var i : int = 0; i<total; i++)
				{
					const column : SpodTableColumnSchema = columns[i];
					const columnName : String = column.name;
					
					_buffer.push('`' + columnName + '`');
					_buffer.push(', ');
				}
				
				_buffer.pop();
				
				_buffer.push(' FROM ');
				_buffer.push('`' + _schema.name + '`');
				_buffer.push(' WHERE ');
				_buffer.push('`' + _schema.identifier + '`=:id');
				
				const statement : SpodStatement = new SpodStatement(tableSchema.type, _object);
				
				if(_schema.identifier in _object)
				{
					// Check the new identifier
					const type : String = getQualifiedClassName(_object[_schema.identifier]);
					if(type == 'int' || type == 'uint' || type == 'Number')
					{
						if(isNaN(_object[_schema.identifier])) 
							throw new SpodError('Given object identifier value is NaN');
					}
					else if(type == 'String')
					{
						if(	null == _object[_schema.identifier])
							throw new SpodError('Given object identifier value is null');
						else if(	String(_object[_schema.identifier]).length == 0 ||
									String(_object[_schema.identifier]) == ''
									)
							throw new SpodError('Given object identifier value is empty');
					}
					else
					{
						if(	null == _object[_schema.identifier])
							throw new SpodError('Given object identifier value is null');
					}
					
					// We've passed the verification
					statement.parameters[':id'] = _object[_schema.identifier];
				}
				else throw new SpodError('Unable to locate identifier in object');
				
				// Make the query
				statement.query = _buffer.join('');
				
				return statement;
				
			} else throw new ArgumentError(getQualifiedClassName(_schema) + ' is not supported');
		}
	}
}
