import parser
import os

fn main() {
	println("Hello, this is the Monkey programming language implementation in V!")
	/*mut typ := repl.Type.lexer
	if os.args.len > 0 {
		if '-parser' in os.args {
			typ = repl.Type.parser
		}
	}
	repl.start(typ)*/
	mut parser := parser.new_parser(os.args[1])
	parser.parse()
}
