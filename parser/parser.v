module parser

import token
import lexer
import ast

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

pub fn (mut parser Parser) parse() ast.Program {
	parser.next()
	mut program := []ast.Statement{}
	for parser.cur_token.typ != token.eof {
		program << parser.top_lvl_stmt()
		parser.next()
	}
	return ast.Program{program}
}

fn (mut parser Parser) top_lvl_stmt() ast.Statement {
	stmt_token := parser.cur_token
	match parser.cur_token.typ {
		token.key_let {
			parser.next()
			parser.expect(token.ident)
			name := ast.Identifier {parser.cur_token, parser.cur_token.literal}
			parser.next()
			if parser.cur_token.typ == token.assign {
				value := parser.expression()
				parser.next()
				parser.expect(token.semicolon)
				return ast.LetStatement{
					token: stmt_token
					name: name
					has_value: true
					value: value
				}
			}
			parser.expect(token.semicolon)
			return ast.LetStatement{
				token: stmt_token
				name: name
				has_value: false
			}
		}
		token.key_function {
			parser.next()
			parser.expect(token.ident)
			name := ast.Identifier {parser.cur_token, parser.cur_token.literal}
			parser.next()
			parser.expect(token.l_paren)
			parser.next()
			mut parameter := []ast.Identifier {}
			if parser.cur_token.typ != token.r_paren {
				for {
					parser.expect(token.ident)
					parameter << ast.Identifier{parser.cur_token, parser.cur_token.literal}
					parser.next()
					if parser.cur_token.typ == token.r_paren {
						break
					}
					parser.expect(token.colon)
					parser.next()
				}
			}
			parser.next()
			parser.expect(token.l_brace)
			stmts := parser.block()
			parser.expect(token.r_brace)
			return ast.FnStatement {
				token: stmt_token
				name: name
				parameter: parameter
				stmts: stmts
			}
		}
		else {
			parser.error('Token is not a top level statement.')
		}
	}
}

fn (mut parser Parser) stmt() ast.Statement {
	stmt_token := parser.cur_token
	match parser.cur_token.typ {
		token.key_return {
			parser.next()
			value := parser.expression()
			parser.next()
			parser.expect(token.semicolon)
			return ast.ReturnStatement{
				token: stmt_token,
				return_value: value
			}
		}
		else {
			parser.error('Token is not a statement')
		}
	}
}

fn (mut parser Parser) expression() ast.Expression {
	parser.next()
	match parser.cur_token.typ {
		token.int {
			return ast.IntegerExpression { parser.cur_token.literal }
		}
		else {
			parser.error('Unknown expression')
		}
	}
}

fn (mut parser Parser) block() []ast.Statement {
	mut statements := []ast.Statement{}
	parser.next()
	return statements
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
