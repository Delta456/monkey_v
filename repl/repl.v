module repl

import os
import lexer
import token


const (
	prompt = ">> "
)

pub fn start() {
	for {
		print(prompt)
		line := os.get_line()
		if line == 'exit' {
			break 
		}
		mut l := lexer.new(line)
		mut tok := l.next_token()

		for tok.typ != token.eof {
			println("token ${tok.typ} : ${tok.literal}")
			tok = l.next_token()
		}
	}
}