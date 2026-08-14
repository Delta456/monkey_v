module parser

import ast
import lexer
import token

const lowest = 1
const equals = 2 // ==
const lessgreater = 3 // > or <
const sum = 4 // +
const product = 5 // *
const prefix = 6 // -X or !X
const call = 7 // myFunc(X)
const index = 8 // array[index]

// Parser is a parser of the Monkey programming language.
pub struct Parser {
mut:
	l          lexer.Lexer
	errs       []string
	cur_token  token.Token
	peek_token token.Token
}

// new returns a new Parser that consumes tokens from `l`.
pub fn new(l lexer.Lexer) Parser {
	mut p := Parser{
		l: l
	}
	// Read two tokens, so cur_token and peek_token are both set.
	p.next_token()
	p.next_token()
	return p
}

// errors returns the parser error messages collected so far.
pub fn (p Parser) errors() []string {
	return p.errs
}

fn (mut p Parser) next_token() {
	p.cur_token = p.peek_token
	p.peek_token = p.l.next_token()
}

fn (p Parser) cur_token_is(typ token.Type) bool {
	return p.cur_token.typ == typ
}

fn (p Parser) peek_token_is(typ token.Type) bool {
	return p.peek_token.typ == typ
}

fn (mut p Parser) expect_peek(typ token.Type) bool {
	if p.peek_token_is(typ) {
		p.next_token()
		return true
	}
	p.peek_error(typ)
	return false
}

fn (mut p Parser) peek_error(typ token.Type) {
	p.errs << 'expected next token to be ${typ}, got ${p.peek_token.typ} instead'
}

fn precedence_of(typ token.Type) int {
	return match typ {
		token.eq, token.not_eq { equals }
		token.lt, token.gt { lessgreater }
		token.plus, token.minus { sum }
		token.slash, token.asterisk { product }
		token.lparen { call }
		token.lbracket { index }
		else { lowest }
	}
}

fn (p Parser) peek_precedence() int {
	return precedence_of(p.peek_token.typ)
}

fn (p Parser) cur_precedence() int {
	return precedence_of(p.cur_token.typ)
}

fn has_infix(typ token.Type) bool {
	return typ in [token.plus, token.minus, token.asterisk, token.slash, token.eq, token.not_eq,
		token.lt, token.gt, token.lparen, token.lbracket]
}

// parse_program parses the whole token stream and returns the resulting AST.
pub fn (mut p Parser) parse_program() ast.Program {
	mut program := ast.Program{}

	for !p.cur_token_is(token.eof) {
		if stmt := p.parse_statement() {
			program.statements << stmt
		}
		p.next_token()
	}

	return program
}

fn (mut p Parser) parse_statement() ?ast.Statement {
	if p.cur_token_is(token.key_let) {
		return p.parse_let_statement()
	}
	if p.cur_token_is(token.key_return) {
		return p.parse_return_statement()
	}
	return p.parse_expression_statement()
}

fn (mut p Parser) parse_let_statement() ?ast.Statement {
	let_token := p.cur_token

	if !p.expect_peek(token.ident) {
		return none
	}

	name := ast.Ident{
		token: p.cur_token
		value: p.cur_token.literal
	}

	if !p.expect_peek(token.assign) {
		return none
	}

	p.next_token()

	value := p.parse_expression(lowest) or { return none }

	for p.peek_token_is(token.semicolon) {
		p.next_token()
	}

	return ast.Statement(ast.LetStatement{
		token: let_token
		name:  name
		value: value
	})
}

fn (mut p Parser) parse_return_statement() ?ast.Statement {
	return_token := p.cur_token

	p.next_token()

	value := p.parse_expression(lowest) or { return none }

	for p.peek_token_is(token.semicolon) {
		p.next_token()
	}

	return ast.Statement(ast.ReturnStatement{
		token:        return_token
		return_value: value
	})
}

fn (mut p Parser) parse_expression_statement() ?ast.Statement {
	stmt_token := p.cur_token

	expr := p.parse_expression(lowest) or { return none }

	if p.peek_token_is(token.semicolon) {
		p.next_token()
	}

	return ast.Statement(ast.ExpressionStatement{
		token:      stmt_token
		expression: expr
	})
}

fn (mut p Parser) parse_expression(precedence int) ?ast.Expression {
	mut left := p.parse_prefix() or {
		p.errs << 'no prefix parse function for ${p.cur_token.typ} found'
		return none
	}

	for !p.cur_token_is(token.semicolon) && precedence < p.peek_precedence() {
		if !has_infix(p.peek_token.typ) {
			return left
		}
		p.next_token()
		left = p.parse_infix(left) or { return none }
	}

	return left
}

fn (mut p Parser) parse_prefix() ?ast.Expression {
	return match p.cur_token.typ {
		token.ident { p.parse_ident() }
		token.int_tok { p.parse_integer_literal() }
		token.float_tok { p.parse_float_literal() }
		token.bang, token.minus { p.parse_prefix_expression() }
		token.key_true, token.key_false { p.parse_boolean() }
		token.lparen { p.parse_grouped_expression() }
		token.key_if { p.parse_if_expression() }
		token.key_function { p.parse_function_literal() }
		token.str { p.parse_string_literal() }
		token.lbracket { p.parse_array_literal() }
		token.lbrace { p.parse_hash_literal() }
		token.key_macro { p.parse_macro_literal() }
		else { none }
	}
}

fn (mut p Parser) parse_infix(left ast.Expression) ?ast.Expression {
	return match p.cur_token.typ {
		token.plus, token.minus, token.asterisk, token.slash, token.eq, token.not_eq, token.lt,
		token.gt {
			p.parse_infix_expression(left)
		}
		token.lparen {
			p.parse_call_expression(left)
		}
		token.lbracket {
			p.parse_index_expression(left)
		}
		else {
			none
		}
	}
}

fn (mut p Parser) parse_ident() ?ast.Expression {
	return ast.Expression(ast.Ident{
		token: p.cur_token
		value: p.cur_token.literal
	})
}

fn (mut p Parser) parse_integer_literal() ?ast.Expression {
	return ast.Expression(ast.IntegerLiteral{
		token: p.cur_token
		value: p.cur_token.literal.i64()
	})
}

fn (mut p Parser) parse_float_literal() ?ast.Expression {
	return ast.Expression(ast.FloatLiteral{
		token: p.cur_token
		value: p.cur_token.literal.f64()
	})
}

fn (mut p Parser) parse_prefix_expression() ?ast.Expression {
	prefix_token := p.cur_token
	operator := p.cur_token.literal

	p.next_token()

	right := p.parse_expression(prefix) or { return none }

	return ast.Expression(ast.PrefixExpression{
		token:    prefix_token
		operator: operator
		right:    right
	})
}

fn (mut p Parser) parse_infix_expression(left ast.Expression) ?ast.Expression {
	infix_token := p.cur_token
	operator := p.cur_token.literal
	prec := p.cur_precedence()

	p.next_token()

	right := p.parse_expression(prec) or { return none }

	return ast.Expression(ast.InfixExpression{
		token:    infix_token
		left:     left
		operator: operator
		right:    right
	})
}

fn (mut p Parser) parse_boolean() ?ast.Expression {
	return ast.Expression(ast.Boolean{
		token: p.cur_token
		value: p.cur_token_is(token.key_true)
	})
}

fn (mut p Parser) parse_grouped_expression() ?ast.Expression {
	p.next_token()

	expr := p.parse_expression(lowest) or { return none }

	if !p.expect_peek(token.rparen) {
		return none
	}

	return expr
}

fn (mut p Parser) parse_if_expression() ?ast.Expression {
	if_token := p.cur_token

	if !p.expect_peek(token.lparen) {
		return none
	}

	p.next_token()
	condition := p.parse_expression(lowest) or { return none }

	if !p.expect_peek(token.rparen) {
		return none
	}

	if !p.expect_peek(token.lbrace) {
		return none
	}

	consequence := p.parse_block_statement()

	mut alternative := ast.BlockStatement{}
	mut has_alternative := false

	if p.peek_token_is(token.key_else) {
		p.next_token()

		if !p.expect_peek(token.lbrace) {
			return none
		}

		alternative = p.parse_block_statement()
		has_alternative = true
	}

	return ast.Expression(ast.IfExpression{
		token:           if_token
		condition:       condition
		consequence:     consequence
		has_alternative: has_alternative
		alternative:     alternative
	})
}

fn (mut p Parser) parse_block_statement() ast.BlockStatement {
	block_token := p.cur_token
	mut statements := []ast.Statement{}

	p.next_token()

	for !p.cur_token_is(token.rbrace) && !p.cur_token_is(token.eof) {
		if stmt := p.parse_statement() {
			statements << stmt
		}
		p.next_token()
	}

	return ast.BlockStatement{
		token:      block_token
		statements: statements
	}
}

fn (mut p Parser) parse_function_literal() ?ast.Expression {
	fn_token := p.cur_token

	if !p.expect_peek(token.lparen) {
		return none
	}

	parameters := p.parse_function_parameters() or { return none }

	if !p.expect_peek(token.lbrace) {
		return none
	}

	body := p.parse_block_statement()

	return ast.Expression(ast.FunctionLiteral{
		token:      fn_token
		parameters: parameters
		body:       body
	})
}

fn (mut p Parser) parse_function_parameters() ?[]ast.Ident {
	mut idents := []ast.Ident{}

	if p.peek_token_is(token.rparen) {
		p.next_token()
		return idents
	}

	p.next_token()
	idents << ast.Ident{
		token: p.cur_token
		value: p.cur_token.literal
	}

	for p.peek_token_is(token.comma) {
		p.next_token()
		p.next_token()
		idents << ast.Ident{
			token: p.cur_token
			value: p.cur_token.literal
		}
	}

	if !p.expect_peek(token.rparen) {
		return none
	}

	return idents
}

fn (mut p Parser) parse_expression_list(end token.Type) ?[]ast.Expression {
	mut list := []ast.Expression{}

	if p.peek_token_is(end) {
		p.next_token()
		return list
	}

	p.next_token()
	list << p.parse_expression(lowest) or { return none }

	for p.peek_token_is(token.comma) {
		p.next_token()
		p.next_token()
		list << p.parse_expression(lowest) or { return none }
	}

	if !p.expect_peek(end) {
		return none
	}

	return list
}

fn (mut p Parser) parse_call_expression(function ast.Expression) ?ast.Expression {
	call_token := p.cur_token
	args := p.parse_expression_list(token.rparen) or { return none }

	return ast.Expression(ast.CallExpression{
		token:     call_token
		function:  function
		arguments: args
	})
}

fn (mut p Parser) parse_string_literal() ?ast.Expression {
	return ast.Expression(ast.StringLiteral{
		token: p.cur_token
		value: p.cur_token.literal
	})
}

fn (mut p Parser) parse_array_literal() ?ast.Expression {
	arr_token := p.cur_token
	elements := p.parse_expression_list(token.rbracket) or { return none }

	return ast.Expression(ast.ArrayLiteral{
		token:    arr_token
		elements: elements
	})
}

fn (mut p Parser) parse_index_expression(left ast.Expression) ?ast.Expression {
	idx_token := p.cur_token

	p.next_token()
	idx := p.parse_expression(lowest) or { return none }

	if !p.expect_peek(token.rbracket) {
		return none
	}

	return ast.Expression(ast.IndexExpression{
		token: idx_token
		left:  left
		index: idx
	})
}

fn (mut p Parser) parse_hash_literal() ?ast.Expression {
	hash_token := p.cur_token
	mut pairs := []ast.HashPair{}

	for !p.peek_token_is(token.rbrace) {
		p.next_token()
		key := p.parse_expression(lowest) or { return none }

		if !p.expect_peek(token.colon) {
			return none
		}

		p.next_token()
		value := p.parse_expression(lowest) or { return none }

		pairs << ast.HashPair{
			key:   key
			value: value
		}

		if !p.peek_token_is(token.rbrace) && !p.expect_peek(token.comma) {
			return none
		}
	}

	if !p.expect_peek(token.rbrace) {
		return none
	}

	return ast.Expression(ast.HashLiteral{
		token: hash_token
		pairs: pairs
	})
}

fn (mut p Parser) parse_macro_literal() ?ast.Expression {
	macro_token := p.cur_token

	if !p.expect_peek(token.lparen) {
		return none
	}

	parameters := p.parse_function_parameters() or { return none }

	if !p.expect_peek(token.lbrace) {
		return none
	}

	body := p.parse_block_statement()

	return ast.Expression(ast.MacroLiteral{
		token:      macro_token
		parameters: parameters
		body:       body
	})
}
