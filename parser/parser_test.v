module parser

import ast
import lexer

fn check_parser_errors(p Parser) {
	errs := p.errors()
	assert errs.len == 0, 'parser has ${errs.len} errors: ${errs.join('; ')}'
}

fn test_let_statements() {
	inputs := ['let x = 5;', 'let y = true;', 'let foobar = y;']
	idents := ['x', 'y', 'foobar']

	for i, input in inputs {
		mut p := new(lexer.new(input))
		program := p.parse_program()
		assert program.statements.len == 1
		check_parser_errors(p)

		stmt := program.statements[0]
		assert_let_statement(stmt, idents[i])
	}
}

fn assert_let_statement(s ast.Statement, name string) {
	assert s.token_literal() == 'let'
	let_stmt := s as ast.LetStatement
	assert let_stmt.name.value == name
	assert let_stmt.name.token_literal() == name
}

fn test_let_statement_errors() {
	inputs := ['let = 5;', 'let x = ;', 'let x 1;']
	for input in inputs {
		mut p := new(lexer.new(input))
		p.parse_program()
		assert p.errors().len > 0
	}
}

fn test_return_statement() {
	inputs := ['return 5;', 'return true;', 'return x;']
	expected := ['5', 'true', 'x']

	for i, input in inputs {
		mut p := new(lexer.new(input))
		program := p.parse_program()
		assert program.statements.len == 1
		check_parser_errors(p)

		return_stmt := program.statements[0] as ast.ReturnStatement
		assert return_stmt.return_value.str() == expected[i]
		assert return_stmt.token_literal() == 'return'
	}
}

fn test_identifier_expression() {
	mut p := new(lexer.new('foobar'))
	program := p.parse_program()
	check_parser_errors(p)

	assert program.statements.len == 1
	stmt := program.statements[0] as ast.ExpressionStatement
	assert_ident(stmt.expression, 'foobar')
}

fn test_integer_expression() {
	mut p := new(lexer.new('5;'))
	program := p.parse_program()
	check_parser_errors(p)

	assert program.statements.len == 1
	stmt := program.statements[0] as ast.ExpressionStatement
	assert_integer_literal(stmt.expression, 5)
}

fn test_float_expression() {
	inputs := ['12.34', '0.56', '78.00']
	expected := [12.34, 0.56, 78.00]

	for i, input in inputs {
		mut p := new(lexer.new(input))
		program := p.parse_program()
		check_parser_errors(p)

		assert program.statements.len == 1
		stmt := program.statements[0] as ast.ExpressionStatement
		assert_float_literal(stmt.expression, expected[i])
	}
}

fn test_parsing_prefix_expressions() {
	inputs := ['!5;', '-15;', '!true', '!false']
	operators := ['!', '-', '!', '!']

	for i, input in inputs {
		mut p := new(lexer.new(input))
		program := p.parse_program()
		check_parser_errors(p)

		assert program.statements.len == 1
		stmt := program.statements[0] as ast.ExpressionStatement
		expr := stmt.expression as ast.PrefixExpression
		assert expr.operator == operators[i]

		if i < 2 {
			assert_integer_literal(expr.right, if i == 0 { i64(5) } else { i64(15) })
		} else {
			assert_boolean_literal(expr.right, i == 2)
		}
	}
}

fn assert_integer_literal(expr ast.Expression, value i64) {
	i := expr as ast.IntegerLiteral
	assert i.value == value
	assert i.token_literal() == '${value}'
}

fn assert_float_literal(expr ast.Expression, value f64) {
	fl := expr as ast.FloatLiteral
	assert fl.value == value
}

fn assert_ident(expr ast.Expression, value string) {
	ident := expr as ast.Ident
	assert ident.value == value
	assert ident.token_literal() == value
}

fn assert_boolean_literal(expr ast.Expression, value bool) {
	b := expr as ast.Boolean
	assert b.value == value
	assert b.token_literal() == '${value}'
}

fn assert_infix_expression_int(expr ast.Expression, left i64, operator string, right i64) {
	op := expr as ast.InfixExpression
	assert_integer_literal(op.left, left)
	assert op.operator == operator
	assert_integer_literal(op.right, right)
}

struct Tst {
	input    string
	left     i64
	operator string
	right    i64
}

fn test_parsing_infix_expressions() {
	tests := [
		Tst{'5 + 5;', 5, '+', 5},
		Tst{'5 - 5;', 5, '-', 5},
		Tst{'5 * 5;', 5, '*', 5},
		Tst{'5 / 5;', 5, '/', 5},
		Tst{'5 > 5;', 5, '>', 5},
		Tst{'5 < 5;', 5, '<', 5},
		Tst{'5 == 5;', 5, '==', 5},
		Tst{'5 != 5;', 5, '!=', 5},
	]

	for tt in tests {
		mut p := new(lexer.new(tt.input))
		program := p.parse_program()
		check_parser_errors(p)

		assert program.statements.len == 1
		stmt := program.statements[0] as ast.ExpressionStatement
		assert_infix_expression_int(stmt.expression, tt.left, tt.operator, tt.right)
	}
}

fn test_operator_precedence_parsing() {
	tests := [
		['-a * b', '((-a) * b)'],
		['!-a', '(!(-a))'],
		['a + b + c', '((a + b) + c)'],
		['a + b - c', '((a + b) - c)'],
		['a * b * c', '((a * b) * c)'],
		['a * b / c', '((a * b) / c)'],
		['a + b / c', '(a + (b / c))'],
		['a + b * c + d / e - f', '(((a + (b * c)) + (d / e)) - f)'],
		['3 + 4; -5 * 5', '(3 + 4)((-5) * 5)'],
		['5 > 4 == 3 < 4', '((5 > 4) == (3 < 4))'],
		['5 < 4 != 3 > 4', '((5 < 4) != (3 > 4))'],
		['3 + 4 * 5 == 3 * 1 + 4 * 5', '((3 + (4 * 5)) == ((3 * 1) + (4 * 5)))'],
		['true', 'true'],
		['false', 'false'],
		['3 > 5 == false', '((3 > 5) == false)'],
		['3 < 5 == true', '((3 < 5) == true)'],
		['1 + (2 + 3) + 4', '((1 + (2 + 3)) + 4)'],
		['(5 + 5) * 2', '((5 + 5) * 2)'],
		['2 / (5 + 5)', '(2 / (5 + 5))'],
		['-(5 + 5)', '(-(5 + 5))'],
		['!(true == true)', '(!(true == true))'],
		['a + add(b * c) + d', '((a + add((b * c))) + d)'],
		['add(a, b, 1, 2 * 3, 4 + 5, add(6, 7 * 8))',
			'add(a, b, 1, (2 * 3), (4 + 5), add(6, (7 * 8)))'],
		['add(a + b + c * d / f + g)', 'add((((a + b) + ((c * d) / f)) + g))'],
		['a * [1, 2, 3, 4][b * c] * d', '((a * ([1, 2, 3, 4][(b * c)])) * d)'],
		['add(a * b[2], b[1], 2 * [1, 2][1])', 'add((a * (b[2])), (b[1]), (2 * ([1, 2][1])))'],
	]

	for tt in tests {
		mut p := new(lexer.new(tt[0]))
		program := p.parse_program()
		check_parser_errors(p)
		assert program.str() == tt[1]
	}
}

fn test_boolean_expression() {
	inputs := ['true', 'false']
	expected := [true, false]

	for i, input in inputs {
		mut p := new(lexer.new(input))
		program := p.parse_program()
		check_parser_errors(p)

		assert program.statements.len == 1
		stmt := program.statements[0] as ast.ExpressionStatement
		assert_boolean_literal(stmt.expression, expected[i])
	}
}

fn test_if_expression() {
	mut p := new(lexer.new('if (x < y) { x }'))
	program := p.parse_program()
	check_parser_errors(p)

	assert program.statements.len == 1
	stmt := program.statements[0] as ast.ExpressionStatement
	expr := stmt.expression as ast.IfExpression

	cond := expr.condition as ast.InfixExpression
	assert_ident(cond.left, 'x')
	assert cond.operator == '<'
	assert_ident(cond.right, 'y')

	assert expr.consequence.statements.len == 1
	cons := expr.consequence.statements[0] as ast.ExpressionStatement
	assert_ident(cons.expression, 'x')

	assert expr.has_alternative == false
}

fn test_if_else_expression() {
	mut p := new(lexer.new('if (x < y) { x } else { y }'))
	program := p.parse_program()
	check_parser_errors(p)

	assert program.statements.len == 1
	stmt := program.statements[0] as ast.ExpressionStatement
	expr := stmt.expression as ast.IfExpression

	assert expr.consequence.statements.len == 1
	cons := expr.consequence.statements[0] as ast.ExpressionStatement
	assert_ident(cons.expression, 'x')

	assert expr.has_alternative == true
	alt := expr.alternative.statements[0] as ast.ExpressionStatement
	assert_ident(alt.expression, 'y')
}

fn test_function_literal_parsing() {
	mut p := new(lexer.new('fn(x, y) { x + y; }'))
	program := p.parse_program()
	check_parser_errors(p)

	assert program.statements.len == 1
	stmt := program.statements[0] as ast.ExpressionStatement
	f := stmt.expression as ast.FunctionLiteral

	assert f.parameters.len == 2
	assert_ident(ast.Expression(f.parameters[0]), 'x')
	assert_ident(ast.Expression(f.parameters[1]), 'y')

	assert f.body.statements.len == 1
	body_stmt := f.body.statements[0] as ast.ExpressionStatement
	body_expr := body_stmt.expression as ast.InfixExpression
	assert_ident(body_expr.left, 'x')
	assert body_expr.operator == '+'
	assert_ident(body_expr.right, 'y')
}

fn test_function_parameter_parsing() {
	inputs := ['fn() {}', 'fn(x) {};', 'fn(x, y, z) {};']
	expected := [[]string{}, ['x'], ['x', 'y', 'z']]

	for i, input in inputs {
		mut p := new(lexer.new(input))
		program := p.parse_program()
		check_parser_errors(p)

		stmt := program.statements[0] as ast.ExpressionStatement
		f := stmt.expression as ast.FunctionLiteral

		assert f.parameters.len == expected[i].len
		for j, name in expected[i] {
			assert_ident(ast.Expression(f.parameters[j]), name)
		}
	}
}

fn test_call_function_parsing() {
	mut p := new(lexer.new('add(1, 2 * 3, 4 + 5);'))
	program := p.parse_program()
	check_parser_errors(p)

	assert program.statements.len == 1
	stmt := program.statements[0] as ast.ExpressionStatement
	expr := stmt.expression as ast.CallExpression

	assert_ident(expr.function, 'add')
	assert expr.arguments.len == 3

	assert_integer_literal(expr.arguments[0], 1)
	assert_infix_expression_int(expr.arguments[1], 2, '*', 3)
	assert_infix_expression_int(expr.arguments[2], 4, '+', 5)
}

fn test_string_literal_expression() {
	mut p := new(lexer.new('"hello world";'))
	program := p.parse_program()
	check_parser_errors(p)

	assert program.statements.len == 1
	stmt := program.statements[0] as ast.ExpressionStatement
	lit := stmt.expression as ast.StringLiteral
	assert lit.value == 'hello world'
}

fn test_parsing_array_literals() {
	mut p := new(lexer.new('[1, 2 * 2, 3 + 3]'))
	program := p.parse_program()
	check_parser_errors(p)

	assert program.statements.len == 1
	stmt := program.statements[0] as ast.ExpressionStatement
	array := stmt.expression as ast.ArrayLiteral

	assert array.elements.len == 3
	assert_integer_literal(array.elements[0], 1)
	assert_infix_expression_int(array.elements[1], 2, '*', 2)
	assert_infix_expression_int(array.elements[2], 3, '+', 3)
}

fn test_parsing_index_expressions() {
	mut p := new(lexer.new('myArray[1 + 1]'))
	program := p.parse_program()
	check_parser_errors(p)

	assert program.statements.len == 1
	stmt := program.statements[0] as ast.ExpressionStatement
	idx_expr := stmt.expression as ast.IndexExpression

	assert_ident(idx_expr.left, 'myArray')
	assert_infix_expression_int(idx_expr.index, 1, '+', 1)
}

fn test_parsing_hash_literals_string_keys() {
	mut p := new(lexer.new('{"one": 1, "two": 2, "three": 3}'))
	program := p.parse_program()
	check_parser_errors(p)

	stmt := program.statements[0] as ast.ExpressionStatement
	hash := stmt.expression as ast.HashLiteral

	expected := {
		'one':   i64(1)
		'two':   i64(2)
		'three': i64(3)
	}

	assert hash.pairs.len == expected.len
	for pair in hash.pairs {
		key := pair.key as ast.StringLiteral
		assert_integer_literal(pair.value, expected[key.value])
	}
}

fn test_parsing_hash_literals_empty() {
	mut p := new(lexer.new('{}'))
	program := p.parse_program()
	check_parser_errors(p)

	stmt := program.statements[0] as ast.ExpressionStatement
	hash := stmt.expression as ast.HashLiteral
	assert hash.pairs.len == 0
}

fn test_parsing_hash_literals_int_keys() {
	mut p := new(lexer.new('{1: 1, 2: 2, 3: 3}'))
	program := p.parse_program()
	check_parser_errors(p)

	stmt := program.statements[0] as ast.ExpressionStatement
	hash := stmt.expression as ast.HashLiteral

	assert hash.pairs.len == 3
	for pair in hash.pairs {
		key := pair.key as ast.IntegerLiteral
		val := pair.value as ast.IntegerLiteral
		assert key.value == val.value
	}
}

fn test_parsing_hash_literals_bool_keys() {
	mut p := new(lexer.new('{true: 1, false: 2}'))
	program := p.parse_program()
	check_parser_errors(p)

	stmt := program.statements[0] as ast.ExpressionStatement
	hash := stmt.expression as ast.HashLiteral

	assert hash.pairs.len == 2
	for pair in hash.pairs {
		key := pair.key as ast.Boolean
		val := pair.value as ast.IntegerLiteral
		if key.value {
			assert val.value == 1
		} else {
			assert val.value == 2
		}
	}
}

fn test_parsing_hash_literals_with_expressions() {
	mut p := new(lexer.new('{"one": 0 + 1, "two": 10 - 8, "three": 15 / 5}'))
	program := p.parse_program()
	check_parser_errors(p)

	stmt := program.statements[0] as ast.ExpressionStatement
	hash := stmt.expression as ast.HashLiteral

	assert hash.pairs.len == 3
	for pair in hash.pairs {
		key := pair.key as ast.StringLiteral
		match key.value {
			'one' { assert_infix_expression_int(pair.value, 0, '+', 1) }
			'two' { assert_infix_expression_int(pair.value, 10, '-', 8) }
			'three' { assert_infix_expression_int(pair.value, 15, '/', 5) }
			else { assert false }
		}
	}
}

fn test_macro_literal_parsing() {
	mut p := new(lexer.new('macro(x, y) { x + y; }'))
	program := p.parse_program()
	check_parser_errors(p)

	assert program.statements.len == 1
	stmt := program.statements[0] as ast.ExpressionStatement
	macro := stmt.expression as ast.MacroLiteral

	assert macro.parameters.len == 2
	assert_ident(ast.Expression(macro.parameters[0]), 'x')
	assert_ident(ast.Expression(macro.parameters[1]), 'y')

	assert macro.body.statements.len == 1
	body_stmt := macro.body.statements[0] as ast.ExpressionStatement
	body_expr := body_stmt.expression as ast.InfixExpression
	assert_ident(body_expr.left, 'x')
	assert body_expr.operator == '+'
	assert_ident(body_expr.right, 'y')
}
