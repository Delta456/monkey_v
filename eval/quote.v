module eval

import ast
import object
import token

pub const func_name_quote = 'quote'
pub const func_name_unquote = 'unquote'

fn quote(node ast.Node, env &object.Environment) object.Quote {
	new_node := eval_unquote_calls(node, env)
	return object.Quote{
		node: new_node
	}
}

fn eval_unquote_calls(quoted ast.Node, env &object.Environment) ast.Node {
	modifier := fn [env] (node ast.Node) ast.Node {
		if node !is ast.CallExpression {
			return node
		}

		call := node as ast.CallExpression
		if call.function.token_literal() != func_name_unquote || call.arguments.len != 1 {
			return node
		}

		unquoted := eval(ast.expr_to_node(call.arguments[0]), env) or { return node }
		return convert_object_to_ast_node(unquoted) or { return node }
	}
	return ast.modify(quoted, modifier)
}

fn convert_object_to_ast_node(obj object.Object) ?ast.Node {
	match obj {
		object.Integer {
			t := token.Token{
				typ:     token.int_tok
				literal: '${obj.value}'
			}
			return ast.Node(ast.IntegerLiteral{
				token: t
				value: obj.value
			})
		}
		object.Boolean {
			t := if obj.value {
				token.Token{
					typ:     token.key_true
					literal: 'true'
				}
			} else {
				token.Token{
					typ:     token.key_false
					literal: 'false'
				}
			}
			return ast.Node(ast.Boolean{
				token: t
				value: obj.value
			})
		}
		object.Quote {
			return obj.node
		}
		else {
			return none
		}
	}
}
