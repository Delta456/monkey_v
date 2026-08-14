module eval

import ast
import lexer
import object
import parser

fn check_eval(input string) object.Object {
	l := lexer.new(input)
	mut p := parser.new(l)
	program := p.parse_program()

	errs := p.errors()
	assert errs.len == 0, 'input ${input} has errors: \n${errs.join('\n')}'

	env := object.new_environment()
	return eval(ast.Node(program), env) or { nil_value }
}

fn assert_integer_object(obj object.Object, expected i64) {
	result := obj as object.Integer
	assert result.value == expected
}

fn assert_float_object(obj object.Object, expected f64) {
	result := obj as object.Float
	assert result.value == expected
}

fn assert_boolean_object(obj object.Object, expected bool) {
	result := obj as object.Boolean
	assert result.value == expected
}

fn assert_nil_object(obj object.Object) {
	assert obj == nil_value
}

fn test_eval_integer_expression() {
	inputs := ['5', '10', '-5', '-10', '5 + 5 + 5 + 5 - 10', '2 * 2 * 2 * 2 * 2', '-50 + 100 + -50',
		'5 * 2 + 10', '5 + 2 * 10', '20 + 2 * -10', '50 / 2 * 2 + 10', '3 * 3 * 3 + 10',
		'3 * (3 * 3) + 10', '(5 + 10 * 2 + 15 / 3) * 2 + -10']
	expected := [i64(5), 10, -5, -10, 10, 32, 0, 20, 25, 0, 60, 37, 37, 50]

	for i, input in inputs {
		evaluated := check_eval(input)
		assert_integer_object(evaluated, expected[i])
	}
}

fn test_eval_float_expression() {
	inputs := ['12.34', '0.56', '78.00', '-12.34', '-0.56', '-78.00',
		'(5 + 10.0 * 2.5 + 15.0 / 3) * 2.1 + -10.1']
	expected := [12.34, 0.56, 78.00, -12.34, -0.56, -78.00, 63.4]

	for i, input in inputs {
		evaluated := check_eval(input)
		assert_float_object(evaluated, expected[i])
	}
}

fn test_eval_boolean_expression() {
	inputs := ['true', 'false', '1 < 2', '1 > 2', '1 < 1', '1 > 1', '1 == 1', '1 != 1', '1 == 2',
		'1 != 2', 'true == true', 'false == false', 'true == false', 'true != false', 'false != true',
		'(1 < 2) == true', '(1 < 2) == false', '(1 > 2) == true', '(1 > 2) == false',
		'"hello" == "hello"', '"hello" == "world"', '"foo" != "bar"', '"foo" != "foo"']
	expected := [true, false, true, false, false, false, true, false, false, true, true, true,
		false, true, true, true, false, false, true, true, false, true, false]

	for i, input in inputs {
		evaluated := check_eval(input)
		assert_boolean_object(evaluated, expected[i])
	}
}

fn test_bang_operator() {
	inputs := ['!true', '!false', '!5', '!!true', '!!false', '!!5']
	expected := [false, true, false, true, false, true]

	for i, input in inputs {
		evaluated := check_eval(input)
		assert_boolean_object(evaluated, expected[i])
	}
}

fn test_if_expression() {
	inputs := ['if (true) { 10 }', 'if (false) { 10 }', 'if (1) { 10 }', 'if (1 < 2) { 10 }',
		'if (1 > 2) { 10 }', 'if (1 < 2) { 10 } else { 20 }', 'if (1 > 2) { 10 } else { 20 }']
	expected := [10, 0, 10, 10, 0, 10, 20]
	is_nil := [false, true, false, false, true, false, false]

	for i, input in inputs {
		evaluated := check_eval(input)
		if is_nil[i] {
			assert_nil_object(evaluated)
		} else {
			assert_integer_object(evaluated, expected[i])
		}
	}
}

fn test_return_statements() {
	inputs := ['return 10;', 'return 10; 9;', 'return 2 * 5; 9;', '9; return 2 * 5; 11;', '
		if (10 > 1) {
			if (10 > 1) {
				return 10;
			}

			return 1;
		}
		']
	expected := [i64(10), 10, 10, 10, 10]

	for i, input in inputs {
		evaluated := check_eval(input)
		assert_integer_object(evaluated, expected[i])
	}
}

fn test_error_handling() {
	tests := [
		['5 + true;', 'type mismatch: Integer + Boolean'],
		['5 + true; 5;', 'type mismatch: Integer + Boolean'],
		['-true', 'unknown operator: -Boolean'],
		['true + false', 'unknown operator: Boolean + Boolean'],
		['5; true + false; 5', 'unknown operator: Boolean + Boolean'],
		['if (10 > 1) { true + false; }', 'unknown operator: Boolean + Boolean'],
		['
		if (10 > 1) {
			if (10 > 1) {
				return true + false;
			}

			return 1;
		}
		',
			'unknown operator: Boolean + Boolean'],
		['foobar', 'identifier not found: foobar'],
		['"Hello" - "World"', 'unknown operator: String - String'],
		['1.5 + "World"', 'unknown operator: Float + String'],
		['{[1, 2]: "Monkey"}', 'unusable as hash key: Array'],
		['{"name": "Monkey"}[fn(x) { x }]', 'unusable as hash key: Function'],
	]

	for tt in tests {
		evaluated := check_eval(tt[0])
		err_obj := evaluated as object.ErrorObj
		assert err_obj.message == tt[1]
	}
}

fn test_let_statements() {
	inputs := ['let a = 5; a;', 'let a = 5 * 5; a;', 'let a = 5; let b = a; b;',
		'let a = 5; let b = a; let c = a + b + 5; c;']
	expected := [i64(5), 25, 5, 15]

	for i, input in inputs {
		evaluated := check_eval(input)
		assert_integer_object(evaluated, expected[i])
	}
}

fn test_function_object() {
	evaluated := check_eval('fn(x) { x + 2; }')
	fun := evaluated as object.Function

	assert fun.parameters.len == 1
	assert fun.parameters[0].str() == 'x'
	assert fun.body.str() == '(x + 2)'
}

fn test_function_application() {
	inputs := ['let identity = fn(x) { x; }; identity(5);',
		'let identity = fn(x) { return x; }; identity(5);',
		'let double = fn(x) { x * 2; }; double(5);', 'let add = fn(x, y) { x + y; }; add(5, 5);',
		'let add = fn(x, y) { x + y; }; add(5 + 5, add(5, 5));', 'fn(x) { x; }(5);']
	expected := [i64(5), 5, 10, 10, 20, 5]

	for i, input in inputs {
		evaluated := check_eval(input)
		assert_integer_object(evaluated, expected[i])
	}
}

fn test_closures() {
	input := '
	let newAdder = fn(x) {
		fn(y) { x + y };
	};

	let addTwo = newAdder(2);
	addTwo(2);
	'
	evaluated := check_eval(input)
	assert_integer_object(evaluated, 4)
}

fn test_string_literal_and_concat() {
	tests := [
		['"Hello World!";', 'Hello World!'],
		['"Hello" + " " + "World!";', 'Hello World!'],
	]
	for tt in tests {
		evaluated := check_eval(tt[0])
		str := evaluated as object.Str
		assert str.value == tt[1]
	}
}

fn test_array_literals() {
	evaluated := check_eval('[1, 2 * 2, 3 + 3]')
	array := evaluated as object.Array

	assert array.elements.len == 3
	assert_integer_object(array.elements[0], 1)
	assert_integer_object(array.elements[1], 4)
	assert_integer_object(array.elements[2], 6)
}

fn test_array_index_expressions() {
	inputs := ['[1, 2, 3][0]', '[1, 2, 3][1]', '[1, 2, 3][2]', 'let i = 0; [1][i]',
		'[1, 2, 3][1 + 1]', 'let arr = [1, 2, 3]; arr[2];',
		'let arr = [1, 2, 3]; arr[0] + arr[1] + arr[2];',
		'let arr = [1, 2, 3]; let i = arr[0]; arr[i]', '[1, 2, 3][3]', '[1, 2, 3][-1]']
	expected := [1, 2, 3, 1, 3, 3, 6, 2, 0, 0]
	is_nil := [false, false, false, false, false, false, false, false, true, true]

	for i, input in inputs {
		evaluated := check_eval(input)
		if is_nil[i] {
			assert_nil_object(evaluated)
		} else {
			assert_integer_object(evaluated, expected[i])
		}
	}
}

fn test_hash_literals() {
	input := '
	let two = "two";
	{
		"one": 10 - 9,
		two: 1 + 1,
		"thr" + "ee": 6 / 2,
		4: 4,
		true: 5,
		false: 6
	};
	'

	evaluated := check_eval(input)
	hash := evaluated as object.Hash

	mut expected := map[string]i64{}
	expected[object.Str{
		value: 'one'
	}.hash_key()] = 1
	expected[object.Str{
		value: 'two'
	}.hash_key()] = 2
	expected[object.Str{
		value: 'three'
	}.hash_key()] = 3
	expected[object.Integer{
		value: 4
	}.hash_key()] = 4
	expected[object.Boolean{
		value: true
	}.hash_key()] = 5
	expected[object.Boolean{
		value: false
	}.hash_key()] = 6

	assert hash.pairs.len == expected.len
	for key, value in expected {
		pair := hash.pairs[key] or {
			assert false
			object.HashPair{}
		}
		assert_integer_object(pair.value, value)
	}
}

fn test_hash_index_expressions() {
	inputs := ['{"foo": 2 + 3}["foo"]', '{"foo": 5}["bar"]', 'let key = "foo"; {"foo": 5}[key]',
		'{}["foo"]', '{5: 5}[5]', '{true: 5}[true]', '{false: 5}[false]']
	expected := [5, 0, 5, 0, 5, 5, 5]
	is_nil := [false, true, false, true, false, false, false]

	for i, input in inputs {
		evaluated := check_eval(input)
		if is_nil[i] {
			assert_nil_object(evaluated)
		} else {
			assert_integer_object(evaluated, expected[i])
		}
	}
}

fn test_quote() {
	tests := [
		['quote(5)', '5'],
		['quote(foobar)', 'foobar'],
		['quote(foobar + barfoo)', '(foobar + barfoo)'],
	]

	for tt in tests {
		evaluated := check_eval(tt[0])
		q := evaluated as object.Quote
		assert q.node.str() == tt[1]
	}
}
