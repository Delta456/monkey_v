module lexer

import token

pub struct Lexer {
	input string
mut:
    pos int // current position in input (points to current char)
	read_pos int // current position in input (after current char)
	ch byte // current char under examination
}

pub fn new(input string) Lexer {
	mut l := Lexer{input : input}
	l.read_char()
	return l
}

fn (mut l Lexer) read_char() {
	if l.read_pos >= l.input.len {
		l.ch = 0
	}
	else {
		l.ch = l.input[l.read_pos]
	}
	l.pos = l.read_pos
	l.read_pos++
}

pub fn (mut l Lexer) next_token() token.Token {
	mut tok := token.Token{}
	l.skip_whitespaces()

	match l.ch {
		`=` {
			tok = new_token(token.assign, l.ch)
			l.read_char()
		}
		`;` {
			tok = new_token(token.semicolon, l.ch)
			l.read_char()
		}
		`(` {
			tok = new_token(token.l_paren, l.ch)
			l.read_char()
		}
		`)` {
			tok = new_token(token.r_paren, l.ch)
			l.read_char()
		}
		`,` {
			tok = new_token(token.colon, l.ch)
			l.read_char()
		}
		`+` {
			tok = new_token(token.plus, l.ch)
			l.read_char()
		}
		`{` {
			tok = new_token(token.l_brace, l.ch)
			l.read_char()
		}
		`}` {
			tok = new_token(token.r_brace, l.ch)
			l.read_char()
		}
		0 {
			tok.literal = ''
			tok.typ = token.eof
		}
		else {
			if is_letter(l.ch) {
				tok.literal = l.read_identifier()
				tok.typ = token.lookup_ident(tok.literal)
			}
			else if l.ch.is_digit() {
				tok.typ = token.int
				tok.literal = l.read_number()
			}
			else {
				tok = new_token(token.illegal, l.ch)
			}
		}
	}
	return tok 
}

fn new_token(token_type string, char byte) token.Token {
	return token.Token{typ: token_type, literal: char.str()}
}

fn (mut l Lexer) read_identifier() string {
	pos := l.pos
	for is_letter(l.ch) {
		l.read_char()
	}
	return l.input[pos..l.pos]
}

fn (mut l Lexer) read_number() string {
	pos := l.pos
	for l.ch.is_digit() {
		l.read_char()
	}
	return l.input[pos..l.pos]
}



fn (mut l Lexer) skip_whitespaces() {
	for l.ch == ` ` || l.ch == `\t` || l.ch == `\n` || l.ch == `\r`{
		l.read_char()
	}
}

fn is_letter(a byte) bool {
	return (a >= `a` && a <= `z`) || (a >= `A` && a <= `Z`) || (a == `_`)
}
