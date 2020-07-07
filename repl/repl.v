module repl

import os
import parser
import lexer
import token

pub enum Type {
	lexer
	parser
}

const (
	prompt = '>> '
)

pub fn start(ty Type) {
	for {
		print(prompt)
		line := os.get_line()
		if line == 'exit' {
			break
		}
		if ty == .parser {
			mut p := parser.new_repl_parser(line)
			program := p.parse_top_lvl()
			println(program.token_literals())
		} else if ty == .lexer {
			mut l := lexer.new(line)
			mut tok := l.next_token()
			for tok.typ != token.eof {
				println('{type : $tok.typ, literal : $tok.literal}')
				tok = l.next_token()
			}
		}
	}
}
