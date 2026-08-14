module eval

import ast
import lexer
import object
import parser

fn quote_check_eval(input string) object.Object {
	l := lexer.new(input)
	mut p := parser.new(l)
	program := p.parse_program()

	errs := p.errors()
	assert errs.len == 0, 'input ${input} has errors: \n${errs.join('\n')}'

	env := object.new_environment()
	return eval(ast.Node(program), env) or { nil_value }
}

fn test_quote_unquote() {
	tests := [
		['quote(unquote(4))', '4'],
		['quote(unquote(4 + 4))', '8'],
		['quote(8 + unquote(4 + 4))', '(8 + 8)'],
		['quote(unquote(4 + 4) + 8)', '(8 + 8)'],
		['let foobar = 8; quote(foobar)', 'foobar'],
		['let foobar = 8; quote(unquote(foobar))', '8'],
		['quote(unquote(true))', 'true'],
		['quote(unquote(true == false))', 'false'],
		['quote(unquote(quote(4 + 4)))', '(4 + 4)'],
		['let quotedInfixExpr = quote(4 + 4);
			   quote(unquote(4 + 4) + unquote(quotedInfixExpr))',
			'(8 + (4 + 4))'],
	]

	for tt in tests {
		evaluated := quote_check_eval(tt[0])
		q := evaluated as object.Quote
		assert q.node.str() == tt[1]
	}
}
