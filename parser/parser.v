module parser

import token
import lexer
import os
import ast

type Prefix_parse_fn fn() ast.Expression
type Infix_parse_fn fn(expr ast.Expression) ast.Expression

pub enum Precendence {
	lowest = 1
	equals
	less_greater
	sum
	product
	prefix
	call
}

struct Parser {
	filename  string
mut:
	lexer     lexer.Lexer
	cur_token token.Token
	idx_token int
	prefix_parse_fns map[string]prefix_parse_fn
	infix_parse_fns map[string]infix_parse_fn
}

pub fn new_parser(filename string) &Parser {
	text := os.read_file(filename) or {
		panic(err)
	}
	mut p := &Parser{
		filename: filename
		lexer: lexer.new(text)
	}
	p.prefix_parse_fns = map[string]prefix_parse_fn
	p.register_prefix(token.ident, parser.parse_identifier)
	return p
}

pub fn new_repl_parser(line string) &Parser {
	return &Parser{
		filename: 'REPL'
		lexer: lexer.new(line)
	}
}

pub fn (mut parser Parser) parse_top_lvl() ast.Program {
	parser.next()
	mut program := []ast.Statement{}
	for parser.cur_token.typ != token.eof {
		program << parser.top_lvl_stmt()
		parser.next()
	}
	return ast.Program{program}
}

pub fn (parser Parser) parse_identifier() ast.Identifier {
	return ast.Identifier{parser.cur_token, parser.cur_token.literal}
}

pub fn (mut parser Parser) parse_stmt() ast.Program {
	parser.next()
	mut program := []ast.Statement{}
	for parser.cur_token.typ != token.eof {
		program << parser.stmt()
		parser.next()
	}
	return ast.Program{program}
}

fn (mut parser Parser) top_lvl_stmt() ast.Statement {
	stmt_token := parser.cur_token
	match parser.cur_token.typ {
		token.key_let { return parser.let(stmt_token) }
		token.key_function { return parser.function(stmt_token, false) }
		else { parser.error('Token $parser.cur_token.typ is not a top level statement.') }
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
				token: stmt_token
				return_value: value
			}
		}
		token.key_let {
			return parser.let(stmt_token)
		}
		else {
			return parser.expression_stmt()
		}
	}
}

fn (mut parser Parser) expression_stmt() ast.ExpressionStatement {
	mut stmt := ast.ExpressionStatement{token: parser.cur_token}
	stmt.expression = parser.parse_expression(.lowest)

	if parser.cur_token.typ == token.semicolon {
		parser.next()
	}
	return stmt
}

fn (parser Parser) parse_expression(pre Precendence) ast.Expression {
	prefix := parser.prefix_parse_fns[parser.cur_token.typ]
	left_expr := prefix()
	return left_expr

}

fn (mut parser Parser) expression() ast.Expression {
	match parser.cur_token.typ {
		token.int { return ast.IntegerExpression{parser.cur_token.literal} }
		token.ident { return ast.Identifier{parser.cur_token, parser.cur_token.literal} }
		token.key_function { return parser.function(parser.cur_token, true) }
		else { parser.error('Unknown $parser.cur_token.typ expression') }
	}
}

fn (mut parser Parser) function(stmt_token token.Token, anonym bool) ast.FnStatement {
	parser.next()
	mut name := ast.Identifier{}
	if !anonym {
		parser.expect(token.ident)
		name = ast.Identifier{parser.cur_token, parser.cur_token.literal}
		parser.next()
	}
	parser.expect(token.l_paren)
	parser.next()
	mut parameter := []ast.Identifier{}
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
	stmts := parser.block()
	return ast.FnStatement{
		token: stmt_token
		anonym: anonym
		name: name
		parameter: parameter
		stmts: stmts
	}
}

fn (mut parser Parser) let(stmt_token token.Token) ast.LetStatement {
	parser.next()
	parser.expect(token.ident)
	name := ast.Identifier{parser.cur_token, parser.cur_token.literal}
	parser.next()
	if parser.cur_token.typ == token.assign {
		parser.next()
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

fn (mut parser Parser) block() []ast.Statement {
	mut statements := []ast.Statement{}
	parser.expect(token.l_brace)
	parser.next()
	for parser.cur_token.typ != token.r_brace {
		statements << parser.stmt()
		parser.next()
	}
	parser.expect(token.r_brace)
	return statements
}

fn(mut parser Parser) register_infix(token_type string, func infix_parse_fn) {
	parser.infix_parse_fns[token_type] = func
}

fn(mut parser Parser) register_prefix(token_type string, func prefix_parse_fn) {
	parser.prefix_parse_fns[token_type] = func
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
