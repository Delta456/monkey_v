module repl

import os
import parser

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
		mut p := parser.new_repl_parser(line)
		p.parse()
	}
}
