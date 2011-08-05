package org.osflash.spod.utils
{
	import org.osflash.spod.builders.expressions.SpodExpressionType;
	import org.osflash.spod.builders.expressions.ISpodExpression;
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public function getNextWhereExpression(	expressions : Vector.<ISpodExpression>, 
											start : int = 0
											) : ISpodExpression
	{
		const total : int = expressions.length;
		for(var i : int = start; i < total; i++)
		{
			const expression : ISpodExpression = expressions[i];
			if(expression.type == SpodExpressionType.WHERE) return expression;
		}
		return null;
	}
}
