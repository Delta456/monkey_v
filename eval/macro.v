module eval

import ast
import object

// define_macros finds macro definitions in `program`, saves them to `env` and removes them
// from the AST.
pub fn define_macros(mut program ast.Program, env &object.Environment) {
	mut defs := []int{}

	for pos, stmt in program.statements {
		if is_macro_definition(stmt) {
			add_macro(stmt, env)
			defs << pos
		}
	}

	for i := defs.len - 1; i >= 0; i-- {
		program.statements.delete(defs[i])
	}
}

fn is_macro_definition(node ast.Statement) bool {
	if node !is ast.LetStatement {
		return false
	}
	let_stmt := node as ast.LetStatement
	return let_stmt.value is ast.MacroLiteral
}

fn add_macro(stmt ast.Statement, env &object.Environment) {
	let_stmt := stmt as ast.LetStatement
	macro_lit := let_stmt.value as ast.MacroLiteral
	macro := object.Macro{
		parameters: macro_lit.parameters
		body:       macro_lit.body
		env:        env
	}
	env.set(let_stmt.name.value, object.Object(macro))
}

// expand_macros expands defined macros and replaces AST nodes with the result of macro
// expansion.
pub fn expand_macros(program ast.Node, env &object.Environment) ast.Node {
	modifier := fn [env] (node ast.Node) ast.Node {
		if node !is ast.CallExpression {
			return node
		}

		call := node as ast.CallExpression
		macro := is_macro_call(call, env) or { return node }

		args := quote_args(call)
		eval_env := extend_macro_env(macro, args)

		evaluated := eval(ast.Node(macro.body), eval_env) or {
			panic('we only support returning AST-nodes from macros')
		}
		if evaluated !is object.Quote {
			panic('we only support returning AST-nodes from macros')
		}

		quoted := evaluated as object.Quote
		return quoted.node
	}

	return ast.modify(program, modifier)
}

fn is_macro_call(call ast.CallExpression, env &object.Environment) ?object.Macro {
	if call.function !is ast.Ident {
		return none
	}
	ident := call.function as ast.Ident

	obj := env.get(ident.value) or { return none }
	if obj !is object.Macro {
		return none
	}
	return obj as object.Macro
}

fn quote_args(call ast.CallExpression) []object.Quote {
	mut args := []object.Quote{cap: call.arguments.len}
	for arg in call.arguments {
		args << object.Quote{
			node: ast.expr_to_node(arg)
		}
	}
	return args
}

fn extend_macro_env(macro object.Macro, args []object.Quote) &object.Environment {
	mut extended := object.new_enclosed_environment(macro.env)
	for i, param in macro.parameters {
		extended.set(param.value, object.Object(args[i]))
	}
	return extended
}
