module repl

import ast
import eval
import lexer
import object
import os
import parser

const prompt = '>> '

// start starts the Monkey REPL, reading from stdin and writing to stdout.
pub fn start() {
	env := object.new_environment()
	macro_env := object.new_environment()

	for {
		print(prompt)
		line := os.get_line()
		if line.len == 0 || line == 'exit' || line == 'quit' {
			break
		}

		mut p := parser.new(lexer.new(line))
		mut program := p.parse_program()

		errs := p.errors()
		if errs.len > 0 {
			print_parser_errors(errs)
			continue
		}

		eval.define_macros(mut program, macro_env)
		expanded := eval.expand_macros(ast.Node(program), macro_env)

		evaluated := eval.eval(expanded, env) or { continue }
		println(evaluated.inspect())
	}
}

fn print_parser_errors(errors []string) {
	for msg in errors {
		println(msg)
	}
}
