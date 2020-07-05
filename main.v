import repl
import os

fn main() {
	println("Hello, this is the Monkey programming language implementation in V!")
	mut typ := repl.Type.lexer
	if os.args.len > 0 {
		if '-parser' in os.args {
			typ = repl.Type.parser
		}
	}
	repl.start(typ)
}
