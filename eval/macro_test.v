module eval

import ast
import lexer
import object
import parser

fn parse_program(input string) ast.Program {
	mut p := parser.new(lexer.new(input))
	return p.parse_program()
}

fn test_define_macros() {
	input := '
  let num = 1;
	let func = fn(x, y) { x + y };
	let mymacro = macro(x, y) { x + y; };
	'

	env := object.new_environment()
	mut program := parse_program(input)

	define_macros(mut program, env)

	assert program.statements.len == 2
	if _ := env.get('num') {
		assert false
	}
	if _ := env.get('func') {
		assert false
	}

	obj := env.get('mymacro') or {
		assert false
		return
	}
	macro := obj as object.Macro

	assert macro.parameters.len == 2
	assert macro.parameters[0].str() == 'x'
	assert macro.parameters[1].str() == 'y'
	assert macro.body.str() == '(x + y)'
}

fn test_expand_macros() {
	tests := [
		['
			let infixExpr = macro() { quote(1 + 2); };
			infixExpr();
			', '(1 + 2)'],
		['
			let reverse = macro(a, b) { quote(unquote(b) - unquote(a)); };
			reverse(2 + 2, 10 - 5);
			',
			'(10 - 5) - (2 + 2)'],
		['
			let unless = macro(condition, consequence, altenative) {
			  quote(
					if (!(unquote(condition))) {
						unquote(consequence)
					} else {
						unquote(altenative)
					}
				);
			};

			unless(10 > 5, puts("not greater"), puts("greater"));
			',
			'
			if (!(10 > 5)) {
				puts("not greater")
			} else {
				puts("greater")
			}
			'],
	]

	for tt in tests {
		mut program := parse_program(tt[0])
		env := object.new_environment()
		define_macros(mut program, env)
		got := expand_macros(ast.Node(program), env).str()

		want := parse_program(tt[1]).str()
		assert got == want
	}
}
