module eval

import ast
import object

pub const nil_value = object.Object(object.Nil{})
pub const true_value = object.Object(object.Boolean{
	value: true
})
pub const false_value = object.Object(object.Boolean{
	value: false
})

// eval evaluates `node` in `env` and returns the resulting object, or `none` if the node
// produces no value (e.g. a `let` statement).
pub fn eval(node ast.Node, env &object.Environment) ?object.Object {
	match node {
		ast.Program {
			return eval_program(node, env)
		}
		ast.ExpressionStatement {
			return eval(ast.expr_to_node(node.expression), env)
		}
		ast.ReturnStatement {
			value := eval(ast.expr_to_node(node.return_value), env) or { return none }
			if is_error(value) {
				return value
			}
			return object.Object(object.ReturnValue{
				value: value
			})
		}
		ast.BlockStatement {
			return eval_block_statement(node, env)
		}
		ast.LetStatement {
			value := eval(ast.expr_to_node(node.value), env) or { return none }
			if is_error(value) {
				return value
			}
			env.set(node.name.value, value)
			return none
		}
		ast.IntegerLiteral {
			return object.Object(object.Integer{
				value: node.value
			})
		}
		ast.FloatLiteral {
			return object.Object(object.Float{
				value: node.value
			})
		}
		ast.Boolean {
			return native_bool_to_boolean_object(node.value)
		}
		ast.PrefixExpression {
			right := eval(ast.expr_to_node(node.right), env) or { return none }
			if is_error(right) {
				return right
			}
			return eval_prefix_expression(node.operator, right)
		}
		ast.InfixExpression {
			left := eval(ast.expr_to_node(node.left), env) or { return none }
			if is_error(left) {
				return left
			}
			right := eval(ast.expr_to_node(node.right), env) or { return none }
			if is_error(right) {
				return right
			}
			return eval_infix_expression(node.operator, left, right)
		}
		ast.IfExpression {
			return eval_if_expression(node, env)
		}
		ast.Ident {
			return eval_ident(node, env)
		}
		ast.FunctionLiteral {
			return object.Object(object.Function{
				parameters: node.parameters
				body:       node.body
				env:        env
			})
		}
		ast.CallExpression {
			if node.function.token_literal() == func_name_quote {
				return object.Object(quote(ast.expr_to_node(node.arguments[0]), env))
			}

			function := eval(ast.expr_to_node(node.function), env) or { return none }
			if is_error(function) {
				return function
			}

			args := eval_expressions(node.arguments, env) or { return none }
			if args.len == 1 && is_error(args[0]) {
				return args[0]
			}

			return apply_function(function, args)
		}
		ast.StringLiteral {
			return object.Object(object.Str{
				value: node.value
			})
		}
		ast.ArrayLiteral {
			elems := eval_expressions(node.elements, env) or { return none }
			if elems.len == 1 && is_error(elems[0]) {
				return elems[0]
			}
			return object.Object(object.Array{
				elements: elems
			})
		}
		ast.IndexExpression {
			left := eval(ast.expr_to_node(node.left), env) or { return none }
			if is_error(left) {
				return left
			}
			idx := eval(ast.expr_to_node(node.index), env) or { return none }
			if is_error(idx) {
				return idx
			}
			return eval_index_expression(left, idx)
		}
		ast.HashLiteral {
			return eval_hash_literal(node, env)
		}
		else {
			return none
		}
	}
}

fn eval_program(program ast.Program, env &object.Environment) ?object.Object {
	mut result := ?object.Object(none)
	for stmt in program.statements {
		res := eval(ast.stmt_to_node(stmt), env)
		result = res
		val := res or { continue }
		match val {
			object.ReturnValue { return val.value }
			object.ErrorObj { return val }
			else {}
		}
	}
	return result
}

fn eval_block_statement(block ast.BlockStatement, env &object.Environment) ?object.Object {
	mut result := ?object.Object(none)
	for stmt in block.statements {
		res := eval(ast.stmt_to_node(stmt), env)
		result = res
		val := res or { continue }
		match val {
			object.ReturnValue { return val }
			object.ErrorObj { return val }
			else {}
		}
	}
	return result
}

fn native_bool_to_boolean_object(b bool) object.Object {
	return if b { true_value } else { false_value }
}

fn eval_prefix_expression(operator string, right object.Object) object.Object {
	return match operator {
		'!' { eval_bang_operator_expression(right) }
		'-' { eval_minus_prefix_operator_expression(right) }
		else { new_error('unknown operator: ${operator}${right.otype()}') }
	}
}

fn eval_bang_operator_expression(right object.Object) object.Object {
	if right == nil_value || right == false_value {
		return true_value
	}
	return false_value
}

fn eval_minus_prefix_operator_expression(right object.Object) object.Object {
	match right {
		object.Integer { return object.Object(object.Integer{
				value: -right.value
			}) }
		object.Float { return object.Object(object.Float{
				value: -right.value
			}) }
		else { return new_error('unknown operator: -${right.otype()}') }
	}
}

fn eval_infix_expression(operator string, left object.Object, right object.Object) object.Object {
	if left.otype() == 'Integer' && right.otype() == 'Integer' {
		return eval_integer_infix_expression(operator, left, right)
	}
	if left.otype() == 'Float' || right.otype() == 'Float' {
		return eval_float_infix_expression(operator, left, right)
	}
	if left.otype() == 'String' && right.otype() == 'String' {
		return eval_string_infix_expression(operator, left, right)
	}
	if operator == '==' {
		return native_bool_to_boolean_object(left == right)
	}
	if operator == '!=' {
		return native_bool_to_boolean_object(left != right)
	}
	if left.otype() != right.otype() {
		return new_error('type mismatch: ${left.otype()} ${operator} ${right.otype()}')
	}
	return new_error('unknown operator: ${left.otype()} ${operator} ${right.otype()}')
}

fn eval_integer_infix_expression(operator string, left object.Object, right object.Object) object.Object {
	left_val := (left as object.Integer).value
	right_val := (right as object.Integer).value

	return match operator {
		'+' { object.Object(object.Integer{
				value: left_val + right_val
			}) }
		'-' { object.Object(object.Integer{
				value: left_val - right_val
			}) }
		'*' { object.Object(object.Integer{
				value: left_val * right_val
			}) }
		'/' { object.Object(object.Integer{
				value: left_val / right_val
			}) }
		'<' { native_bool_to_boolean_object(left_val < right_val) }
		'>' { native_bool_to_boolean_object(left_val > right_val) }
		'<=' { native_bool_to_boolean_object(left_val <= right_val) }
		'>=' { native_bool_to_boolean_object(left_val >= right_val) }
		'==' { native_bool_to_boolean_object(left_val == right_val) }
		'!=' { native_bool_to_boolean_object(left_val != right_val) }
		else { new_error('unknown operator: ${left.otype()} ${operator} ${right.otype()}') }
	}
}

fn eval_float_infix_expression(operator string, left object.Object, right object.Object) object.Object {
	left_val := match left {
		object.Integer { f64(left.value) }
		object.Float { left.value }
		else { return new_error('unknown operator: ${left.otype()} ${operator} ${right.otype()}') }
	}
	right_val := match right {
		object.Integer { f64(right.value) }
		object.Float { right.value }
		else { return new_error('unknown operator: ${left.otype()} ${operator} ${right.otype()}') }
	}

	return match operator {
		'+' { object.Object(object.Float{
				value: left_val + right_val
			}) }
		'-' { object.Object(object.Float{
				value: left_val - right_val
			}) }
		'*' { object.Object(object.Float{
				value: left_val * right_val
			}) }
		'/' { object.Object(object.Float{
				value: left_val / right_val
			}) }
		'<' { native_bool_to_boolean_object(left_val < right_val) }
		'>' { native_bool_to_boolean_object(left_val > right_val) }
		'<=' { native_bool_to_boolean_object(left_val <= right_val) }
		'>=' { native_bool_to_boolean_object(left_val >= right_val) }
		'==' { native_bool_to_boolean_object(left_val == right_val) }
		'!=' { native_bool_to_boolean_object(left_val != right_val) }
		else { new_error('unknown operator: ${left.otype()} ${operator} ${right.otype()}') }
	}
}

fn eval_string_infix_expression(operator string, left object.Object, right object.Object) object.Object {
	left_val := (left as object.Str).value
	right_val := (right as object.Str).value

	return match operator {
		'+' { object.Object(object.Str{
				value: left_val + right_val
			}) }
		'==' { native_bool_to_boolean_object(left_val == right_val) }
		'!=' { native_bool_to_boolean_object(left_val != right_val) }
		else { new_error('unknown operator: ${left.otype()} ${operator} ${right.otype()}') }
	}
}

fn eval_if_expression(ie ast.IfExpression, env &object.Environment) ?object.Object {
	condition := eval(ast.expr_to_node(ie.condition), env) or { return none }
	if is_error(condition) {
		return condition
	}

	if is_truthy(condition) {
		return eval(ast.Node(ie.consequence), env)
	} else if ie.has_alternative {
		return eval(ast.Node(ie.alternative), env)
	}
	return nil_value
}

fn is_truthy(obj object.Object) bool {
	return obj != nil_value && obj != false_value
}

fn new_error(msg string) object.Object {
	return object.Object(object.ErrorObj{
		message: msg
	})
}

fn is_error(obj object.Object) bool {
	return obj is object.ErrorObj
}

fn eval_ident(node ast.Ident, env &object.Environment) ?object.Object {
	if val := env.get(node.value) {
		return val
	}
	if builtin := builtins[node.value] {
		return object.Object(builtin)
	}
	return new_error('identifier not found: ${node.value}')
}

fn eval_expressions(exprs []ast.Expression, env &object.Environment) ?[]object.Object {
	mut result := []object.Object{cap: exprs.len}
	for expr in exprs {
		evaluated := eval(ast.expr_to_node(expr), env) or { return none }
		if is_error(evaluated) {
			return [evaluated]
		}
		result << evaluated
	}
	return result
}

fn extend_function_env(fun object.Function, args []object.Object) &object.Environment {
	mut env := object.new_enclosed_environment(fun.env)
	for i, param in fun.parameters {
		env.set(param.value, args[i])
	}
	return env
}

fn apply_function(fun object.Object, args []object.Object) object.Object {
	match fun {
		object.Function {
			extended_env := extend_function_env(fun, args)
			evaluated := eval(ast.Node(fun.body), extended_env) or { return nil_value }
			return unwrap_return_value(evaluated)
		}
		object.Builtin {
			return fun.func(args)
		}
		else {
			return new_error('not a function: ${fun.otype()}')
		}
	}
}

fn unwrap_return_value(obj object.Object) object.Object {
	match obj {
		object.ReturnValue { return obj.value }
		else { return obj }
	}
}

fn eval_index_expression(left object.Object, index object.Object) object.Object {
	if left is object.Array && index is object.Integer {
		return eval_array_index_expression(left, index)
	}
	if left is object.Hash {
		return eval_hash_index_expression(left, index)
	}
	return new_error('index operator not supported: ${left.otype()}')
}

fn eval_array_index_expression(array object.Object, index object.Object) object.Object {
	arr := array as object.Array
	idx := (index as object.Integer).value
	max := i64(arr.elements.len - 1)

	if idx < 0 || idx > max {
		return nil_value
	}

	return arr.elements[idx]
}

fn eval_hash_literal(node ast.HashLiteral, env &object.Environment) ?object.Object {
	mut pairs := map[string]object.HashPair{}

	for pair in node.pairs {
		key := eval(ast.expr_to_node(pair.key), env) or { return none }
		if is_error(key) {
			return key
		}

		hash_key := object.hash_key_of(key) or {
			return new_error('unusable as hash key: ${key.otype()}')
		}

		value := eval(ast.expr_to_node(pair.value), env) or { return none }
		if is_error(value) {
			return value
		}

		pairs[hash_key] = object.HashPair{
			key:   key
			value: value
		}
	}

	return object.Object(object.Hash{
		pairs: pairs
	})
}

fn eval_hash_index_expression(left object.Object, index object.Object) object.Object {
	key := object.hash_key_of(index) or {
		return new_error('unusable as hash key: ${index.otype()}')
	}

	hash_obj := left as object.Hash
	if pair := hash_obj.pairs[key] {
		return pair.value
	}
	return nil_value
}
