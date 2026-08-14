import ast
import eval
import lexer
import object
import os
import parser
import repl

fn main() {
	// Start the Monkey REPL if no script was given.
	if os.args.len == 1 {
		println('This is the Monkey programming language!')
		println('Feel free to type in commands')
		repl.start()
		return
	}

	// Otherwise, run the given Monkey script.
	run_program(os.args[1]) or {
		eprintln(err)
		exit(1)
	}
}

fn run_program(filename string) ! {
	data := os.read_file(filename) or { return error('could not read ${filename}: ${err}') }

	mut p := parser.new(lexer.new(data))
	mut program := p.parse_program()

	errs := p.errors()
	if errs.len > 0 {
		return error(errs[0])
	}

	env := object.new_environment()
	macro_env := object.new_environment()

	eval.define_macros(mut program, macro_env)
	expanded := eval.expand_macros(ast.Node(program), macro_env)

	result := eval.eval(expanded, env) or { return }
	if result is object.Nil {
		return
	}

	println(result.inspect())
}
