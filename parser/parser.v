module parser

import token
import lexer

struct Parser {
	filename string
mut:
	lexer lexer.Lexer
	cur_token token.Token
	idx_token int
}

//pub fn new_parser(filename string) &Parser {}

pub fn new_repl_parser(line string) &Parser {
	return &Parser{
		filename: 'REPL'
		lexer: lexer.new(line)
	}
}

pub fn (mut parser Parser) parse() {
	parser.next()

	for parser.cur_token.typ != token.eof {
		parser.top_lvl_stmt()
		parser.next()
	}
}

fn (mut parser Parser) top_lvl_stmt() {
	match (parser.cur_token.typ) {
		token.key_let {
			parser.next()
			parser.expect(token.ident)
			parser.next()
			if parser.cur_token.typ == token.assign {
				parser.next()
				parser.next()
				parser.expect(token.semicolon)
				return
			}
			parser.expect(token.semicolon)
			return
		}
		token.key_function {

		}
		else {
			parser.error('Token is not a top level statement.')
		}
	}
}

fn (mut parser Parser) expect(typ string) {
	if parser.cur_token.typ != typ {
		parser.error('Unexpected token. Expected $typ but got $parser.cur_token.typ')
	}
}

fn (mut parser Parser) next() {
	parser.cur_token = parser.lexer.next_token()
	parser.idx_token++
}

fn (mut parser Parser) error(msg string) {
	eprintln(msg)
	exit(1)
}
