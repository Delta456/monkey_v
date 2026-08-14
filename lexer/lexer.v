module lexer

import token

// Lexer turns Monkey source code into a stream of tokens.
pub struct Lexer {
	input string
mut:
	pos      int // current position in input (points to current char)
	read_pos int // current reading position in input (after current char)
	ch       u8  // current char under examination
}

// new returns a new Lexer for the given input.
pub fn new(input string) Lexer {
	mut l := Lexer{
		input: input
	}
	l.read_char()
	return l
}

fn (mut l Lexer) read_char() {
	if l.read_pos >= l.input.len {
		l.ch = 0
	} else {
		l.ch = l.input[l.read_pos]
	}
	l.pos = l.read_pos
	l.read_pos++
}

fn (l Lexer) peek_char() u8 {
	if l.read_pos >= l.input.len {
		return 0
	}
	return l.input[l.read_pos]
}

// next_token returns the next token in the input.
pub fn (mut l Lexer) next_token() token.Token {
	l.skip_whitespace()

	if l.ch == `/` && l.peek_char() == `/` {
		l.skip_comment()
	}

	mut tok := token.Token{}
	match l.ch {
		`=` {
			if l.peek_char() == `=` {
				ch := l.ch
				l.read_char()
				tok = token.Token{
					typ:     token.eq
					literal: ch.ascii_str() + l.ch.ascii_str()
				}
			} else {
				tok = new_token(token.assign, l.ch)
			}
		}
		`!` {
			if l.peek_char() == `=` {
				ch := l.ch
				l.read_char()
				tok = token.Token{
					typ:     token.not_eq
					literal: ch.ascii_str() + l.ch.ascii_str()
				}
			} else {
				tok = new_token(token.bang, l.ch)
			}
		}
		`;` {
			tok = new_token(token.semicolon, l.ch)
		}
		`:` {
			tok = new_token(token.colon, l.ch)
		}
		`(` {
			tok = new_token(token.lparen, l.ch)
		}
		`)` {
			tok = new_token(token.rparen, l.ch)
		}
		`,` {
			tok = new_token(token.comma, l.ch)
		}
		`+` {
			tok = new_token(token.plus, l.ch)
		}
		`-` {
			tok = new_token(token.minus, l.ch)
		}
		`*` {
			tok = new_token(token.asterisk, l.ch)
		}
		`/` {
			tok = new_token(token.slash, l.ch)
		}
		`<` {
			tok = new_token(token.lt, l.ch)
		}
		`>` {
			tok = new_token(token.gt, l.ch)
		}
		`{` {
			tok = new_token(token.lbrace, l.ch)
		}
		`}` {
			tok = new_token(token.rbrace, l.ch)
		}
		`[` {
			tok = new_token(token.lbracket, l.ch)
		}
		`]` {
			tok = new_token(token.rbracket, l.ch)
		}
		`"` {
			tok = token.Token{
				typ:     token.str
				literal: l.read_string()
			}
		}
		0 {
			tok = token.Token{
				typ:     token.eof
				literal: ''
			}
		}
		else {
			if is_digit(l.ch) {
				return l.read_number_token()
			}

			if is_letter(l.ch) {
				literal := l.read_ident()
				return token.Token{
					typ:     token.lookup_ident(literal)
					literal: literal
				}
			}

			tok = new_token(token.illegal, l.ch)
		}
	}

	l.read_char()
	return tok
}

fn (mut l Lexer) skip_whitespace() {
	for l.ch == ` ` || l.ch == `\t` || l.ch == `\n` || l.ch == `\r` {
		l.read_char()
	}
}

fn (mut l Lexer) skip_comment() {
	for l.ch != `\n` && l.ch != `\r` && l.ch != 0 {
		l.read_char()
	}
	l.skip_whitespace()
}

fn (mut l Lexer) read_string() string {
	pos := l.pos + 1
	for {
		l.read_char()
		if l.ch == `"` || l.ch == 0 {
			break
		}
	}
	return l.input[pos..l.pos]
}

fn (mut l Lexer) read(check_fn fn (u8) bool) string {
	pos := l.pos
	for check_fn(l.ch) {
		l.read_char()
	}
	return l.input[pos..l.pos]
}

fn (mut l Lexer) read_ident() string {
	return l.read(is_letter)
}

fn (mut l Lexer) read_number() string {
	return l.read(is_digit)
}

fn (mut l Lexer) read_number_token() token.Token {
	int_part := l.read_number()
	if l.ch != `.` {
		return token.Token{
			typ:     token.int_tok
			literal: int_part
		}
	}

	l.read_char()
	frac_part := l.read_number()
	return token.Token{
		typ:     token.float_tok
		literal: int_part + '.' + frac_part
	}
}

fn is_letter(ch u8) bool {
	return (`a` <= ch && ch <= `z`) || (`A` <= ch && ch <= `Z`) || ch == `_`
}

fn is_digit(ch u8) bool {
	return `0` <= ch && ch <= `9`
}

fn new_token(typ token.Type, ch u8) token.Token {
	return token.Token{
		typ:     typ
		literal: ch.ascii_str()
	}
}
